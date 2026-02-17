import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/models/order_model.dart';
import '../../domain/models/customer_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../../driver/data/repositories/trip_repository.dart';
import '../../../../app/di/injection_container.dart' as di;
import '../../../../features/common/domain/repositories/notification_repository.dart';
import '../../../../features/common/domain/models/notification_model.dart';
import '../../data/repositories/payment_repository.dart';
import 'package:uuid/uuid.dart';

class CustomerOrderProvider extends ChangeNotifier {
  CustomerOrderProvider()
    : _orderRepository = di.sl<OrderRepository>(),
      _customerRepository = di.sl<CustomerRepository>(),
      _tripRepository = di.sl<TripRepository>(),
      _notificationRepository = di.sl<NotificationRepository>(),
      _paymentRepository = di.sl<PaymentRepository>();

  final OrderRepository _orderRepository;
  final CustomerRepository _customerRepository;
  final TripRepository _tripRepository;
  final NotificationRepository _notificationRepository;
  final PaymentRepository _paymentRepository;
  StreamSubscription<List<Order>>? _subscription;

  // Current logged-in customer (in real app, this would come from auth)
  String? _currentCustomerId;
  Customer? _currentCustomer;
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  String? get currentCustomerId => _currentCustomerId;
  Customer? get currentCustomer => _currentCustomer;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _initRealtimeSubscription() {
    if (_currentCustomerId == null) return;
    _subscription?.cancel();
    _subscription = _orderRepository.streamOrders().listen((data) {
      // Filter for this customer
      _orders = data.where((o) => o.customerId == _currentCustomerId).toList();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // Filtered orders by status
  List<Order> get pendingOrders =>
      _orders.where((order) => order.isPending || order.isConfirmed).toList();
  List<Order> get activeOrders =>
      _orders.where((order) => order.isAssigned || order.isInTransit).toList();
  List<Order> get completedOrders =>
      _orders.where((order) => order.isDelivered).toList();
  List<Order> get cancelledOrders =>
      _orders.where((order) => order.isCancelled).toList();

  // Stats
  int get totalOrders => _orders.length;
  int get activeOrdersCount => activeOrders.length;
  int get pendingOrdersCount => pendingOrders.length;
  double get totalSpent => _orders
      .where((o) => o.isDelivered)
      .fold(0.0, (sum, order) => sum + order.totalCost);

  // Notification State
  final Set<String> _readNotificationIds = {};

  bool isNotificationRead(String id) => _readNotificationIds.contains(id);

  void markNotificationAsRead(String id) {
    if (!_readNotificationIds.contains(id)) {
      _readNotificationIds.add(id);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead(List<String> ids) {
    bool changed = false;
    for (final id in ids) {
      if (!_readNotificationIds.contains(id)) {
        _readNotificationIds.add(id);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  int get unreadNotificationCount {
    int count = 0;

    // Count pending orders
    for (final order in pendingOrders) {
      if (!isNotificationRead('pnd-${order.id}')) {
        count++;
      }
    }

    // Count in transit orders
    for (final order in activeOrders) {
      if (order.isInTransit && !isNotificationRead('trn-${order.id}')) {
        count++;
      }
    }

    return count;
  }

  Future<void> initializeCustomer(String customerId) async {
    _currentCustomerId = customerId;
    _setLoading(true);
    try {
      _currentCustomer = await _customerRepository.getCustomerById(customerId);
      await loadOrders();
      _initRealtimeSubscription();
      _error = null;
    } catch (e) {
      _error = 'Failed to load customer data';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadOrders() async {
    if (_currentCustomerId == null) return;
    _setLoading(true);
    try {
      _orders = await _orderRepository.getOrdersByCustomerId(
        _currentCustomerId!,
      );
      debugPrint(
        'DEBUG: Loaded ${_orders.length} orders for customer $_currentCustomerId',
      );
      debugPrint('DEBUG: Pending orders: ${pendingOrders.length}');
      debugPrint('DEBUG: Active orders: ${activeOrders.length}');
      debugPrint('DEBUG: Completed orders: ${completedOrders.length}');
      if (_orders.isNotEmpty) {
        debugPrint(
          'DEBUG: First order ID: ${_orders.first.id}, Status: ${_orders.first.status}',
        );
      }
      _error = null;
    } catch (e) {
      debugPrint('DEBUG: Error loading orders: $e');
      _error = 'Failed to load orders';
    } finally {
      _setLoading(false);
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      return await _orderRepository.getOrderById(orderId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> createOrder(Order order) async {
    try {
      debugPrint('DEBUG: Creating order with ID: ${order.id}');
      debugPrint('DEBUG: Customer ID: ${order.customerId}');
      debugPrint('DEBUG: Order data: ${order.toJson()}');

      // Calculate commission (70% Company, 30% Driver) - Configurable in future
      final double totalCost = order.totalCost;
      final double companyCommission = totalCost * 0.70;
      final double driverPayout = totalCost * 0.30;

      final orderWithCommission = order.copyWith(
        companyCommission: companyCommission,
        driverPayout: driverPayout,
      );

      final newOrder = await _orderRepository.createOrder(orderWithCommission);
      _orders.insert(0, newOrder);
      _error = null;
      notifyListeners();
      debugPrint(
        'DEBUG: Order created successfully with new ID: ${newOrder.id}',
      );
      return true;
    } catch (e) {
      debugPrint('DEBUG: Order creation error: $e');
      _error = 'Failed to create order: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmDelivery(String orderId) async {
    try {
      // 1. Update the order status
      await _orderRepository.confirmDelivery(orderId);

      // 2. Update the corresponding trip status if it exists
      try {
        await _tripRepository.updateTripStatus(orderId, 'delivered');
      } catch (e) {
        debugPrint('Note: Trip status update failed or not found: $e');
      }

      await loadOrders(); // Reload to get updated status
      return true;
    } catch (e) {
      _error = 'Failed to confirm delivery: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Process M-Pesa payment using STK Push
  Future<bool> processPayment(
    String orderId,
    double amount, {
    String? phoneNumber,
  }) async {
    final targetPhone = phoneNumber ?? _currentCustomer?.phone;

    if (targetPhone == null || targetPhone.isEmpty) {
      _error = 'Phone number is required';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final result = await _paymentRepository.initiateMpesaStkPush(
        phoneNumber: targetPhone,
        amount: amount,
        orderId: orderId,
      );

      debugPrint('M-Pesa STK Push initiated: $result');
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      // 1. Get order details to check if it has a driver assigned
      final order = await getOrderById(orderId);

      // 2. Perform the cancellation in the orders table
      await _orderRepository.cancelOrder(orderId, reason: reason);

      final isAssignedOrInTransit =
          order != null &&
          (order.driverId != null || order.isAssigned || order.isInTransit);

      // 3. If it was assigned/in-transit, notify driver and update trip
      if (isAssignedOrInTransit) {
        // Update trip status
        try {
          await _tripRepository.updateTripStatus(orderId, 'cancelled');
        } catch (e) {
          debugPrint('Note: Trip cancellation failed (might not exist): $e');
        }

        // Notify driver if assigned
        if (order.driverId != null) {
          try {
            const uuid = Uuid();
            final notification = AppNotification(
              id: uuid.v4(),
              userId: order.driverId!,
              title: 'Order Cancelled',
              message:
                  'Customer has cancelled the order for ${order.cargoType} to ${order.deliveryLocation}.',
              type: 'alert',
              relatedEntityId: order.id,
              isRead: false,
              createdAt: DateTime.now(),
            );
            await _notificationRepository.sendNotification(notification);
          } catch (e) {
            debugPrint('Failed to notify driver of cancellation: $e');
          }
        }
      }

      await loadOrders(); // Reload to get updated status
      return true;
    } catch (e) {
      _error = 'Failed to cancel order: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomer(Customer customer, {File? image}) async {
    _setLoading(true);
    try {
      String? imageUrl = customer.profileImage;

      // Handle image upload if provided
      if (image != null) {
        imageUrl = await _customerRepository.uploadProfileImage(
          customer.id,
          image,
        );
      }

      final updatedCustomer = customer.copyWith(profileImage: imageUrl);
      final savedCustomer = await _customerRepository.updateCustomer(
        updatedCustomer,
      );

      _currentCustomer = savedCustomer;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update customer: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
