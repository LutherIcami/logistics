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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/admin/drivers/add'),
        backgroundColor: const Color(0xFF1E293B),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Driver', style: TextStyle(color: Colors.white)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Controls
            const Text(
              'Driver Operations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _buildSearchAndFilter(),
            const SizedBox(height: 32),

            // Performance Section
            const Text(
              'Staff Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  _PerformanceCard(
                    title: 'On-Time Performance',
                    value: '94.2%',
                    trend: '+2.5%',
                    icon: Icons.timer_rounded,
                    color: Colors.green,
                  ),
                  SizedBox(width: 16),
                  _PerformanceCard(
                    title: 'System Safety Score',
                    value: '4.85 / 5',
                    trend: '+0.3%',
                    icon: Icons.verified_user_rounded,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 16),
                  _PerformanceCard(
                    title: 'Avg. Fuel Economy',
                    value: '18.4 mpg',
                    trend: '-1.2%',
                    icon: Icons.local_gas_station_rounded,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Driver status tabs
            const Text(
              'Active Roster',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            DefaultTabController(
              length: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: const Color(0xFF1E293B),
                    unselectedLabelColor: Colors.grey[500],
                    indicatorColor: const Color(0xFF1E293B),
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(text: 'All Staff'),
                      Tab(text: 'Active'),
                      Tab(text: 'On Leave'),
                      Tab(text: 'Inactive'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 500, // Fixed height for tab content
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
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Consumer<DriverProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search by name or ID...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.blue),
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune_rounded, color: Colors.grey),
                onPressed: () {},
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDriverList(BuildContext context, String statusFilter) {
    return Consumer<DriverProvider>(
      builder: (context, provider, _) {
        final drivers = provider.getMappedDrivers(statusFilter);
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (drivers.isEmpty) {
          return Center(
            child: Text(
              'No staff records found in this category.',
              style: TextStyle(color: Colors.grey[400]),
            ),
          );
        }
        return ListView.builder(
          physics:
              const NeverScrollableScrollPhysics(), // Handled by parent scroll
          itemCount: drivers.length,
          itemBuilder: (context, index) {
            return _DriverListItem(driver: drivers[index]);
          },
        );
      },
    );
  }
}

class _DriverListItem extends StatelessWidget {
  final Driver driver;
  const _DriverListItem({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => context.go('/admin/drivers/${driver.id}'),
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              driver.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          driver.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          driver.email,
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(driver.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            driver.status.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(driver.status),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'on_leave':
        return Colors.orange;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _PerformanceCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;

  const _PerformanceCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  trend,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: trend.startsWith('+') ? Colors.green : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
