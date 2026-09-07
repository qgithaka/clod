import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/cart_provider.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../domain/entities/item_entity.dart';
import '../../data/repositories/sale_repository.dart';
import '../../core/services/receipt_service.dart';

class PosView extends ConsumerStatefulWidget {
  const PosView({super.key});

  @override
  ConsumerState<PosView> createState() => _PosViewState();
}

class _PosViewState extends ConsumerState<PosView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(activeItemsProvider);
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Attach Customer',
            onPressed: _showCustomerSelection,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear Cart',
            onPressed: () => ref.read(cartProvider.notifier).clearCart(),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side: Items Grid
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search items...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  ),
                ),
                Expanded(
                  child: itemsAsync.when(
                    data: (items) {
                      final filtered = items.where((i) {
                        return _searchQuery.isEmpty || i.name.toLowerCase().contains(_searchQuery);
                      }).toList();
                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return InkWell(
                            onTap: () => ref.read(cartProvider.notifier).addItem(item),
                            child: Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    item.type == ItemType.product ? Icons.inventory : Icons.build,
                                    size: 40,
                                    color: item.type == ItemType.product ? Colors.blue : Colors.purple,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(item.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(item.sellingPrice.format()),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
          ),
          // Right side: Cart
          Expanded(
            flex: 4,
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    width: double.infinity,
                    child: Text(
                      'Cart - ${cartState.customer?.name ?? 'Walk-in Customer'}',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartState.items.length,
                      itemBuilder: (context, index) {
                        final line = cartState.items[index];
                        return ListTile(
                          title: Text(line.item.name),
                          subtitle: Text('${line.overridePrice.format()} x ${line.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => ref.read(cartProvider.notifier).updateQuantity(line.item.id, line.quantity - 1),
                              ),
                              Text('${line.quantity}', style: const TextStyle(fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => ref.read(cartProvider.notifier).updateQuantity(line.item.id, line.quantity + 1),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(cartState.total.format(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          icon: const Icon(Icons.payment),
                          label: const Text('Checkout', style: TextStyle(fontSize: 18)),
                          style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                          onPressed: cartState.items.isEmpty ? null : _checkout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomerSelection() async {
    final customers = await ref.read(customerRepositoryProvider).watchAllCustomers().first;
    if (!mounted) return;
    
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: customers.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return ListTile(
                leading: const Icon(Icons.person_off),
                title: const Text('Walk-in Customer (Detach)'),
                onTap: () {
                  ref.read(cartProvider.notifier).detachCustomer();
                  Navigator.pop(context);
                },
              );
            }
            final customer = customers[index - 1];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(customer.name),
              subtitle: Text('Balance: ${customer.currentBalance.format()}'),
              onTap: () {
                ref.read(cartProvider.notifier).attachCustomer(customer);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _checkout() {
    final cartState = ref.read(cartProvider);
    
      showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Complete Sale'),
          content: Text('Total amount: ${cartState.total.format()}\nSelect payment method:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.money),
              label: const Text('Cash'),
              onPressed: () {
                Navigator.pop(context);
                _processCheckout(false);
              },
            ),
            if (cartState.customer != null)
              FilledButton.icon(
                icon: const Icon(Icons.credit_card),
                label: const Text('Credit'),
                onPressed: () {
                  Navigator.pop(context);
                  _processCheckout(true);
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _processCheckout(bool isCredit) async {
    final cartState = ref.read(cartProvider);
    try {
      final saleId = await ref.read(saleRepositoryProvider).processCheckout(cartState, isCredit);
      
      if (!mounted) return;
      ref.read(cartProvider.notifier).clearCart();
      
        showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Sale Complete!'),
            content: Text('Sale #$saleId was successfully recorded.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.receipt),
                label: const Text('Share Receipt'),
                onPressed: () {
                  ref.read(receiptServiceProvider).generateAndShareReceipt(
                    cart: cartState,
                    isCredit: isCredit,
                    saleId: saleId,
                  );
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
