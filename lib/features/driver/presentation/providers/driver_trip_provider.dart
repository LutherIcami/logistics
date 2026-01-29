import 'package:flutter/foundation.dart';
import '../../domain/models/trip_model.dart';
import '../../data/repositories/trip_repository.dart';
import '../../../../app/di/injection_container.dart' as di;
import '../../../admin/domain/models/driver_model.dart';
import '../../../admin/domain/models/vehicle_model.dart';
import '../../../admin/data/repositories/driver_repository.dart';
import '../../../admin/data/repositories/vehicle_repository.dart';

class DriverTripProvider extends ChangeNotifier {
  DriverTripProvider()
    : _tripRepository = di.sl<TripRepository>(),
      _driverRepository = di.sl<DriverRepository>(),
      _vehicleRepository = di.sl<VehicleRepository>();

  final TripRepository _tripRepository;
  final DriverRepository _driverRepository;
  final VehicleRepository _vehicleRepository;

  // Current logged-in driver (in real app, this would come from auth)
  String? _currentDriverId;
  Driver? _currentDriver;
  Vehicle? _assignedVehicle;
  List<Trip> _trips = [];
  bool _isLoading = false;
  String? _error;

  String? get currentDriverId => _currentDriverId;
  Driver? get currentDriver => _currentDriver;
  Vehicle? get assignedVehicle => _assignedVehicle;
  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasMaintenanceAlert => _assignedVehicle?.needsMaintenance ?? false;

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

  int get unreadNotificationCount {
    int count = 0;
    // Maintenance alert is a global unread state
    if (hasMaintenanceAlert) count++;

    // Unassigned (new) trips are considered unread notifications
    // Using isAssigned as a proxy for "Needs Action/Unread"
    count += assignedTrips.length;

    return count;
  }

  double getEarningsForPeriod(String period) {
    final now = DateTime.now();
    DateTime threshold;

    switch (period) {
      case 'Today':
        threshold = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        threshold = now.subtract(Duration(days: now.weekday - 1));
        threshold = DateTime(threshold.year, threshold.month, threshold.day);
        break;
      case 'This Month':
        threshold = DateTime(now.year, now.month, 1);
        break;
      case 'All Time':
      default:
        return totalEarnings;
    }

    return _trips
        .where(
          (t) =>
              t.isDelivered &&
              t.deliveryDate != null &&
              t.deliveryDate!.isAfter(threshold),
        )
        .fold(0.0, (sum, trip) => sum + (trip.estimatedEarnings ?? 0.0));
  }

  int getTripCountForPeriod(String period) {
    final now = DateTime.now();
    DateTime threshold;

    switch (period) {
      case 'Today':
        threshold = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        threshold = now.subtract(Duration(days: now.weekday - 1));
        threshold = DateTime(threshold.year, threshold.month, threshold.day);
        break;
      case 'This Month':
        threshold = DateTime(now.year, now.month, 1);
        break;
      case 'All Time':
      default:
        return _trips.where((t) => t.isDelivered).length;
    }

    return _trips
        .where(
          (t) =>
              t.isDelivered &&
              t.deliveryDate != null &&
              t.deliveryDate!.isAfter(threshold),
        )
        .length;
  }

  double get weekEarnings => getEarningsForPeriod('This Week');

  double get totalDistance =>
      _trips.fold(0.0, (sum, trip) => sum + (trip.distance ?? 0.0));

  double get totalEarnings => _trips
      .where((t) => t.isDelivered)
      .fold(0.0, (sum, trip) => sum + (trip.estimatedEarnings ?? 0.0));

  List<Trip> get recentEarnings =>
      _trips.where((t) => t.isDelivered).toList()..sort(
        (a, b) => (b.deliveryDate ?? b.assignedDate).compareTo(
          a.deliveryDate ?? a.assignedDate,
        ),
      );

  Future<void> setCurrentDriver(String driverId) async {
    _currentDriverId = driverId;
    _setLoading(true);
    try {
      _currentDriver = await _driverRepository.getDriverById(driverId);

      // Auto-initialize driver record if missing for a valid auth user
      if (_currentDriver == null) {
        // We can't easily get the name/email here without injecting AuthProvider
        // But we can attempt a basic initialization if the repository supports it
        // Or we set a specific error that the dashboard can handle with an "Initialize" button
      }

      if (_currentDriver?.currentVehicle != null) {
        _assignedVehicle = await _vehicleRepository.getVehicleById(
          _currentDriver!.currentVehicle!,
        );
      } else {
        _assignedVehicle = null;
      }
      await loadTrips();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> initializeDriverProfile(String name, String email) async {
    if (_currentDriverId == null) return;
    _setLoading(true);
    try {
      final newDriver = Driver(
        id: _currentDriverId!,
        name: name,
        email: email,
        phone: '',
        status: 'active',
        rating: 5.0,
        joinDate: DateTime.now(),
      );
      await _driverRepository.addDriver(newDriver);
      _currentDriver = newDriver;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Initialization failed: $e';
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
      final updatedTrip = await _tripRepository.updateTripStatus(
        tripId,
        status,
      );
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
