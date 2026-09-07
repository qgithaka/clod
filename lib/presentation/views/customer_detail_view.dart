import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/money.dart';
import '../../data/repositories/customer_repository.dart';

class CustomerDetailView extends ConsumerWidget {
  final int customerId;
  const CustomerDetailView({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerProvider(customerId));
    final txnsAsync = ref.watch(creditTransactionsProvider(customerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/customers/$customerId/edit'),
          ),
        ],
      ),
      body: customerAsync.when(
        data: (customer) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        child: Text(customer.name[0].toUpperCase(), style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(height: 16),
                      Text(customer.name, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text('Phone: ${customer.phone ?? 'N/A'}'),
                      Text('Address: ${customer.address ?? 'N/A'}'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatBox(label: 'Balance', value: customer.currentBalance.format(), isError: customer.currentBalance.cents > 0),
                          _StatBox(label: 'Credit Limit', value: customer.creditLimit.format()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Transaction History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: txnsAsync.when(
                  data: (txns) {
                    if (txns.isEmpty) return const Center(child: Text('No credit transactions yet.'));
                    return ListView.builder(
                      itemCount: txns.length,
                      itemBuilder: (context, index) {
                        final txn = txns[index];
                        final isPayment = txn.type == 'PAYMENT';
                        return ListTile(
                          leading: Icon(
                            isPayment ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isPayment ? Colors.green : Colors.red,
                          ),
                          title: Text(isPayment ? 'Payment Received' : 'Sale Charged'),
                          subtitle: Text(txn.createdAt.toString().split('.')[0]),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isPayment ? '-' : '+'}${txn.amount.format()}',
                                style: TextStyle(
                                  color: isPayment ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showRepaymentDialog(context, ref, customerId);
        },
        icon: const Icon(Icons.payment),
        label: const Text('Record Payment'),
      ),
    );
  }

  Future<void> _showRepaymentDialog(BuildContext context, WidgetRef ref, int customerId) async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                final repo = ref.read(customerRepositoryProvider);
                await repo.recordRepayment(customerId, Money.fromDouble(amount), note: noteController.text.isEmpty ? null : noteController.text);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isError;

  const _StatBox({required this.label, required this.value, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: isError ? Theme.of(context).colorScheme.error : null,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
