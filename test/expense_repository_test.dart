import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:clod/data/database/app_database.dart';
import 'package:clod/data/repositories/expense_repository.dart';

void main() {
  late AppDatabase db;
  late ExpenseRepository expenseRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    expenseRepo = ExpenseRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Add and fetch expenses', () async {
    await expenseRepo.addExpense(category: 'Rent', amountCents: 50000);
    await expenseRepo.addExpense(category: 'Supplies', amountCents: 1500, note: 'Pens and paper');

    final expenses = await expenseRepo.watchExpenses().first;
    expect(expenses.length, 2);
    expect(expenses.first.category, 'Supplies'); // ordered by desc created at
    expect(expenses.first.amountCents, 1500);
    expect(expenses.last.category, 'Rent');
  });
}
