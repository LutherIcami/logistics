import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/shipment_provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/admin_module_card.dart';
import '../widgets/admin_stat_card.dart';
import '../../../../core/widgets/profile_completion_banner.dart';

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
          const SliverToBoxAdapter(child: ProfileCompletionBanner()),
          _buildAppBar(context, user),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Network Vitals'),
                  const SizedBox(height: 16),
                  _buildVitalsRow(
                    vehicleProvider,
                    financeProvider,
                    shipmentProvider,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Priority Directives'),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Operational Command'),
                  const SizedBox(height: 16),
                  _buildModuleGrid(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Live Terminal Activity'),
                  const SizedBox(height: 16),
                  _buildActivityFeed(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, dynamic user) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF0F172A),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.dashboard_customize_rounded,
                  size: 200,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'LOGISTICS COMMAND CENTER',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Universal Terminal',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    Text(
                      user?.fullName ?? 'Fleet Commander',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
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
            Icons.notifications_none_rounded,
            color: Colors.white70,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.power_settings_new_rounded,
            color: Colors.redAccent,
          ),
          onPressed: () {
            context.read<AuthProvider>().logout();
            context.go('/login');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildVitalsRow(
    VehicleProvider vp,
    FinanceProvider fp,
    ShipmentProvider sp,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          AdminStatCard(
            title: 'Fleet Ready',
            value: '${vp.activeVehiclesCount} Units',
            icon: Icons.local_shipping_rounded,
            color: Colors.blue,
          ),
          const SizedBox(width: 16),
          AdminStatCard(
            title: 'Gross Revenue',
            value: 'KES ${fp.totalRevenue.toStringAsFixed(0)}',
            icon: Icons.account_balance_wallet_rounded,
            color: Colors.green,
          ),
          const SizedBox(width: 16),
          AdminStatCard(
            title: 'Queued Loads',
            value: '${sp.pendingCount} Pending',
            icon: Icons.inventory_2_rounded,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _QuickActionBtn(
          icon: Icons.add_task_rounded,
          label: 'Assign Trip',
          onTap: () => context.go('/admin/shipments'),
          color: Colors.indigo,
        ),
        const SizedBox(width: 12),
        _QuickActionBtn(
          icon: Icons.person_add_alt_1_rounded,
          label: 'Deploy Driver',
          onTap: () => context.push('/admin/drivers/new'),
          color: Colors.teal,
        ),
        const SizedBox(width: 12),
        _QuickActionBtn(
          icon: Icons.post_add_rounded,
          label: 'New Invoice',
          onTap: () => context.go('/admin/finance'),
          color: Colors.amber[700]!,
        ),
      ],
    );
  }

  Widget _buildModuleGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        AdminModuleCard(
          title: 'Fleet & Assets',
          subtitle: 'Maintenance & diagnostics',
          icon: Icons.token_rounded,
          color: Colors.blue,
          onTap: () => context.go('/admin/fleet'),
        ),
        AdminModuleCard(
          title: 'Operations Staff',
          subtitle: 'Driver pool management',
          icon: Icons.shield_rounded,
          color: Colors.orange,
          onTap: () => context.go('/admin/drivers'),
        ),
        AdminModuleCard(
          title: 'Directives',
          subtitle: 'Shipment & load control',
          icon: Icons.radar_rounded,
          color: Colors.purple,
          onTap: () => context.go('/admin/shipments'),
        ),
        AdminModuleCard(
          title: 'Financials',
          subtitle: 'Revenue & ledger',
          icon: Icons.account_tree_rounded,
          color: Colors.green,
          onTap: () => context.go('/admin/finance'),
        ),
      ],
    );
  }

  Widget _buildActivityFeed() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _ActivityItem(
            icon: Icons.check_circle_rounded,
            color: Colors.green,
            title: 'Trip #KJ-908 Completed',
            time: '2 mins ago',
            user: 'Driver Mutua',
          ),
          const Divider(height: 1, indent: 64),
          _ActivityItem(
            icon: Icons.local_shipping_rounded,
            color: Colors.blue,
            title: 'Fleet Expand: New Vehicle',
            time: '15 mins ago',
            user: 'Manager Sarah',
          ),
          const Divider(height: 1, indent: 64),
          _ActivityItem(
            icon: Icons.warning_rounded,
            color: Colors.orange,
            title: 'Maintenance Alert: KCB 123X',
            time: '1 hour ago',
            user: 'System Bot',
          ),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String time;
  final String user;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.time,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'By $user • $time',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
