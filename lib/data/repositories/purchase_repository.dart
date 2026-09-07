import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/daos.dart';
import '../../core/money.dart';
import '../../domain/entities/item_entity.dart';
import 'business_profile_repository.dart';

class PurchaseOrderLine {
  final int itemId;
  final int quantity;
  final Money unitCost;

  PurchaseOrderLine({
    required this.itemId,
    required this.quantity,
    required this.unitCost,
  });
}

class PurchaseRepository {
  final AppDatabase _db;

  PurchaseRepository(this._db);

  Future<int> createDraftPO(List<PurchaseOrderLine> lines) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    int totalCents = 0;
    for (var l in lines) {
      totalCents += l.unitCost.cents * l.quantity;
    }

    return await _db.transaction(() async {
      final poId = await _db.purchaseDao.insertPurchase(
        PurchasesCompanion.insert(
          status: 'draft',
          totalAmountCents: totalCents,
          createdAt: now,
        ),
      );

      for (var l in lines) {
        await _db
            .into(_db.purchaseItems)
            .insert(
              PurchaseItemsCompanion.insert(
                purchaseId: poId,
                itemId: l.itemId,
                quantity: l.quantity,
                unitCostCents: l.unitCost.cents,
              ),
            );
      }
      return poId;
    });
  }

  Future<void> markAsOrdered(int poId) async {
    await (_db.update(_db.purchases)..where((tbl) => tbl.id.equals(poId)))
        .write(const PurchasesCompanion(status: Value('ordered')));
  }

  Future<void> markAsReceived(int poId) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    await _db.transaction(() async {
      // 1. Mark PO as received
      await (_db.update(
        _db.purchases,
      )..where((tbl) => tbl.id.equals(poId))).write(
        PurchasesCompanion(
          status: const Value('received'),
          receivedAt: Value(now),
        ),
      );

      // 2. Process each item: update stock, insert movement, update average cost
      final items = await (_db.select(
        _db.purchaseItems,
      )..where((tbl) => tbl.purchaseId.equals(poId))).get();

      for (final poItem in items) {
        final currentItem = await _db.itemDao.getItem(poItem.itemId);

        final oldQty = currentItem.stockQuantity ?? 0;
        final oldCost = currentItem.buyingPriceCents ?? 0;
        final newQty = poItem.quantity;
        final newCost = poItem.unitCostCents;

        // Calculate weighted average cost
        final totalOldValue = oldQty * oldCost;
        final totalNewValue = newQty * newCost;
        final totalQty = oldQty + newQty;

        final averageCostCents = totalQty > 0
            ? (totalOldValue + totalNewValue) ~/ totalQty
            : 0;

        // Update Item
        await _db.itemDao.updateItem(
          ItemsCompanion(
            id: Value(currentItem.id),
            stockQuantity: Value(totalQty),
            buyingPriceCents: Value(averageCostCents),
            updatedAt: Value(now),
          ),
        );

        // Insert Stock Movement
        await _db
            .into(_db.stockMovements)
            .insert(
              StockMovementsCompanion.insert(
                itemId: poItem.itemId,
                quantityChange: newQty,
                reason: 'purchase',
                createdAt: now,
                referenceId: Value(poId),
              ),
            );
      }
    });
  }

  Stream<List<Purchase>> watchPurchases(String status) {
    return (_db.select(
      _db.purchases,
    )..where((t) => t.status.equals(status))).watch();
  }
}

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return PurchaseRepository(ref.watch(databaseProvider));
});
