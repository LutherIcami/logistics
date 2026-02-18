import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/vehicle_model.dart';
import '../../providers/vehicle_provider.dart';
import '../base_module_page.dart';

class FleetMaintenancePage extends StatefulWidget {
  const FleetMaintenancePage({super.key});

  @override
  State<FleetMaintenancePage> createState() => _FleetMaintenancePageState();
}

class _FleetMaintenancePageState extends State<FleetMaintenancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    Future.microtask(() {
      if (mounted) {
        context.read<VehicleProvider>().loadLogs();
      }
    });
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
        return BaseModulePage(
          title: 'Fleet Operations',
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if (_tabController.index == 2) {
                context.push('/admin/fleet/maintenance/record-fuel');
              } else {
                context.push('/admin/fleet/maintenance/record-service');
              }
            },
            label: Text(
              _tabController.index == 2 ? 'Record Fuel' : 'Record Service',
            ),
            icon: Icon(
              _tabController.index == 2 ? Icons.local_gas_station : Icons.build,
            ),
            backgroundColor: _tabController.index == 2
                ? Colors.orange
                : Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF1E293B),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.orange,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Schedule'),
                    Tab(text: 'Service Logs'),
                    Tab(text: 'Fuel Logs'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildScheduleTab(provider),
                    _buildServiceLogsTab(provider),
                    _buildFuelLogsTab(provider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleTab(VehicleProvider provider) {
    final maintenanceVehicles = provider.vehiclesNeedingMaintenance;
    return SingleChildScrollView(
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
            ...maintenanceVehicles.map((v) => _MaintenanceItem(vehicle: v)),
        ],
      ),
    );
  }

  Widget _buildServiceLogsTab(VehicleProvider provider) {
    if (provider.maintenanceLogs.isEmpty) {
      return const Center(child: Text('No maintenance logs recorded.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: provider.maintenanceLogs.length,
      itemBuilder: (context, index) {
        final log = provider.maintenanceLogs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFEFF6FF),
              child: Icon(Icons.build_rounded, color: Colors.blue),
            ),
            title: Text(
              '${log.vehicleRegistration} - ${log.type.name.toUpperCase()}',
            ),
            subtitle: Text(
              '${log.description}\nReported by: ${log.driverName} • ${log.serviceProvider ?? "Unknown Provider"}',
            ),
            onTap: () => _showServiceLogDetail(context, log),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'KES ${log.totalCost.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  log.date.toString().split(' ')[0],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildFuelLogsTab(VehicleProvider provider) {
    if (provider.fuelLogs.isEmpty) {
      return const Center(child: Text('No fuel logs recorded.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: provider.fuelLogs.length,
      itemBuilder: (context, index) {
        final log = provider.fuelLogs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFF7ED),
              child: Icon(
                Icons.local_gas_station_rounded,
                color: Colors.orange,
              ),
            ),
            title: Text(log.vehicleRegistration),
            subtitle: Text(
              '${log.liters}L @ ${log.stationName ?? "Unknown Station"}',
            ),
            onTap: () => _showFuelLogDetail(context, log),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'KES ${log.totalCost.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  log.date.toString().split(' ')[0],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  void _showServiceLogDetail(BuildContext context, dynamic log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${log.vehicleRegistration} Service'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(label: 'Type', value: log.type.name.toUpperCase()),
              _DetailRow(
                label: 'Date',
                value: log.date.toString().split(' ')[0],
              ),
              _DetailRow(label: 'Odometer', value: '${log.odometer} km'),
              _DetailRow(label: 'Reported By', value: log.driverName),
              _DetailRow(
                label: 'Provider',
                value: log.serviceProvider ?? 'N/A',
              ),
              _DetailRow(
                label: 'Cost',
                value: 'KES ${log.totalCost}',
                isBold: true,
              ),
              const Divider(),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(log.description),
              if (log.nextServiceDate != null) ...[
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Next Service',
                  value: log.nextServiceDate.toString().split(' ')[0],
                ),
              ],
              if (log.notes != null && log.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(log.notes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFuelLogDetail(BuildContext context, dynamic log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${log.vehicleRegistration} Fueling'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailRow(label: 'Date', value: log.date.toString().split(' ')[0]),
            _DetailRow(label: 'Odometer', value: '${log.odometer} km'),
            _DetailRow(label: 'Quantity', value: '${log.liters} Liters'),
            _DetailRow(label: 'Station', value: log.stationName ?? 'N/A'),
            _DetailRow(
              label: 'Total Cost',
              value: 'KES ${log.totalCost}',
              isBold: true,
            ),
            _DetailRow(
              label: 'Price/Liter',
              value: 'KES ${log.costPerLiter.toStringAsFixed(2)}',
            ),
            if (log.notes != null && log.notes!.isNotEmpty) ...[
              const Divider(),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(log.notes!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
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
    final v = vehicle as Vehicle;
    final isOverdue = v.isMaintenanceOverdue;
    final urgencyLabel = v.maintenanceUrgencyLabel;
    final urgencyColor = v.maintenanceUrgencyColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: urgencyColor.withValues(alpha: 0.2),
          width: 1.5,
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
              color: urgencyColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOverdue ? Icons.error_rounded : Icons.calendar_today_rounded,
              color: urgencyColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Due: ${v.nextMaintenanceDate?.toString().split(' ')[0] ?? "Not Set"}',
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
                  color: urgencyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  urgencyLabel.toUpperCase(),
                  style: TextStyle(
                    color: urgencyColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                v.registrationNumber,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
