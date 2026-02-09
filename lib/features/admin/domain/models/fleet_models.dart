enum MaintenanceType {
  routine,
  repair,
  tires,
  oilChange,
  insurance,
  inspection,
  other,
}

class FuelLog {
  final String id;
  final String vehicleId;
  final String vehicleRegistration;
  final String driverId;
  final String driverName;
  final DateTime date;
  final double odometer;
  final double liters;
  final double totalCost;
  final String? stationName;
  final String? receiptImage;
  final String? notes;

  FuelLog({
    required this.id,
    required this.vehicleId,
    required this.vehicleRegistration,
    required this.driverId,
    required this.driverName,
    required this.date,
    required this.odometer,
    required this.liters,
    required this.totalCost,
    this.stationName,
    this.receiptImage,
    this.notes,
  });

  double get costPerLiter => liters > 0 ? totalCost / liters : 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicle_id': vehicleId,
    'vehicle_registration': vehicleRegistration,
    'driver_id': driverId,
    'driver_name': driverName,
    'date': date.toIso8601String(),
    'odometer': odometer,
    'liters': liters,
    'total_cost': totalCost,
    'station_name': stationName,
    'receipt_image': receiptImage,
    'notes': notes,
  };

  factory FuelLog.fromJson(Map<String, dynamic> json) => FuelLog(
    id: json['id'],
    vehicleId: json['vehicle_id'],
    vehicleRegistration: json['vehicle_registration'],
    driverId: json['driver_id'],
    driverName: json['driver_name'],
    date: DateTime.parse(json['date']),
    odometer: json['odometer'].toDouble(),
    liters: json['liters'].toDouble(),
    totalCost: json['total_cost'].toDouble(),
    stationName: json['station_name'],
    receiptImage: json['receipt_image'],
    notes: json['notes'],
  );
}

class MaintenanceLog {
  final String id;
  final String vehicleId;
  final String vehicleRegistration;
  final String driverId;
  final String driverName;
  final DateTime date;
  final double odometer;
  final MaintenanceType type;
  final String description;
  final double totalCost;
  final String? serviceProvider;
  final String? receiptImage;
  final double? nextServiceOdometer;
  final DateTime? nextServiceDate;
  final String? notes;

  MaintenanceLog({
    required this.id,
    required this.vehicleId,
    required this.vehicleRegistration,
    required this.driverId,
    required this.driverName,
    required this.date,
    required this.odometer,
    required this.type,
    required this.description,
    required this.totalCost,
    this.serviceProvider,
    this.receiptImage,
    this.nextServiceOdometer,
    this.nextServiceDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicle_id': vehicleId,
    'vehicle_registration': vehicleRegistration,
    'driver_id': driverId,
    'driver_name': driverName,
    'date': date.toIso8601String(),
    'odometer': odometer,
    'type': type.name,
    'description': description,
    'total_cost': totalCost,
    'service_provider': serviceProvider,
    'receipt_image': receiptImage,
    'next_service_odometer': nextServiceOdometer,
    'next_service_date': nextServiceDate?.toIso8601String(),
    'notes': notes,
  };

  factory MaintenanceLog.fromJson(Map<String, dynamic> json) => MaintenanceLog(
    id: json['id'],
    vehicleId: json['vehicle_id'],
    vehicleRegistration: json['vehicle_registration'],
    driverId: json['driver_id'],
    driverName: json['driver_name'],
    date: DateTime.parse(json['date']),
    odometer: json['odometer'].toDouble(),
    type: MaintenanceType.values.firstWhere((e) => e.name == json['type']),
    description: json['description'],
    totalCost: json['total_cost'].toDouble(),
    serviceProvider: json['service_provider'],
    receiptImage: json['receipt_image'],
    nextServiceOdometer: json['next_service_odometer']?.toDouble(),
    nextServiceDate: json['next_service_date'] != null
        ? DateTime.parse(json['next_service_date'])
        : null,
    notes: json['notes'],
  );
}

enum DiagnosticSeverity { low, medium, high, critical }

enum DiagnosticStatus { reported, inReview, scheduled, resolved, dismissed }

class DiagnosticReport {
  final String id;
  final String vehicleId;
  final String vehicleRegistration;
  final String reporterId;
  final String reporterName;
  final DateTime date;
  final double odometer;
  final String issueDescription;
  final DiagnosticSeverity severity;
  final DiagnosticStatus status;
  final List<String> images;
  final String? resolutionLogId;
  final String? notes;

  DiagnosticReport({
    required this.id,
    required this.vehicleId,
    required this.vehicleRegistration,
    required this.reporterId,
    required this.reporterName,
    required this.date,
    required this.odometer,
    required this.issueDescription,
    this.severity = DiagnosticSeverity.low,
    this.status = DiagnosticStatus.reported,
    this.images = const [],
    this.resolutionLogId,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicle_id': vehicleId,
    'vehicle_registration': vehicleRegistration,
    'reporter_id': reporterId,
    'reporter_name': reporterName,
    'date': date.toIso8601String(),
    'odometer': odometer,
    'issue_description': issueDescription,
    'severity': severity.name,
    'status': status.name,
    'images': images,
    'resolution_log_id': resolutionLogId,
    'notes': notes,
  };

  factory DiagnosticReport.fromJson(Map<String, dynamic> json) =>
      DiagnosticReport(
        id: json['id'],
        vehicleId: json['vehicle_id'],
        vehicleRegistration: json['vehicle_registration'],
        reporterId: json['reporter_id'],
        reporterName: json['reporter_name'],
        date: DateTime.parse(json['date']),
        odometer: json['odometer'].toDouble(),
        issueDescription: json['issue_description'],
        severity: DiagnosticSeverity.values.firstWhere(
          (e) => e.name == json['severity'],
        ),
        status: DiagnosticStatus.values.firstWhere(
          (e) => e.name == json['status'],
        ),
        images: json['images'] != null ? List<String>.from(json['images']) : [],
        resolutionLogId: json['resolution_log_id'],
        notes: json['notes'],
      );

  DiagnosticReport copyWith({
    String? id,
    String? vehicleId,
    String? vehicleRegistration,
    String? reporterId,
    String? reporterName,
    DateTime? date,
    double? odometer,
    String? issueDescription,
    DiagnosticSeverity? severity,
    DiagnosticStatus? status,
    List<String>? images,
    String? resolutionLogId,
    String? notes,
  }) {
    return DiagnosticReport(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      issueDescription: issueDescription ?? this.issueDescription,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      images: images ?? this.images,
      resolutionLogId: resolutionLogId ?? this.resolutionLogId,
      notes: notes ?? this.notes,
    );
  }
}
