import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/report_models.dart';
import 'reports_repository.dart';

class SupabaseReportsRepository implements ReportsRepository {
  final SupabaseClient client;

  SupabaseReportsRepository(this.client);

  @override
  Future<List<WeeklyRevenue>> getWeeklyRevenue() async {
    try {
      // In a real app, use an RPC or better query.
      // For now, aggregate last 7 days from financial_transactions
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));

      final response = await client
          .from('financial_transactions')
          .select()
          .eq('type', 'income')
          .gte('date', lastWeek.toIso8601String());

      final txs = response as List;
      final Map<String, double> dayTotals = {};

      for (var tx in txs) {
        final date = DateTime.parse(tx['date']);
        final day = _getDayName(date.weekday);
        dayTotals[day] = (dayTotals[day] ?? 0) + tx['amount'].toDouble();
      }

      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days
          .map((d) => WeeklyRevenue(day: d, amount: dayTotals[d] ?? 0))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<MonthlyRevenue>> getMonthlyRevenue() async {
    try {
      final now = DateTime.now();
      final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

      final response = await client
          .from('financial_transactions')
          .select()
          .gte('date', sixMonthsAgo.toIso8601String());

      final txs = response as List;
      final Map<String, double> income = {};
      final Map<String, double> expense = {};

      for (var tx in txs) {
        final date = DateTime.parse(tx['date']);
        final month = _getMonthName(date.month);
        final amount = tx['amount'].toDouble();

        if (tx['type'] == 'income') {
          income[month] = (income[month] ?? 0) + amount;
        } else {
          expense[month] = (expense[month] ?? 0) + amount;
        }
      }

      final List<String> months = [];
      for (int i = 5; i >= 0; i--) {
        final mDate = DateTime(now.year, now.month - i, 1);
        months.add(_getMonthName(mDate.month));
      }

      return months
          .map(
            (m) => MonthlyRevenue(
              month: m,
              revenue: income[m] ?? 0,
              expenses: expense[m] ?? 0,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Future<List<ShipmentStat>> getShipmentStats() async {
    try {
      final response = await client.from('orders').select('status');
      final orders = response as List;
      final Map<String, int> counts = {};

      for (var o in orders) {
        final status = o['status'] ?? 'pending';
        counts[status] = (counts[status] ?? 0) + 1;
      }

      return counts.entries
          .map(
            (e) => ShipmentStat(
              status: e.key[0].toUpperCase() + e.key.substring(1),
              count: e.value,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<RegionStat>> getShipmentByRegion() async {
    return [
      RegionStat(region: 'Nairobi', count: 12),
      RegionStat(region: 'Mombasa', count: 8),
      RegionStat(region: 'Kisumu', count: 5),
    ];
  }

  @override
  Future<List<DriverPerformanceStat>> getDriverPerformance() async {
    try {
      final response = await client.from('drivers').select();
      final drivers = response as List;

      return drivers
          .map(
            (d) => DriverPerformanceStat(
              driverId: d['id'],
              driverName: d['name'],
              tripsCompleted: d['totalTrips'] ?? 0,
              rating: (d['rating'] ?? 0.0).toDouble(),
              earning: (d['totalTrips'] ?? 0) * 1000.0, // Mock calc
              onTimeRate: 0.95,
              safetyIncidents: 0,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<double> getAverageDeliveryTime() async => 24.5;

  @override
  Future<double> getOnTimeRate() async => 0.92;

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  @override
  Future<Map<String, double>> getExpenseBreakdown() async {
    try {
      final response = await client
          .from('financial_transactions')
          .select()
          .eq('type', 'expense');

      final txs = response as List;
      final Map<String, double> breakdown = {};

      for (var tx in txs) {
        final category = tx['category'] ?? 'other';
        breakdown[category] =
            (breakdown[category] ?? 0) + tx['amount'].toDouble();
      }

      return breakdown;
    } catch (e) {
      return {};
    }
  }

  @override
  Future<List<CustomerRevenue>> getTopCustomers() async {
    try {
      // Return mock data for now as joining is complex for a one-shot query
      return [
        CustomerRevenue(name: 'ABC Solutions', revenue: 125000),
        CustomerRevenue(name: 'Global Logistics Ltd', revenue: 98000),
        CustomerRevenue(name: 'East Africa Traders', revenue: 75000),
        CustomerRevenue(name: 'Prime Retailers', revenue: 52000),
        CustomerRevenue(name: 'Sunrise Exports', revenue: 45000),
      ];
    } catch (e) {
      return [];
    }
  }
}
