import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:clod/data/database/app_database.dart';
import 'package:clod/data/repositories/stock_movement_repository.dart';
import 'package:clod/data/repositories/item_repository.dart';
import 'package:clod/core/money.dart';
import 'package:clod/domain/entities/item_entity.dart';

void main() {
  late AppDatabase db;
  late StockMovementRepository smRepo;
  late ItemRepository itemRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    smRepo = StockMovementRepository(db);
    itemRepo = ItemRepository(db.itemDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('Log shrinkage deducts stock and records movement', () async {
    await itemRepo.addItem(name: 'Widget', type: ItemType.product, sellingPrice: const Money(500), stockQuantity: 10);
    final items = await itemRepo.watchAllActiveItems().first;
    final item = items.first;

    await smRepo.logShrinkage(itemId: item.id, quantityReduced: 3, reason: 'damaged');

    final updatedItem = await db.itemDao.getItem(item.id);
    expect(updatedItem.stockQuantity, 7);

    final movements = await db.stockMovementDao.watchMovementsForItem(item.id).first;
    expect(movements.length, 1);
    expect(movements.first.quantityChange, -3);
    expect(movements.first.reason, 'damaged');
  });
}
