import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/money.dart';
import '../database/app_database.dart';
import '../database/daos.dart';
import '../../domain/entities/customer_entity.dart';
import 'business_profile_repository.dart';

class CustomerRepository {
  final CustomerDao _dao;

  CustomerRepository(this._dao);

  Stream<List<CustomerEntity>> watchAllCustomers() {
    return _dao.watchAllCustomers().map((list) => list.map((c) => CustomerEntity.fromData(c)).toList());
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
}

final customerDaoProvider = Provider<CustomerDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.customerDao;
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.watch(customerDaoProvider));
});

final customersProvider = StreamProvider<List<CustomerEntity>>((ref) {
  return ref.watch(customerRepositoryProvider).watchAllCustomers();
});
