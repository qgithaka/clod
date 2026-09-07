import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../database/app_database.dart';
import '../database/daos.dart';
import '../../domain/entities/item_entity.dart';
import 'business_profile_repository.dart';

class ItemRepository {
  final ItemDao _dao;

  ItemRepository(this._dao);

  Stream<List<ItemEntity>> watchAllActiveItems() {
    return _dao.watchAllActiveItems().map(
      (list) => list.map((i) => ItemEntity.fromData(i)).toList(),
    );
  }

  Stream<ItemEntity> watchItem(int id) {
    return _dao
        .watchAllActiveItems()
        .map((list) => list.firstWhere((i) => i.id == id))
        .map((i) => ItemEntity.fromData(i));
  }

  Future<void> addItem({
    required String name,
    required ItemType type,
    required Money sellingPrice,
    Money? buyingPrice,
    int? stockQuantity,
    int? lowStockThreshold,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _dao.insertItem(
      ItemsCompanion.insert(
        name: name,
        type: type == ItemType.product ? 'product' : 'service',
        sellingPriceCents: sellingPrice.cents,
        buyingPriceCents: Value(buyingPrice?.cents),
        stockQuantity: Value(stockQuantity),
        lowStockThreshold: Value(lowStockThreshold),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateItem(
    int id, {
    required String name,
    required ItemType type,
    required Money sellingPrice,
    Money? buyingPrice,
    int? stockQuantity,
    int? lowStockThreshold,
    required DateTime createdAt,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _dao.updateItem(
      ItemsCompanion(
        id: Value(id),
        name: Value(name),
        type: Value(type == ItemType.product ? 'product' : 'service'),
        sellingPriceCents: Value(sellingPrice.cents),
        buyingPriceCents: Value(buyingPrice?.cents),
        stockQuantity: Value(stockQuantity),
        lowStockThreshold: Value(lowStockThreshold),
        createdAt: Value(createdAt.toUtc().millisecondsSinceEpoch),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> softDeleteItem(int id) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _dao.updateItem(
      ItemsCompanion(
        id: Value(id),
        isActive: const Value(false),
        updatedAt: Value(now),
      ),
    );
  }
}

final itemDaoProvider = Provider<ItemDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.itemDao;
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository(ref.watch(itemDaoProvider));
});

final activeItemsProvider = StreamProvider<List<ItemEntity>>((ref) {
  return ref.watch(itemRepositoryProvider).watchAllActiveItems();
});

final itemProvider = StreamProvider.family<ItemEntity, int>((ref, id) {
  return ref.watch(itemRepositoryProvider).watchItem(id);
});
