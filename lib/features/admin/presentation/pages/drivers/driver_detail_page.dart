import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/driver_model.dart';
import '../../providers/driver_provider.dart';
import '../base_module_page.dart';

class DriverDetailPage extends StatelessWidget {
  const DriverDetailPage({super.key, required this.driverId});

  final String driverId;

  @override
  Widget build(BuildContext context) {
    return BaseModulePage(
      title: 'Driver Details',
      child: FutureBuilder<Driver?>(
        future: context.read<DriverProvider>().getDriverById(driverId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final driver = snapshot.data;
          if (driver == null) {
            return const Center(child: Text('Driver not found'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      child: Text(
                        driver.name.isNotEmpty ? driver.name[0] : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            driver.email,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${driver.statusDisplayEmoji} ${driver.statusDisplayText}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          context.go('/admin/drivers/${driver.id}/edit'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          _confirmDelete(context: context, driver: driver),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Details',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _InfoTile(label: 'Driver ID', value: driver.id),
                    _InfoTile(label: 'Phone', value: driver.phone),
                    if (driver.licenseNumber != null)
                      _InfoTile(
                        label: 'License No.',
                        value: driver.licenseNumber ?? '-',
                      ),
                    if (driver.licenseExpiry != null)
                      _InfoTile(
                        label: 'License Expiry',
                        value: driver.licenseExpiry ?? '-',
                      ),
                    _InfoTile(
                      label: 'Total Trips',
                      value: driver.totalTrips.toString(),
                    ),
                    _InfoTile(
                      label: 'Rating',
                      value: '${driver.rating.toStringAsFixed(1)} / 5',
                    ),
                    if (driver.currentLocation != null)
                      _InfoTile(
                        label: 'Current Location',
                        value: driver.currentLocation ?? '-',
                      ),
                    if (driver.currentVehicle != null)
                      _InfoTile(
                        label: 'Assigned Vehicle',
                        value: driver.currentVehicle ?? '-',
                      ),
                    _InfoTile(
                      label: 'Level',
                      value: driver.driverLevel,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete({
    required BuildContext context,
    required Driver driver,
  }) async {
    final provider = context.read<DriverProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Driver'),
              content: Text(
                'Are you sure you want to delete ${driver.name}? '
                'This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    await provider.deleteDriver(driver.id);
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Driver ${driver.name} deleted')),
    );
    router.go('/admin/drivers');
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

