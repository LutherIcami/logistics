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
    // Mock earnings based on period
    double earnings;
    int trips;
    switch (_selectedPeriod) {
      case 'Today':
        earnings = 3500;
        trips = 2;
        break;
      case 'This Week':
        earnings = 18500;
        trips = 8;
        break;
      case 'This Month':
        earnings = 72000;
        trips = 32;
        break;
      default:
        earnings = provider.totalEarnings;
        trips = provider.totalTrips;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Total Earnings',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'KES ${earnings.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
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
              '$trips trips completed',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsBreakdown(DriverTripProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earnings Breakdown',
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
                _EarningsRow(
                  label: 'Trip Earnings',
                  amount: 15000,
                  icon: Icons.local_shipping,
                  color: Colors.blue,
                ),
                const Divider(),
                _EarningsRow(
                  label: 'Bonuses',
                  amount: 2500,
                  icon: Icons.card_giftcard,
                  color: Colors.green,
                ),
                const Divider(),
                _EarningsRow(
                  label: 'Tips',
                  amount: 1000,
                  icon: Icons.favorite,
                  color: Colors.pink,
                ),
                const Divider(),
                _EarningsRow(
                  label: 'Deductions',
                  amount: -500,
                  icon: Icons.remove_circle,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPayments(DriverTripProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Payments',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _PaymentTile(
                date: DateTime.now().subtract(const Duration(days: 1)),
                amount: 8500,
                status: 'Completed',
                tripCount: 4,
              ),
              const Divider(height: 1),
              _PaymentTile(
                date: DateTime.now().subtract(const Duration(days: 8)),
                amount: 12000,
                status: 'Completed',
                tripCount: 6,
              ),
              const Divider(height: 1),
              _PaymentTile(
                date: DateTime.now().subtract(const Duration(days: 15)),
                amount: 15500,
                status: 'Completed',
                tripCount: 8,
              ),
            ],
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

  const _EarningsRow({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = amount < 0;
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
          Expanded(child: Text(label)),
          Text(
            '${isNegative ? '-' : '+'}KES ${amount.abs().toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isNegative ? Colors.red : Colors.green,
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
  final int tripCount;

  const _PaymentTile({
    required this.date,
    required this.amount,
    required this.status,
    required this.tripCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        child: const Icon(Icons.check_circle, color: Colors.green),
      ),
      title: Text(
        'KES ${amount.toStringAsFixed(0)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '$tripCount trips • ${date.day}/${date.month}/${date.year}',
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status,
          style: const TextStyle(color: Colors.green, fontSize: 12),
        ),
      ),
    );
  }
}
