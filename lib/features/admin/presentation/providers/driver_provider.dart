import 'package:flutter/foundation.dart';

import '../../../admin/domain/models/driver_model.dart';
import '../../../admin/data/repositories/driver_repository.dart';
import '../../../../app/di/injection_container.dart' as di;

class DriverProvider extends ChangeNotifier {
  DriverProvider() : _repository = di.sl<DriverRepository>();

  final DriverRepository _repository;

  List<Driver> _drivers = [];
  bool _isLoading = false;
  String? _error;

  String _searchQuery = '';
  String _statusFilter = 'all'; // all, active, on_leave, inactive

  List<Driver> get drivers => _drivers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  List<Driver> get filteredDrivers => getMappedDrivers(_statusFilter);

  List<Driver> getMappedDrivers(String status) {
    return _drivers.where((driver) {
      final matchesStatus = status.toLowerCase() == 'all'
          ? true
          : driver.status.toLowerCase() == status.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty
          ? true
          : driver.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                driver.email.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                driver.phone.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                driver.id.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  Future<void> loadInitialDrivers() async {
    _setLoading(true);
    try {
      _drivers = await _repository.getDrivers();
      _error = null;
    } catch (e) {
      _error = 'Failed to load drivers';
    } finally {
      _setLoading(false);
    }
  }

  Future<Driver?> getDriverById(String id) async {
    try {
      return await _repository.getDriverById(id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> addDriver(Driver driver) async {
    try {
      final newDriver = await _repository.addDriver(driver);
      _drivers.add(newDriver);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add driver';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDriver(Driver driver) async {
    try {
      final updatedDriver = await _repository.updateDriver(driver);
      final index = _drivers.indexWhere((d) => d.id == driver.id);
      if (index != -1) {
        _drivers[index] = updatedDriver;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update driver';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDriver(String id) async {
    try {
      await _repository.deleteDriver(id);
      _drivers.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete driver';
      notifyListeners();
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
