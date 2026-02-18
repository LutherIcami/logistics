import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reports_provider.dart';
import 'analytics_theme.dart';

class FinancialReportPage extends StatefulWidget {
  const FinancialReportPage({super.key});

  @override
  State<FinancialReportPage> createState() => _FinancialReportPageState();
}

class _FinancialReportPageState extends State<FinancialReportPage> {
  int _selectedView = 1; // Default to Monthly Overview
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsProvider>().loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnalyticsTheme.backgroundGray,
      appBar: AppBar(
        title: const Text('Financial Intelligence'),
        backgroundColor: AnalyticsTheme.cardWhite,
        foregroundColor: AnalyticsTheme.textDark,
        elevation: 0,
      ),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AnalyticsTheme.primaryGreen),
                  const SizedBox(height: 16),
                  Text(
                    'Loading financial data...',
                    style: AnalyticsTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadReports(),
            color: AnalyticsTheme.primaryGreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AnalyticsTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AnalyticsTheme.spacingXL),
                  _buildToggle(),
                  const SizedBox(height: AnalyticsTheme.spacingXL),

                  if (_selectedView == 0)
                    _buildWeeklyPerformanceChart(provider)
                  else
                    _buildMonthlyPerformanceChart(provider),

                  const SizedBox(height: AnalyticsTheme.spacingXL),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildExpenseBreakdownChart(provider),
                      ),
                      const SizedBox(width: AnalyticsTheme.spacingL),
                      Expanded(flex: 2, child: _buildTopCustomers(provider)),
                    ],
                  ),
                  const SizedBox(height: AnalyticsTheme.spacingXL),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Financial Ledger', style: AnalyticsTheme.headingLarge),
        const SizedBox(height: AnalyticsTheme.spacingXS),
        Text(
          'Company revenue (30%), expenses, and profit margins',
          style: AnalyticsTheme.bodyMedium,
        ),
        const SizedBox(height: AnalyticsTheme.spacingXS),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AnalyticsTheme.spacingM,
            vertical: AnalyticsTheme.spacingS,
          ),
          decoration: BoxDecoration(
            color: AnalyticsTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AnalyticsTheme.radiusS),
            border: Border.all(
              color: AnalyticsTheme.primaryBlue.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AnalyticsTheme.primaryBlue,
              ),
              const SizedBox(width: AnalyticsTheme.spacingS),
              Flexible(
                child: Text(
                  'Revenue shown is company share after 70% driver commission',
                  style: AnalyticsTheme.bodySmall.copyWith(
                    color: AnalyticsTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AnalyticsTheme.cardWhite,
        borderRadius: BorderRadius.circular(AnalyticsTheme.radiusM),
        boxShadow: AnalyticsTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleButton(0, 'Weekly'),
            _buildToggleButton(1, 'Monthly'),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(int index, String label) {
    final isSelected = _selectedView == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedView = index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AnalyticsTheme.spacingL,
          vertical: AnalyticsTheme.spacingS,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AnalyticsTheme.primaryGreen,
                    AnalyticsTheme.primaryTeal,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(AnalyticsTheme.radiusS),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AnalyticsTheme.textLight,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyPerformanceChart(ReportsProvider provider) {
    if (provider.weeklyRevenue.isEmpty) {
      return _buildEmptyState('No weekly data available');
    }

    final maxY =
        provider.weeklyRevenue
            .map((e) => e.amount)
            .reduce((a, b) => a > b ? a : b) *
        1.2;

    return _buildChartContainer(
      title: 'Company Revenue Trend (7 Days)',
      subtitle: 'Daily company income (30% of total)',
      child: SizedBox(
        height: 280,
        child: BarChart(
          BarChartData(
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AnalyticsTheme.textDark,
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    AnalyticsTheme.formatCurrency(rod.toY),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < 0 ||
                        value.toInt() >= provider.weeklyRevenue.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        provider.weeklyRevenue[value.toInt()].day,
                        style: AnalyticsTheme.bodySmall,
                      ),
                    );
                  },
                  reservedSize: 32,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox.shrink();
                    return Text(
                      AnalyticsTheme.formatCurrency(value),
                      style: AnalyticsTheme.bodySmall.copyWith(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 5,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: AnalyticsTheme.borderLight, strokeWidth: 1),
            ),
            barGroups: provider.weeklyRevenue.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.amount,
                    width: 24,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AnalyticsTheme.radiusS),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        AnalyticsTheme.primaryGreen,
                        AnalyticsTheme.primaryTeal,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ],
              );
            }).toList(),
            maxY: maxY,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyPerformanceChart(ReportsProvider provider) {
    if (provider.monthlyRevenue.isEmpty) {
      return _buildEmptyState('No monthly data available');
    }

    final maxVal =
        provider.monthlyRevenue
            .map((e) => e.revenue > e.expenses ? e.revenue : e.expenses)
            .reduce((a, b) => a > b ? a : b) *
        1.2;

    return _buildChartContainer(
      title: 'Performance Overview',
      subtitle: 'Company Revenue (30%) vs Driver Payments (70%)',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegend('Company Revenue', AnalyticsTheme.primaryGreen),
              const SizedBox(width: AnalyticsTheme.spacingM),
              _buildLegend('Driver Payments', AnalyticsTheme.primaryRed),
            ],
          ),
          const SizedBox(height: AnalyticsTheme.spacingL),
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                maxY: maxVal,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AnalyticsTheme.textDark,
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final isRevenue = rodIndex == 0;
                      return BarTooltipItem(
                        '${isRevenue ? "Company Revenue" : "Driver Payments"}\n${AnalyticsTheme.formatCurrency(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < 0 ||
                            value.toInt() >= provider.monthlyRevenue.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            provider.monthlyRevenue[value.toInt()].month,
                            style: AnalyticsTheme.bodySmall,
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          AnalyticsTheme.formatCurrency(value),
                          style: AnalyticsTheme.bodySmall.copyWith(
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal / 5,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: AnalyticsTheme.borderLight, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: provider.monthlyRevenue.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barsSpace: 6,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.revenue,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AnalyticsTheme.radiusS),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            AnalyticsTheme.primaryGreen,
                            AnalyticsTheme.primaryTeal,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      BarChartRodData(
                        toY: entry.value.expenses,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AnalyticsTheme.radiusS),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            AnalyticsTheme.primaryRed,
                            AnalyticsTheme.primaryOrange,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseBreakdownChart(ReportsProvider provider) {
    if (provider.expenseBreakdown.isEmpty) {
      return _buildEmptyState('No expense data available');
    }

    final breakdownEntries = provider.expenseBreakdown.entries.toList();
    final total = breakdownEntries.fold(0.0, (sum, e) => sum + e.value);

    return _buildChartContainer(
      title: 'Expense Categories',
      subtitle: 'Where the money goes',
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.4,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: List.generate(breakdownEntries.length, (i) {
                  final isTouched = i == _touchedIndex;
                  final fontSize = isTouched ? 14.0 : 11.0;
                  final radius = isTouched ? 70.0 : 60.0;
                  final entry = breakdownEntries[i];
                  final color = AnalyticsTheme.getExpenseColor(entry.key);
                  final percentage = (entry.value / total * 100);

                  return PieChartSectionData(
                    color: color,
                    value: entry.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(color: Colors.black26, blurRadius: 2),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: AnalyticsTheme.spacingL),
          Wrap(
            spacing: AnalyticsTheme.spacingM,
            runSpacing: AnalyticsTheme.spacingS,
            children: breakdownEntries.map((entry) {
              return _buildLegendWithAmount(
                entry.key,
                AnalyticsTheme.getExpenseColor(entry.key),
                entry.value,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomers(ReportsProvider provider) {
    if (provider.topCustomers.isEmpty) {
      return _buildEmptyState('No customer data available');
    }

    return _buildChartContainer(
      title: 'Top Stakeholders',
      subtitle: 'Leading revenue sources',
      child: Column(
        children: provider.topCustomers.map((customer) {
          return Container(
            margin: const EdgeInsets.only(bottom: AnalyticsTheme.spacingM),
            padding: const EdgeInsets.all(AnalyticsTheme.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AnalyticsTheme.primaryGreen.withValues(alpha: 0.05),
                  AnalyticsTheme.primaryTeal.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AnalyticsTheme.radiusM),
              border: Border.all(
                color: AnalyticsTheme.primaryGreen.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AnalyticsTheme.primaryGreen,
                        AnalyticsTheme.primaryTeal,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AnalyticsTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: AnalyticsTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        AnalyticsTheme.formatCurrency(customer.revenue),
                        style: TextStyle(
                          fontSize: 12,
                          color: AnalyticsTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AnalyticsTheme.textLight,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartContainer({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AnalyticsTheme.spacingL),
      decoration: BoxDecoration(
        color: AnalyticsTheme.cardWhite,
        borderRadius: BorderRadius.circular(AnalyticsTheme.radiusL),
        boxShadow: AnalyticsTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AnalyticsTheme.headingSmall),
          const SizedBox(height: AnalyticsTheme.spacingXS),
          Text(subtitle, style: AnalyticsTheme.bodySmall),
          const SizedBox(height: AnalyticsTheme.spacingL),
          child,
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AnalyticsTheme.spacingS),
        Text(
          label,
          style: AnalyticsTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildLegendWithAmount(String label, Color color, double amount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AnalyticsTheme.spacingS),
        Text(
          '$label: ${AnalyticsTheme.formatCurrency(amount)}',
          style: AnalyticsTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AnalyticsTheme.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(AnalyticsTheme.spacingL),
      decoration: BoxDecoration(
        color: AnalyticsTheme.cardWhite,
        borderRadius: BorderRadius.circular(AnalyticsTheme.radiusL),
        boxShadow: AnalyticsTheme.cardShadow,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: AnalyticsTheme.textLight,
            ),
            const SizedBox(height: AnalyticsTheme.spacingM),
            Text(message, style: AnalyticsTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
