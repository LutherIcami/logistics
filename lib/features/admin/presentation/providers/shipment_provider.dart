import 'package:flutter/material.dart';
import '../../../customer/domain/models/order_model.dart';
import '../../../customer/data/repositories/order_repository.dart';
import '../../../../app/di/injection_container.dart' as di;

class ShipmentProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Order> _shipments = [];
  List<Order> _filteredShipments = [];
  String _currentFilter = 'All';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Order> get shipments => _filteredShipments;
  String get currentFilter => _currentFilter;

  // Stats
  int get pendingCount => _shipments.where((s) => s.isPending).length;
  int get activeCount =>
      _shipments.where((s) => s.isInTransit || s.isAssigned).length;
  int get completedCount => _shipments.where((s) => s.isDelivered).length;

  ShipmentProvider() : _repository = di.sl<OrderRepository>() {
    loadShipments();
  }

  final OrderRepository _repository;

  Future<void> loadShipments() async {
    _isLoading = true;
    notifyListeners();
    try {
      _shipments = await _repository.getOrders();
      _applyFilter();
      _error = null;
    } catch (e) {
      _error = 'Failed to load shipments';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String status) {
    _currentFilter = status;
    _applyFilter();
    notifyListeners();
  }

  void search(String query) {
    if (query.isEmpty) {
      _applyFilter();
    } else {
      final q = query.toLowerCase();
      _filteredShipments = _shipments.where((s) {
        final matchesQuery =
            s.id.toLowerCase().contains(q) ||
            s.customerName.toLowerCase().contains(q) ||
            s.trackingNumber?.toLowerCase().contains(q) == true ||
            s.pickupLocation.toLowerCase().contains(q) ||
            s.deliveryLocation.toLowerCase().contains(q);

        if (_currentFilter == 'All') return matchesQuery;
        return matchesQuery && s.status == _currentFilter.toLowerCase();
      }).toList();
      notifyListeners();
    }
  }

  void _applyFilter() {
    if (_currentFilter == 'All') {
      _filteredShipments = List.from(_shipments);
    } else {
      _filteredShipments = _shipments.where((s) {
        // Map display text back to status codes for filtering if needed,
        // or just compare against status or statusDisplayText
        return s.statusDisplayText == _currentFilter ||
            s.status == _currentFilter.toLowerCase().replaceAll(' ', '_');
      }).toList();
    }
  }

  Order? getShipmentById(String id) {
    try {
      return _shipments.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addShipment(Order shipment) async {
    try {
      final newShipment = await _repository.createOrder(shipment);
      _shipments.insert(0, newShipment);
      _applyFilter();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add shipment';
      notifyListeners();
    }
  }

  Future<void> updateShipment(Order shipment) async {
    try {
      final updatedShipment = await _repository.updateOrder(shipment);
      final index = _shipments.indexWhere((s) => s.id == shipment.id);
      if (index != -1) {
        _shipments[index] = updatedShipment;
        _applyFilter();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update shipment';
      notifyListeners();
    }
  }

  void updateStatus(String id, String newStatus) {
    final index = _shipments.indexWhere((s) => s.id == id);
    if (index != -1) {
      _shipments[index] = _shipments[index].copyWith(status: newStatus);
      _applyFilter();
      notifyListeners();
    }
  }

  // Helper to get available statuses
  static const List<String> availableStatuses = [
    'pending',
    'confirmed',
    'assigned',
    'in_transit',
    'delivered',
    'cancelled',
  ];
}
