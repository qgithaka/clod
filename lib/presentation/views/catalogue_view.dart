import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/item_repository.dart';
import '../../domain/entities/item_entity.dart';

class CatalogueView extends ConsumerStatefulWidget {
  const CatalogueView({super.key});

  @override
  ConsumerState<CatalogueView> createState() => _CatalogueViewState();
}

class _CatalogueViewState extends ConsumerState<CatalogueView> {
  String _searchQuery = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(activeItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search items...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _filter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Types')),
                    DropdownMenuItem(value: 'Products', child: Text('Products')),
                    DropdownMenuItem(value: 'Services', child: Text('Services')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _filter = val);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                var filtered = items.where((i) {
                  if (_searchQuery.isNotEmpty && !i.name.toLowerCase().contains(_searchQuery)) return false;
                  if (_filter == 'Products' && i.type != ItemType.product) return false;
                  if (_filter == 'Services' && i.type != ItemType.service) return false;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No items found.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.type == ItemType.product ? Colors.blue.shade100 : Colors.purple.shade100,
                        child: Icon(
                          item.type == ItemType.product ? Icons.inventory : Icons.build,
                          color: item.type == ItemType.product ? Colors.blue : Colors.purple,
                        ),
                      ),
                      title: Text(item.name),
                      subtitle: item.type == ItemType.product 
                          ? Text('Stock: ${item.stockQuantity ?? 0}')
                          : const Text('Service'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.isLowStock) 
                            const Tooltip(
                              message: 'Low Stock',
                              child: Icon(Icons.warning, color: Colors.orange),
                            ),
                          const SizedBox(width: 8),
                          Text(item.sellingPrice.format(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      onTap: () => context.go('/catalogue/${item.id}'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/catalogue/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
