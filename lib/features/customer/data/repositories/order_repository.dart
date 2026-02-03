import 'dart:async';
import '../../domain/models/order_model.dart';

/// Abstract contract for order data access.
abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<List<Order>> getOrdersByCustomerId(String customerId);
  Future<Order?> getOrderById(String id);
  Future<Order> createOrder(Order order);
  Future<Order> updateOrder(Order order);
  Future<void> cancelOrder(String orderId);
  Stream<List<Order>> streamOrders();
}

/// Simple in-memory mock implementation for local/testing use.
class MockOrderRepository implements OrderRepository {
  final List<Order> _orders = [
    Order(
      id: 'ORD-001',
      customerId: 'CUST-001',
      customerName: 'ABC Logistics Ltd',
      pickupLocation: 'Nairobi Warehouse, Industrial Area',
      deliveryLocation: 'Mombasa Port, Container Terminal',
      status: 'in_transit',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      pickupDate: DateTime.now().subtract(const Duration(days: 1)),
      estimatedDelivery: DateTime.now().add(const Duration(hours: 6)),
      driverId: 'DRV-001',
      driverName: 'John Mwangi',
      vehiclePlate: 'KDA 123A',
      cargoType: 'General Cargo',
      cargoWeight: 5000.0,
      specialInstructions: 'Handle with care. Fragile items included.',
      distance: 480.0,
      totalCost: 15000.0,
      trackingNumber: 'TRK-2024-001',
    ),
    Order(
      id: 'ORD-002',
      customerId: 'CUST-001',
      customerName: 'ABC Logistics Ltd',
      pickupLocation: 'Eldoret Distribution Center',
      deliveryLocation: 'Kisumu Market, Oginga Odinga Street',
      status: 'delivered',
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      pickupDate: DateTime.now().subtract(const Duration(days: 4)),
      deliveryDate: DateTime.now().subtract(const Duration(days: 3)),
      estimatedDelivery: DateTime.now().subtract(const Duration(days: 3)),
      driverId: 'DRV-001',
      driverName: 'John Mwangi',
      vehiclePlate: 'KDA 123A',
      cargoType: 'Perishable Goods',
      cargoWeight: 3000.0,
      specialInstructions: 'Keep refrigerated. Urgent delivery.',
      distance: 320.0,
      totalCost: 12000.0,
      trackingNumber: 'TRK-2024-002',
    ),
    Order(
      id: 'ORD-003',
      customerId: 'CUST-001',
      customerName: 'ABC Logistics Ltd',
      pickupLocation: 'Nakuru Depot',
      deliveryLocation: 'Nairobi CBD, Tom Mboya Street',
      status: 'confirmed',
      orderDate: DateTime.now().subtract(const Duration(hours: 3)),
      estimatedDelivery: DateTime.now().add(const Duration(days: 1)),
      cargoType: 'Electronics',
      cargoWeight: 2000.0,
      distance: 160.0,
      totalCost: 8000.0,
      trackingNumber: 'TRK-2024-003',
    ),
    Order(
      id: 'ORD-004',
      customerId: 'CUST-001',
      customerName: 'ABC Logistics Ltd',
      pickupLocation: 'Thika Highway, Exit 5',
      deliveryLocation: 'Machakos Town, Market Square',
      status: 'pending',
      orderDate: DateTime.now().subtract(const Duration(hours: 1)),
      estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
      cargoType: 'Construction Materials',
      cargoWeight: 8000.0,
      distance: 80.0,
      totalCost: 6000.0,
      trackingNumber: 'TRK-2024-004',
    ),
  ];

  @override
  Future<List<Order>> getOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<Order>.unmodifiable(_orders);
  }

  @override
  Future<List<Order>> getOrdersByCustomerId(String customerId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // For mock/testing: return all orders but update their customerId to match
    // This ensures orders show up regardless of which user is logged in
    final ordersForCustomer = _orders.map((order) {
      return order.copyWith(
        customerId: customerId,
        customerName: order.customerName, // Keep original name
      );
    }).toList()..sort((a, b) => b.orderDate.compareTo(a.orderDate));

    print(
      'DEBUG MockRepo: Returning ${ordersForCustomer.length} orders for customer $customerId',
    );
    return ordersForCustomer;
  }

  @override
  Future<Order?> getOrderById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Order> createOrder(Order order) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final newOrder = order.copyWith(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      trackingNumber: 'TRK-${DateTime.now().millisecondsSinceEpoch}',
    );
    _orders.add(newOrder);
    return newOrder;
  }

  @override
  Future<Order> updateOrder(Order order) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _orders[index] = order;
    } else {
      _orders.add(order);
    }
    return order;
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: 'cancelled');
    }
  }

  @override
  Stream<List<Order>> streamOrders() {
    // Return a periodic stream for mock
    return Stream.periodic(const Duration(seconds: 5), (_) => _orders);
  }
}
