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
  final String? trackingNumber;

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
    this.trackingNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      if (driverName != null) 'driver_name': driverName,
      'pickup_location': pickupLocation,
      'delivery_location': deliveryLocation,
      'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      'status': status,
      'assigned_date': assignedDate.toIso8601String(),
      'pickup_date': pickupDate?.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'estimated_delivery': estimatedDelivery?.toIso8601String(),
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (vehiclePlate != null) 'vehicle_plate': vehiclePlate,
      'cargo_type': cargoType,
      if (cargoWeight != null) 'cargo_weight': cargoWeight,
      if (specialInstructions != null)
        'special_instructions': specialInstructions,
      if (distance != null) 'distance': distance,
      if (estimatedEarnings != null) 'estimated_earnings': estimatedEarnings,
      if (additionalInfo != null) 'additional_info': additionalInfo,
      if (trackingNumber != null) 'tracking_number': trackingNumber,
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      driverId: json['driver_id'] ?? json['driverId'],
      driverName: json['driver_name'] ?? json['driverName'],
      pickupLocation: json['pickup_location'] ?? json['pickupLocation'],
      deliveryLocation: json['delivery_location'] ?? json['deliveryLocation'],
      customerName: json['customer_name'] ?? json['customerName'],
      customerPhone: json['customer_phone'] ?? json['customerPhone'],
      status: json['status'] ?? 'assigned',
      assignedDate: DateTime.parse(
        json['assigned_date'] ??
            json['assignedDate'] ??
            DateTime.now().toIso8601String(),
      ),
      pickupDate: json['pickup_date'] != null
          ? DateTime.parse(json['pickup_date'])
          : (json['pickupDate'] != null
                ? DateTime.parse(json['pickupDate'])
                : null),
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'])
          : (json['deliveryDate'] != null
                ? DateTime.parse(json['deliveryDate'])
                : null),
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.parse(json['estimated_delivery'])
          : (json['estimatedDelivery'] != null
                ? DateTime.parse(json['estimatedDelivery'])
                : null),
      vehicleId: json['vehicle_id'] ?? json['vehicleId'],
      vehiclePlate: json['vehicle_plate'] ?? json['vehiclePlate'],
      cargoType: json['cargo_type'] ?? json['cargoType'],
      cargoWeight: (json['cargo_weight'] ?? json['cargoWeight'])?.toDouble(),
      specialInstructions:
          json['special_instructions'] ?? json['specialInstructions'],
      distance: (json['distance'])?.toDouble(),
      estimatedEarnings:
          (json['estimated_earnings'] ?? json['estimatedEarnings'])?.toDouble(),
      additionalInfo: json['additional_info'] ?? json['additionalInfo'],
      trackingNumber: json['tracking_number'] ?? json['trackingNumber'],
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
    String? trackingNumber,
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
      trackingNumber: trackingNumber ?? this.trackingNumber,
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
