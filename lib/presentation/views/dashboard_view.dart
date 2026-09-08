// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/money.dart';
import '../../data/repositories/analytics_repository.dart';

// Ultra-Premium Dark Theme Colors
const _bgColor = Color(0xFF0E0F14); // Pure dark background
const _surfaceColor = Color(0xFF181A20); // Card background
const _surfaceColorHover = Color(0xFF22252D);
const _borderColor = Color(0xFF2A2D35); // Subtle border
const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFF8E8E93);
const _accentGreen = Color(0xFF10B981);
const _accentRed = Color(0xFFEF4444);
const _accentBlue = Color(0xFF3B82F6);
const _accentPurple = Color(0xFF8B5CF6);

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      body: metricsAsync.when(
        data: (metrics) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overview / Dashboard',
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 13,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome Back, Jason',
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Last update: 2 min ago',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Top Row: KPIs
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 1200
                        ? 4
                        : constraints.maxWidth > 800
                        ? 2
                        : 1;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 2.2,
                      children: [
                        _buildKpiCard(
                          title: 'Today\'s Revenue',
                          value: Money(metrics.todaysRevenueCents).format(),
                          change: '+2.4%',
                          isPositive: true,
                          sparklineData: [2, 4, 3, 7, 5, 8, 9, 12],
                          chartColor: _accentGreen,
                        ),
                        _buildKpiCard(
                          title: 'Outstanding Debt',
                          value: Money(metrics.totalOutstandingDebtCents)
                              .format(),
                          change: '-1.2%',
                          isPositive: false,
                          sparklineData: [8, 7, 7, 6, 4, 5, 4, 3],
                          chartColor: _accentRed,
                        ),
                        _buildKpiCard(
                          title: 'Active Customers',
                          value: '142',
                          change: '+12',
                          isPositive: true,
                          sparklineData: [2, 3, 3, 4, 6, 5, 8, 9],
                          chartColor: _accentBlue,
                        ),
                        _buildKpiCard(
                          title: 'Low Stock Items',
                          value: '${metrics.lowStockCount}',
                          change: '+3',
                          isPositive: false,
                          sparklineData: [1, 1, 2, 1, 2, 3, 3, 4],
                          chartColor: _accentPurple,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Middle Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 1000;
                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: _buildMarketOverviewChart()),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 3,
                            child: _buildExchangePanel(context),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildMarketOverviewChart(),
                          const SizedBox(height: 24),
                          _buildExchangePanel(context),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Bottom Row Data Table
                _buildMarketOverviewTable(),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _accentBlue)),
        error: (e, s) => Center(
          child: Text('Error: $e', style: const TextStyle(color: _accentRed)),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required List<double> sparklineData,
    required Color chartColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? _accentGreen : _accentRed).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: isPositive ? _accentGreen : _accentRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: -10,
            bottom: -10,
            width: 120,
            height: 60,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: sparklineData
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: chartColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: chartColor.withValues(alpha: 0.15),
                      gradient: LinearGradient(
                        colors: [
                          chartColor.withValues(alpha: 0.3),
                          chartColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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

  Widget _buildMarketOverviewChart() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Financial Overview',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  children: [
                    _buildChartTab('1D', false),
                    _buildChartTab('7D', true),
                    _buildChartTab('1M', false),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: _borderColor,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: _textSecondary,
                          fontSize: 11,
                        );
                        String text = '';
                        switch (value.toInt()) {
                          case 0:
                            text = 'Mon';
                            break;
                          case 2:
                            text = 'Tue';
                            break;
                          case 4:
                            text = 'Wed';
                            break;
                          case 6:
                            text = 'Thu';
                            break;
                          case 8:
                            text = 'Fri';
                            break;
                          case 10:
                            text = 'Sat';
                            break;
                          case 12:
                            text = 'Sun';
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}k',
                          style: const TextStyle(
                            color: _textSecondary,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 30),
                      FlSpot(2, 45),
                      FlSpot(4, 35),
                      FlSpot(6, 60),
                      FlSpot(8, 40),
                      FlSpot(10, 80),
                      FlSpot(12, 70),
                    ],
                    isCurved: true,
                    color: _accentGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          _accentGreen.withValues(alpha: 0.2),
                          _accentGreen.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 20),
                      FlSpot(2, 25),
                      FlSpot(4, 15),
                      FlSpot(6, 30),
                      FlSpot(8, 20),
                      FlSpot(10, 40),
                      FlSpot(12, 35),
                    ],
                    isCurved: true,
                    color: _accentPurple,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          _accentPurple.withValues(alpha: 0.2),
                          _accentPurple.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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

  Widget _buildChartTab(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2C2F36) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? _textPrimary : _textSecondary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildExchangePanel(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Action Terminal',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Execute fast POS or Ledger operations',
            style: TextStyle(color: _textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _surfaceColorHover,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'POS Terminal',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    child: const Text(
                      'New Invoice',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Launch POS',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketOverviewTable() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(color: _textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: _borderColor, height: 1),
          DataTable(
            headingTextStyle: const TextStyle(
              color: _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            dataTextStyle: const TextStyle(
              color: _textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            dividerThickness: 1,
            horizontalMargin: 24,
            columns: const [
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Customer / Desc')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Date')),
            ],
            rows: [
              _buildDataRow(
                'Sale',
                'Walk-in Customer',
                'KSh 2,450',
                'Paid',
                'Today, 10:45 AM',
                _accentGreen,
              ),
              _buildDataRow(
                'Credit',
                'John Doe',
                'KSh 1,200',
                'Pending',
                'Today, 09:12 AM',
                _accentRed,
              ),
              _buildDataRow(
                'Expense',
                'Office Supplies',
                'KSh 450',
                'Paid',
                'Yesterday',
                _accentBlue,
              ),
              _buildDataRow(
                'Sale',
                'Walk-in Customer',
                'KSh 8,900',
                'Paid',
                'Yesterday',
                _accentGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(
    String type,
    String desc,
    String amount,
    String status,
    String date,
    Color statusColor,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(type)),
        DataCell(Text(desc)),
        DataCell(
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(Text(date, style: const TextStyle(color: _textSecondary))),
      ],
    );
  }
}
