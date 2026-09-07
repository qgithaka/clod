import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:clod/data/database/app_database.dart';
import 'package:clod/data/repositories/purchase_repository.dart';
import 'package:clod/data/repositories/item_repository.dart';
import 'package:clod/core/money.dart';
import 'package:clod/domain/entities/item_entity.dart';

void main() {
  late AppDatabase db;
  late PurchaseRepository purchaseRepo;
  late ItemRepository itemRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    purchaseRepo = PurchaseRepository(db);
    itemRepo = ItemRepository(db.itemDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('Purchase Order Workflow', () async {
    await itemRepo.addItem(name: 'Widget', type: ItemType.product, sellingPrice: const Money(500), stockQuantity: 10, buyingPrice: const Money(200));
    final items = await itemRepo.watchAllActiveItems().first;
    final item = items.first;

    // 1. Create Draft PO
    final lines = [
      PurchaseOrderLine(itemId: item.id, quantity: 20, unitCost: const Money(250)),
    ];
    final poId = await purchaseRepo.createDraftPO(lines);

    var purchases = await db.purchaseDao.watchAllPurchases().first;
    expect(purchases.length, 1);
    expect(purchases.first.status, 'draft');
    expect(purchases.first.totalAmountCents, 5000); // 20 * 250

    // 2. Mark Ordered
    await purchaseRepo.markAsOrdered(poId);
    purchases = await db.purchaseDao.watchAllPurchases().first;
    expect(purchases.first.status, 'ordered');

    // 3. Mark Received
    await purchaseRepo.markAsReceived(poId);
    purchases = await db.purchaseDao.watchAllPurchases().first;
    expect(purchases.first.status, 'received');
    expect(purchases.first.receivedAt, isNotNull);

    // 4. Verify Stock & Average Cost
    final updatedItem = await db.itemDao.getItem(item.id);
    expect(updatedItem.stockQuantity, 30); // 10 + 20

    // Average cost logic: (10 * 200 + 20 * 250) / 30 = (2000 + 5000) / 30 = 7000 / 30 = 233.33 -> 233 cents
    expect(updatedItem.buyingPriceCents, 233);

    // 5. Verify Stock Movement
    final movements = await db.stockMovementDao.watchMovementsForItem(item.id).first;
    expect(movements.length, 1);
    expect(movements.first.quantityChange, 20);
    expect(movements.first.reason, 'purchase');
  });
}
