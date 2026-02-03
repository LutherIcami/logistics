import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/models/order_model.dart';
import '../../domain/models/customer_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../../../app/di/injection_container.dart' as di;

class CustomerOrderProvider extends ChangeNotifier {
  CustomerOrderProvider()
    : _orderRepository = di.sl<OrderRepository>(),
      _customerRepository = di.sl<CustomerRepository>();

  final OrderRepository _orderRepository;
  final CustomerRepository _customerRepository;
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
      print(
        'DEBUG: Loaded ${_orders.length} orders for customer $_currentCustomerId',
      );
      print('DEBUG: Pending orders: ${pendingOrders.length}');
      print('DEBUG: Active orders: ${activeOrders.length}');
      print('DEBUG: Completed orders: ${completedOrders.length}');
      if (_orders.isNotEmpty) {
        print(
          'DEBUG: First order ID: ${_orders.first.id}, Status: ${_orders.first.status}',
        );
      }
      _error = null;
    } catch (e) {
      print('DEBUG: Error loading orders: $e');
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
      print('DEBUG: Creating order with ID: ${order.id}');
      print('DEBUG: Customer ID: ${order.customerId}');
      print('DEBUG: Order data: ${order.toJson()}');

      final newOrder = await _orderRepository.createOrder(order);
      _orders.insert(0, newOrder);
      _error = null;
      notifyListeners();
      print('DEBUG: Order created successfully with new ID: ${newOrder.id}');
      return true;
    } catch (e) {
      print('DEBUG: Order creation error: $e');
      _error = 'Failed to create order: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      await _orderRepository.cancelOrder(orderId);
      await loadOrders(); // Reload to get updated status
      return true;
    } catch (e) {
      _error = 'Failed to cancel order';
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
