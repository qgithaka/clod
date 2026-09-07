import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/money.dart';
import '../../data/repositories/analytics_repository.dart';

class DateRangeNotifier extends Notifier<DateTimeRange> {
  @override
  DateTimeRange build() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }
  void setRange(DateTimeRange range) => state = range;
}
final dateRangeProvider = NotifierProvider<DateRangeNotifier, DateTimeRange>(DateRangeNotifier.new);

class CashBasisNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle(bool v) => state = v;
}
final cashBasisProvider = NotifierProvider<CashBasisNotifier, bool>(CashBasisNotifier.new);

final profitLossProvider = FutureProvider.autoDispose<ProfitAndLossReport>((ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  final range = ref.watch(dateRangeProvider);
  final cashBasis = ref.watch(cashBasisProvider);

  return repo.getProfitAndLoss(
    range.start.toUtc().millisecondsSinceEpoch,
    range.end.toUtc().millisecondsSinceEpoch,
    isCashBasis: cashBasis,
  );
});

final stockValuationProvider = FutureProvider.autoDispose<int>((ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getStockValuation(retail: false);
});

class ProfitLossView extends ConsumerWidget {
  const ProfitLossView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(profitLossProvider);
    final stockValAsync = ref.watch(stockValuationProvider);
    final range = ref.watch(dateRangeProvider);
    final cashBasis = ref.watch(cashBasisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit & Loss'),
        actions: [
          Row(
            children: [
              const Text('Cash Basis'),
              Switch(
                value: cashBasis,
                onChanged: (v) => ref.read(cashBasisProvider.notifier).toggle(v),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 1)),
                initialDateRange: range,
              );
              if (picked != null) {
                ref.read(dateRangeProvider.notifier).setRange(DateTimeRange(
                  start: picked.start,
                  end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
                ));
              }
            },
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildRow('Revenue', Money(report.revenueCents).format(), isBold: true),
              const Divider(),
              _buildRow('Cost of Goods Sold (COGS)', '- ${Money(report.cogsCents).format()}'),
              const Divider(),
              _buildRow('Gross Profit', Money(report.grossProfitCents).format(), isBold: true, color: Colors.blue),
              const Divider(thickness: 2),
              _buildRow('Expenses', '- ${Money(report.expensesCents).format()}'),
              const Divider(),
              _buildRow(
                'Net Profit',
                Money(report.netProfitCents).format(),
                isBold: true,
                color: report.netProfitCents >= 0 ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Stock Valuation (at cost)', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      stockValAsync.when(
                        data: (val) => Text(Money(val).format(), style: Theme.of(context).textTheme.headlineSmall),
                        loading: () => const CircularProgressIndicator(),
                        error: (e, s) => Text('Error: $e'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color, double size = 16}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: size,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: size,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
