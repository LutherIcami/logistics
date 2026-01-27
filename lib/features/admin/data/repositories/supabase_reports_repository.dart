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
      // Aggregate from financial_transactions for last 6 months
      return [
        MonthlyRevenue(month: 'Jan', revenue: 450000, expenses: 320000),
        MonthlyRevenue(month: 'Feb', revenue: 520000, expenses: 350000),
        MonthlyRevenue(month: 'Mar', revenue: 480000, expenses: 330000),
        MonthlyRevenue(month: 'Apr', revenue: 600000, expenses: 410000),
        MonthlyRevenue(month: 'May', revenue: 750000, expenses: 500000),
        MonthlyRevenue(month: 'Jun', revenue: 820000, expenses: 550000),
      ]; // Temporary mock placeholder in repo until we have enough data
    } catch (e) {
      return [];
    }
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
}
