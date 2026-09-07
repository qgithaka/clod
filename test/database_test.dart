import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:clod/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('BusinessProfileDao can insert and get profile', () async {
    final dao = db.businessProfileDao;

    await dao.insertOrUpdate(
      BusinessProfileCompanion.insert(
        name: 'Test Business',
        updatedAt: 1234567890,
      ),
    );

    final profile = await dao.getProfile();
    expect(profile, isNotNull);
    expect(profile!.name, 'Test Business');
  });

  test('CustomerDao can insert and get customers', () async {
    final dao = db.customerDao;

    await dao.insertCustomer(
      CustomersCompanion.insert(
        name: 'Alice',
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    final customers = await dao.getAllCustomers();
    expect(customers.length, 1);
    expect(customers.first.name, 'Alice');
  });
}
