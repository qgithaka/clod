import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/document_entity.dart';
import '../../core/money.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/business_profile_repository.dart';

class DocumentPdfService {
  final AppDatabase _db;

  DocumentPdfService(this._db);

  Future<void> generateAndShareDocument(DocumentEntity doc) async {
    final pdf = pw.Document();

    final customer = await _db.customerDao.getCustomer(doc.customerId);
    final profile = await _db.businessProfileDao.getProfile();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                profile?.name ?? 'Clod Business',
                style: const pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (profile?.address != null) pw.Text(profile!.address!),
              pw.SizedBox(height: 20),
              pw.Text(
                doc.type.toUpperCase(),
                style: const pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('Document #${doc.id}'),
              pw.SizedBox(height: 20),
              pw.Text(
                'Bill To:',
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(customer.name),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Item', 'Qty', 'Unit Price', 'Total'],
                data: doc.items
                    .map(
                      (i) => [
                        i.itemName,
                        i.quantity.toString(),
                        Money(i.unitPriceCents).format(),
                        Money(i.unitPriceCents * i.quantity).format(),
                      ],
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total: ',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    Money(doc.totalAmountCents).format(),
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${doc.type}_${doc.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    // ignore: deprecated_member_use
    await Share.shareXFiles([
      XFile(file.path),
    ], text: '${doc.type.toUpperCase()} #${doc.id}');
  }
}

final documentPdfServiceProvider = Provider<DocumentPdfService>((ref) {
  return DocumentPdfService(ref.watch(databaseProvider));
});
