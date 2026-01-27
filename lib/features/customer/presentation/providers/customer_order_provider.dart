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

  Future<void> initializeCustomer(String customerId) async {
    _currentCustomerId = customerId;
    _setLoading(true);
    try {
      _currentCustomer = await _customerRepository.getCustomerById(customerId);
      await loadOrders();
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
      _error = null;
    } catch (e) {
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
      final newOrder = await _orderRepository.createOrder(order);
      _orders.insert(0, newOrder);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create order';
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

  Future<bool> updateCustomer(Customer customer) async {
    try {
      _currentCustomer = customer;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update customer';
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
