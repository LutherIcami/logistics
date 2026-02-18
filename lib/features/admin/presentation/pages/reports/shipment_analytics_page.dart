import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reports_provider.dart';
import 'analytics_theme.dart';

class ShipmentAnalyticsPage extends StatefulWidget {
  const ShipmentAnalyticsPage({super.key});

  @override
  State<ShipmentAnalyticsPage> createState() => _ShipmentAnalyticsPageState();
}

class _ShipmentAnalyticsPageState extends State<ShipmentAnalyticsPage> {
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
        title: const Text('Shipment Analytics'),
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
                  CircularProgressIndicator(color: AnalyticsTheme.primaryBlue),
                  const SizedBox(height: 16),
                  Text(
                    'Loading shipment data...',
                    style: AnalyticsTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final total = provider.shipmentStats.fold(
            0,
            (sum, e) => sum + e.count,
          );

          return RefreshIndicator(
            onRefresh: () => provider.loadReports(),
            color: AnalyticsTheme.primaryBlue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AnalyticsTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AnalyticsTheme.spacingXL),

                  // KPI Cards
                  _buildKPIRow(provider, total),
                  const SizedBox(height: AnalyticsTheme.spacingXL),

                  // Charts Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildStatusPieChart(provider, total)),
                      const SizedBox(width: AnalyticsTheme.spacingL),
                      Expanded(child: _buildRegionBarChart(provider)),
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
        Text('Shipment Velocity', style: AnalyticsTheme.headingLarge),
        const SizedBox(height: AnalyticsTheme.spacingXS),
        Text(
          'Transit times and delivery success rates',
          style: AnalyticsTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildKPIRow(ReportsProvider provider, int total) {
    final delivered = provider.shipmentStats
        .firstWhere(
          (s) => s.status.toLowerCase() == 'delivered',
          orElse: () => provider.shipmentStats.first,
        )
        .count;
    final successRate = total > 0 ? (delivered / total) : 0.0;

    return Wrap(
      spacing: AnalyticsTheme.spacingM,
      runSpacing: AnalyticsTheme.spacingM,
      children: [
        _StatCard(
          title: 'Total Shipments',
          value: AnalyticsTheme.formatNumber(total),
          icon: Icons.local_shipping_rounded,
          color: AnalyticsTheme.primaryBlue,
          subtitle: 'All time',
        ),
        _StatCard(
          title: 'Avg Delivery Time',
          value: '${provider.avgDeliveryTimeHours.toStringAsFixed(1)}h',
          icon: Icons.schedule_rounded,
          color: AnalyticsTheme.primaryOrange,
          subtitle: 'Hours',
        ),
        _StatCard(
          title: 'On-Time Rate',
          value: AnalyticsTheme.formatPercentage(provider.overallOnTimeRate),
          icon: Icons.check_circle_rounded,
          color: AnalyticsTheme.primaryGreen,
          subtitle: 'Performance',
        ),
        _StatCard(
          title: 'Success Rate',
          value: AnalyticsTheme.formatPercentage(successRate),
          icon: Icons.verified_rounded,
          color: AnalyticsTheme.primaryPurple,
          subtitle: 'Completed',
        ),
      ],
    );
  }

  Widget _buildStatusPieChart(ReportsProvider provider, int total) {
    if (provider.shipmentStats.isEmpty) {
      return _buildEmptyState('No status data available');
    }

    return Container(
      height: 400,
      padding: const EdgeInsets.all(AnalyticsTheme.spacingL),
      decoration: BoxDecoration(
        color: AnalyticsTheme.cardWhite,
        borderRadius: BorderRadius.circular(AnalyticsTheme.radiusL),
        boxShadow: AnalyticsTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Distribution', style: AnalyticsTheme.headingSmall),
          const SizedBox(height: AnalyticsTheme.spacingXS),
          Text('Breakdown by order status', style: AnalyticsTheme.bodySmall),
          const SizedBox(height: AnalyticsTheme.spacingL),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 60,
                      sections: provider.shipmentStats.map((stat) {
                        final percentage = (stat.count / total * 100);
                        return PieChartSectionData(
                          color: AnalyticsTheme.getStatusColor(stat.status),
                          value: stat.count.toDouble(),
                          title: '${percentage.toStringAsFixed(0)}%',
                          radius: 70,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 2),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: AnalyticsTheme.spacingL),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: provider.shipmentStats
                        .map(
                          (stat) => Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AnalyticsTheme.spacingS,
                            ),
                            child: _Indicator(
                              color: AnalyticsTheme.getStatusColor(stat.status),
                              text: stat.status,
                              count: stat.count,
                              percentage: (stat.count / total * 100),
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

  Widget _buildRegionBarChart(ReportsProvider provider) {
    if (provider.shipmentByRegion.isEmpty) {
      return _buildEmptyState('No region data available');
    }

    final maxVal = provider.shipmentByRegion
        .fold(0, (acc, e) => e.count > acc ? e.count : acc)
        .toDouble();

    return Container(
      height: 400,
      padding: const EdgeInsets.all(AnalyticsTheme.spacingL),
      decoration: BoxDecoration(
        color: AnalyticsTheme.cardWhite,
        borderRadius: BorderRadius.circular(AnalyticsTheme.radiusL),
        boxShadow: AnalyticsTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Regional Performance', style: AnalyticsTheme.headingSmall),
          const SizedBox(height: AnalyticsTheme.spacingXS),
          Text('Shipments by destination', style: AnalyticsTheme.bodySmall),
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
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AnalyticsTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < provider.shipmentByRegion.length) {
                          final region =
                              provider.shipmentByRegion[value.toInt()].region;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              region.length > 10
                                  ? '${region.substring(0, 10)}...'
                                  : region,
                              style: AnalyticsTheme.bodySmall,
                              textAlign: TextAlign.center,
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
                            AnalyticsTheme.primaryBlue,
                            AnalyticsTheme.primaryCyan,
                          ],
                        ),
                        width: 24,
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
      height: 300,
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
              Icons.inventory_2_outlined,
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(AnalyticsTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(AnalyticsTheme.radiusL),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: AnalyticsTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AnalyticsTheme.radiusM),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: AnalyticsTheme.spacingM),
          Text(
            value,
            style: AnalyticsTheme.headingMedium.copyWith(
              fontSize: 28,
              color: color,
            ),
          ),
          const SizedBox(height: AnalyticsTheme.spacingXS),
          Text(title, style: AnalyticsTheme.bodyMedium),
          Text(subtitle, style: AnalyticsTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final int count;
  final double percentage;

  const _Indicator({
    required this.color,
    required this.text,
    required this.count,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AnalyticsTheme.spacingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: AnalyticsTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AnalyticsTheme.textMedium,
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: AnalyticsTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
