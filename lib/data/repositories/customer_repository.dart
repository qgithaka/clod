import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/money.dart';
import '../database/app_database.dart';
import '../database/daos.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/credit_transaction_entity.dart';
import 'business_profile_repository.dart';

class CustomerRepository {
  final CustomerDao _dao;
  final CreditTransactionDao _creditDao;

  CustomerRepository(this._dao, this._creditDao);

  Stream<List<CustomerEntity>> watchAllCustomers() {
    return _dao.watchAllCustomers().map((list) => list.map((c) => CustomerEntity.fromData(c)).toList());
  }

  Stream<CustomerEntity> watchCustomer(int id) {
    // We can filter the all stream or use a specific drift query. Since we only have getCustomer, we can write a quick stream fallback
    return _dao.watchAllCustomers().map((list) => list.firstWhere((c) => c.id == id)).map((c) => CustomerEntity.fromData(c));
  }

  Stream<List<CreditTransactionEntity>> watchTransactions(int customerId) {
    return _creditDao.watchTransactionsForCustomer(customerId)
      .map((list) => list.map((t) => CreditTransactionEntity.fromData(t)).toList());
  }

  Future<void> addCustomer({
    required String name,
    String? phone,
    String? address,
    required Money creditLimit,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _dao.insertCustomer(CustomersCompanion.insert(
      name: name,
      phone: Value(phone),
      address: Value(address),
      creditLimitCents: Value(creditLimit.cents),
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<void> updateCustomer(
    int id, {
    required String name,
    String? phone,
    String? address,
    required Money creditLimit,
    required bool isActive,
    required Money currentBalance,
    required DateTime createdAt,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _dao.updateCustomer(CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      address: Value(address),
      creditLimitCents: Value(creditLimit.cents),
      currentBalanceCents: Value(currentBalance.cents),
      isActive: Value(isActive),
      createdAt: Value(createdAt.toUtc().millisecondsSinceEpoch),
      updatedAt: Value(now),
    ));
  }

  Future<void> recordRepayment(int customerId, Money amount, {String? note}) async {
    final db = _dao.attachedDatabase;
    await db.transaction(() async {
      final customer = await _dao.getCustomer(customerId);
      final newBalance = customer.currentBalanceCents - amount.cents;
      
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      
      await _creditDao.insertTransaction(CreditTransactionsCompanion.insert(
        customerId: customerId,
        amountCents: -amount.cents,
        note: Value(note),
        createdAt: now,
      ));

      await _dao.updateCustomer(
        customer.copyWith(
          currentBalanceCents: newBalance,
          updatedAt: now,
        ).toCompanion(true)
      );
    });
  }
}

final customerDaoProvider = Provider<CustomerDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.customerDao;
});

final creditTransactionDaoProvider = Provider<CreditTransactionDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.creditTransactionDao;
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.watch(customerDaoProvider), ref.watch(creditTransactionDaoProvider));
});

final customersProvider = StreamProvider<List<CustomerEntity>>((ref) {
  return ref.watch(customerRepositoryProvider).watchAllCustomers();
});

final customerProvider = StreamProvider.family<CustomerEntity, int>((ref, id) {
  return ref.watch(customerRepositoryProvider).watchCustomer(id);
});

final creditTransactionsProvider = StreamProvider.family<List<CreditTransactionEntity>, int>((ref, customerId) {
  return ref.watch(customerRepositoryProvider).watchTransactions(customerId);
});
