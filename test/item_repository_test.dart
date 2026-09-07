import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:clod/data/database/app_database.dart';
import 'package:clod/data/repositories/item_repository.dart';
import 'package:clod/domain/entities/item_entity.dart';
import 'package:clod/core/money.dart';

void main() {
  late AppDatabase db;
  late ItemRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ItemRepository(db.itemDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('softDeleteItem hides item from watchAllActiveItems stream', () async {
    await repo.addItem(
      name: 'Hammer',
      type: ItemType.product,
      sellingPrice: const Money(1500),
    );

    var items = await repo.watchAllActiveItems().first;
    expect(items.length, 1);
    final itemId = items.first.id;

    await repo.softDeleteItem(itemId);

    items = await repo.watchAllActiveItems().first;
    expect(items.length, 0);

    final allItems = await db.itemDao.getAllItems();
    expect(allItems.length, 1);
    expect(allItems.first.isActive, false);
  });
}
