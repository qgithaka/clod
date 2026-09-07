import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:clod/data/database/app_database.dart';
import 'package:clod/data/repositories/sale_repository.dart';
import 'package:clod/data/repositories/item_repository.dart';
import 'package:clod/data/repositories/customer_repository.dart';
import 'package:clod/core/providers/cart_provider.dart';
import 'package:clod/core/money.dart';
import 'package:clod/domain/entities/item_entity.dart';
import 'package:clod/domain/entities/customer_entity.dart';

void main() {
  late AppDatabase db;
  late SaleRepository saleRepo;
  late ItemRepository itemRepo;
  late CustomerRepository custRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    saleRepo = SaleRepository(db);
    itemRepo = ItemRepository(db.itemDao);
    custRepo = CustomerRepository(db.customerDao, db.creditTransactionDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('processCheckout (Cash) records sale and deducts stock', () async {
    await itemRepo.addItem(name: 'Apple', type: ItemType.product, sellingPrice: const Money(100), stockQuantity: 10);
    final items = await itemRepo.watchAllActiveItems().first;
    final item = items.first;

    final cart = CartState(
      items: [CartLineItem(item: item, quantity: 3)],
    );

    final saleId = await saleRepo.processCheckout(cart, false);
    
    // verify sale
    final sales = await db.saleDao.watchAllSales().first;
    expect(sales.length, 1);
    expect(sales.first.id, saleId);
    expect(sales.first.totalAmountCents, 300);
    expect(sales.first.paymentMethod, 'cash');

    // verify stock
    final updatedItem = await db.itemDao.getItem(item.id);
    expect(updatedItem.stockQuantity, 7);
  });

  test('processCheckout (Credit) updates customer balance and records transaction', () async {
    await itemRepo.addItem(name: 'Banana', type: ItemType.product, sellingPrice: const Money(200), stockQuantity: 5);
    final items = await itemRepo.watchAllActiveItems().first;
    final item = items.first;

    await custRepo.addCustomer(name: 'Jane Doe', phone: '', address: '', creditLimit: const Money(1000));
    final customers = await custRepo.watchAllCustomers().first;
    final cust = customers.first;

    final cart = CartState(
      items: [CartLineItem(item: item, quantity: 2)],
      customer: cust,
    );

    final saleId = await saleRepo.processCheckout(cart, true);

    // verify sale
    final sales = await db.saleDao.watchAllSales().first;
    expect(sales.length, 1);
    expect(sales.first.paymentMethod, 'credit');
    expect(sales.first.customerId, cust.id);

    // verify stock
    final updatedItem = await db.itemDao.getItem(item.id);
    expect(updatedItem.stockQuantity, 3);

    // verify credit transaction and balance
    final updatedCust = await db.customerDao.getCustomer(cust.id);
    expect(updatedCust.currentBalanceCents, 400);

    final txs = await db.creditTransactionDao.watchTransactionsForCustomer(cust.id).first;
    expect(txs.length, 1);
    expect(txs.first.amountCents, 400); // positive debt
    expect(txs.first.referenceSaleId, saleId);
  });
}
