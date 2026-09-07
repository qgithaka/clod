import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import 'business_profile_repository.dart';

class DashboardMetrics {
  final int todaysRevenueCents;
  final int totalOutstandingDebtCents;
  final int lowStockCount;

  DashboardMetrics({
    required this.todaysRevenueCents,
    required this.totalOutstandingDebtCents,
    required this.lowStockCount,
  });
}

class ProfitAndLossReport {
  final int revenueCents;
  final int cogsCents;
  final int grossProfitCents;
  final int expensesCents;
  final int netProfitCents;

  ProfitAndLossReport({
    required this.revenueCents,
    required this.cogsCents,
    required this.grossProfitCents,
    required this.expensesCents,
    required this.netProfitCents,
  });
}

class AnalyticsRepository {
  final AppDatabase _db;

  AnalyticsRepository(this._db);

  Future<DashboardMetrics> getDashboardMetrics() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toUtc().millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).toUtc().millisecondsSinceEpoch;

    // Today's Revenue (sum of totalAmountCents for sales today)
    final salesRevenueQuery = _db.select(_db.sales)
      ..where((s) => s.createdAt.isBetweenValues(startOfDay, endOfDay));
    final sales = await salesRevenueQuery.get();
    int todaysRevenue = sales.fold(0, (sum, sale) => sum + sale.totalAmountCents);

    // Total Outstanding Debt (sum of balances > 0)
    final debtQuery = _db.selectOnly(_db.customers)
      ..addColumns([_db.customers.currentBalanceCents.sum()]);
    final debtResult = await debtQuery.getSingle();
    final totalDebt = debtResult.read(_db.customers.currentBalanceCents.sum())?.toInt() ?? 0;

    // Low Stock Count
    final lowStockQuery = _db.select(_db.items)
      ..where((i) => i.stockQuantity.isSmallerOrEqual(i.lowStockThreshold));
    final lowStockItems = await lowStockQuery.get();

    return DashboardMetrics(
      todaysRevenueCents: todaysRevenue,
      totalOutstandingDebtCents: totalDebt, // Assuming balance is positive when they owe us
      lowStockCount: lowStockItems.length,
    );
  }

  Future<ProfitAndLossReport> getProfitAndLoss(int startDate, int endDate, {bool isCashBasis = false}) async {
    // 1. Revenue
    int revenue = 0;
    int cogs = 0;

    final salesQuery = _db.select(_db.sales)
      ..where((s) => s.createdAt.isBetweenValues(startDate, endDate));
    final salesList = await salesQuery.get();

    if (isCashBasis) {
      // For cash basis, revenue is the cash paid at the time of sale + any payments made in the period
      for (var sale in salesList) {
        if (sale.paymentMethod == 'cash') {
          revenue += sale.totalAmountCents;
        }
      }
      
      // We also need to add repayments made in the period
      final repaymentsQuery = _db.select(_db.creditTransactions)
        ..where((t) => t.amountCents.isSmallerThanValue(0) & t.createdAt.isBetweenValues(startDate, endDate));
      final repayments = await repaymentsQuery.get();
      revenue += repayments.fold(0, (sum, t) => sum + t.amountCents.abs());
      
      // COGS is tricky on cash basis, but typically we'll just use the standard COGS for the items sold
      final saleIds = salesList.map((s) => s.id).toList();
      if (saleIds.isNotEmpty) {
        final itemsQuery = _db.select(_db.saleItems)..where((i) => i.saleId.isIn(saleIds));
        final soldItems = await itemsQuery.get();
        for (var item in soldItems) {
            final masterItem = await (_db.select(_db.items)..where((i) => i.id.equals(item.itemId))).getSingle();
            cogs += (item.quantity * (masterItem.buyingPriceCents ?? 0));
        }
      }
    } else {
      // Accrual basis
      revenue = salesList.fold(0, (sum, sale) => sum + sale.totalAmountCents);
      
      final saleIds = salesList.map((s) => s.id).toList();
      if (saleIds.isNotEmpty) {
        final itemsQuery = _db.select(_db.saleItems)..where((i) => i.saleId.isIn(saleIds));
        final soldItems = await itemsQuery.get();
        for (var item in soldItems) {
            final masterItem = await (_db.select(_db.items)..where((i) => i.id.equals(item.itemId))).getSingle();
            cogs += (item.quantity * (masterItem.buyingPriceCents ?? 0));
        }
      }
    }

    // Shrinkage cost (adds to COGS or Expenses? usually COGS or a separate expense. Let's add to Expenses)
    final shrinkageQuery = _db.select(_db.stockMovements)
      ..where((m) => m.reason.isIn(['damaged', 'expired', 'lost']) & m.createdAt.isBetweenValues(startDate, endDate));
    final shrinkageList = await shrinkageQuery.get();
    
    // We need unit costs for shrinkage. 
    int shrinkageCost = 0;
    for (var shrink in shrinkageList) {
       final item = await (_db.select(_db.items)..where((i) => i.id.equals(shrink.itemId))).getSingleOrNull();
       if (item != null) {
           shrinkageCost += shrink.quantityChange.abs() * (item.buyingPriceCents ?? 0);
       }
    }

    // 3. Expenses
    final expensesQuery = _db.select(_db.expenses)
      ..where((e) => e.occurredAt.isBetweenValues(startDate, endDate));
    final expensesList = await expensesQuery.get();
    int operatingExpenses = expensesList.fold(0, (sum, e) => sum + e.amountCents);

    final totalExpenses = operatingExpenses + shrinkageCost;
    final grossProfit = revenue - cogs;
    final netProfit = grossProfit - totalExpenses;

    return ProfitAndLossReport(
      revenueCents: revenue,
      cogsCents: cogs,
      grossProfitCents: grossProfit,
      expensesCents: totalExpenses,
      netProfitCents: netProfit,
    );
  }

  Future<int> getStockValuation({bool retail = false}) async {
    final items = await _db.select(_db.items).get();
    if (retail) {
      int val = 0;
      for (var i in items) val += ((i.stockQuantity ?? 0) * i.sellingPriceCents);
      return val;
    } else {
      int val = 0;
      for (var i in items) val += ((i.stockQuantity ?? 0) * (i.buyingPriceCents ?? 0));
      return val;
    }
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.watch(databaseProvider));
});

final dashboardMetricsProvider = FutureProvider.autoDispose<DashboardMetrics>((ref) {
  return ref.watch(analyticsRepositoryProvider).getDashboardMetrics();
});
