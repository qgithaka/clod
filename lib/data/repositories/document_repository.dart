import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'business_profile_repository.dart';
import '../../domain/entities/document_entity.dart';

class DocumentRepository {
  final AppDatabase _db;

  DocumentRepository(this._db);

  Stream<List<DocumentEntity>> watchDocuments(String type) {
    return (_db.select(_db.documents)
          ..where((d) => d.type.equals(type))
          ..orderBy([
            (d) =>
                OrderingTerm(expression: d.createdAt, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((list) => list.map((d) => DocumentEntity.fromData(d)).toList());
  }

  Future<int> createDocument({
    required String type,
    required int customerId,
    required List<DocumentLineItem> items,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    int totalCents = 0;
    for (var i in items) {
      totalCents += i.quantity * i.unitPriceCents;
    }

    final contentJson = jsonEncode(items.map((i) => i.toJson()).toList());

    return await _db
        .into(_db.documents)
        .insert(
          DocumentsCompanion.insert(
            type: type,
            status: 'draft',
            customerId: customerId,
            totalAmountCents: totalCents,
            contentJson: contentJson,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> updateDocumentStatus(int id, String newStatus) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_db.update(_db.documents)..where((t) => t.id.equals(id))).write(
      DocumentsCompanion(status: Value(newStatus), updatedAt: Value(now)),
    );
  }

  Future<void> convertQuoteToInvoice(int quoteId) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_db.update(_db.documents)..where((t) => t.id.equals(quoteId))).write(
      DocumentsCompanion(
        type: const Value('invoice'),
        status: const Value('draft'),
        updatedAt: Value(now),
      ),
    );
  }
}

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository(ref.watch(databaseProvider));
});
