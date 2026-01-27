import 'package:flutter/material.dart';

class Trip {
  final String id;
  final String driverId;
  final String? driverName;
  final String pickupLocation;
  final String deliveryLocation;
  final String customerName;
  final String? customerPhone;
  final String status; // 'assigned', 'in_transit', 'delivered', 'cancelled'
  final DateTime assignedDate;
  final DateTime? pickupDate;
  final DateTime? deliveryDate;
  final DateTime? estimatedDelivery;
  final String? vehicleId;
  final String? vehiclePlate;
  final String cargoType;
  final double? cargoWeight; // in kg
  final String? specialInstructions;
  final double? distance; // in km
  final double? estimatedEarnings;
  final Map<String, dynamic>? additionalInfo;

  Trip({
    required this.id,
    required this.driverId,
    this.driverName,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.customerName,
    this.customerPhone,
    this.status = 'assigned',
    required this.assignedDate,
    this.pickupDate,
    this.deliveryDate,
    this.estimatedDelivery,
    this.vehicleId,
    this.vehiclePlate,
    required this.cargoType,
    this.cargoWeight,
    this.specialInstructions,
    this.distance,
    this.estimatedEarnings,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'driverName': driverName,
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'status': status,
      'assignedDate': assignedDate.toIso8601String(),
      'pickupDate': pickupDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'vehicleId': vehicleId,
      'vehiclePlate': vehiclePlate,
      'cargoType': cargoType,
      'cargoWeight': cargoWeight,
      'specialInstructions': specialInstructions,
      'distance': distance,
      'estimatedEarnings': estimatedEarnings,
      'additionalInfo': additionalInfo,
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      driverId: json['driverId'],
      driverName: json['driverName'],
      pickupLocation: json['pickupLocation'],
      deliveryLocation: json['deliveryLocation'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      status: json['status'] ?? 'assigned',
      assignedDate: DateTime.parse(json['assignedDate']),
      pickupDate: json['pickupDate'] != null
          ? DateTime.parse(json['pickupDate'])
          : null,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : null,
      vehicleId: json['vehicleId'],
      vehiclePlate: json['vehiclePlate'],
      cargoType: json['cargoType'],
      cargoWeight: json['cargoWeight']?.toDouble(),
      specialInstructions: json['specialInstructions'],
      distance: json['distance']?.toDouble(),
      estimatedEarnings: json['estimatedEarnings']?.toDouble(),
      additionalInfo: json['additionalInfo'],
    );
  }

  Trip copyWith({
    String? id,
    String? driverId,
    String? driverName,
    String? pickupLocation,
    String? deliveryLocation,
    String? customerName,
    String? customerPhone,
    String? status,
    DateTime? assignedDate,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    DateTime? estimatedDelivery,
    String? vehicleId,
    String? vehiclePlate,
    String? cargoType,
    double? cargoWeight,
    String? specialInstructions,
    double? distance,
    double? estimatedEarnings,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Trip(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      status: status ?? this.status,
      assignedDate: assignedDate ?? this.assignedDate,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      vehicleId: vehicleId ?? this.vehicleId,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      cargoType: cargoType ?? this.cargoType,
      cargoWeight: cargoWeight ?? this.cargoWeight,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      distance: distance ?? this.distance,
      estimatedEarnings: estimatedEarnings ?? this.estimatedEarnings,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  // Helper methods
  bool get isAssigned => status == 'assigned';
  bool get isInTransit => status == 'in_transit';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';

  String get statusDisplayText {
    switch (status) {
      case 'assigned':
        return 'Assigned';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'assigned':
        return Colors.blue;
      case 'in_transit':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
