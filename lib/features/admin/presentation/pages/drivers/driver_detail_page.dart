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
      title: 'Personnel File',
      child: FutureBuilder<Driver?>(
        future: context.read<DriverProvider>().getDriverById(driverId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final driver = snapshot.data;
          if (driver == null) {
            return const Center(child: Text('Personnel record not found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, driver),
                const SizedBox(height: 32),
                _buildMetricsRow(driver),
                const SizedBox(height: 32),
                _buildDetailSection('Operational Intel', [
                  _DetailRow(
                    icon: Icons.badge_outlined,
                    label: 'Staff ID',
                    value: driver.id,
                  ),
                  _DetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Primary Contact',
                    value: driver.phone,
                  ),
                  _DetailRow(
                    icon: Icons.email_outlined,
                    label: 'Corporate Email',
                    value: driver.email,
                  ),
                  _DetailRow(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Driver Rank',
                    value: driver.driverLevel,
                  ),
                ]),
                const SizedBox(height: 24),
                _buildDetailSection('Compliance Credentials', [
                  _DetailRow(
                    icon: Icons.assignment_outlined,
                    label: 'License Reference',
                    value: driver.licenseNumber ?? 'N/A',
                  ),
                  _DetailRow(
                    icon: Icons.event_available_outlined,
                    label: 'Compliance Expiry',
                    value: driver.licenseExpiry ?? 'N/A',
                  ),
                ]),
                const SizedBox(height: 24),
                _buildDetailSection('Fleet Deployment', [
                  _DetailRow(
                    icon: Icons.local_shipping_outlined,
                    label: 'Assigned Vehicle',
                    value: driver.currentVehicle ?? 'Unassigned',
                  ),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Last Reported Location',
                    value: driver.currentLocation ?? 'Unknown',
                  ),
                ]),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Driver driver) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                driver.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          driver.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        driver.statusDisplayText.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(driver.status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Joined ${driver.joinDate.year}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildActionButtons(context, driver),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Driver driver) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF64748B)),
          onPressed: () => context.push('/admin/drivers/${driver.id}/edit'),
          tooltip: 'Edit Profile',
        ),
        IconButton(
          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
          onPressed: () => _confirmDelete(context: context, driver: driver),
          tooltip: 'Delete Record',
        ),
      ],
    );
  }

  Widget _buildMetricsRow(Driver driver) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Success Rate',
            value: '98.5%',
            icon: Icons.task_alt_rounded,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MetricCard(
            label: 'Total Trips',
            value: driver.totalTrips.toString(),
            icon: Icons.map_rounded,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MetricCard(
            label: 'Safety Score',
            value: driver.rating.toStringAsFixed(1),
            icon: Icons.star_rounded,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
          child: Column(children: children),
        ),
      ],
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

  Future<void> _confirmDelete({
    required BuildContext context,
    required Driver driver,
  }) async {
    final provider = context.read<DriverProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text(
              'Are you sure you want to decommission ${driver.name}? This removes all operational records.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete Permanently'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      await provider.deleteDriver(driver.id);
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Personnel record purged successfully.'),
          ),
        );
        context.go('/admin/drivers');
      }
    }
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
