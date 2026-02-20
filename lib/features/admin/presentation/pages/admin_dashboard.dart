import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/shipment_provider.dart';
import '../providers/finance_provider.dart';
import '../providers/driver_provider.dart';
import '../providers/admin_customer_provider.dart';
import '../widgets/admin_module_card.dart';
import '../widgets/admin_stat_card.dart';
import '../../../../core/widgets/profile_completion_banner.dart';
import '../../../../core/widgets/responsive.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();
    final shipmentProvider = context.watch<ShipmentProvider>();
    final financeProvider = context.watch<FinanceProvider>();
    final customerProvider = context.watch<AdminCustomerProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: ProfileCompletionBanner()),
          _buildAppBar(context, user),
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Network Vitals'),
                    const SizedBox(height: 16),
                    _buildVitalsRow(
                      context,
                      vehicleProvider,
                      financeProvider,
                      shipmentProvider,
                      customerProvider,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Field Intelligence'),
                    const SizedBox(height: 16),
                    _buildDriverStatusRow(context),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Priority Directives'),
                    const SizedBox(height: 16),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Operational Command'),
                              const SizedBox(height: 16),
                              _buildModuleGrid(context),
                            ],
                          ),
                        ),
                        if (Responsive.isDesktop(context)) ...[
                          const SizedBox(width: 32),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Live Terminal activity'),
                                const SizedBox(height: 16),
                                _buildActivityFeed(),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (!Responsive.isDesktop(context)) ...[
                      const SizedBox(height: 32),
                      _buildSectionTitle('Live Terminal activity'),
                      const SizedBox(height: 16),
                      _buildActivityFeed(),
                    ],
                    const SizedBox(height: 60),
                  ],
                ),
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
          icon: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.user;
              final showBadge =
                  user != null &&
                  !user.isProfileComplete &&
                  !authProvider.isNotificationRead('profile-incomplete');

              return Badge(
                label: showBadge ? const Text('1') : null,
                isLabelVisible: showBadge,
                backgroundColor: Colors.red,
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white70,
                ),
              );
            },
          ),
          onPressed: () => context.push('/admin/notifications'),
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
    BuildContext context,
    VehicleProvider vp,
    FinanceProvider fp,
    ShipmentProvider sp,
    AdminCustomerProvider cp,
  ) {
    var cards = [
      AdminStatCard(
        title: 'Queued Loads',
        value: '${sp.pendingCount} New',
        icon: Icons.inventory_2_rounded,
        color: Colors.orange,
        onTap: () => context.go('/admin/shipments'),
      ),
      AdminStatCard(
        title: 'Active Missions',
        value: '${sp.activeCount} In Transit',
        icon: Icons.radar_rounded,
        color: Colors.blue,
        onTap: () => context.go('/admin/shipments'),
      ),
      AdminStatCard(
        title: 'Personnel Ready',
        value: '${sp.assignedCount} Assigned',
        icon: Icons.person_pin_rounded,
        color: Colors.purple,
        onTap: () => context.go('/admin/drivers'),
      ),
      AdminStatCard(
        title: 'Client Net',
        value: '${cp.customerCount} Active',
        icon: Icons.people_alt_rounded,
        color: Colors.cyan,
        onTap: () => context.go('/admin/customers'),
      ),
    ];

    return Responsive(
      mobile: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: cards
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(width: 200, child: c),
                ),
              )
              .toList(),
        ),
      ),
      desktop: Row(
        children: cards
            .map(
              (c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: c,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDriverStatusRow(BuildContext context) {
    final driverProvider = context.watch<DriverProvider>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.online_prediction_rounded,
                        color: Colors.greenAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DRIVER NETWORK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Real-time connectivity status',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => context.go('/admin/drivers'),
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: const Text('MANAGE DRIVERS'),
                style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Responsive(
            mobile: Column(
              children: [
                _buildStatusItem(
                  context,
                  'Active Drivers',
                  '${driverProvider.activeDriversCount}',
                  Colors.green,
                  'active',
                ),
                const SizedBox(height: 12),
                _buildStatusItem(
                  context,
                  'Idle Personnel',
                  '${driverProvider.idleDriversCount}',
                  Colors.orange,
                  'idle',
                ),
                const SizedBox(height: 12),
                _buildStatusItem(
                  context,
                  'Offline/Off-duty',
                  '${driverProvider.offlineDriversCount}',
                  Colors.grey,
                  'offline',
                ),
              ],
            ),
            desktop: Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    context,
                    'Active Drivers',
                    '${driverProvider.activeDriversCount}',
                    Colors.greenAccent,
                    'active',
                  ),
                ),
                const VerticalDivider(color: Colors.white10),
                Expanded(
                  child: _buildStatusItem(
                    context,
                    'Idle Personnel',
                    '${driverProvider.idleDriversCount}',
                    Colors.orangeAccent,
                    'idle',
                  ),
                ),
                const VerticalDivider(color: Colors.white10),
                Expanded(
                  child: _buildStatusItem(
                    context,
                    'Offline/Off-duty',
                    '${driverProvider.offlineDriversCount}',
                    Colors.white30,
                    'offline',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          if (status != 'offline')
            InkWell(
              onTap: () {
                context.read<ShipmentProvider>().broadcastMessage(
                  'Sector Check: All $label please confirm status.',
                  status: status,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ping transmitted to all $label'),
                    backgroundColor: const Color(0xFF0F172A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bolt_rounded, size: 14, color: color),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    var actions = [
      _QuickActionBtn(
        icon: Icons.broadcast_on_personal_rounded,
        label: 'Broadcast Staff',
        onTap: () {
          final controller = TextEditingController();
          // Show a simple dialog for now to broadcast to all drivers
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('New Fleet Broadcast'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter message to all active drivers...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    final message = controller.text;
                    Navigator.pop(context);
                    if (message.isNotEmpty) {
                      await context.read<ShipmentProvider>().broadcastMessage(
                        message,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Broadcast sent to all active drivers!',
                            ),
                            backgroundColor: Colors.indigo,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Transmit'),
                ),
              ],
            ),
          );
        },
        color: Colors.redAccent,
      ),
      _QuickActionBtn(
        icon: Icons.person_add_alt_1_rounded,
        label: 'Deploy Driver',
        onTap: () => context.push('/admin/drivers/add'),
        color: Colors.teal,
      ),
      _QuickActionBtn(
        icon: Icons.post_add_rounded,
        label: 'New Invoice',
        onTap: () => context.go('/admin/finance'),
        color: Colors.amber[700]!,
      ),
      _QuickActionBtn(
        icon: Icons.person_add_rounded,
        label: 'Register Client',
        onTap: () => context.push('/admin/customers/add'),
        color: Colors.cyan[700]!,
      ),
    ];

    return Responsive(
      mobile: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: actions
              .map(
                (a) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(width: 140, child: a),
                ),
              )
              .toList(),
        ),
      ),
      desktop: Row(
        children: actions
            .map(
              (a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: a,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildModuleGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        Consumer<VehicleProvider>(
          builder: (context, vp, _) => AdminModuleCard(
            title: 'Fleet & Assets',
            subtitle: vp.vehiclesNeedingMaintenance.isNotEmpty
                ? '${vp.vehiclesNeedingMaintenance.length} ACTION REQUIRED'
                : 'Maintenance & diagnostics',
            icon: Icons.token_rounded,
            color: Colors.blue,
            onTap: () => context.go('/admin/fleet'),
          ),
        ),
        Consumer<ShipmentProvider>(
          builder: (context, sp, _) => AdminModuleCard(
            title: 'Operations Staff',
            subtitle: '${sp.activeCount} DRIVERS ON-MISSION',
            icon: Icons.shield_rounded,
            color: Colors.orange,
            onTap: () => context.go('/admin/drivers'),
          ),
        ),
        Consumer<ShipmentProvider>(
          builder: (context, sp, _) => AdminModuleCard(
            title: 'Directives',
            subtitle: sp.pendingCount > 0
                ? '${sp.pendingCount} PENDING ASSIGNMENT'
                : 'Shipment & load control',
            icon: Icons.radar_rounded,
            color: Colors.purple,
            onTap: () => context.go('/admin/shipments'),
          ),
        ),
        AdminModuleCard(
          title: 'Clients',
          subtitle: 'Acquisition & CRM',
          icon: Icons.people_alt_rounded,
          color: Colors.cyan,
          onTap: () => context.go('/admin/customers'),
        ),
        AdminModuleCard(
          title: 'Financials',
          subtitle: 'Revenue & ledger',
          icon: Icons.account_tree_rounded,
          color: Colors.green,
          onTap: () => context.go('/admin/finance'),
        ),
        AdminModuleCard(
          title: 'Analytics Forge',
          subtitle: 'Performance insights',
          icon: Icons.analytics_rounded,
          color: Colors.deepPurple,
          onTap: () => context.go('/admin/reports'),
        ),
      ],
    );
  }

  Widget _buildActivityFeed() {
    return Consumer3<ShipmentProvider, VehicleProvider, AuthProvider>(
      builder: (context, shipmentProvider, vehicleProvider, authProvider, _) {
        final activities = <Map<String, dynamic>>[];

        // Get recently completed shipments (last 5)
        final completedShipments =
            shipmentProvider.shipments
                .where((s) => s.status == 'delivered')
                .toList()
              ..sort(
                (a, b) => (b.deliveryDate ?? DateTime.now()).compareTo(
                  a.deliveryDate ?? DateTime.now(),
                ),
              );

        for (var shipment in completedShipments.take(3)) {
          final timeAgo = _getTimeAgo(shipment.deliveryDate ?? DateTime.now());
          activities.add({
            'icon': Icons.check_circle_rounded,
            'color': Colors.green,
            'title': 'Shipment #${shipment.id.substring(0, 8)} Delivered',
            'time': timeAgo,
            'user': shipment.driverName ?? 'Driver',
            'timestamp': shipment.deliveryDate ?? DateTime.now(),
            'type': 'shipment',
            'id': shipment.id,
          });
        }

        // Get vehicles needing maintenance
        final maintenanceVehicles = vehicleProvider.vehicles
            .where((v) => v.needsMaintenance || v.isMaintenanceOverdue)
            .toList();

        for (var vehicle in maintenanceVehicles.take(2)) {
          activities.add({
            'icon': Icons.warning_rounded,
            'color': Colors.orange,
            'title': 'Maintenance Alert: ${vehicle.registrationNumber}',
            'time': 'Pending',
            'user': 'Fleet System',
            'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
            'type': 'maintenance',
          });
        }

        // Get assigned but not yet in transit shipments (last 3)
        final assignedShipments = shipmentProvider.shipments
            .where((s) => s.isAssigned && !s.isInTransit)
            .take(3);

        for (var shipment in assignedShipments) {
          activities.add({
            'icon': Icons.assignment_ind_rounded,
            'color': Colors.purple,
            'title': 'Mission Assigned: ${shipment.cargoType}',
            'time': 'Awaiting start',
            'user': shipment.driverName ?? 'Driver',
            'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
            'type': 'mission',
            'id': shipment.id,
          });
        }

        // Get in-transit shipments (last 3)
        final inTransitShipments = shipmentProvider.shipments
            .where((s) => s.isInTransit)
            .take(3);

        for (var shipment in inTransitShipments) {
          activities.add({
            'icon': Icons.radar_rounded,
            'color': Colors.blue,
            'title': 'Active Mission: #${shipment.id.substring(0, 8)}',
            'time': 'In Transit',
            'user': shipment.driverName ?? 'Driver',
            'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
            'type': 'mission',
            'id': shipment.id,
          });
        }

        // Sort all activities by timestamp
        activities.sort(
          (a, b) => (b['timestamp'] as DateTime).compareTo(
            a['timestamp'] as DateTime,
          ),
        );

        // Take top 5 most recent activities
        final topActivities = activities.take(5).toList();

        if (topActivities.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
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
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_rounded, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'No recent activity',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

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
              for (int i = 0; i < topActivities.length; i++) ...[
                _ActivityItem(
                  icon: topActivities[i]['icon'] as IconData,
                  color: topActivities[i]['color'] as Color,
                  title: topActivities[i]['title'] as String,
                  time: topActivities[i]['time'] as String,
                  user: topActivities[i]['user'] as String,
                  actionIcon:
                      (topActivities[i]['type'] == 'mission' ||
                          topActivities[i]['type'] == 'shipment')
                      ? Icons.chat_bubble_outline_rounded
                      : (topActivities[i]['type'] == 'maintenance'
                            ? Icons.build_rounded
                            : null),
                  onActionPressed: () {
                    if (topActivities[i]['type'] == 'mission' ||
                        topActivities[i]['type'] == 'shipment') {
                      final orderId = topActivities[i]['id'] as String;
                      context.push(
                        '/chat/$orderId/admin/${authProvider.user?.fullName ?? 'Admin'}',
                      );
                    } else if (topActivities[i]['type'] == 'maintenance') {
                      context.go('/admin/vehicles');
                    }
                  },
                  onTap: () {
                    final title = topActivities[i]['title'] as String;
                    if (title.contains('Shipment')) {
                      context.go('/admin/shipments');
                    } else if (title.contains('Mission')) {
                      context.go('/admin/shipments');
                    } else if (title.contains('Maintenance')) {
                      context.go('/admin/fleet');
                    }
                  },
                ),
                if (i < topActivities.length - 1)
                  const Divider(height: 1, indent: 64),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() > 1 ? 's' : ''} ago';
    }
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.15),
                          color.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
  final VoidCallback? onTap;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.time,
    required this.user,
    this.onTap,
    this.actionIcon,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
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
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        user,
                        style: TextStyle(
                          color: Colors.blueAccent.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' • $time',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (actionIcon != null)
              IconButton(
                icon: Icon(actionIcon, size: 20, color: Colors.blue),
                onPressed: onActionPressed,
              ),
            if (onTap != null && actionIcon == null)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
