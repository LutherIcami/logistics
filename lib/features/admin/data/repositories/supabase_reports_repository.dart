import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/report_models.dart';
import 'reports_repository.dart';

class SupabaseReportsRepository implements ReportsRepository {
  final SupabaseClient client;

  SupabaseReportsRepository(this.client);

  @override
  Future<List<WeeklyRevenue>> getWeeklyRevenue() async {
    try {
      final response = await client.rpc('get_weekly_revenue');
      return (response as List).map((json) {
        return WeeklyRevenue(
          day: json['day'] as String,
          amount: (json['amount'] as num).toDouble(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<MonthlyRevenue>> getMonthlyRevenue() async {
    try {
      final response = await client.rpc('get_monthly_performance');
      return (response as List).map((json) {
        return MonthlyRevenue(
          month: json['month'] as String,
          revenue: (json['revenue'] as num).toDouble(),
          expenses: (json['expenses'] as num).toDouble(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ShipmentStat>> getShipmentStats() async {
    try {
      final response = await client.rpc('get_shipment_stats');
      return (response as List).map((json) {
        return ShipmentStat(
          status: json['status'] as String,
          count: (json['count'] as num).toInt(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<RegionStat>> getShipmentByRegion() async {
    try {
      final response = await client.from('orders').select('delivery_location');
      final orders = response as List;
      final Map<String, int> regionCounts = {};

      for (var o in orders) {
        final location = o['delivery_location'] as String?;
        if (location == null || location.isEmpty) continue;

        // Simple heuristic: Take the last part after a comma as the region/city
        // E.g., "123 Main St, Nairobi" -> "Nairobi"
        final parts = location.split(',');
        String region = parts.last.trim();

        // Capitalize first letter
        if (region.isNotEmpty) {
          region = region[0].toUpperCase() + region.substring(1).toLowerCase();
        }

        regionCounts[region] = (regionCounts[region] ?? 0) + 1;
      }

      final sortedRegions = regionCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Return top 5 regions to avoid clutter
      return sortedRegions
          .take(5)
          .map((e) => RegionStat(region: e.key, count: e.value))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<DriverPerformanceStat>> getDriverPerformance() async {
    try {
      debugPrint('Fetching driver performance stats...');
      final response = await client.rpc('get_driver_performance_stats');
      debugPrint('Driver performance response: $response');

      if (response == null) {
        debugPrint('Driver performance response is null');
        return [];
      }

      final list = (response as List).map((json) {
        debugPrint('Processing driver: ${json['driver_name']}');
        return DriverPerformanceStat(
          driverId: json['driver_id'] as String,
          driverName: json['driver_name'] as String,
          tripsCompleted: (json['trips_completed'] as num).toInt(),
          rating: (json['rating'] as num).toDouble(),
          earning: (json['earnings'] as num).toDouble(),
          onTimeRate: (json['on_time_rate'] as num?)?.toDouble() ?? 0.0,
          safetyIncidents: (json['safety_incidents'] as num).toInt(),
        );
      }).toList();

      debugPrint('Fetched ${list.length} drivers');
      return list;
    } catch (e, stackTrace) {
      debugPrint('Error loading driver performance: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  @override
  Future<double> getAverageDeliveryTime() async {
    try {
      final response = await client.rpc('get_avg_delivery_time');
      return (response as num).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Future<double> getOnTimeRate() async {
    try {
      final response = await client.rpc('get_global_on_time_rate');
      return (response as num).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Future<Map<String, double>> getExpenseBreakdown() async {
    try {
      final response = await client.rpc('get_expense_breakdown');
      final Map<String, double> breakdown = {};
      for (var item in (response as List)) {
        breakdown[item['category'] as String] = (item['amount'] as num)
            .toDouble();
      }
      return breakdown;
    } catch (e) {
      return {};
    }
  }

  @override
  Future<List<CustomerRevenue>> getTopCustomers() async {
    try {
      final response = await client.rpc('get_top_customers');
      return (response as List).map((json) {
        return CustomerRevenue(
          name: json['name'] as String,
          revenue: (json['revenue'] as num).toDouble(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
