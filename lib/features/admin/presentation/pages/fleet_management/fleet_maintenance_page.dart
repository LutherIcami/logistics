import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vehicle_provider.dart';
import '../base_module_page.dart';

class FleetMaintenancePage extends StatelessWidget {
  const FleetMaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, provider, _) {
        final maintenanceVehicles = provider.vehiclesNeedingMaintenance;

        return BaseModulePage(
          title: 'Maintenance Schedule',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummary(provider),
                const SizedBox(height: 32),
                const Text(
                  'Upcoming Maintenance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                if (maintenanceVehicles.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('No vehicles need maintenance.'),
                    ),
                  )
                else
                  ...maintenanceVehicles.map(
                    (v) => _MaintenanceItem(vehicle: v),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummary(VehicleProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
            label: 'Overdue',
            count: provider.vehiclesNeedingMaintenance
                .where((v) => v.isMaintenanceOverdue)
                .length,
            color: Colors.red,
          ),
          _Stat(
            label: 'Upcoming',
            count: provider.vehiclesNeedingMaintenance
                .where((v) => !v.isMaintenanceOverdue)
                .length,
            color: Colors.orange,
          ),
          _Stat(
            label: 'In Workshop',
            count: provider.maintenanceVehiclesCount,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _Stat({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _MaintenanceItem extends StatelessWidget {
  final dynamic vehicle;

  const _MaintenanceItem({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final isOverdue = vehicle.isMaintenanceOverdue;
    final urgency = vehicle.maintenanceUrgency;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOverdue ? Colors.red.shade100 : Colors.grey.shade200,
        ),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOverdue ? Colors.red.shade50 : Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOverdue ? Icons.error_rounded : Icons.calendar_today_rounded,
              color: isOverdue ? Colors.red : Colors.orange,
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
                Text(
                  'Due: ${vehicle.nextMaintenanceDate?.toString().split(' ')[0]}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isOverdue ? Colors.red : Colors.orange).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  urgency.toUpperCase(),
                  style: TextStyle(
                    color: isOverdue ? Colors.red : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                vehicle.registrationNumber,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
