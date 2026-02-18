import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../base_module_page.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseModulePage(
      title: 'Analytics Forge',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Operational Intelligence',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'In-depth data analysis and performance monitoring.',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          _buildReportActionCard(
            context,
            title: 'System Overview',
            subtitle: 'Comprehensive performance dashboard',
            icon: Icons.dashboard_rounded,
            color: Colors.purple,
            onTap: () => context.go('/admin/reports/system'),
          ),
          const SizedBox(height: 16),
          _buildReportActionCard(
            context,
            title: 'Financial Ledger',
            subtitle: 'Revenue, expenses, and profit margins',
            icon: Icons.account_balance_rounded,
            color: Colors.teal,
            onTap: () => context.go('/admin/reports/financial'),
          ),
          const SizedBox(height: 16),
          _buildReportActionCard(
            context,
            title: 'Shipment Velocity',
            subtitle: 'Transit times and delivery success rates',
            icon: Icons.auto_graph_rounded,
            color: Colors.blue,
            onTap: () => context.go('/admin/reports/shipments'),
          ),
          const SizedBox(height: 16),
          _buildReportActionCard(
            context,
            title: 'Staff Proficiency',
            subtitle: 'Driver safety scores and punctuality',
            icon: Icons.groups_2_rounded,
            color: Colors.indigo,
            onTap: () => context.go('/admin/reports/driver-performance'),
          ),
          const SizedBox(height: 16),
          _buildReportActionCard(
            context,
            title: 'Asset Optimization',
            subtitle: 'Fuel efficiency and maintenance ROI',
            icon: Icons.construction_rounded,
            color: Colors.orange,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vehicle analytics processing...'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFFE2E8F0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
