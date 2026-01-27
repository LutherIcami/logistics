import 'package:flutter/foundation.dart';
import '../../domain/models/trip_model.dart';
import '../../data/repositories/trip_repository.dart';
import '../../../../app/di/injection_container.dart' as di;
import '../../../admin/domain/models/driver_model.dart';
import '../../../admin/data/repositories/driver_repository.dart';

class DriverTripProvider extends ChangeNotifier {
  DriverTripProvider() 
      : _tripRepository = di.sl<TripRepository>(),
        _driverRepository = di.sl<DriverRepository>();

  final TripRepository _tripRepository;
  final DriverRepository _driverRepository;

  // Current logged-in driver (in real app, this would come from auth)
  String? _currentDriverId;
  Driver? _currentDriver;
  List<Trip> _trips = [];
  bool _isLoading = false;
  String? _error;

  String? get currentDriverId => _currentDriverId;
  Driver? get currentDriver => _currentDriver;
  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered trips by status
  List<Trip> get assignedTrips =>
      _trips.where((trip) => trip.isAssigned).toList();
  List<Trip> get inTransitTrips =>
      _trips.where((trip) => trip.isInTransit).toList();
  List<Trip> get completedTrips =>
      _trips.where((trip) => trip.isDelivered).toList();

  // Stats
  int get totalTrips => _trips.length;
  int get activeTrips => assignedTrips.length + inTransitTrips.length;
  double get totalEarnings =>
      _trips.where((t) => t.isDelivered).fold(0.0, (sum, trip) => sum + (trip.estimatedEarnings ?? 0.0));

  Future<void> setCurrentDriver(String driverId) async {
    _currentDriverId = driverId;
    _setLoading(true);
    try {
      _currentDriver = await _driverRepository.getDriverById(driverId);
      await loadTrips();
      _error = null;
    } catch (e) {
      _error = 'Failed to load driver data';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTrips() async {
    if (_currentDriverId == null) return;
    _setLoading(true);
    try {
      _trips = await _tripRepository.getTripsByDriverId(_currentDriverId!);
      _error = null;
    } catch (e) {
      _error = 'Failed to load trips';
    } finally {
      _setLoading(false);
    }
  }

  Future<Trip?> getTripById(String tripId) async {
    try {
      return await _tripRepository.getTripById(tripId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateTripStatus(String tripId, String status) async {
    try {
      final updatedTrip = await _tripRepository.updateTripStatus(tripId, status);
      final index = _trips.indexWhere((t) => t.id == tripId);
      if (index != -1) {
        _trips[index] = updatedTrip;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update trip status';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDriverLocation(String location) async {
    if (_currentDriver == null) return false;
    try {
      final updatedDriver = _currentDriver!.copyWith(currentLocation: location);
      await _driverRepository.updateDriver(updatedDriver);
      _currentDriver = updatedDriver;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update location';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDriverStatus(String status) async {
    if (_currentDriver == null) return false;
    try {
      final updatedDriver = _currentDriver!.copyWith(status: status);
      await _driverRepository.updateDriver(updatedDriver);
      _currentDriver = updatedDriver;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update status';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDriver(Driver driver) async {
    try {
      await _driverRepository.updateDriver(driver);
      _currentDriver = driver;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update driver';
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
