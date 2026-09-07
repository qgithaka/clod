import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;

import '../../data/database/app_database.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/credit_transaction_entity.dart';

class CreditStatementService {
  Future<void> generateAndShareStatement({
    required BusinessProfileData? businessProfile,
    required CustomerEntity customer,
    required List<CreditTransactionEntity> transactions,
  }) async {
    final pdf = pw.Document();

    pw.ImageProvider? logoImage;
    if (businessProfile?.logoPath != null) {
      final file = File(businessProfile!.logoPath!);
      if (file.existsSync()) {
        logoImage = pw.MemoryImage(file.readAsBytesSync());
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (businessProfile != null)
                      pw.Text(
                        businessProfile.name,
                        style: const pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    if (businessProfile?.phone != null)
                      pw.Text('Phone: ${businessProfile!.phone}'),
                    if (businessProfile?.address != null)
                      pw.Text('Address: ${businessProfile!.address}'),
                  ],
                ),
                if (logoImage != null)
                  pw.Container(
                    width: 80,
                    height: 80,
                    child: pw.Image(logoImage),
                  ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'CREDIT STATEMENT',
            style: const pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Customer:',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(customer.name),
                  if (customer.phone != null) pw.Text(customer.phone!),
                  if (customer.address != null) pw.Text(customer.address!),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Date: ${DateTime.now().toIso8601String().split('T')[0]}',
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Total Outstanding: ${customer.currentBalance.format()}',
                    style: const pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Description', 'Type', 'Amount'],
            data: transactions.map((txn) {
              final isPayment = txn.type == 'PAYMENT';
              return [
                txn.createdAt.toIso8601String().split('T')[0],
                txn.referenceNote ??
                    (isPayment ? 'Payment Received' : 'Sale Charged'),
                txn.type,
                (isPayment ? '-' : '+') + txn.amount.format(),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      p.join(
        output.path,
        'statement_${customer.name.replaceAll(' ', '_')}.pdf',
      ),
    );
    await file.writeAsBytes(await pdf.save());

    // ignore: deprecated_member_use
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Credit Statement for ${customer.name}');
  }
}

final creditStatementServiceProvider = Provider<CreditStatementService>((ref) {
  return CreditStatementService();
});
