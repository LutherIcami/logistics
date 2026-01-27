import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/shipment_provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/admin_module_card.dart';
import '../widgets/admin_stat_card.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();
    final shipmentProvider = context.watch<ShipmentProvider>();
    final financeProvider = context.watch<FinanceProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Stats
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  AdminStatCard(
                    title: 'Active Trucks',
                    value: '${vehicleProvider.activeVehiclesCount}',
                    icon: Icons.local_shipping,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  AdminStatCard(
                    title: 'Revenue (M)',
                    value:
                        'KES ${financeProvider.totalRevenue.toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  AdminStatCard(
                    title: 'Pending Jobs',
                    value: '${shipmentProvider.pendingCount}',
                    icon: Icons.assignment_late,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  AdminStatCard(
                    title: 'Alerts',
                    value:
                        '${vehicleProvider.vehiclesNeedingMaintenance.length}',
                    icon: Icons.warning,
                    color: Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Modules Grid
            Text(
              'Management Modules',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                AdminModuleCard(
                  title: 'Fleet Management',
                  subtitle: 'Manage trucks, trailers, and maintenance.',
                  icon: Icons.local_shipping,
                  color: Colors.blue,
                  onTap: () => context.go('/admin/fleet'),
                ),
                AdminModuleCard(
                  title: 'Drivers',
                  subtitle: 'Onboard drivers, view schedules and performance.',
                  icon: Icons.people,
                  color: Colors.orange,
                  onTap: () => context.go('/admin/drivers'),
                ),
                AdminModuleCard(
                  title: 'Shipments',
                  subtitle: 'Create orders, track deliveries, assign loads.',
                  icon: Icons.inventory_2,
                  color: Colors.purple,
                  onTap: () => context.go('/admin/shipments'),
                ),
                AdminModuleCard(
                  title: 'Customers',
                  subtitle: 'Client database, contracts, and pricing.',
                  icon: Icons.business,
                  color: Colors.teal,
                  onTap: () => context.go('/admin/customers'),
                ),
                AdminModuleCard(
                  title: 'Finance',
                  subtitle: 'Invoicing, expenses, and payroll.',
                  icon: Icons.attach_money,
                  color: Colors.green,
                  onTap: () => context.go('/admin/finance'),
                ),
                AdminModuleCard(
                  title: 'Reports & Analytics',
                  subtitle: 'View detailed system performance reports.',
                  icon: Icons.bar_chart,
                  color: Colors.indigo,
                  onTap: () => context.go('/admin/reports'),
                ),
                AdminModuleCard(
                  title: 'System Settings',
                  subtitle: 'Configure app settings and user roles.',
                  icon: Icons.settings,
                  color: Colors.grey,
                  onTap: () => context.go('/admin/settings'),
                ),
                AdminModuleCard(
                  title: 'Support',
                  subtitle: 'Help center and tickets.',
                  icon: Icons.help_outline,
                  color: Colors.redAccent,
                  onTap: () => context.go('/admin/support'),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
