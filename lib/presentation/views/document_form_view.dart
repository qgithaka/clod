import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/document_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/item_repository.dart';
import '../../domain/entities/document_entity.dart';
import '../../core/money.dart';

class DocumentFormView extends ConsumerStatefulWidget {
  final String documentType;

  const DocumentFormView({super.key, required this.documentType});

  @override
  ConsumerState<DocumentFormView> createState() => _DocumentFormViewState();
}

class _DocumentFormViewState extends ConsumerState<DocumentFormView> {
  int? _selectedCustomerId;
  final List<DocumentLineItem> _items = [];

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final itemsAsync = ref.watch(activeItemsProvider);

    int totalCents = 0;
    for (var i in _items) {
      totalCents += (i.quantity * i.unitPriceCents);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Create ${widget.documentType.toUpperCase()}'),
      ),
      body: customersAsync.when(
        data: (customers) {
          if (customers.isEmpty)
            return const Center(child: Text('Please create a customer first.'));
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Customer'),
                      value: _selectedCustomerId,
                      items: customers
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCustomerId = v),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Line Items',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return ListTile(
                            title: Text(item.itemName),
                            subtitle: Text(
                              '${item.quantity} x ${Money(item.unitPriceCents).format()}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  setState(() => _items.removeAt(index)),
                            ),
                          );
                        },
                      ),
                    ),
                    Text(
                      'Total: ${Money(totalCents).format()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    itemsAsync.when(
                      data: (activeItems) {
                        return FilledButton.tonal(
                          onPressed: () =>
                              _showAddItemDialog(context, activeItems),
                          child: const Text('Add Item'),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Text('Error: $e'),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _selectedCustomerId == null || _items.isEmpty
                          ? null
                          : _saveDocument,
                      child: const Text('Save Document'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showAddItemDialog(
    BuildContext context,
    List<dynamic> activeItems,
  ) async {
    int? selectedItemId;
    int qty = 1;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Line Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Item'),
                    value: selectedItemId,
                    items: activeItems
                        .map(
                          (i) => DropdownMenuItem(
                            value: i.id as int,
                            child: Text(i.name as String),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedItemId = v),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    initialValue: '1',
                    keyboardType: TextInputType.number,
                    onChanged: (v) => qty = int.tryParse(v) ?? 1,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (selectedItemId != null && qty > 0) {
                      final item = activeItems.firstWhere(
                        (i) => i.id == selectedItemId,
                      );
                      this.setState(() {
                        _items.add(
                          DocumentLineItem(
                            itemId: item.id as int,
                            itemName: item.name as String,
                            quantity: qty,
                            unitPriceCents: item.sellingPriceCents as int,
                          ),
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveDocument() async {
    try {
      await ref
          .read(documentRepositoryProvider)
          .createDocument(
            type: widget.documentType,
            customerId: _selectedCustomerId!,
            items: _items,
          );
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
