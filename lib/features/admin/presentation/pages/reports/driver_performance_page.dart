import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reports_provider.dart';
import '../../../domain/models/report_models.dart';
import 'analytics_theme.dart';

class DriverPerformancePage extends StatefulWidget {
  const DriverPerformancePage({super.key});

  @override
  State<DriverPerformancePage> createState() => _DriverPerformancePageState();
}

class _DriverPerformancePageState extends State<DriverPerformancePage> {
  String _selectedFilter = 'all';

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
        title: const Text('Driver Performance'),
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
                    color: AnalyticsTheme.primaryIndigo,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading driver data...',
                    style: AnalyticsTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final filteredDrivers = _getFilteredDrivers(
            provider.driverPerformance,
          );

          return RefreshIndicator(
            onRefresh: () => provider.loadReports(),
            color: AnalyticsTheme.primaryIndigo,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AnalyticsTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AnalyticsTheme.spacingXL),
                  _buildFilterChips(),
                  const SizedBox(height: AnalyticsTheme.spacingL),
                  if (filteredDrivers.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredDrivers.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AnalyticsTheme.spacingM),
                      itemBuilder: (context, index) {
                        return _DriverPerformanceCard(
                          driver: filteredDrivers[index],
                        );
                      },
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
        Text('Staff Proficiency', style: AnalyticsTheme.headingLarge),
        const SizedBox(height: AnalyticsTheme.spacingXS),
        Text(
          'Driver safety scores and punctuality metrics',
          style: AnalyticsTheme.bodyMedium,
        ),
      ],
    );
  }

  List<DriverPerformanceStat> _getFilteredDrivers(
    List<DriverPerformanceStat> all,
  ) {
    if (_selectedFilter == 'all') return all;
    if (_selectedFilter == 'top') {
      return all.where((d) => d.rating >= 4.5).toList();
    }
    if (_selectedFilter == 'good') {
      return all.where((d) => d.rating >= 4.0 && d.rating < 4.5).toList();
    }
    if (_selectedFilter == 'needs_improvement') {
      return all.where((d) => d.rating < 4.0).toList();
    }
    return all;
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All Drivers',
            isSelected: _selectedFilter == 'all',
            onTap: () => setState(() => _selectedFilter = 'all'),
            color: AnalyticsTheme.primaryIndigo,
          ),
          const SizedBox(width: AnalyticsTheme.spacingS),
          _FilterChip(
            label: 'Top Performers',
            isSelected: _selectedFilter == 'top',
            onTap: () => setState(() => _selectedFilter = 'top'),
            color: AnalyticsTheme.primaryGreen,
          ),
          const SizedBox(width: AnalyticsTheme.spacingS),
          _FilterChip(
            label: 'Good',
            isSelected: _selectedFilter == 'good',
            onTap: () => setState(() => _selectedFilter = 'good'),
            color: AnalyticsTheme.primaryBlue,
          ),
          const SizedBox(width: AnalyticsTheme.spacingS),
          _FilterChip(
            label: 'Needs Improvement',
            isSelected: _selectedFilter == 'needs_improvement',
            onTap: () => setState(() => _selectedFilter = 'needs_improvement'),
            color: AnalyticsTheme.primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
              Icons.people_outline,
              size: 48,
              color: AnalyticsTheme.textLight,
            ),
            const SizedBox(height: AnalyticsTheme.spacingM),
            Text('No drivers found', style: AnalyticsTheme.bodyMedium),
            const SizedBox(height: AnalyticsTheme.spacingS),
            Text(
              _selectedFilter == 'all'
                  ? 'No drivers in the system yet. Add drivers to see performance data.'
                  : 'Try adjusting your filters or add more drivers',
              style: AnalyticsTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AnalyticsTheme.spacingM),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to drivers page or show add driver dialog
                Navigator.pop(context);
              },
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Go to Drivers'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AnalyticsTheme.primaryIndigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AnalyticsTheme.spacingL,
                  vertical: AnalyticsTheme.spacingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AnalyticsTheme.radiusM),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AnalyticsTheme.radiusL),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AnalyticsTheme.spacingM,
            vertical: AnalyticsTheme.spacingS,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color : AnalyticsTheme.cardWhite,
            borderRadius: BorderRadius.circular(AnalyticsTheme.radiusL),
            border: Border.all(
              color: isSelected ? color : AnalyticsTheme.borderLight,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? AnalyticsTheme.cardShadow : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AnalyticsTheme.textMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverPerformanceCard extends StatelessWidget {
  final DriverPerformanceStat driver;

  const _DriverPerformanceCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    final ratingColor = _getRatingColor(driver.rating);

    return Container(
      padding: const EdgeInsets.all(AnalyticsTheme.spacingL),
      decoration: BoxDecoration(
        color: AnalyticsTheme.cardWhite,
        borderRadius: BorderRadius.circular(AnalyticsTheme.radiusL),
        boxShadow: AnalyticsTheme.cardShadow,
        border: Border.all(color: ratingColor.withOpacity(0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [ratingColor, ratingColor.withOpacity(0.7)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ratingColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    driver.driverName.isNotEmpty
                        ? driver.driverName[0].toUpperCase()
                        : 'D',
                    style: const TextStyle(
                      fontSize: 24,
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
                    Text(driver.driverName, style: AnalyticsTheme.headingSmall),
                    const SizedBox(height: AnalyticsTheme.spacingXS),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 18, color: ratingColor),
                        const SizedBox(width: 4),
                        Text(
                          driver.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: ratingColor,
                          ),
                        ),
                        const SizedBox(width: AnalyticsTheme.spacingS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AnalyticsTheme.spacingS,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: ratingColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AnalyticsTheme.radiusS,
                            ),
                          ),
                          child: Text(
                            _getRatingLabel(driver.rating),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: ratingColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AnalyticsTheme.spacingL),
          Container(
            padding: const EdgeInsets.all(AnalyticsTheme.spacingM),
            decoration: BoxDecoration(
              color: AnalyticsTheme.backgroundGray,
              borderRadius: BorderRadius.circular(AnalyticsTheme.radiusM),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.local_shipping_rounded,
                    label: 'Trips',
                    value: driver.tripsCompleted.toString(),
                    color: AnalyticsTheme.primaryBlue,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AnalyticsTheme.borderLight,
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.check_circle_rounded,
                    label: 'On-Time',
                    value: AnalyticsTheme.formatPercentage(driver.onTimeRate),
                    color: AnalyticsTheme.primaryGreen,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AnalyticsTheme.borderLight,
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.shield_rounded,
                    label: 'Safety',
                    value: _getSafetyScore(driver).toStringAsFixed(1),
                    color: AnalyticsTheme.primaryOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    return AnalyticsTheme.getRatingColor(rating);
  }

  String _getRatingLabel(double rating) {
    if (rating >= 4.5) return 'EXCELLENT';
    if (rating >= 4.0) return 'GOOD';
    if (rating >= 3.5) return 'AVERAGE';
    return 'NEEDS WORK';
  }

  double _getSafetyScore(DriverPerformanceStat driver) {
    // Calculate safety score: start at 5.0, subtract 0.5 for each incident
    final score = 5.0 - (driver.safetyIncidents * 0.5);
    return score < 0.0 ? 0.0 : score;
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: AnalyticsTheme.spacingXS),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AnalyticsTheme.textDark,
          ),
        ),
        Text(label, style: AnalyticsTheme.bodySmall),
      ],
    );
  }
}
