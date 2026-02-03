// Import for Color
import 'package:flutter/material.dart';

class Vehicle {
  final String id;
  final String registrationNumber;
  final String make;
  final String model;
  final int year;
  final String type; // 'truck', 'van', 'pickup', 'trailer'
  final String status; // 'active', 'maintenance', 'inactive', 'sold'
  final String? assignedDriverId;
  final String? assignedDriverName;
  final double fuelCapacity; // in liters
  final double currentFuelLevel; // in liters
  final double mileage; // in km
  final DateTime purchaseDate;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final String? currentLocation;
  final double? loadCapacity; // in tons
  final String? insuranceExpiry;
  final String? licenseExpiry;
  final double? purchasePrice;
  final double? currentValue;
  final List<String> images;
  final Map<String, dynamic>? specifications;
  final Map<String, dynamic>? additionalInfo;

  Vehicle({
    required this.id,
    required this.registrationNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.type,
    this.status = 'active',
    this.assignedDriverId,
    this.assignedDriverName,
    required this.fuelCapacity,
    this.currentFuelLevel = 0.0,
    this.mileage = 0.0,
    required this.purchaseDate,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.currentLocation,
    this.loadCapacity,
    this.insuranceExpiry,
    this.licenseExpiry,
    this.purchasePrice,
    this.currentValue,
    this.images = const [],
    this.specifications,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registration_number': registrationNumber,
      'make': make,
      'model': model,
      'year': year,
      'type': type,
      'status': status,
      if (assignedDriverId != null) 'assigned_driver_id': assignedDriverId,
      if (assignedDriverName != null)
        'assigned_driver_name': assignedDriverName,
      'fuel_capacity': fuelCapacity,
      'current_fuel_level': currentFuelLevel,
      'mileage': mileage,
      'purchase_date': purchaseDate.toIso8601String(),
      if (lastMaintenanceDate != null)
        'last_maintenance_date': lastMaintenanceDate!.toIso8601String(),
      if (nextMaintenanceDate != null)
        'next_maintenance_date': nextMaintenanceDate!.toIso8601String(),
      if (currentLocation != null) 'current_location': currentLocation,
      if (loadCapacity != null) 'load_capacity': loadCapacity,
      if (insuranceExpiry != null) 'insurance_expiry': insuranceExpiry,
      if (licenseExpiry != null) 'license_expiry': licenseExpiry,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (currentValue != null) 'current_value': currentValue,
      'images': images,
      if (specifications != null) 'specifications': specifications,
      if (additionalInfo != null) 'additional_info': additionalInfo,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      registrationNumber:
          json['registration_number'] ??
          json['registrationNumber'], // Fallback for old data
      make: json['make'],
      model: json['model'],
      year: json['year'],
      type: json['type'] ?? 'truck',
      status: json['status'] ?? 'active',
      assignedDriverId: json['assigned_driver_id'] ?? json['assignedDriverId'],
      assignedDriverName:
          json['assigned_driver_name'] ?? json['assignedDriverName'],
      fuelCapacity:
          (json['fuel_capacity'] ?? json['fuelCapacity'])?.toDouble() ?? 0.0,
      currentFuelLevel:
          (json['current_fuel_level'] ?? json['currentFuelLevel'])
              ?.toDouble() ??
          0.0,
      mileage: (json['mileage'])?.toDouble() ?? 0.0,
      purchaseDate: DateTime.parse(
        json['purchase_date'] ??
            json['purchaseDate'] ??
            DateTime.now().toIso8601String(),
      ),
      lastMaintenanceDate: json['last_maintenance_date'] != null
          ? DateTime.parse(json['last_maintenance_date'])
          : null,
      nextMaintenanceDate: json['next_maintenance_date'] != null
          ? DateTime.parse(json['next_maintenance_date'])
          : null,
      currentLocation: json['current_location'] ?? json['currentLocation'],
      loadCapacity: (json['load_capacity'] ?? json['loadCapacity'])?.toDouble(),
      insuranceExpiry: json['insurance_expiry'] ?? json['insuranceExpiry'],
      licenseExpiry: json['license_expiry'] ?? json['licenseExpiry'],
      purchasePrice: (json['purchase_price'] ?? json['purchasePrice'])
          ?.toDouble(),
      currentValue: (json['current_value'] ?? json['currentValue'])?.toDouble(),
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      specifications: json['specifications'],
      additionalInfo: json['additional_info'] ?? json['additionalInfo'],
    );
  }

  Vehicle copyWith({
    String? id,
    String? registrationNumber,
    String? make,
    String? model,
    int? year,
    String? type,
    String? status,
    String? assignedDriverId,
    String? assignedDriverName,
    double? fuelCapacity,
    double? currentFuelLevel,
    double? mileage,
    DateTime? purchaseDate,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    String? currentLocation,
    double? loadCapacity,
    String? insuranceExpiry,
    String? licenseExpiry,
    double? purchasePrice,
    double? currentValue,
    List<String>? images,
    Map<String, dynamic>? specifications,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Vehicle(
      id: id ?? this.id,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      type: type ?? this.type,
      status: status ?? this.status,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      fuelCapacity: fuelCapacity ?? this.fuelCapacity,
      currentFuelLevel: currentFuelLevel ?? this.currentFuelLevel,
      mileage: mileage ?? this.mileage,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      currentLocation: currentLocation ?? this.currentLocation,
      loadCapacity: loadCapacity ?? this.loadCapacity,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentValue: currentValue ?? this.currentValue,
      images: images ?? this.images,
      specifications: specifications ?? this.specifications,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  // Helper methods
  bool get isActive => status == 'active';
  bool get isInMaintenance => status == 'maintenance';
  bool get isInactive => status == 'inactive';
  bool get isSold => status == 'sold';

  String get statusDisplayText {
    switch (status) {
      case 'active':
        return 'Active';
      case 'maintenance':
        return 'In Maintenance';
      case 'inactive':
        return 'Inactive';
      case 'sold':
        return 'Sold';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'inactive':
        return Colors.grey;
      case 'sold':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String get typeDisplayText {
    switch (type) {
      case 'truck':
        return 'Truck';
      case 'van':
        return 'Van';
      case 'pickup':
        return 'Pickup';
      case 'trailer':
        return 'Trailer';
      default:
        return type;
    }
  }

  double get fuelLevelPercentage =>
      fuelCapacity > 0 ? (currentFuelLevel / fuelCapacity) * 100 : 0;

  bool get needsMaintenance {
    if (nextMaintenanceDate == null) return false;
    // Alert if maintenance is due within 7 days or already past
    final thresholdDate = DateTime.now().add(const Duration(days: 7));
    return nextMaintenanceDate!.isBefore(thresholdDate);
  }

  bool get isMaintenanceOverdue {
    if (nextMaintenanceDate == null) return false;
    return DateTime.now().isAfter(nextMaintenanceDate!);
  }

  String get maintenanceUrgency {
    if (nextMaintenanceDate == null) return 'none';
    final diff = nextMaintenanceDate!.difference(DateTime.now()).inDays;
    if (diff < 0) return 'critical';
    if (diff <= 3) return 'high';
    if (diff <= 7) return 'moderate';
    return 'none';
  }

  String get maintenanceUrgencyLabel {
    if (nextMaintenanceDate == null) return 'Healthy';
    final diff = nextMaintenanceDate!.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Critical';
    if (diff <= 3) return 'Upcoming';
    if (diff <= 7) return 'Due Soon';
    return 'Healthy';
  }

  Color get maintenanceUrgencyColor {
    final urgency = maintenanceUrgencyLabel;
    switch (urgency) {
      case 'Critical':
        return Colors.red;
      case 'Upcoming':
        return Colors.orange;
      case 'Due Soon':
        return Colors.blue;
      case 'Healthy':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  bool get insuranceExpired {
    if (insuranceExpiry == null) return false;
    try {
      final expiryDate = DateTime.parse(insuranceExpiry!);
      return DateTime.now().isAfter(expiryDate);
    } catch (_) {
      return false;
    }
  }

  bool get licenseExpired {
    if (licenseExpiry == null) return false;
    try {
      final expiryDate = DateTime.parse(licenseExpiry!);
      return DateTime.now().isAfter(expiryDate);
    } catch (_) {
      return false;
    }
  }

  String get displayName => '$make $model ($registrationNumber)';
}
