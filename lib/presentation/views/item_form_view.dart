import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../data/repositories/item_repository.dart';
import '../../domain/entities/item_entity.dart';

class ItemFormView extends ConsumerStatefulWidget {
  final String itemId;
  const ItemFormView({super.key, required this.itemId});

  @override
  ConsumerState<ItemFormView> createState() => _ItemFormViewState();
}

class _ItemFormViewState extends ConsumerState<ItemFormView> {
  final _formKey = GlobalKey<FormState>();
  ItemType _type = ItemType.product;

  final _nameController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _thresholdController = TextEditingController();

  ItemEntity? _existingItem;

  @override
  void initState() {
    super.initState();
    if (widget.itemId != 'new') {
      // Async initialization will happen in build via Riverpod
    }
  }

  void _populate(ItemEntity item) {
    if (_existingItem != null) return;
    _existingItem = item;
    _type = item.type;
    _nameController.text = item.name;
    _sellingPriceController.text = (item.sellingPrice.cents / 100)
        .toStringAsFixed(2);
    if (item.buyingPrice != null) {
      _buyingPriceController.text = (item.buyingPrice!.cents / 100)
          .toStringAsFixed(2);
    }
    if (item.stockQuantity != null) {
      _stockController.text = item.stockQuantity.toString();
    }
    if (item.lowStockThreshold != null) {
      _thresholdController.text = item.lowStockThreshold.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemId != 'new') {
      final itemAsync = ref.watch(itemProvider(int.parse(widget.itemId)));
      if (itemAsync.isLoading)
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      if (itemAsync.hasValue && itemAsync.value != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _populate(itemAsync.value!));
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemId == 'new' ? 'Add Item' : 'Edit Item'),
        actions: [
          if (widget.itemId != 'new')
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await ref
                    .read(itemRepositoryProvider)
                    .softDeleteItem(int.parse(widget.itemId));
                if (context.mounted) context.pop();
              },
            ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<ItemType>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Item Type'),
                    items: const [
                      DropdownMenuItem(
                        value: ItemType.product,
                        child: Text('Product (Physical)'),
                      ),
                      DropdownMenuItem(
                        value: ItemType.service,
                        child: Text('Service (Intangible)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _type = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _sellingPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Selling Price',
                      prefixText: '\$',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  if (_type == ItemType.product) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _buyingPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Buying Price (Optional)',
                        prefixText: '\$',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            decoration: const InputDecoration(
                              labelText: 'Stock Quantity',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _thresholdController,
                            decoration: const InputDecoration(
                              labelText: 'Low Stock Alert At',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Save Item'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(itemRepositoryProvider);
    final sellingPrice = double.tryParse(_sellingPriceController.text) ?? 0;

    double? buyingPrice;
    if (_buyingPriceController.text.isNotEmpty) {
      buyingPrice = double.tryParse(_buyingPriceController.text);
    }

    int? stock, threshold;
    if (_type == ItemType.product) {
      stock = int.tryParse(_stockController.text);
      threshold = int.tryParse(_thresholdController.text);
    }

    if (widget.itemId == 'new') {
      await repo.addItem(
        name: _nameController.text,
        type: _type,
        sellingPrice: Money.fromDouble(sellingPrice),
        buyingPrice: buyingPrice != null ? Money.fromDouble(buyingPrice) : null,
        stockQuantity: stock,
        lowStockThreshold: threshold,
      );
    } else {
      await repo.updateItem(
        int.parse(widget.itemId),
        name: _nameController.text,
        type: _type,
        sellingPrice: Money.fromDouble(sellingPrice),
        buyingPrice: buyingPrice != null ? Money.fromDouble(buyingPrice) : null,
        stockQuantity: stock,
        lowStockThreshold: threshold,
        createdAt: _existingItem!.createdAt,
      );
    }

    if (mounted) context.pop();
  }
}
