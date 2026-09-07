import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/document_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../domain/entities/document_entity.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/services/document_pdf_service.dart';
import '../../core/money.dart';

import 'package:intl/intl.dart';

final documentListProvider =
    StreamProvider.family<List<DocumentEntity>, String>((ref, type) {
      return ref.watch(documentRepositoryProvider).watchDocuments(type);
    });

class DocumentListView extends ConsumerStatefulWidget {
  const DocumentListView({super.key});

  @override
  ConsumerState<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends ConsumerState<DocumentListView> {
  String _selectedType = 'quote';

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(documentListProvider(_selectedType));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'quote', label: Text('Quotes')),
                ButtonSegment(value: 'invoice', label: Text('Invoices')),
              ],
              selected: {_selectedType},
              onSelectionChanged: (set) =>
                  setState(() => _selectedType = set.first),
            ),
          ),
        ),
      ),
      body: docsAsync.when(
        data: (docs) {
          if (docs.isEmpty)
            return Center(child: Text('No ${_selectedType}s found.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    _selectedType == 'quote'
                        ? Icons.request_quote
                        : Icons.receipt,
                  ),
                ),
                title: Text('${_selectedType.toUpperCase()} #${d.id}'),
                subtitle: Text(
                  'Status: ${d.status}\n${DateFormat.yMd().add_Hm().format(DateTime.fromMillisecondsSinceEpoch(d.createdAt))}',
                ),
                trailing: Text(
                  Money(d.totalAmountCents).format(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                isThreeLine: true,
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.picture_as_pdf),
                              title: const Text('View PDF'),
                              onTap: () {
                                Navigator.pop(context);
                                ref
                                    .read(documentPdfServiceProvider)
                                    .generateAndShareDocument(d);
                              },
                            ),
                            if (d.type == 'quote' && d.status == 'draft')
                              ListTile(
                                leading: const Icon(Icons.transform),
                                title: const Text('Convert to Invoice'),
                                onTap: () {
                                  Navigator.pop(context);
                                  ref
                                      .read(documentRepositoryProvider)
                                      .convertQuoteToInvoice(d.id);
                                },
                              ),
                            if (d.type == 'quote')
                              ListTile(
                                leading: const Icon(Icons.shopping_cart),
                                title: const Text('Convert to Cart Sale'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  final cart = ref.read(cartProvider.notifier);
                                  cart.clearCart();

                                  // Fetch customer
                                  try {
                                    final customerRepo = ref.read(
                                      customerRepositoryProvider,
                                    );
                                    final customer = await customerRepo
                                        .watchCustomer(d.customerId)
                                        .first;
                                    cart.attachCustomer(customer);
                                  } catch (e) {
                                    // Handle
                                  }

                                  // Simplified logic, assume all items are found in POS
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Added to Cart! (Partial logic for now)',
                                        ),
                                      ),
                                    );
                                    context.go('/pos');
                                  }
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/documents/new', extra: _selectedType);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
