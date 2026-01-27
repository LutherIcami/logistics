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
    this.specifications,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registrationNumber': registrationNumber,
      'make': make,
      'model': model,
      'year': year,
      'type': type,
      'status': status,
      'assignedDriverId': assignedDriverId,
      'assignedDriverName': assignedDriverName,
      'fuelCapacity': fuelCapacity,
      'currentFuelLevel': currentFuelLevel,
      'mileage': mileage,
      'purchaseDate': purchaseDate.toIso8601String(),
      'lastMaintenanceDate': lastMaintenanceDate?.toIso8601String(),
      'nextMaintenanceDate': nextMaintenanceDate?.toIso8601String(),
      'currentLocation': currentLocation,
      'loadCapacity': loadCapacity,
      'insuranceExpiry': insuranceExpiry,
      'licenseExpiry': licenseExpiry,
      'purchasePrice': purchasePrice,
      'currentValue': currentValue,
      'specifications': specifications,
      'additionalInfo': additionalInfo,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      registrationNumber: json['registrationNumber'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      type: json['type'] ?? 'truck',
      status: json['status'] ?? 'active',
      assignedDriverId: json['assignedDriverId'],
      assignedDriverName: json['assignedDriverName'],
      fuelCapacity: json['fuelCapacity']?.toDouble() ?? 0.0,
      currentFuelLevel: json['currentFuelLevel']?.toDouble() ?? 0.0,
      mileage: json['mileage']?.toDouble() ?? 0.0,
      purchaseDate: DateTime.parse(json['purchaseDate']),
      lastMaintenanceDate: json['lastMaintenanceDate'] != null
          ? DateTime.parse(json['lastMaintenanceDate'])
          : null,
      nextMaintenanceDate: json['nextMaintenanceDate'] != null
          ? DateTime.parse(json['nextMaintenanceDate'])
          : null,
      currentLocation: json['currentLocation'],
      loadCapacity: json['loadCapacity']?.toDouble(),
      insuranceExpiry: json['insuranceExpiry'],
      licenseExpiry: json['licenseExpiry'],
      purchasePrice: json['purchasePrice']?.toDouble(),
      currentValue: json['currentValue']?.toDouble(),
      specifications: json['specifications'],
      additionalInfo: json['additionalInfo'],
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

  double get fuelLevelPercentage => fuelCapacity > 0 ? (currentFuelLevel / fuelCapacity) * 100 : 0;

  bool get needsMaintenance {
    if (nextMaintenanceDate == null) return false;
    return DateTime.now().isAfter(nextMaintenanceDate!);
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