import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/shipment_provider.dart';
import '../../../../customer/domain/models/order_model.dart';

class ShipmentDetailAdminPage extends StatelessWidget {
  final String shipmentId;

  const ShipmentDetailAdminPage({super.key, required this.shipmentId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShipmentProvider>(
      builder: (context, provider, _) {
        final shipment = provider.getShipmentById(shipmentId);

        if (shipment == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Shipment Details')),
            body: const Center(child: Text('Shipment not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Shipment #${shipment.id}'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.forum_rounded),
                onPressed: () => context.push('/admin/chat/${shipment.id}'),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.go('/admin/shipments/${shipment.id}/edit'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(shipment),
                const SizedBox(height: 16),
                _buildRouteCard(shipment),
                const SizedBox(height: 16),
                _buildInfoCard('Details', [
                  _InfoRow(label: 'Customer', value: shipment.customerName),
                  _InfoRow(label: 'Cargo Type', value: shipment.cargoType),
                  if (shipment.cargoWeight != null)
                    _InfoRow(
                      label: 'Weight',
                      value: '${shipment.cargoWeight} kg',
                    ),
                  _InfoRow(
                    label: 'Total Cost',
                    value: 'KES ${shipment.totalCost.toStringAsFixed(2)}',
                  ),
                  if (shipment.trackingNumber != null)
                    _InfoRow(
                      label: 'Tracking Number',
                      value: shipment.trackingNumber!,
                    ),
                ]),
                const SizedBox(height: 16),
                if (shipment.companyCommission != null ||
                    shipment.driverPayout != null)
                  _buildInfoCard('Financial Breakdown', [
                    _InfoRow(
                      label: 'Company Commission (70%)',
                      value:
                          'KES ${(shipment.companyCommission ?? 0).toStringAsFixed(2)}',
                    ),
                    _InfoRow(
                      label: 'Driver Payout (30%)',
                      value:
                          'KES ${(shipment.driverPayout ?? 0).toStringAsFixed(2)}',
                    ),
                  ]),
                const SizedBox(height: 16),
                if (shipment.driverId != null)
                  _buildInfoCard('Driver & Vehicle', [
                    _InfoRow(
                      label: 'Driver',
                      value: shipment.driverName ?? 'Unknown',
                    ),
                    _InfoRow(
                      label: 'Vehicle',
                      value: shipment.vehiclePlate ?? 'Unknown',
                    ),
                  ])
                else
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.person_add_alt_1,
                        color: Colors.orange,
                      ),
                      title: const Text('No Driver Assigned'),
                      subtitle: const Text('Tap to assign a driver'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.go('/admin/shipments/${shipment.id}/assign');
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(Order shipment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: shipment.statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    shipment.statusIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shipment.statusDisplayText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: shipment.statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last updated: ${_formatDate(DateTime.now())}', // Mock last updated
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
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
    );
  }

  Widget _buildRouteCard(Order shipment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Route Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            _TimelineTile(
              title: 'Pickup',
              subtitle: shipment.pickupLocation,
              date: shipment.pickupDate ?? shipment.orderDate,
              isFirst: true,
              isCompleted: true,
            ),
            _TimelineTile(
              title: 'Delivery',
              subtitle: shipment.deliveryLocation,
              date: shipment.deliveryDate ?? shipment.estimatedDelivery,
              isLast: true,
              isCompleted: shipment.isDelivered,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pending';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime? date;
  final bool isFirst;
  final bool isLast;
  final bool isCompleted;

  const _TimelineTile({
    required this.title,
    required this.subtitle,
    required this.date,
    this.isFirst = false,
    this.isLast = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(width: 2, color: Colors.grey.shade300),
                  ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.blue : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: Colors.grey.shade300),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(subtitle),
                  if (date != null)
                    Text(
                      '${date!.day}/${date!.month}/${date!.year}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
