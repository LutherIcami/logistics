import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/driver_provider.dart';
import '../../../providers/vehicle_provider.dart';
import '../../base_module_page.dart';
import '../../../../domain/models/driver_model.dart';

class VehicleDetailPage extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailPage({super.key, required this.vehicleId});

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().loadInitialDrivers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, provider, _) {
        final vehicle = provider.vehicles.firstWhere(
          (v) => v.id == widget.vehicleId,
          orElse: () => throw Exception('Vehicle not found'),
        );

        return BaseModulePage(
          title: vehicle.displayName,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () =>
                  context.push('/admin/fleet/vehicles/${vehicle.id}/edit'),
              tooltip: 'Edit Vehicle',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'maintenance':
                    _scheduleMaintenance(context, vehicle);
                    break;
                  case 'delete':
                    _confirmDelete(context, provider, vehicle);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'maintenance',
                  child: Text('Schedule Maintenance'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Vehicle'),
                ),
              ],
            ),
          ],
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Gallery
                if (vehicle.images.isNotEmpty) ...[
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vehicle.images.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(vehicle.images[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Status Card
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        vehicle.statusColor.withValues(alpha: 0.1),
                        vehicle.statusColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: vehicle.statusColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vehicle Status',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              vehicle.statusDisplayText,
                              style: TextStyle(
                                color: vehicle.statusColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vehicle.typeDisplayText,
                              style: TextStyle(
                                color: vehicle.statusColor.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: vehicle.statusColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Vehicle Information
                Text(
                  'Vehicle Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Registration',
                          value: vehicle.registrationNumber,
                        ),
                        const Divider(),
                        _InfoRow(
                          label: 'Make/Model',
                          value: '${vehicle.make} ${vehicle.model}',
                        ),
                        const Divider(),
                        _InfoRow(label: 'Year', value: vehicle.year.toString()),
                        const Divider(),
                        _InfoRow(label: 'Type', value: vehicle.typeDisplayText),
                        if (vehicle.loadCapacity != null) ...[
                          const Divider(),
                          _InfoRow(
                            label: 'Load Capacity',
                            value:
                                '${vehicle.loadCapacity!.toStringAsFixed(1)} tons',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Operational Status
                Text(
                  'Operational Status',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Assigned Driver',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  vehicle.assignedDriverName ?? 'Not Assigned',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: vehicle.assignedDriverName != null
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    size: 20,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      _showAssignDriverDialog(context, vehicle),
                                  tooltip: 'Change Assignment',
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                        _InfoRow(
                          label: 'Current Location',
                          value: vehicle.currentLocation ?? 'Not set',
                        ),
                        const Divider(),
                        _InfoRow(
                          label: 'Mileage',
                          value: '${vehicle.mileage.toStringAsFixed(0)} km',
                        ),
                        const Divider(),
                        _InfoRow(
                          label: 'Fuel Level',
                          value:
                              '${vehicle.fuelLevelPercentage.toStringAsFixed(0)}% (${vehicle.currentFuelLevel.toStringAsFixed(0)}L / ${vehicle.fuelCapacity.toStringAsFixed(0)}L)',
                        ),
                        if (vehicle.purchasePrice != null) ...[
                          const Divider(),
                          _InfoRow(
                            label: 'Purchase Price',
                            value:
                                'KES ${vehicle.purchasePrice!.toStringAsFixed(0)}',
                          ),
                        ],
                        if (vehicle.currentValue != null) ...[
                          const Divider(),
                          _InfoRow(
                            label: 'Current Value',
                            value:
                                'KES ${vehicle.currentValue!.toStringAsFixed(0)}',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Maintenance & Compliance
                Text(
                  'Maintenance & Compliance',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (vehicle.lastMaintenanceDate != null) ...[
                          _InfoRow(
                            label: 'Last Maintenance',
                            value: DateFormat(
                              'MMM dd, yyyy',
                            ).format(vehicle.lastMaintenanceDate!),
                          ),
                          const Divider(),
                        ],
                        if (vehicle.nextMaintenanceDate != null) ...[
                          _InfoRow(
                            label: 'Next Maintenance',
                            value: DateFormat(
                              'MMM dd, yyyy',
                            ).format(vehicle.nextMaintenanceDate!),
                            color: vehicle.needsMaintenance
                                ? Colors.orange
                                : null,
                          ),
                          if (vehicle.needsMaintenance) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Maintenance is overdue!',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Divider(),
                        ],
                        _InfoRow(
                          label: 'Insurance Expiry',
                          value: vehicle.insuranceExpiry ?? 'Not set',
                          color: vehicle.insuranceExpired ? Colors.red : null,
                        ),
                        if (vehicle.insuranceExpired) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Insurance has expired!',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Divider(),
                        _InfoRow(
                          label: 'License Expiry',
                          value: vehicle.licenseExpiry ?? 'Not set',
                          color: vehicle.licenseExpired ? Colors.red : null,
                        ),
                        if (vehicle.licenseExpired) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'License has expired!',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Purchase Information
                Text(
                  'Purchase Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Purchase Date',
                          value: DateFormat(
                            'MMM dd, yyyy',
                          ).format(vehicle.purchaseDate),
                        ),
                        if (vehicle.purchasePrice != null) ...[
                          const Divider(),
                          _InfoRow(
                            label: 'Purchase Price',
                            value:
                                'KES ${vehicle.purchasePrice!.toStringAsFixed(0)}',
                          ),
                        ],
                        if (vehicle.currentValue != null) ...[
                          const Divider(),
                          _InfoRow(
                            label: 'Current Value',
                            value:
                                'KES ${vehicle.currentValue!.toStringAsFixed(0)}',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (vehicle.specifications != null &&
                    vehicle.specifications!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Specifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: vehicle.specifications!.entries.map((entry) {
                          return Column(
                            children: [
                              _InfoRow(
                                label: entry.key,
                                value: entry.value.toString(),
                              ),
                              if (entry.key !=
                                  vehicle.specifications!.keys.last)
                                const Divider(),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _scheduleMaintenance(BuildContext context, vehicle) {
    final nextMaintenance = DateTime.now().add(const Duration(days: 90));
    final lastMaintenance = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Maintenance'),
        content: const Text(
          'Mark maintenance as completed and schedule next service?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final provider = context.read<VehicleProvider>();
              final success = await provider.updateVehicleMaintenance(
                vehicle.id,
                lastMaintenance,
                nextMaintenance,
              );
              if (context.mounted) {
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Maintenance scheduled successfully'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to schedule maintenance'),
                    ),
                  );
                }
              }
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showAssignDriverDialog(BuildContext context, dynamic vehicle) {
    // Determine current driver
    Driver? selectedDriver;
    final drivers = context.read<DriverProvider>().drivers;

    // Safety check - filter out drivers already assigned to OTHER vehicles logic?
    // For now allow re-assigning (backend should handle swap or just overwrite)

    try {
      if (vehicle.assignedDriverId != null) {
        selectedDriver = drivers.firstWhere(
          (d) => d.id == vehicle.assignedDriverId,
        );
      }
    } catch (_) {}

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Assign Driver'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a driver to assign to this vehicle. This will link the vehicle to the driver for future trips.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Driver>(
                  decoration: InputDecoration(
                    labelText: 'Driver',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  isExpanded: true,
                  value: selectedDriver,
                  items: [
                    ...drivers.map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text(d.name, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => selectedDriver = v),
                ),
              ],
            ),
            actions: [
              if (vehicle.assignedDriverId != null)
                TextButton(
                  onPressed: () async {
                    // Unassign logic
                    final provider = context.read<VehicleProvider>();
                    final updatedVehicle = vehicle.copyWith(
                      unassignDriver: true,
                    );
                    final success = await provider.updateVehicle(
                      updatedVehicle,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Driver unassigned successfully'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Unassign',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (selectedDriver == null) return;

                  final provider = context.read<VehicleProvider>();
                  final updatedVehicle = vehicle.copyWith(
                    assignedDriverId: selectedDriver!.id,
                    assignedDriverName: selectedDriver!.name,
                  );

                  final success = await provider.updateVehicle(updatedVehicle);
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${selectedDriver!.name} assigned successfully',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to assign driver'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, VehicleProvider provider, vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
          'Are you sure you want to delete ${vehicle.displayName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success = await provider.deleteVehicle(vehicle.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${vehicle.displayName} deleted successfully',
                      ),
                    ),
                  );
                  context.go('/admin/fleet');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete vehicle')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
