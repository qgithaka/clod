import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/money.dart';
import '../../data/repositories/customer_repository.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: customersAsync.when(
        data: (customers) {
          final debtors = customers.where((c) => c.currentBalance.cents > 0).toList();
          debtors.sort((a, b) => b.currentBalance.cents.compareTo(a.currentBalance.cents));
          
          final totalDebtCents = debtors.fold(0, (sum, c) => sum + c.currentBalance.cents);
          final totalDebt = Money(totalDebtCents);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          'Total Outstanding Debt',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalDebt.format(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Top Debtors', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Expanded(
                  child: debtors.isEmpty
                      ? const Center(child: Text('No outstanding debt!'))
                      : ListView.builder(
                          itemCount: debtors.length > 10 ? 10 : debtors.length,
                          itemBuilder: (context, index) {
                            final debtor = debtors[index];
                            return ListTile(
                              leading: CircleAvatar(child: Text('${index + 1}')),
                              title: Text(debtor.name),
                              trailing: Text(
                                debtor.currentBalance.format(),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                            );
                          },
                        ),
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
}
