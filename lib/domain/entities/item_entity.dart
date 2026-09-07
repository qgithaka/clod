import '../../core/money.dart';
import '../../data/database/app_database.dart';

enum ItemType { product, service }

class ItemEntity {
  final int id;
  final String name;
  final ItemType type;
  final Money sellingPrice;

  // Product specific
  final Money? buyingPrice;
  final int? stockQuantity;
  final int? lowStockThreshold;

  final bool isActive;
  final DateTime createdAt;

  const ItemEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.sellingPrice,
    this.buyingPrice,
    this.stockQuantity,
    this.lowStockThreshold,
    required this.isActive,
    required this.createdAt,
  });

  factory ItemEntity.fromData(Item data) {
    return ItemEntity(
      id: data.id,
      name: data.name,
      type: data.type == 'product' ? ItemType.product : ItemType.service,
      sellingPrice: Money(data.sellingPriceCents),
      buyingPrice: data.buyingPriceCents != null
          ? Money(data.buyingPriceCents!)
          : null,
      stockQuantity: data.stockQuantity,
      lowStockThreshold: data.lowStockThreshold,
      isActive: data.isActive,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        data.createdAt,
        isUtc: true,
      ),
    );
  }

  bool get isLowStock {
    if (type == ItemType.service) return false;
    if (stockQuantity == null || lowStockThreshold == null) return false;
    return stockQuantity! <= lowStockThreshold!;
  }
}
