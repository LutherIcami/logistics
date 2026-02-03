import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/vehicle_provider.dart';
import '../base_module_page.dart';

class FleetDashboardPage extends StatefulWidget {
  const FleetDashboardPage({super.key});

  @override
  State<FleetDashboardPage> createState() => _FleetDashboardPageState();
}

class _FleetDashboardPageState extends State<FleetDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const BaseModulePage(
            title: 'Fleet Management',
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return BaseModulePage(
          title: 'Fleet Management',
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/admin/fleet/vehicles/add'),
            backgroundColor: const Color(0xFF1E293B),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'New Vehicle',
              style: TextStyle(color: Colors.white),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title
                const Text(
                  'Fleet Performance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 20),

                // Horizontal Stats
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      _CompactStatCard(
                        title: 'Total Assets',
                        value: '${provider.totalVehicles}',
                        icon: Icons.local_shipping_rounded,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      _CompactStatCard(
                        title: 'Operational',
                        value: '${provider.activeVehiclesCount}',
                        icon: Icons.check_circle_rounded,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _CompactStatCard(
                        title: 'Maintenance',
                        value: '${provider.maintenanceVehiclesCount}',
                        icon: Icons.build_circle_rounded,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 16),
                      _CompactStatCard(
                        title: 'Fleet Value',
                        value:
                            'KES ${provider.totalFleetValue.toStringAsFixed(0)}',
                        icon: Icons.account_balance_rounded,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Critical Alerts
                if (provider.vehiclesNeedingMaintenance.isNotEmpty ||
                    provider.vehiclesWithExpiredInsurance.isNotEmpty ||
                    provider.vehiclesWithExpiredLicense.isNotEmpty ||
                    provider.lowFuelVehicles.isNotEmpty) ...[
                  const Text(
                    'Critical Alerts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (provider.vehiclesNeedingMaintenance.isNotEmpty)
                    _StandardAlertCard(
                      title: 'Urgent Maintenance Required',
                      subtitle:
                          '${provider.vehiclesNeedingMaintenance.length} vehicles exceeded limit',
                      icon: Icons.warning_amber_rounded,
                      color: Colors.orange,
                      onTap: () => context.push('/admin/fleet/maintenance'),
                    ),
                  const SizedBox(height: 12),
                  if (provider.vehiclesWithExpiredInsurance.isNotEmpty)
                    _StandardAlertCard(
                      title: 'Insurance Compliance Issues',
                      subtitle:
                          '${provider.vehiclesWithExpiredInsurance.length} policies expired',
                      icon: Icons.gpp_bad_rounded,
                      color: Colors.red,
                      onTap: () => context.push('/admin/fleet/vehicles'),
                    ),
                  const SizedBox(height: 12),
                  if (provider.vehiclesWithExpiredLicense.isNotEmpty)
                    _StandardAlertCard(
                      title: 'License Compliance Issues',
                      subtitle:
                          '${provider.vehiclesWithExpiredLicense.length} vehicles lack valid licenses',
                      icon: Icons.assignment_late_rounded,
                      color: Colors.redAccent,
                      onTap: () => context.push('/admin/fleet/vehicles'),
                    ),
                  const SizedBox(height: 12),
                  if (provider.lowFuelVehicles.isNotEmpty)
                    _StandardAlertCard(
                      title: 'Low Fuel Warning',
                      subtitle:
                          '${provider.lowFuelVehicles.length} active vehicles below 15%',
                      icon: Icons.local_gas_station_rounded,
                      color: Colors.deepOrange,
                      onTap: () => context.push('/admin/fleet/vehicles'),
                    ),
                  const SizedBox(height: 32),
                ],

                // Quick Navigation
                const Text(
                  'Operations',
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
                  childAspectRatio: 1.4,
                  children: [
                    _MenuActionCard(
                      title: 'Full Inventory',
                      icon: Icons.view_list_rounded,
                      color: Colors.blue,
                      onTap: () => context.push('/admin/fleet/vehicles'),
                    ),
                    _MenuActionCard(
                      title: 'Schedules',
                      icon: Icons.event_note_rounded,
                      color: Colors.indigo,
                      onTap: () => context.push('/admin/fleet/maintenance'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Recent Activity / Featured Vehicles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Assets',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/admin/fleet/vehicles'),
                      child: const Text('Manage All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (provider.vehicles.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'Inventory is empty.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...provider.vehicles
                      .take(5)
                      .map((v) => _AssetListItem(vehicle: v)),

                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompactStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _CompactStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StandardAlertCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StandardAlertCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withValues(alpha: 0.5),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetListItem extends StatelessWidget {
  final dynamic vehicle;

  const _AssetListItem({required this.vehicle});

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
      child: InkWell(
        onTap: () => context.push('/admin/fleet/vehicles/${vehicle.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Color(0xFF64748B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          vehicle.registrationNumber,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          vehicle.statusDisplayText,
                          style: TextStyle(
                            color: vehicle.statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
