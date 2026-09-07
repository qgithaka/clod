import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/providers/cart_provider.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/business_profile_repository.dart';

class ReceiptService {
  final AppDatabase _db;

  ReceiptService(this._db);

  Future<void> generateAndShareReceipt({
    required CartState cart,
    required bool isCredit,
    required int saleId,
  }) async {
    final profileDao = _db.businessProfileDao;
    final profile = await profileDao.getProfile();
    final logoFile = profile?.logoPath != null
        ? File(profile!.logoPath!)
        : null;

    final pdf = pw.Document();

    pw.ImageProvider? logoImage;
    if (logoFile != null && logoFile.existsSync()) {
      logoImage = pw.MemoryImage(logoFile.readAsBytesSync());
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logoImage != null) pw.Image(logoImage, width: 80, height: 80),
              pw.SizedBox(height: 8),
              if (profile?.name != null)
                pw.Text(
                  profile!.name,
                  style: const pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              if (profile?.address != null) pw.Text(profile!.address!),
              if (profile?.phone != null) pw.Text('Tel: ${profile!.phone}'),
              pw.Divider(),
              pw.Text(
                'RECEIPT #$saleId',
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(DateTime.now().toString().split('.')[0]),
              if (cart.customer != null)
                pw.Text('Customer: ${cart.customer!.name}'),
              pw.Divider(),
              ...cart.items.map(
                (line) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text('${line.quantity}x ${line.item.name}'),
                    ),
                    pw.Text(line.lineTotal.format()),
                  ],
                ),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: const pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  pw.Text(
                    cart.total.format(),
                    style: const pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text('Payment Method: ${isCredit ? 'CREDIT' : 'CASH'}'),
              pw.SizedBox(height: 16),
              pw.Text(
                'Thank you for your business!',
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/receipt_$saleId.pdf');
    await file.writeAsBytes(await pdf.save());

    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)], subject: 'Receipt #$saleId');
  }
}

final receiptServiceProvider = Provider<ReceiptService>((ref) {
  return ReceiptService(ref.watch(databaseProvider));
});
