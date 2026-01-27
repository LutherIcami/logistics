import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reports_provider.dart';
import '../../../domain/models/report_models.dart';

class DriverPerformancePage extends StatefulWidget {
  const DriverPerformancePage({super.key});

  @override
  State<DriverPerformancePage> createState() => _DriverPerformancePageState();
}

class _DriverPerformancePageState extends State<DriverPerformancePage> {
  String _filter = 'All'; // All, Top Rated, High Volume

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Performance')),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredDrivers = _getFilteredDrivers(
            provider.driverPerformance,
          );

          return Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDrivers.length,
                  itemBuilder: (context, index) {
                    final driver = filteredDrivers[index];
                    return _DriverPerformanceCard(driver: driver);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<DriverPerformanceStat> _getFilteredDrivers(
    List<DriverPerformanceStat> all,
  ) {
    final list = List<DriverPerformanceStat>.from(all);
    if (_filter == 'Top Rated') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
      return list.take(10).toList();
    } else if (_filter == 'High Volume') {
      list.sort((a, b) => b.tripsCompleted.compareTo(a.tripsCompleted));
      return list.take(10).toList();
    }
    return list; // Return original order (probably default sort)
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: _filter == 'All',
            onTap: () => setState(() => _filter = 'All'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Top Rated',
            isSelected: _filter == 'Top Rated',
            onTap: () => setState(() => _filter = 'Top Rated'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'High Volume',
            isSelected: _filter == 'High Volume',
            onTap: () => setState(() => _filter = 'High Volume'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getRatingColor(
                    driver.rating,
                  ).withValues(alpha: 0.1),
                  child: Text(
                    driver.driverName[0],
                    style: TextStyle(
                      fontSize: 20,
                      color: _getRatingColor(driver.rating),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.driverName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'ID: ${driver.driverId}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        driver.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  label: 'Trips',
                  value: driver.tripsCompleted.toString(),
                ),
                _StatItem(
                  label: 'On-Time',
                  value: '${(driver.onTimeRate * 100).toStringAsFixed(0)}%',
                ),
                _StatItem(
                  label: 'Earnings',
                  value: 'KES ${(driver.earning / 1000).toStringAsFixed(1)}k',
                ),
                _StatItem(
                  label: 'Safety',
                  value: driver.safetyIncidents.toString(),
                  valueColor: driver.safetyIncidents > 0
                      ? Colors.red
                      : Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 3.5) return Colors.orange;
    return Colors.red;
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: valueColor,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
