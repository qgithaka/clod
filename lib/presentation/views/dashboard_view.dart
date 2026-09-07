import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../data/repositories/analytics_repository.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'P&L Report',
            onPressed: () => context.go('/dashboard/pl'),
          ),
        ],
      ),
      body: metricsAsync.when(
        data: (metrics) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildMetricCard(
                context,
                title: 'Today\'s Revenue',
                value: Money(metrics.todaysRevenueCents).format(),
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildMetricCard(
                context,
                title: 'Total Outstanding Debt',
                value: Money(metrics.totalOutstandingDebtCents).format(),
                icon: Icons.money_off,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              _buildMetricCard(
                context,
                title: 'Low Stock Alerts',
                value: '${metrics.lowStockCount} Items',
                icon: Icons.warning_amber,
                color: Colors.orange,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
