import 'package:flutter/foundation.dart';
import '../../../admin/domain/models/vehicle_model.dart';
import '../../../admin/data/repositories/vehicle_repository.dart';
import '../../../../app/di/injection_container.dart' as di;

class VehicleProvider extends ChangeNotifier {
  VehicleProvider() : _repository = di.sl<VehicleRepository>();

  final VehicleRepository _repository;

  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered vehicles
  List<Vehicle> get activeVehicles =>
      _vehicles.where((v) => v.isActive).toList();
  List<Vehicle> get maintenanceVehicles =>
      _vehicles.where((v) => v.isInMaintenance).toList();
  List<Vehicle> get inactiveVehicles =>
      _vehicles.where((v) => v.isInactive).toList();

  // Stats
  int get totalVehicles => _vehicles.length;
  int get activeVehiclesCount => activeVehicles.length;
  int get maintenanceVehiclesCount => maintenanceVehicles.length;
  int get inactiveVehiclesCount => inactiveVehicles.length;

  List<Vehicle> get vehiclesNeedingMaintenance =>
      _vehicles.where((v) => v.needsMaintenance).toList();

  List<Vehicle> get vehiclesWithExpiredInsurance =>
      _vehicles.where((v) => v.insuranceExpired).toList();

  List<Vehicle> get vehiclesWithExpiredLicense =>
      _vehicles.where((v) => v.licenseExpired).toList();

  double get totalFleetValue =>
      _vehicles.fold(0.0, (sum, vehicle) => sum + (vehicle.currentValue ?? 0.0));

  double get averageFuelEfficiency {
    final vehiclesWithFuel = _vehicles.where((v) => v.fuelCapacity > 0);
    if (vehiclesWithFuel.isEmpty) return 0.0;
    return vehiclesWithFuel.fold(0.0, (sum, v) => sum + v.fuelLevelPercentage) / vehiclesWithFuel.length;
  }

  Future<void> loadInitialVehicles() async {
    _setLoading(true);
    try {
      _vehicles = await _repository.getVehicles();
      _error = null;
    } catch (e) {
      _error = 'Failed to load vehicles';
    } finally {
      _setLoading(false);
    }
  }

  Future<Vehicle?> getVehicleById(String id) async {
    try {
      return await _repository.getVehicleById(id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> addVehicle(Vehicle vehicle) async {
    try {
      final newVehicle = await _repository.addVehicle(vehicle);
      _vehicles.add(newVehicle);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add vehicle';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVehicle(Vehicle vehicle) async {
    try {
      final updatedVehicle = await _repository.updateVehicle(vehicle);
      final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        _vehicles[index] = updatedVehicle;
      } else {
        _vehicles.add(updatedVehicle);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update vehicle';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      await _repository.deleteVehicle(vehicleId);
      _vehicles.removeWhere((v) => v.id == vehicleId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete vehicle';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVehicleMaintenance(String vehicleId, DateTime lastMaintenance, DateTime nextMaintenance) async {
    try {
      final vehicle = await getVehicleById(vehicleId);
      if (vehicle != null) {
        final updatedVehicle = vehicle.copyWith(
          lastMaintenanceDate: lastMaintenance,
          nextMaintenanceDate: nextMaintenance,
          status: 'active', // Assuming maintenance is complete
        );
        return await updateVehicle(updatedVehicle);
      }
      return false;
    } catch (e) {
      _error = 'Failed to update maintenance';
      notifyListeners();
      return false;
    }
  }

  Future<List<Vehicle>> getVehiclesNeedingMaintenance() async {
    try {
      return await _repository.getVehiclesNeedingMaintenance();
    } catch (_) {
      return [];
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
