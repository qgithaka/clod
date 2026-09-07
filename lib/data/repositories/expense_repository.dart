import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'business_profile_repository.dart';

class ExpenseRepository {
  final AppDatabase _db;

  ExpenseRepository(this._db);

  Stream<List<Expense>> watchExpenses({int? startDate, int? endDate}) {
    return (_db.select(_db.expenses)
          ..where((t) {
            var condition = const Constant(true) as Expression<bool>;
            if (startDate != null) {
              condition =
                  condition & t.createdAt.isBiggerOrEqualValue(startDate);
            }
            if (endDate != null) {
              condition =
                  condition & t.createdAt.isSmallerOrEqualValue(endDate);
            }
            return condition;
          })
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<int> addExpense({
    required String category,
    required int amountCents,
    String? note,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    return await _db.expenseDao.insertExpense(
      ExpensesCompanion.insert(
        category: category,
        amountCents: amountCents,
        note: Value(note),
        occurredAt: now,
        createdAt: now,
      ),
    );
  }
}

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(databaseProvider));
});
