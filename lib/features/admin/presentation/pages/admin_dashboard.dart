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
    final authProvider = context.watch<AuthProvider>();

    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1E293B),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E293B), Color(0xFF334155)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Icon(
                        Icons.local_shipping,
                        size: 200,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Logos Logistics',
                            style: TextStyle(
                              color: Colors.blue[400],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Welcome, ${user?.fullName ?? 'Admin'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your distribution fleet and operations.',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  context.go('/login');
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Overview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Operations Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/admin/reports'),
                        child: const Text('View Reports'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        AdminStatCard(
                          title: 'Available Fleet',
                          value:
                              '${vehicleProvider.activeVehiclesCount} Active',
                          icon: Icons.local_shipping_rounded,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        AdminStatCard(
                          title: 'Revenue Today',
                          value:
                              'KES ${financeProvider.totalRevenue.toStringAsFixed(0)}',
                          icon: Icons.account_balance_wallet_rounded,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 16),
                        AdminStatCard(
                          title: 'Awaiting Shipment',
                          value: '${shipmentProvider.pendingCount} Pending',
                          icon: Icons.pending_actions_rounded,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 16),
                        AdminStatCard(
                          title: 'Fleet Alerts',
                          value:
                              '${vehicleProvider.vehiclesNeedingMaintenance.length} High',
                          icon: Icons.error_outline_rounded,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Grid Section
                  const Text(
                    'Administrative Controls',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15,
                    children: [
                      AdminModuleCard(
                        title: 'Fleet & Assets',
                        subtitle: 'Monitor truck status and maintenance logs.',
                        icon: Icons.inventory_rounded,
                        color: Colors.blue,
                        onTap: () => context.go('/admin/fleet'),
                      ),
                      AdminModuleCard(
                        title: 'Operational Staff',
                        subtitle: 'Manage drivers and performance cycles.',
                        icon: Icons.supervised_user_circle_rounded,
                        color: Colors.orange,
                        onTap: () => context.go('/admin/drivers'),
                      ),
                      AdminModuleCard(
                        title: 'Delivery Management',
                        subtitle: 'Assign loads and real-time tracking.',
                        icon: Icons.route_rounded,
                        color: Colors.purple,
                        onTap: () => context.go('/admin/shipments'),
                      ),
                      AdminModuleCard(
                        title: 'Business Clients',
                        subtitle: 'Database of vendors and customers.',
                        icon: Icons.business_center_rounded,
                        color: Colors.teal,
                        onTap: () => context.go('/admin/customers'),
                      ),
                      AdminModuleCard(
                        title: 'Financial Ledger',
                        subtitle: 'Transaction history and payroll.',
                        icon: Icons.payments_rounded,
                        color: Colors.green,
                        onTap: () => context.go('/admin/finance'),
                      ),
                      AdminModuleCard(
                        title: 'Insight Analytics',
                        subtitle: 'Data-driven logical performance.',
                        icon: Icons.insights_rounded,
                        color: Colors.indigo,
                        onTap: () => context.go('/admin/reports'),
                      ),
                      AdminModuleCard(
                        title: 'System Config',
                        subtitle: 'Platform security and settings.',
                        icon: Icons.settings_applications_rounded,
                        color: Colors.blueGrey,
                        onTap: () => context.go('/admin/settings'),
                      ),
                      AdminModuleCard(
                        title: 'Support Hub',
                        subtitle: 'Get help or report system issues.',
                        icon: Icons.support_agent_rounded,
                        color: Colors.redAccent,
                        onTap: () => context.go('/admin/support'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
