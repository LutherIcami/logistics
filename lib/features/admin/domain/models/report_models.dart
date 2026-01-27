class WeeklyRevenue {
  final String day;
  final double amount;

  WeeklyRevenue({required this.day, required this.amount});
}

class MonthlyRevenue {
  final String month;
  final double revenue;
  final double expenses;

  MonthlyRevenue({
    required this.month,
    required this.revenue,
    required this.expenses,
  });
}

class ShipmentStat {
  final String status;
  final int count;

  ShipmentStat({required this.status, required this.count});
}

class RegionStat {
  final String region;
  final int count;

  RegionStat({required this.region, required this.count});
}

class DriverPerformanceStat {
  final String driverId;
  final String driverName;
  final int tripsCompleted;
  final double rating;
  final double earning;
  final int safetyIncidents;
  final double onTimeRate; // 0.0 to 1.0

  DriverPerformanceStat({
    required this.driverId,
    required this.driverName,
    required this.tripsCompleted,
    required this.rating,
    required this.earning,
    this.safetyIncidents = 0,
    this.onTimeRate = 1.0,
  });
}
