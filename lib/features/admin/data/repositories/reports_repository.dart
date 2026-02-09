import '../../domain/models/report_models.dart';

abstract class ReportsRepository {
  Future<List<WeeklyRevenue>> getWeeklyRevenue();
  Future<List<MonthlyRevenue>> getMonthlyRevenue();
  Future<List<ShipmentStat>> getShipmentStats();
  Future<List<RegionStat>> getShipmentByRegion();
  Future<List<DriverPerformanceStat>> getDriverPerformance();
  Future<double> getAverageDeliveryTime();
  Future<double> getOnTimeRate();

  // Advanced Financials
  Future<Map<String, double>> getExpenseBreakdown();
  Future<List<CustomerRevenue>> getTopCustomers();
}

class CustomerRevenue {
  final String name;
  final double revenue;
  CustomerRevenue({required this.name, required this.revenue});
}
