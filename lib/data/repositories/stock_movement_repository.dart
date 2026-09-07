import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'business_profile_repository.dart';

class StockMovementRepository {
  final AppDatabase _db;

  StockMovementRepository(this._db);

  Future<void> logShrinkage({
    required int itemId,
    required int quantityReduced,
    required String reason,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    await _db.transaction(() async {
      final currentItem = await _db.itemDao.getItem(itemId);
      final oldQty = currentItem.stockQuantity ?? 0;
      final newQty = oldQty - quantityReduced;

      await _db.itemDao.updateItem(
        ItemsCompanion(
          id: Value(itemId),
          stockQuantity: Value(newQty < 0 ? 0 : newQty),
          updatedAt: Value(now),
        ),
      );

      await _db.stockMovementDao.insertMovement(
        StockMovementsCompanion.insert(
          itemId: itemId,
          quantityChange: -quantityReduced,
          reason: reason,
          createdAt: now,
        ),
      );
    });
  }
}

final stockMovementRepositoryProvider = Provider<StockMovementRepository>((
  ref,
) {
  return StockMovementRepository(ref.watch(databaseProvider));
});
