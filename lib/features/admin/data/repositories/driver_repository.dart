import 'dart:async';
import 'dart:io';

import '../../../admin/domain/models/driver_model.dart';

/// Abstract contract for driver data access.
abstract class DriverRepository {
  Future<List<Driver>> getDrivers();
  Future<Driver?> getDriverById(String id);
  Future<Driver> addDriver(Driver driver);
  Future<Driver> updateDriver(Driver driver);
  Future<void> deleteDriver(String id);
  Future<String> uploadProfileImage(String driverId, File image);
}

/// Simple in-memory mock implementation for local/testing use.
class MockDriverRepository implements DriverRepository {
  final List<Driver> _drivers = [
    Driver(
      id: 'DRV-001',
      name: 'John Mwangi',
      email: 'john.mwangi@example.com',
      phone: '+254700000001',
      status: 'active',
      rating: 4.6,
      totalTrips: 120,
      currentLocation: 'Nairobi',
      currentVehicle: 'KDA 123A',
      joinDate: DateTime(2022, 1, 10),
    ),
    Driver(
      id: 'DRV-002',
      name: 'David Ochieng',
      email: 'david.ochieng@example.com',
      phone: '+254700000002',
      status: 'on_leave',
      rating: 4.3,
      totalTrips: 72,
      currentLocation: 'Mombasa',
      currentVehicle: 'KDB 456B',
      joinDate: DateTime(2021, 7, 3),
    ),
    Driver(
      id: 'DRV-003',
      name: 'Peter Kamau',
      email: 'peter.kamau@example.com',
      phone: '+254700000003',
      status: 'inactive',
      rating: 3.9,
      totalTrips: 34,
      currentLocation: 'Nakuru',
      currentVehicle: 'KDC 789C',
      joinDate: DateTime(2023, 3, 15),
    ),
  ];

  @override
  Future<List<Driver>> getDrivers() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<Driver>.unmodifiable(_drivers);
  }

  @override
  Future<Driver?> getDriverById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return _drivers.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Driver> addDriver(Driver driver) async {
    _drivers.add(driver);
    return driver;
  }

  @override
  Future<Driver> updateDriver(Driver driver) async {
    final index = _drivers.indexWhere((d) => d.id == driver.id);
    if (index != -1) {
      _drivers[index] = driver;
    } else {
      _drivers.add(driver);
    }
    return driver;
  }

  @override
  Future<void> deleteDriver(String id) async {
    _drivers.removeWhere((d) => d.id == id);
  }

  @override
  Future<String> uploadProfileImage(String driverId, File image) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return 'https://via.placeholder.com/150';
  }
}
