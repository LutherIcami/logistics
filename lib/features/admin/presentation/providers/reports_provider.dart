import 'package:flutter/material.dart';
import '../../domain/models/report_models.dart';
import '../../data/repositories/reports_repository.dart';
import '../../../../app/di/injection_container.dart' as di;

class ReportsProvider extends ChangeNotifier {
  bool _isLoading = false;
  final ReportsRepository _repository;

  ReportsProvider() : _repository = di.sl<ReportsRepository>() {
    loadReports();
  }

  // Financials
  List<WeeklyRevenue> _weeklyRevenue = [];
  List<MonthlyRevenue> _monthlyRevenue = [];

  // Shipments
  List<ShipmentStat> _shipmentStats = [];
  List<RegionStat> _shipmentByRegion = [];
  double _avgDeliveryTimeHours = 0;
  double _overallOnTimeRate = 0;

  // Drivers
  List<DriverPerformanceStat> _driverPerformance = [];

  bool get isLoading => _isLoading;
  List<WeeklyRevenue> get weeklyRevenue => _weeklyRevenue;
  List<MonthlyRevenue> get monthlyRevenue => _monthlyRevenue;

  List<ShipmentStat> get shipmentStats => _shipmentStats;
  List<RegionStat> get shipmentByRegion => _shipmentByRegion;
  double get avgDeliveryTimeHours => _avgDeliveryTimeHours;
  double get overallOnTimeRate => _overallOnTimeRate;

  List<DriverPerformanceStat> get driverPerformance => _driverPerformance;

  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getWeeklyRevenue(),
        _repository.getMonthlyRevenue(),
        _repository.getShipmentStats(),
        _repository.getShipmentByRegion(),
        _repository.getDriverPerformance(),
        _repository.getAverageDeliveryTime(),
        _repository.getOnTimeRate(),
      ]);

      _weeklyRevenue = results[0] as List<WeeklyRevenue>;
      _monthlyRevenue = results[1] as List<MonthlyRevenue>;
      _shipmentStats = results[2] as List<ShipmentStat>;
      _shipmentByRegion = results[3] as List<RegionStat>;
      _driverPerformance = results[4] as List<DriverPerformanceStat>;
      _avgDeliveryTimeHours = results[5] as double;
      _overallOnTimeRate = results[6] as double;
    } catch (e) {
      debugPrint('Error loading reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
