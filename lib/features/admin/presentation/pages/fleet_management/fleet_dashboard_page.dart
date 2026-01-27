import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/vehicle_provider.dart';
import '../base_module_page.dart';
import 'vehicles/vehicles_list_page.dart';

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
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/admin/fleet/vehicles/add'),
              tooltip: 'Add Vehicle',
            ),
          ],
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fleet Overview Cards
                Text(
                  'Fleet Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _FleetStatCard(
                        title: 'Total Vehicles',
                        value: '${provider.totalVehicles}',
                        icon: Icons.local_shipping,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FleetStatCard(
                        title: 'Active',
                        value: '${provider.activeVehiclesCount}',
                        icon: Icons.play_circle,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _FleetStatCard(
                        title: 'In Maintenance',
                        value: '${provider.maintenanceVehiclesCount}',
                        icon: Icons.build,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FleetStatCard(
                        title: 'Inactive',
                        value: '${provider.inactiveVehiclesCount}',
                        icon: Icons.stop_circle,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Fleet Value & Efficiency
                Text(
                  'Fleet Performance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _FleetStatCard(
                        title: 'Total Value',
                        value: 'KES ${provider.totalFleetValue.toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FleetStatCard(
                        title: 'Avg Fuel Level',
                        value: '${provider.averageFuelEfficiency.toStringAsFixed(0)}%',
                        icon: Icons.local_gas_station,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Alerts Section
                Text(
                  'Maintenance Alerts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (provider.vehiclesNeedingMaintenance.isEmpty &&
                    provider.vehiclesWithExpiredInsurance.isEmpty &&
                    provider.vehiclesWithExpiredLicense.isEmpty)
                  Card(
                    color: Colors.green.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'All vehicles are up to date!',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  if (provider.vehiclesNeedingMaintenance.isNotEmpty)
                    _AlertCard(
                      title: 'Vehicles Needing Maintenance',
                      count: provider.vehiclesNeedingMaintenance.length,
                      color: Colors.orange,
                      icon: Icons.build,
                      onTap: () {
                        // Filter to show maintenance needed vehicles
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VehiclesListPage(
                              filterStatus: 'maintenance_needed',
                            ),
                          ),
                        );
                      },
                    ),
                  if (provider.vehiclesWithExpiredInsurance.isNotEmpty)
                    _AlertCard(
                      title: 'Expired Insurance',
                      count: provider.vehiclesWithExpiredInsurance.length,
                      color: Colors.red,
                      icon: Icons.warning,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VehiclesListPage(
                              filterStatus: 'insurance_expired',
                            ),
                          ),
                        );
                      },
                    ),
                  if (provider.vehiclesWithExpiredLicense.isNotEmpty)
                    _AlertCard(
                      title: 'Expired License',
                      count: provider.vehiclesWithExpiredLicense.length,
                      color: Colors.red,
                      icon: Icons.error,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VehiclesListPage(
                              filterStatus: 'license_expired',
                            ),
                          ),
                        );
                      },
                    ),
                ],
                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        title: 'View All Vehicles',
                        icon: Icons.list,
                        color: Colors.blue,
                        onTap: () => context.push('/admin/fleet/vehicles'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        title: 'Add New Vehicle',
                        icon: Icons.add_circle,
                        color: Colors.green,
                        onTap: () => context.push('/admin/fleet/vehicles/add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        title: 'Maintenance Schedule',
                        icon: Icons.calendar_today,
                        color: Colors.orange,
                        onTap: () => context.push('/admin/fleet/maintenance'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        title: 'Fuel Management',
                        icon: Icons.local_gas_station,
                        color: Colors.teal,
                        onTap: () => context.push('/admin/fleet/fuel'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Vehicles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Vehicles',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/admin/fleet/vehicles'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (provider.vehicles.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No vehicles in fleet'),
                    ),
                  )
                else
                  ...provider.vehicles.take(3).map((vehicle) => _VehicleCard(vehicle: vehicle)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FleetStatCard extends StatelessWidget {
  const _FleetStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$count vehicle${count == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: color.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});

  final dynamic vehicle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/admin/fleet/vehicles/${vehicle.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: Colors.blue,
                  size: 32,
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
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.currentLocation ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: vehicle.statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            vehicle.statusDisplayText,
                            style: TextStyle(
                              color: vehicle.statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (vehicle.assignedDriverName != null)
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                vehicle.assignedDriverName!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
