import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:clod/data/database/app_database.dart';
import 'package:clod/data/repositories/document_repository.dart';
import 'package:clod/data/repositories/customer_repository.dart';
import 'package:clod/domain/entities/document_entity.dart';
import 'package:clod/core/money.dart';

void main() {
  late AppDatabase db;
  late DocumentRepository docRepo;
  late CustomerRepository custRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    docRepo = DocumentRepository(db);
    custRepo = CustomerRepository(db.customerDao, db.creditTransactionDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('Document lifecycle and conversion', () async {
    await custRepo.addCustomer(name: 'John Doe', creditLimit: const Money(0));
    final customers = await custRepo.watchAllCustomers().first;
    final customer = customers.first;

    final items = [
      DocumentLineItem(itemId: 1, itemName: 'Test Item', quantity: 2, unitPriceCents: 500)
    ];

    // 1. Create quote
    final quoteId = await docRepo.createDocument(
      type: 'quote',
      customerId: customer.id,
      items: items,
    );

    var quotes = await docRepo.watchDocuments('quote').first;
    expect(quotes.length, 1);
    expect(quotes.first.type, 'quote');
    expect(quotes.first.status, 'draft');
    expect(quotes.first.totalAmountCents, 1000); // 2 * 500

    // 2. Update status
    await docRepo.updateDocumentStatus(quoteId, 'sent');
    quotes = await docRepo.watchDocuments('quote').first;
    expect(quotes.first.status, 'sent');

    // 3. Convert to invoice
    await docRepo.convertQuoteToInvoice(quoteId);
    quotes = await docRepo.watchDocuments('quote').first;
    expect(quotes.isEmpty, true);

    final invoices = await docRepo.watchDocuments('invoice').first;
    expect(invoices.length, 1);
    expect(invoices.first.type, 'invoice');
    expect(invoices.first.status, 'draft');
  });
}
