import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:clod/data/database/app_database.dart';
import 'package:clod/data/repositories/customer_repository.dart';
import 'package:clod/core/money.dart';

void main() {
  late AppDatabase db;
  late CustomerRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CustomerRepository(db.customerDao, db.creditTransactionDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('addCustomer inserts a customer with correct credit limit', () async {
    await repo.addCustomer(
      name: 'John Doe',
      creditLimit: const Money(50000),
    );

    final customers = await db.customerDao.getAllCustomers();
    expect(customers.length, 1);
    expect(customers.first.name, 'John Doe');
    expect(customers.first.creditLimitCents, 50000);
    expect(customers.first.currentBalanceCents, 0);
  });

  test('recordRepayment atomically updates balance and inserts transaction', () async {
    await repo.addCustomer(
      name: 'Jane Doe',
      creditLimit: const Money(100000),
    );
    
    var customers = await db.customerDao.getAllCustomers();
    final customerId = customers.first.id;

    await db.customerDao.updateCustomer(customers.first.copyWith(currentBalanceCents: 15000).toCompanion(true));

    await repo.recordRepayment(customerId, const Money(5000), note: 'Cash payment');

    customers = await db.customerDao.getAllCustomers();
    expect(customers.first.currentBalanceCents, 10000);

    final txns = await db.creditTransactionDao.watchTransactionsForCustomer(customerId).first;
    expect(txns.length, 1);
    expect(txns.first.amountCents, -5000);
    expect(txns.first.note, 'Cash payment');
  });
}
