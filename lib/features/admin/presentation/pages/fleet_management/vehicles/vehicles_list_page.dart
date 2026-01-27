import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/vehicle_provider.dart';
import '../../base_module_page.dart';

class VehiclesListPage extends StatefulWidget {
  const VehiclesListPage({
    super.key,
    this.filterStatus,
  });

  final String? filterStatus;

  @override
  State<VehiclesListPage> createState() => _VehiclesListPageState();
}

class _VehiclesListPageState extends State<VehiclesListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedStatus = widget.filterStatus ?? 'all';

    // Set initial tab based on filter
    switch (_selectedStatus) {
      case 'active':
        _tabController.index = 1;
        break;
      case 'maintenance':
        _tabController.index = 2;
        break;
      case 'inactive':
        _tabController.index = 3;
        break;
      default:
        _tabController.index = 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const BaseModulePage(
            title: 'Vehicles',
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return BaseModulePage(
          title: 'Vehicles',
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/admin/fleet/vehicles/add'),
              tooltip: 'Add Vehicle',
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
              tooltip: 'Filter',
            ),
          ],
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onSurfaceVariant,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: [
                  Tab(text: 'All (${provider.totalVehicles})'),
                  Tab(text: 'Active (${provider.activeVehiclesCount})'),
                  Tab(text: 'Maintenance (${provider.maintenanceVehiclesCount})'),
                  Tab(text: 'Inactive (${provider.inactiveVehiclesCount})'),
                ],
                onTap: (index) {
                  setState(() {
                    switch (index) {
                      case 0:
                        _selectedStatus = 'all';
                        break;
                      case 1:
                        _selectedStatus = 'active';
                        break;
                      case 2:
                        _selectedStatus = 'maintenance';
                        break;
                      case 3:
                        _selectedStatus = 'inactive';
                        break;
                    }
                  });
                },
              ),
              Expanded(
                child: _buildVehiclesList(context, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVehiclesList(BuildContext context, VehicleProvider provider) {
    late List<dynamic> vehicles;
    switch (_selectedStatus) {
      case 'active':
        vehicles = provider.activeVehicles;
        break;
      case 'maintenance':
        vehicles = provider.maintenanceVehicles;
        break;
      case 'inactive':
        vehicles = provider.inactiveVehicles;
        break;
      case 'maintenance_needed':
        vehicles = provider.vehiclesNeedingMaintenance;
        break;
      case 'insurance_expired':
        vehicles = provider.vehiclesWithExpiredInsurance;
        break;
      case 'license_expired':
        vehicles = provider.vehiclesWithExpiredLicense;
        break;
      default:
        vehicles = provider.vehicles;
    }

    if (vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No vehicles found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _VehicleListItem(vehicle: vehicle);
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Vehicles'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Vehicles'),
              onTap: () {
                setState(() {
                  _selectedStatus = 'all';
                  _tabController.index = 0;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Active'),
              onTap: () {
                setState(() {
                  _selectedStatus = 'active';
                  _tabController.index = 1;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('In Maintenance'),
              onTap: () {
                setState(() {
                  _selectedStatus = 'maintenance';
                  _tabController.index = 2;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Inactive'),
              onTap: () {
                setState(() {
                  _selectedStatus = 'inactive';
                  _tabController.index = 3;
                });
                Navigator.of(context).pop();
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Needs Maintenance'),
              onTap: () {
                setState(() {
                  _selectedStatus = 'maintenance_needed';
                  _tabController.index = 0;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Insurance Expired'),
              onTap: () {
                setState(() {
                  _selectedStatus = 'insurance_expired';
                  _tabController.index = 0;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('License Expired'),
              onTap: () {
                setState(() {
                  _selectedStatus = 'license_expired';
                  _tabController.index = 0;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _VehicleListItem extends StatelessWidget {
  const _VehicleListItem({required this.vehicle});

  final dynamic vehicle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/admin/fleet/vehicles/${vehicle.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                              vehicle.currentLocation ?? 'Unknown location',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: vehicle.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      vehicle.statusDisplayText,
                      style: TextStyle(
                        color: vehicle.statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _VehicleInfo(
                      icon: Icons.calendar_today,
                      label: 'Mileage',
                      value: '${vehicle.mileage.toStringAsFixed(0)} km',
                    ),
                  ),
                  Expanded(
                    child: _VehicleInfo(
                      icon: Icons.local_gas_station,
                      label: 'Fuel',
                      value: '${vehicle.fuelLevelPercentage.toStringAsFixed(0)}%',
                    ),
                  ),
                  if (vehicle.assignedDriverName != null)
                    Expanded(
                      child: _VehicleInfo(
                        icon: Icons.person,
                        label: 'Driver',
                        value: vehicle.assignedDriverName!,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (vehicle.needsMaintenance)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, size: 12, color: Colors.orange),
                          SizedBox(width: 4),
                          Text(
                            'Maintenance Due',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (vehicle.insuranceExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.error, size: 12, color: Colors.red),
                          SizedBox(width: 4),
                          Text(
                            'Insurance Expired',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleInfo extends StatelessWidget {
  const _VehicleInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
