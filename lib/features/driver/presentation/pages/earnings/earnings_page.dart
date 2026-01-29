import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/driver_trip_provider.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  String _selectedPeriod = 'This Week';

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverTripProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSelector(),
              const SizedBox(height: 24),
              _buildTotalEarningsCard(provider),
              const SizedBox(height: 24),
              _buildEarningsBreakdown(provider),
              const SizedBox(height: 24),
              _buildRecentPayments(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Today', 'This Week', 'This Month', 'All Time'].map((
          period,
        ) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedPeriod = period);
                }
              },
              selectedColor: Colors.orange.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? Colors.orange : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalEarningsCard(DriverTripProvider provider) {
    final earnings = provider.getEarningsForPeriod(_selectedPeriod);
    final trips = provider.getTripCountForPeriod(_selectedPeriod);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$_selectedPeriod Earnings',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'KES ${earnings.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$trips missions completed',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsBreakdown(DriverTripProvider provider) {
    if (provider.recentEarnings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SUMMARY STATISTICS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _EarningsRow(
                  label: 'Gross Revenue',
                  amount: provider.getEarningsForPeriod(_selectedPeriod),
                  icon: Icons.payments_rounded,
                  color: Colors.blue,
                ),
                const Divider(),
                _EarningsRow(
                  label: 'Active Pipelines',
                  amount: provider.activeTrips.toDouble(),
                  icon: Icons.pending_actions_rounded,
                  color: Colors.orange,
                  isMoney: false,
                ),
                const Divider(),
                _EarningsRow(
                  label: 'Total Completed',
                  amount: provider.completedTrips.length.toDouble(),
                  icon: Icons.task_alt_rounded,
                  color: Colors.green,
                  isMoney: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPayments(DriverTripProvider provider) {
    final recent = provider.recentEarnings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PAYMENT HISTORY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '${recent.length} RECORDS',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recent.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No transaction history found',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length > 5 ? 5 : recent.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final trip = recent[index];
                return _PaymentTile(
                  date: trip.deliveryDate ?? trip.assignedDate,
                  amount: trip.estimatedEarnings ?? 0.0,
                  status: 'Delivered',
                  location: trip.deliveryLocation,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _EarningsRow extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isMoney;

  const _EarningsRow({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.isMoney = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            isMoney ? 'KES ${amount.toStringAsFixed(0)}' : '${amount.toInt()}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: amount < 0 ? Colors.red : Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final DateTime date;
  final double amount;
  final String status;
  final String location;

  const _PaymentTile({
    required this.date,
    required this.amount,
    required this.status,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          color: Colors.green,
          size: 20,
        ),
      ),
      title: Text(
        'KES ${amount.toStringAsFixed(0)}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        '$location • ${date.day}/${date.month}/${date.year}',
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey,
        size: 16,
      ),
    );
  }
}
