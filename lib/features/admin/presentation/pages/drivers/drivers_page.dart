import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../base_module_page.dart';
import '../../providers/driver_provider.dart';
import '../../../domain/models/driver_model.dart';

class DriversPage extends StatelessWidget {
  const DriversPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseModulePage(
      title: 'Drivers Management',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Add Driver button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Driver Roster',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                FilledButton.icon(
                  onPressed: () => context.go('/admin/drivers/add'),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Add Driver'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and filter bar
            _buildSearchAndFilter(),
            const SizedBox(height: 16),

            // Driver status tabs
            DefaultTabController(
              length: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Active'),
                      Tab(text: 'On Leave'),
                      Tab(text: 'Inactive'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: TabBarView(
                      children: [
                        _buildDriverList(context, 'all'),
                        _buildDriverList(context, 'active'),
                        _buildDriverList(context, 'on_leave'),
                        _buildDriverList(context, 'inactive'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick Stats
            const SizedBox(height: 24),
            Text(
              'Driver Performance',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                _PerformanceCard(
                  title: 'On Time Delivery',
                  value: '92%',
                  trend: 2.5,
                  color: Colors.green,
                ),
                SizedBox(width: 16),
                _PerformanceCard(
                  title: 'Safety Score',
                  value: '4.8/5',
                  trend: 0.3,
                  color: Colors.blue,
                ),
                SizedBox(width: 16),
                _PerformanceCard(
                  title: 'Fuel Efficiency',
                  value: '7.8 L/100km',
                  trend: -1.2,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Consumer<DriverProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search drivers...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: provider.setSearchQuery,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Advanced filters coming soon'),
                  ),
                );
              },
              icon: const Icon(Icons.filter_list),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[200],
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDriverList(BuildContext context, String statusFilter) {
    return Consumer<DriverProvider>(
      builder: (context, provider, _) {
        provider.setStatusFilter(statusFilter);
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final drivers = provider.filteredDrivers;
        if (drivers.isEmpty) {
          return const Center(child: Text('No drivers found'));
        }
        return ListView.separated(
          itemCount: drivers.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final driver = drivers[index];
            return _DriverListTile(driver: driver);
          },
        );
      },
    );
  }

}

class _DriverListTile extends StatelessWidget {
  const _DriverListTile({required this.driver});

  final Driver driver;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 0,
      ),
      leading: CircleAvatar(
        radius: 24,
        child: Text(
          driver.name.isNotEmpty ? driver.name[0] : '?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        driver.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'ID: ${driver.id}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(driver.statusDisplayText.toLowerCase())
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              driver.statusDisplayText,
              style: TextStyle(
                color:
                    _getStatusColor(driver.statusDisplayText.toLowerCase()),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () => _showActionsMenu(context, driver),
          ),
        ],
      ),
      onTap: () => context.go('/admin/drivers/${driver.id}'),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'on leave':
        return Colors.orange;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Future<void> _showActionsMenu(BuildContext context, Driver driver) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/admin/drivers/${driver.id}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Driver'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/admin/drivers/${driver.id}/edit');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete Driver',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  final provider = context.read<DriverProvider>();
                  final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Driver'),
                            content: Text(
                              'Are you sure you want to delete ${driver.name}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      ) ??
                      false;

                  if (!confirmed) return;

                  await provider.deleteDriver(driver.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Driver ${driver.name} deleted'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final String title;
  final String value;
  final double trend;
  final Color color;

  const _PerformanceCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    trend >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: trend >= 0 ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  Text(
                    '${trend.abs()}%',
                    style: TextStyle(
                      color: trend >= 0 ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: trend / 10 + 0.5, // Just for demo
                backgroundColor: color.withValues(alpha: 0.1),
                color: color,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
