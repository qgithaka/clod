import 'package:flutter_test/flutter_test.dart';
import 'package:clod/domain/entities/item_entity.dart';
import 'package:clod/core/money.dart';

void main() {
  test('Service is never low stock', () {
    final service = ItemEntity(
      id: 1,
      name: 'Consulting',
      type: ItemType.service,
      sellingPrice: const Money(10000),
      stockQuantity: 0,
      lowStockThreshold: 10,
      isActive: true,
      createdAt: DateTime.now(),
    );
    expect(service.isLowStock, false);
  });

  test('Product is low stock when at or below threshold', () {
    final product = ItemEntity(
      id: 2,
      name: 'Widget',
      type: ItemType.product,
      sellingPrice: const Money(500),
      stockQuantity: 5,
      lowStockThreshold: 5,
      isActive: true,
      createdAt: DateTime.now(),
    );
    expect(product.isLowStock, true);
  });

  test('Product is not low stock when above threshold', () {
    final product = ItemEntity(
      id: 2,
      name: 'Widget',
      type: ItemType.product,
      sellingPrice: const Money(500),
      stockQuantity: 6,
      lowStockThreshold: 5,
      isActive: true,
      createdAt: DateTime.now(),
    );
    expect(product.isLowStock, false);
  });
}
