import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/item_repository.dart';
import '../../data/repositories/stock_movement_repository.dart';

class ShrinkageView extends ConsumerStatefulWidget {
  const ShrinkageView({super.key});

  @override
  ConsumerState<ShrinkageView> createState() => _ShrinkageViewState();
}

class _ShrinkageViewState extends ConsumerState<ShrinkageView> {
  int? _selectedItemId;
  int _quantity = 1;
  String _reason = 'damaged';

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(activeItemsProvider);

    return Scaffold(
      body: itemsAsync.when(
        data: (items) {
          final products = items
              .where((i) => i.type.name == 'product')
              .toList();
          if (products.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Select Product',
                  ),
                  value: _selectedItemId,
                  items: products
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.name} (Stock: ${p.stockQuantity})'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedItemId = v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantity Reduced',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: '1',
                  onChanged: (v) =>
                      setState(() => _quantity = int.tryParse(v) ?? 1),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Reason'),
                  value: _reason,
                  items: const [
                    DropdownMenuItem(value: 'damaged', child: Text('Damaged')),
                    DropdownMenuItem(value: 'expired', child: Text('Expired')),
                    DropdownMenuItem(value: 'lost', child: Text('Lost')),
                    DropdownMenuItem(
                      value: 'adjustment',
                      child: Text('Manual Adjustment'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _reason = v!),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _selectedItemId == null || _quantity <= 0
                      ? null
                      : _logShrinkage,
                  child: const Text('Log Issue'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _logShrinkage() async {
    try {
      await ref
          .read(stockMovementRepositoryProvider)
          .logShrinkage(
            itemId: _selectedItemId!,
            quantityReduced: _quantity,
            reason: _reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock issue logged successfully.')),
      );
      setState(() {
        _selectedItemId = null;
        _quantity = 1;
        _reason = 'damaged';
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
