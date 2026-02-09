import 'package:flutter/material.dart';

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String pickupLocation;
  final String deliveryLocation;
  final String status;
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
  final String? cancellationReason;
  final double? companyCommission;
  final double? driverPayout;
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
    this.cancellationReason,
    this.companyCommission,
    this.driverPayout,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'pickup_location': pickupLocation,
      'delivery_location': deliveryLocation,
      'status': status,
      'order_date': orderDate.toIso8601String(),
      'cargo_type': cargoType,
      'total_cost': totalCost,
    };

    if (pickupDate != null) {
      data['pickup_date'] = pickupDate!.toIso8601String();
    }
    if (deliveryDate != null) {
      data['delivery_date'] = deliveryDate!.toIso8601String();
    }
    if (estimatedDelivery != null) {
      data['estimated_delivery'] = estimatedDelivery!.toIso8601String();
    }
    if (driverId != null) data['driver_id'] = driverId;
    if (driverName != null) data['driver_name'] = driverName;
    if (vehiclePlate != null) data['vehicle_plate'] = vehiclePlate;
    if (cargoWeight != null) data['cargo_weight'] = cargoWeight;
    if (specialInstructions != null) {
      data['special_instructions'] = specialInstructions;
    }
    if (distance != null) data['distance'] = distance;
    if (trackingNumber != null) data['tracking_number'] = trackingNumber;
    if (cancellationReason != null) {
      data['cancellation_reason'] = cancellationReason;
    }
    if (companyCommission != null) {
      data['company_commission'] = companyCommission;
    }
    if (driverPayout != null) data['driver_payout'] = driverPayout;
    if (additionalInfo != null) {
      data['additional_info'] = additionalInfo;
    }

    return data;
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customer_id'] ?? json['customerId'],
      customerName: json['customer_name'] ?? json['customerName'],
      pickupLocation: json['pickup_location'] ?? json['pickupLocation'],
      deliveryLocation: json['delivery_location'] ?? json['deliveryLocation'],
      status: json['status'] ?? 'pending',
      orderDate: DateTime.parse(json['order_date'] ?? json['orderDate']),
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
      driverId: json['driver_id'] ?? json['driverId'],
      driverName: json['driver_name'] ?? json['driverName'],
      vehiclePlate: json['vehicle_plate'] ?? json['vehiclePlate'],
      cargoType: json['cargo_type'] ?? json['cargoType'],
      cargoWeight: (json['cargo_weight'] ?? json['cargoWeight'])?.toDouble(),
      specialInstructions:
          json['special_instructions'] ?? json['specialInstructions'],
      distance: (json['distance'])?.toDouble(),
      totalCost: (json['total_cost'] ?? json['totalCost'] ?? 0.0).toDouble(),
      trackingNumber: json['tracking_number'] ?? json['trackingNumber'],
      cancellationReason:
          json['cancellation_reason'] ?? json['cancellationReason'],
      companyCommission:
          (json['company_commission'] ?? json['companyCommission'])?.toDouble(),
      driverPayout: (json['driver_payout'] ?? json['driverPayout'])?.toDouble(),
      additionalInfo: json['additional_info'] ?? json['additionalInfo'],
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
    String? cancellationReason,
    double? companyCommission,
    double? driverPayout,
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
      cancellationReason: cancellationReason ?? this.cancellationReason,
      companyCommission: companyCommission ?? this.companyCommission,
      driverPayout: driverPayout ?? this.driverPayout,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isAssigned => status == 'assigned';
  bool get isInTransit => status == 'in_transit';
  bool get isPendingConfirmation => status == 'pending_confirmation';
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
      case 'pending_confirmation':
        return 'Pending Confirmation';
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
      case 'pending_confirmation':
        return Colors.teal;
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
      case 'pending_confirmation':
        return '📝';
      case 'delivered':
        return '✅';
      case 'cancelled':
        return '❌';
      default:
        return '📦';
    }
  }
}
