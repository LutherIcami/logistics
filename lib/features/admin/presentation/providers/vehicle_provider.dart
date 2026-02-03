import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../admin/domain/models/vehicle_model.dart';
import '../../../admin/domain/models/fleet_models.dart';
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

  List<Vehicle> get lowFuelVehicles =>
      _vehicles.where((v) => v.isActive && v.fuelLevelPercentage < 15).toList();

  double get totalFleetValue => _vehicles.fold(
    0.0,
    (sum, vehicle) => sum + (vehicle.currentValue ?? 0.0),
  );

  double get averageFuelEfficiency {
    final vehiclesWithFuel = _vehicles.where((v) => v.fuelCapacity > 0);
    if (vehiclesWithFuel.isEmpty) return 0.0;
    return vehiclesWithFuel.fold(0.0, (sum, v) => sum + v.fuelLevelPercentage) /
        vehiclesWithFuel.length;
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
      _error = 'Failed to add vehicle: ${e.toString()}';
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
      _error = 'Failed to update vehicle: ${e.toString()}';
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
      _error = 'Failed to delete vehicle: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVehicleMaintenance(
    String vehicleId,
    DateTime lastMaintenance,
    DateTime nextMaintenance,
  ) async {
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

  Future<List<String>> uploadVehicleImages(
    String vehicleId,
    List<File> images,
  ) async {
    try {
      return await _repository.uploadVehicleImages(vehicleId, images);
    } catch (e) {
      _error = 'Failed to upload images';
      notifyListeners();
      return [];
    }
  }

  List<FuelLog> _fuelLogs = [];
  List<MaintenanceLog> _maintenanceLogs = [];

  List<FuelLog> get fuelLogs => _fuelLogs;
  List<MaintenanceLog> get maintenanceLogs => _maintenanceLogs;

  Future<void> loadLogs({String? vehicleId}) async {
    try {
      final results = await Future.wait([
        _repository.getFuelLogs(vehicleId: vehicleId),
        _repository.getMaintenanceLogs(vehicleId: vehicleId),
      ]);
      _fuelLogs = results[0] as List<FuelLog>;
      _maintenanceLogs = results[1] as List<MaintenanceLog>;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load logs';
      notifyListeners();
    }
  }

  Future<bool> recordFuelLog(FuelLog log) async {
    try {
      final newLog = await _repository.addFuelLog(log);
      _fuelLogs.insert(0, newLog);

      // Update vehicle mileage if this is a newer odometer reading
      final vehicle = await getVehicleById(log.vehicleId);
      if (vehicle != null && log.odometer > vehicle.mileage) {
        await updateVehicle(vehicle.copyWith(mileage: log.odometer));
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to record fuel log';
      notifyListeners();
      return false;
    }
  }

  Future<bool> recordMaintenanceLog(MaintenanceLog log) async {
    try {
      final newLog = await _repository.addMaintenanceLog(log);
      _maintenanceLogs.insert(0, newLog);

      // Update vehicle maintenance info
      final vehicle = await getVehicleById(log.vehicleId);
      if (vehicle != null) {
        final updatedVehicle = vehicle.copyWith(
          lastMaintenanceDate: log.date,
          nextMaintenanceDate: log.nextServiceDate,
          mileage: log.odometer > vehicle.mileage
              ? log.odometer
              : vehicle.mileage,
          status: 'active',
        );
        await updateVehicle(updatedVehicle);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to record maintenance log';
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
