import 'dart:async';
import 'dart:io';
import '../../../admin/domain/models/vehicle_model.dart';
import '../../../admin/domain/models/fleet_models.dart';

/// Abstract contract for vehicle data access.
abstract class VehicleRepository {
  Future<List<Vehicle>> getVehicles();
  Future<Vehicle?> getVehicleById(String id);
  Future<Vehicle> addVehicle(Vehicle vehicle);
  Future<Vehicle> updateVehicle(Vehicle vehicle);
  Future<void> deleteVehicle(String id);
  Future<List<Vehicle>> getVehiclesByStatus(String status);
  Future<List<Vehicle>> getVehiclesNeedingMaintenance();
  Future<List<String>> uploadVehicleImages(String vehicleId, List<File> images);

  // New Fuel and Maintenance methods
  Future<List<FuelLog>> getFuelLogs({String? vehicleId});
  Future<FuelLog> addFuelLog(FuelLog log);
  Future<List<MaintenanceLog>> getMaintenanceLogs({String? vehicleId});
  Future<MaintenanceLog> addMaintenanceLog(MaintenanceLog log);
}

/// Simple in-memory mock implementation for local/testing use.
class MockVehicleRepository implements VehicleRepository {
  final List<Vehicle> _vehicles = [
    Vehicle(
      id: 'VEH-001',
      registrationNumber: 'KDA 123A',
      make: 'Isuzu',
      model: 'FVR 34S',
      year: 2020,
      type: 'truck',
      status: 'active',
      assignedDriverId: 'DRV-001',
      assignedDriverName: 'John Mwangi',
      fuelCapacity: 200.0,
      currentFuelLevel: 150.0,
      mileage: 45000.0,
      purchaseDate: DateTime(2020, 6, 15),
      lastMaintenanceDate: DateTime(2024, 1, 10),
      nextMaintenanceDate: DateTime(2024, 7, 10),
      currentLocation: 'Nairobi',
      loadCapacity: 10.0,
      insuranceExpiry: '2024-12-31',
      licenseExpiry: '2025-06-30',
      purchasePrice: 4500000.0,
      currentValue: 3800000.0,
      specifications: {
        'engine': '4HK1-TC 5.2L Turbo',
        'horsepower': '190 hp',
        'transmission': '6-speed manual',
        'drive_type': '4x2',
      },
    ),
    Vehicle(
      id: 'VEH-002',
      registrationNumber: 'KDB 456B',
      make: 'Toyota',
      model: 'Hilux',
      year: 2022,
      type: 'pickup',
      status: 'active',
      assignedDriverId: 'DRV-002',
      assignedDriverName: 'David Ochieng',
      fuelCapacity: 80.0,
      currentFuelLevel: 60.0,
      mileage: 28000.0,
      purchaseDate: DateTime(2022, 3, 20),
      lastMaintenanceDate: DateTime(2023, 12, 15),
      nextMaintenanceDate: DateTime(2024, 6, 15),
      currentLocation: 'Mombasa',
      loadCapacity: 1.2,
      insuranceExpiry: '2025-03-20',
      licenseExpiry: '2026-03-20',
      purchasePrice: 2800000.0,
      currentValue: 2600000.0,
    ),
    Vehicle(
      id: 'VEH-003',
      registrationNumber: 'KDC 789C',
      make: 'Nissan',
      model: 'NV350',
      year: 2021,
      type: 'van',
      status: 'maintenance',
      fuelCapacity: 75.0,
      currentFuelLevel: 20.0,
      mileage: 32000.0,
      purchaseDate: DateTime(2021, 8, 10),
      lastMaintenanceDate: DateTime(2024, 2, 1),
      nextMaintenanceDate: DateTime(2024, 5, 1),
      currentLocation: 'Nairobi Workshop',
      loadCapacity: 1.5,
      insuranceExpiry: '2024-08-10',
      licenseExpiry: '2025-08-10',
      purchasePrice: 2200000.0,
      currentValue: 1950000.0,
    ),
    Vehicle(
      id: 'VEH-004',
      registrationNumber: 'KDD 012D',
      make: 'Isuzu',
      model: 'NMR 85',
      year: 2019,
      type: 'truck',
      status: 'inactive',
      fuelCapacity: 180.0,
      currentFuelLevel: 10.0,
      mileage: 78000.0,
      purchaseDate: DateTime(2019, 11, 5),
      lastMaintenanceDate: DateTime(2023, 8, 20),
      nextMaintenanceDate: DateTime(2024, 2, 20),
      currentLocation: 'Nairobi Depot',
      loadCapacity: 8.0,
      insuranceExpiry: '2024-11-05',
      licenseExpiry: '2025-11-05',
      purchasePrice: 3200000.0,
      currentValue: 1800000.0,
    ),
    Vehicle(
      id: 'VEH-005',
      registrationNumber: 'KDE 345E',
      make: 'Hino',
      model: '500 Series',
      year: 2023,
      type: 'truck',
      status: 'active',
      fuelCapacity: 220.0,
      currentFuelLevel: 180.0,
      mileage: 15000.0,
      purchaseDate: DateTime(2023, 1, 25),
      lastMaintenanceDate: DateTime(2023, 12, 1),
      nextMaintenanceDate: DateTime(2024, 6, 1),
      currentLocation: 'Eldoret',
      loadCapacity: 12.0,
      insuranceExpiry: '2025-01-25',
      licenseExpiry: '2026-01-25',
      purchasePrice: 5200000.0,
      currentValue: 5000000.0,
    ),
  ];

  @override
  Future<List<Vehicle>> getVehicles() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<Vehicle>.unmodifiable(_vehicles);
  }

  @override
  Future<Vehicle?> getVehicleById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return _vehicles.firstWhere((vehicle) => vehicle.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _vehicles.add(vehicle);
    return vehicle;
  }

  @override
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
    } else {
      _vehicles.add(vehicle);
    }
    return vehicle;
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _vehicles.removeWhere((vehicle) => vehicle.id == id);
  }

  @override
  Future<List<Vehicle>> getVehiclesByStatus(String status) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _vehicles.where((vehicle) => vehicle.status == status).toList();
  }

  @override
  Future<List<Vehicle>> getVehiclesNeedingMaintenance() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _vehicles.where((vehicle) => vehicle.needsMaintenance).toList();
  }

  @override
  Future<List<String>> uploadVehicleImages(
    String vehicleId,
    List<File> images,
  ) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return images.map((_) => 'https://via.placeholder.com/400').toList();
  }

  @override
  Future<List<FuelLog>> getFuelLogs({String? vehicleId}) async => [];

  @override
  Future<FuelLog> addFuelLog(FuelLog log) async => log;

  @override
  Future<List<MaintenanceLog>> getMaintenanceLogs({String? vehicleId}) async =>
      [];

  @override
  Future<MaintenanceLog> addMaintenanceLog(MaintenanceLog log) async => log;
}
