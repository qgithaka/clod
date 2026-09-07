import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:clod/data/database/app_database.dart';
import 'package:clod/data/repositories/analytics_repository.dart';
import 'package:clod/data/repositories/customer_repository.dart';
import 'package:clod/data/repositories/item_repository.dart';
import 'package:clod/data/repositories/sale_repository.dart';
import 'package:clod/data/repositories/expense_repository.dart';
import 'package:clod/core/money.dart';
import 'package:clod/core/providers/cart_provider.dart';
import 'package:clod/domain/entities/item_entity.dart';
import 'package:clod/domain/entities/customer_entity.dart';

void main() {
  late AppDatabase db;
  late AnalyticsRepository analyticsRepo;
  late CustomerRepository custRepo;
  late ItemRepository itemRepo;
  late SaleRepository saleRepo;
  late ExpenseRepository expenseRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    analyticsRepo = AnalyticsRepository(db);
    custRepo = CustomerRepository(db.customerDao, db.creditTransactionDao);
    itemRepo = ItemRepository(db.itemDao);
    saleRepo = SaleRepository(db);
    expenseRepo = ExpenseRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('P&L calculation and date slicing', () async {
    // 1. Setup Data
    await custRepo.addCustomer(
      name: 'Test Customer',
      creditLimit: const Money(10000),
    );
    final customer = (await custRepo.watchAllCustomers().first).first;

    await itemRepo.addItem(
      name: 'Test Item',
      type: ItemType.product,
      sellingPrice: const Money(500),
      buyingPrice: const Money(100),
      stockQuantity: 10,
      lowStockThreshold: 5,
    );
    final item = (await itemRepo.watchAllActiveItems().first).first;

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    // Sale: 2 units at 500 = 1000 total. Paid 500, credit 500. Wait, processCheckout only takes isCredit (true/false) meaning all cash or all credit.
    // Let's do 1 full credit sale (1000) and then a repayment of 500.
    final cart = CartState(
      items: [CartLineItem(item: item, quantity: 2, price: const Money(500))],
      customer: customer,
    );
    final saleId = await saleRepo.processCheckout(cart, true);

    // Repayment
    await db
        .into(db.creditTransactions)
        .insert(
          CreditTransactionsCompanion.insert(
            customerId: customer.id,
            amountCents: -500,
            createdAt: now,
          ),
        );
    // Directly update balance using the DAO to match what the repayment logic does (since I inserted a transaction manually, let's just update the customer balance manually in db so we don't mess with repo methods that might double insert)
    await (db.update(
      db.customers,
    )..where((c) => c.id.equals(customer.id))).write(
      CustomersCompanion(
        currentBalanceCents: drift.Value(
          customer.currentBalance.cents + 1000 - 500,
        ),
        updatedAt: drift.Value(now),
      ),
    );

    // Expense: 300 cents
    await expenseRepo.addExpense(
      category: 'Rent',
      amountCents: 300,
      note: 'Test',
    );

    // 2. Test Accrual P&L
    // Revenue = 1000 (total sale amount)
    // COGS = 200
    // Gross = 800
    // Expenses = 300
    // Net = 500
    final accrualPl = await analyticsRepo.getProfitAndLoss(
      now - 10000,
      now + 10000,
      isCashBasis: false,
    );
    expect(accrualPl.revenueCents, 1000);
    expect(accrualPl.cogsCents, 200);
    expect(accrualPl.grossProfitCents, 800);
    expect(accrualPl.expensesCents, 300);
    expect(accrualPl.netProfitCents, 500);

    // 3. Test Cash P&L
    // Revenue = 500 (amount paid)
    // COGS = 200
    // Gross = 300
    // Expenses = 300
    // Net = 0
    final cashPl = await analyticsRepo.getProfitAndLoss(
      now - 10000,
      now + 10000,
      isCashBasis: true,
    );
    expect(cashPl.revenueCents, 500);
    expect(cashPl.cogsCents, 200);
    expect(cashPl.grossProfitCents, 300);
    expect(cashPl.expensesCents, 300);
    expect(cashPl.netProfitCents, 0);

    // 4. Test Dashboard Metrics
    final metrics = await analyticsRepo.getDashboardMetrics();
    expect(metrics.todaysRevenueCents, 1000);
    expect(metrics.totalOutstandingDebtCents, 500);
  });
}
