import 'dart:convert';
import '../../data/database/app_database.dart';

class DocumentLineItem {
  final int itemId;
  final String itemName;
  final int quantity;
  final int unitPriceCents;
  
  DocumentLineItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPriceCents,
  });
  
  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'itemName': itemName,
    'quantity': quantity,
    'unitPriceCents': unitPriceCents,
  };
  
  factory DocumentLineItem.fromJson(Map<String, dynamic> json) => DocumentLineItem(
    itemId: json['itemId'] as int,
    itemName: json['itemName'] as String,
    quantity: json['quantity'] as int,
    unitPriceCents: json['unitPriceCents'] as int,
  );
}

class DocumentEntity {
  final int id;
  final String type;
  final String status;
  final int customerId;
  final int totalAmountCents;
  final List<DocumentLineItem> items;
  final int createdAt;
  final int updatedAt;
  
  DocumentEntity({
    required this.id,
    required this.type,
    required this.status,
    required this.customerId,
    required this.totalAmountCents,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory DocumentEntity.fromData(Document data) {
    final List<dynamic> jsonList = jsonDecode(data.contentJson) as List<dynamic>;
    return DocumentEntity(
      id: data.id,
      type: data.type,
      status: data.status,
      customerId: data.customerId,
      totalAmountCents: data.totalAmountCents,
      items: jsonList.map((j) => DocumentLineItem.fromJson(j as Map<String, dynamic>)).toList(),
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
