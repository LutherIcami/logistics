import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reports_provider.dart';
import '../../../domain/models/report_models.dart';

class FinancialReportPage extends StatefulWidget {
  const FinancialReportPage({super.key});

  @override
  State<FinancialReportPage> createState() => _FinancialReportPageState();
}

class _FinancialReportPageState extends State<FinancialReportPage> {
  int _selectedView = 0; // 0: Weekly, 1: Monthly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Report')),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToggle(context),
                const SizedBox(height: 24),

                if (_selectedView == 0)
                  _buildWeeklyChart(context, provider)
                else
                  _buildMonthlyChart(context, provider),

                const SizedBox(height: 24),
                _buildSummaryStats(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggle(BuildContext context) {
    return Center(
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 0, label: Text('Weekly Revenue')),
          ButtonSegment(value: 1, label: Text('Monthly Overview')),
        ],
        selected: {_selectedView},
        onSelectionChanged: (Set<int> newSelection) {
          setState(() {
            _selectedView = newSelection.first;
          });
        },
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, ReportsProvider provider) {
    final maxAmount = provider.weeklyRevenue
        .map((e) => e.amount)
        .fold(0.0, (prev, element) => element > prev ? element : prev);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Revenue (Last 7 Days)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: provider.weeklyRevenue.map((data) {
              final heightFactor = maxAmount > 0
                  ? data.amount / maxAmount
                  : 0.0;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: 'KES ${data.amount.toStringAsFixed(0)}',
                    child: Container(
                      width: 30,
                      height: 160 * heightFactor,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.day,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyChart(BuildContext context, ReportsProvider provider) {
    final maxVal = provider.monthlyRevenue
        .map((e) => e.revenue > e.expenses ? e.revenue : e.expenses)
        .fold(0.0, (prev, element) => element > prev ? element : prev);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Revenue vs Expenses (6 Months)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: Colors.green, label: 'Revenue'),
            const SizedBox(width: 16),
            _LegendItem(color: Colors.red, label: 'Expense'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: provider.monthlyRevenue.map((data) {
              final revFactor = maxVal > 0 ? data.revenue / maxVal : 0.0;
              final expFactor = maxVal > 0 ? data.expenses / maxVal : 0.0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: 'Rev: KES ${data.revenueText}',
                        child: Container(
                          width: 12,
                          height: 180 * revFactor,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Tooltip(
                        message: 'Exp: KES ${data.expensesText}',
                        child: Container(
                          width: 12,
                          height: 180 * expFactor,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(data.month, style: const TextStyle(fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(ReportsProvider provider) {
    // Calculate totals based on mock data
    double totalRev = 0;
    double totalExp = 0;

    if (_selectedView == 0) {
      totalRev = provider.weeklyRevenue.fold(
        0,
        (sum, item) => sum + item.amount,
      );
      // Mock weekly expense as 70% of revenue for simplicity
      totalExp = totalRev * 0.7;
    } else {
      totalRev = provider.monthlyRevenue.fold(
        0,
        (sum, item) => sum + item.revenue,
      );
      totalExp = provider.monthlyRevenue.fold(
        0,
        (sum, item) => sum + item.expenses,
      );
    }

    final profit = totalRev - totalExp;
    final profitMargin = totalRev > 0 ? (profit / totalRev) * 100 : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Performance Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            _buildStatRow(
              'Total Revenue',
              'KES ${totalRev.toStringAsFixed(0)}',
              Colors.green,
            ),
            _buildStatRow(
              'Total Expenses',
              'KES ${totalExp.toStringAsFixed(0)}',
              Colors.red,
            ),
            const Divider(),
            _buildStatRow(
              'Net Profit',
              'KES ${profit.toStringAsFixed(0)}',
              Colors.blue,
            ),
            _buildStatRow(
              'Margin',
              '${profitMargin.toStringAsFixed(1)}%',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

extension on MonthlyRevenue {
  String get revenueText => '${(revenue / 1000).toStringAsFixed(1)}k';
  String get expensesText => '${(expenses / 1000).toStringAsFixed(1)}k';
}
