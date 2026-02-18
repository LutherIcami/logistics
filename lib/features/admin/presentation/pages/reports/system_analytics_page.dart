import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reports_provider.dart';
import 'analytics_theme.dart';

class SystemAnalyticsPage extends StatefulWidget {
  const SystemAnalyticsPage({super.key});

  @override
  State<SystemAnalyticsPage> createState() => _SystemAnalyticsPageState();
}

class _SystemAnalyticsPageState extends State<SystemAnalyticsPage> {
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
        title: const Text('System Analytics'),
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
                  CircularProgressIndicator(
                    color: AnalyticsTheme.primaryPurple,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading analytics...',
                    style: AnalyticsTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadReports(),
            color: AnalyticsTheme.primaryPurple,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AnalyticsTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AnalyticsTheme.spacingXL),

                  // Key Metrics Row
                  _buildKeyMetricsRow(provider),
                  const SizedBox(height: AnalyticsTheme.spacingXL),

                  // Revenue Chart
                  _buildSectionHeader(
                    'Company Revenue & Driver Payouts Trend',
                    'Monthly financial performance overview',
                  ),
                  const SizedBox(height: AnalyticsTheme.spacingM),
                  _buildRevenueChart(provider),
                  const SizedBox(height: AnalyticsTheme.spacingXL),

                  // Two Column Layout for Status & Region
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildShipmentStatusChart(provider)),
                      const SizedBox(width: AnalyticsTheme.spacingL),
                      Expanded(child: _buildRegionChart(provider)),
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
        Text('System Overview', style: AnalyticsTheme.headingLarge),
        const SizedBox(height: AnalyticsTheme.spacingXS),
        Text(
          'Comprehensive performance metrics and insights',
          style: AnalyticsTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AnalyticsTheme.headingMedium),
        const SizedBox(height: AnalyticsTheme.spacingXS),
        Text(subtitle, style: AnalyticsTheme.bodySmall),
      ],
    );
  }

  Widget _buildKeyMetricsRow(ReportsProvider provider) {
    // Current Data:
    // revenue = Company Revenue (approx 30%)
    // expenses = Driver Earnings (approx 70%)

    final companyRevenue = provider.monthlyRevenue.fold(
      0.0,
      (sum, e) => sum + e.revenue,
    );
    final driverPayouts = provider.monthlyRevenue.fold(
      0.0,
      (sum, e) => sum + e.expenses,
    );

    // Total Volume = Company Revenue + Driver Payouts
    final totalVolume = companyRevenue + driverPayouts;

    // Company Share % = Company Revenue / Total Volume
    final companyShare = totalVolume > 0 ? (companyRevenue / totalVolume) : 0.0;

    return Wrap(
      spacing: AnalyticsTheme.spacingM,
      runSpacing: AnalyticsTheme.spacingM,
      children: [
        _MetricCard(
          title: 'Total Volume',
          value: AnalyticsTheme.formatCurrency(totalVolume),
          subtitle: 'Gross Transaction Value',
          icon: Icons.monetization_on_rounded,
          color: AnalyticsTheme.primaryBlue,
          trend: '+12.5%',
          trendUp: true,
        ),
        _MetricCard(
          title: 'Company Revenue',
          value: AnalyticsTheme.formatCurrency(companyRevenue),
          subtitle: 'Net Revenue (30%)',
          icon: Icons.account_balance_wallet_rounded,
          color: AnalyticsTheme.primaryGreen,
          trend: '+8.3%',
          trendUp: true,
        ),
        _MetricCard(
          title: 'Driver Payouts',
          value: AnalyticsTheme.formatCurrency(driverPayouts),
          subtitle: 'Disbursed to drivers',
          icon: Icons.people_alt_rounded,
          color: AnalyticsTheme.primaryOrange,
          trend: '+15.2%',
          trendUp: true, // More payouts means more trips
        ),
        _MetricCard(
          title: 'Company Share',
          value: AnalyticsTheme.formatPercentage(companyShare),
          subtitle: 'Avg. Commission Rate',
          icon: Icons.pie_chart_rounded,
          color: AnalyticsTheme.primaryPurple,
          trend: '0.0%',
          trendUp: true,
        ),
      ],
    );
  }

  Widget _buildRevenueChart(ReportsProvider provider) {
    if (provider.monthlyRevenue.isEmpty) {
      return _buildEmptyState('No revenue data available');
    }

    final data = provider.monthlyRevenue;
    final maxY =
        data.fold(0.0, (acc, e) => e.revenue > acc ? e.revenue : acc) * 1.2;

    return Container(
      height: 320,
      padding: const EdgeInsets.all(AnalyticsTheme.spacingL),
      decoration: BoxDecoration(
        color: AnalyticsTheme.cardWhite,
        borderRadius: BorderRadius.circular(AnalyticsTheme.radiusL),
        boxShadow: AnalyticsTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildLegend('Company Revenue', AnalyticsTheme.primaryBlue),
              const SizedBox(width: AnalyticsTheme.spacingM),
              _buildLegend('Driver Payouts', AnalyticsTheme.primaryRed),
            ],
          ),
          const SizedBox(height: AnalyticsTheme.spacingL),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AnalyticsTheme.borderLight,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              data[value.toInt()].month,
                              style: AnalyticsTheme.bodySmall,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          AnalyticsTheme.formatCurrency(value),
                          style: AnalyticsTheme.bodySmall.copyWith(
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.revenue);
                    }).toList(),
                    isCurved: true,
                    color: AnalyticsTheme.primaryBlue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AnalyticsTheme.cardWhite,
                          strokeWidth: 2,
                          strokeColor: AnalyticsTheme.primaryBlue,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AnalyticsTheme.primaryBlue.withOpacity(0.2),
                          AnalyticsTheme.primaryBlue.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.expenses);
                    }).toList(),
                    isCurved: true,
                    color: AnalyticsTheme.primaryRed,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AnalyticsTheme.cardWhite,
                          strokeWidth: 2,
                          strokeColor: AnalyticsTheme.primaryRed,
                        );
                      },
                    ),
                  ),
                ],
                maxY: maxY,
                minY: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentStatusChart(ReportsProvider provider) {
    if (provider.shipmentStats.isEmpty) {
      return _buildEmptyState('No shipment data');
    }

    final total = provider.shipmentStats.fold(0, (sum, e) => sum + e.count);

    return Container(
      height: 360,
      padding: const EdgeInsets.all(AnalyticsTheme.spacingL),
      decoration: BoxDecoration(
        color: AnalyticsTheme.cardWhite,
        borderRadius: BorderRadius.circular(AnalyticsTheme.radiusL),
        boxShadow: AnalyticsTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Status Distribution', style: AnalyticsTheme.headingSmall),
          const SizedBox(height: AnalyticsTheme.spacingXS),
          Text(
            'Total: ${AnalyticsTheme.formatNumber(total)} orders',
            style: AnalyticsTheme.bodySmall,
          ),
          const SizedBox(height: AnalyticsTheme.spacingL),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: provider.shipmentStats.map((stat) {
                        final percentage = (stat.count / total * 100);
                        return PieChartSectionData(
                          color: AnalyticsTheme.getStatusColor(stat.status),
                          value: stat.count.toDouble(),
                          title: '${percentage.toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: AnalyticsTheme.spacingM),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: provider.shipmentStats
                        .map(
                          (stat) => Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AnalyticsTheme.spacingXS,
                            ),
                            child: _buildLegendWithCount(
                              stat.status,
                              AnalyticsTheme.getStatusColor(stat.status),
                              stat.count,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionChart(ReportsProvider provider) {
    if (provider.shipmentByRegion.isEmpty) {
      return _buildEmptyState('No region data');
    }

    final maxVal = provider.shipmentByRegion
        .fold(0, (acc, e) => e.count > acc ? e.count : acc)
        .toDouble();

    return Container(
      height: 360,
      padding: const EdgeInsets.all(AnalyticsTheme.spacingL),
      decoration: BoxDecoration(
        color: AnalyticsTheme.cardWhite,
        borderRadius: BorderRadius.circular(AnalyticsTheme.radiusL),
        boxShadow: AnalyticsTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Regions', style: AnalyticsTheme.headingSmall),
          const SizedBox(height: AnalyticsTheme.spacingXS),
          Text(
            'Shipment distribution by location',
            style: AnalyticsTheme.bodySmall,
          ),
          const SizedBox(height: AnalyticsTheme.spacingL),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AnalyticsTheme.textDark,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${provider.shipmentByRegion[groupIndex].region}\n${rod.toY.toInt()} shipments',
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
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < provider.shipmentByRegion.length) {
                          final region =
                              provider.shipmentByRegion[value.toInt()].region;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              region.length > 8
                                  ? region.substring(0, 8)
                                  : region,
                              style: AnalyticsTheme.bodySmall,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AnalyticsTheme.borderLight,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: provider.shipmentByRegion.asMap().entries.map((
                  entry,
                ) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.count.toDouble(),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AnalyticsTheme.primaryIndigo,
                            AnalyticsTheme.primaryPurple,
                          ],
                        ),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AnalyticsTheme.radiusS),
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
              Icons.analytics_outlined,
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

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AnalyticsTheme.spacingS),
        Text(label, style: AnalyticsTheme.bodySmall),
      ],
    );
  }

  Widget _buildLegendWithCount(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AnalyticsTheme.spacingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AnalyticsTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AnalyticsTheme.textMedium,
                ),
              ),
              Text(count.toString(), style: AnalyticsTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String trend;
  final bool trendUp;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.trend,
    required this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(AnalyticsTheme.spacingL),
      decoration: BoxDecoration(
        color: AnalyticsTheme.cardWhite,
        borderRadius: BorderRadius.circular(AnalyticsTheme.radiusL),
        boxShadow: AnalyticsTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AnalyticsTheme.radiusM),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AnalyticsTheme.spacingS,
                  vertical: AnalyticsTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color:
                      (trendUp
                              ? AnalyticsTheme.primaryGreen
                              : AnalyticsTheme.primaryRed)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AnalyticsTheme.radiusS),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: trendUp
                          ? AnalyticsTheme.primaryGreen
                          : AnalyticsTheme.primaryRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: trendUp
                            ? AnalyticsTheme.primaryGreen
                            : AnalyticsTheme.primaryRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AnalyticsTheme.spacingM),
          Text(
            value,
            style: AnalyticsTheme.headingMedium.copyWith(fontSize: 24),
          ),
          const SizedBox(height: AnalyticsTheme.spacingXS),
          Text(title, style: AnalyticsTheme.bodyMedium),
          Text(subtitle, style: AnalyticsTheme.bodySmall),
        ],
      ),
    );
  }
}
