import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard(
            context,
            title: 'Financial Report',
            icon: Icons.bar_chart,
            onTap: () => context.go('/admin/reports/financial'),
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            context,
            title: 'Shipment Analytics',
            icon: Icons.local_shipping,
            onTap: () => context.go('/admin/reports/shipments'),
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            context,
            title: 'Driver Performance',
            icon: Icons.people,
            onTap: () => context.go('/admin/reports/driver-performance'),
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            context,
            title: 'Vehicle Utilization',
            icon: Icons.directions_car,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vehicle stats coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
