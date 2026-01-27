import 'package:flutter/material.dart';

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String pickupLocation;
  final String deliveryLocation;
  final String status; // 'pending', 'confirmed', 'assigned', 'in_transit', 'delivered', 'cancelled'
  final DateTime orderDate;
  final DateTime? pickupDate;
  final DateTime? deliveryDate;
  final DateTime? estimatedDelivery;
  final String? driverId;
  final String? driverName;
  final String? vehiclePlate;
  final String cargoType;
  final double? cargoWeight; // in kg
  final String? specialInstructions;
  final double? distance; // in km
  final double totalCost;
  final String? trackingNumber;
  final Map<String, dynamic>? additionalInfo;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.pickupLocation,
    required this.deliveryLocation,
    this.status = 'pending',
    required this.orderDate,
    this.pickupDate,
    this.deliveryDate,
    this.estimatedDelivery,
    this.driverId,
    this.driverName,
    this.vehiclePlate,
    required this.cargoType,
    this.cargoWeight,
    this.specialInstructions,
    this.distance,
    required this.totalCost,
    this.trackingNumber,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'pickupDate': pickupDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'driverId': driverId,
      'driverName': driverName,
      'vehiclePlate': vehiclePlate,
      'cargoType': cargoType,
      'cargoWeight': cargoWeight,
      'specialInstructions': specialInstructions,
      'distance': distance,
      'totalCost': totalCost,
      'trackingNumber': trackingNumber,
      'additionalInfo': additionalInfo,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      pickupLocation: json['pickupLocation'],
      deliveryLocation: json['deliveryLocation'],
      status: json['status'] ?? 'pending',
      orderDate: DateTime.parse(json['orderDate']),
      pickupDate: json['pickupDate'] != null
          ? DateTime.parse(json['pickupDate'])
          : null,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : null,
      driverId: json['driverId'],
      driverName: json['driverName'],
      vehiclePlate: json['vehiclePlate'],
      cargoType: json['cargoType'],
      cargoWeight: json['cargoWeight']?.toDouble(),
      specialInstructions: json['specialInstructions'],
      distance: json['distance']?.toDouble(),
      totalCost: (json['totalCost'] ?? 0.0).toDouble(),
      trackingNumber: json['trackingNumber'],
      additionalInfo: json['additionalInfo'],
    );
  }

  Order copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? pickupLocation,
    String? deliveryLocation,
    String? status,
    DateTime? orderDate,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    DateTime? estimatedDelivery,
    String? driverId,
    String? driverName,
    String? vehiclePlate,
    String? cargoType,
    double? cargoWeight,
    String? specialInstructions,
    double? distance,
    double? totalCost,
    String? trackingNumber,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      cargoType: cargoType ?? this.cargoType,
      cargoWeight: cargoWeight ?? this.cargoWeight,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      distance: distance ?? this.distance,
      totalCost: totalCost ?? this.totalCost,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isAssigned => status == 'assigned';
  bool get isInTransit => status == 'in_transit';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';

  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
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
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'assigned':
        return Colors.purple;
      case 'in_transit':
        return Colors.amber;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusIcon {
    switch (status) {
      case 'pending':
        return '⏳';
      case 'confirmed':
        return '✓';
      case 'assigned':
        return '🚚';
      case 'in_transit':
        return '🚛';
      case 'delivered':
        return '✅';
      case 'cancelled':
        return '❌';
      default:
        return '📦';
    }
  }
}
