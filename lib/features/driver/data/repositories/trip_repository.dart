import 'dart:async';
import '../../domain/models/trip_model.dart';

/// Abstract contract for trip data access.
abstract class TripRepository {
  Future<List<Trip>> getTripsByDriverId(String driverId);
  Future<Trip?> getTripById(String id);
  Future<Trip> updateTripStatus(String tripId, String status);
  Future<Trip> updateTrip(Trip trip);
  Future<Trip> createTrip(Trip trip);
  Stream<List<Trip>> streamTrips(String driverId);
}

/// Simple in-memory mock implementation for local/testing use.
class MockTripRepository implements TripRepository {
  final List<Trip> _trips = [
    Trip(
      id: 'TRP-001',
      driverId: 'DRV-001',
      driverName: 'John Mwangi',
      pickupLocation: 'Nairobi Warehouse, Industrial Area',
      deliveryLocation: 'Mombasa Port, Container Terminal',
      customerName: 'ABC Logistics Ltd',
      customerPhone: '+254712345678',
      status: 'assigned',
      assignedDate: DateTime.now().subtract(const Duration(hours: 2)),
      estimatedDelivery: DateTime.now().add(const Duration(hours: 8)),
      vehicleId: 'VEH-001',
      vehiclePlate: 'KDA 123A',
      cargoType: 'General Cargo',
      cargoWeight: 5000.0,
      specialInstructions: 'Handle with care. Fragile items included.',
      distance: 480.0,
      estimatedEarnings: 15000.0,
    ),
    Trip(
      id: 'TRP-002',
      driverId: 'DRV-001',
      driverName: 'John Mwangi',
      pickupLocation: 'Eldoret Distribution Center',
      deliveryLocation: 'Kisumu Market, Oginga Odinga Street',
      customerName: 'Kenya Fresh Produce',
      customerPhone: '+254723456789',
      status: 'in_transit',
      assignedDate: DateTime.now().subtract(const Duration(days: 1)),
      pickupDate: DateTime.now().subtract(const Duration(hours: 4)),
      estimatedDelivery: DateTime.now().add(const Duration(hours: 3)),
      vehicleId: 'VEH-001',
      vehiclePlate: 'KDA 123A',
      cargoType: 'Perishable Goods',
      cargoWeight: 3000.0,
      specialInstructions: 'Keep refrigerated. Urgent delivery.',
      distance: 320.0,
      estimatedEarnings: 12000.0,
    ),
    Trip(
      id: 'TRP-003',
      driverId: 'DRV-001',
      driverName: 'John Mwangi',
      pickupLocation: 'Nakuru Depot',
      deliveryLocation: 'Nairobi CBD, Tom Mboya Street',
      customerName: 'City Retailers',
      customerPhone: '+254734567890',
      status: 'delivered',
      assignedDate: DateTime.now().subtract(const Duration(days: 2)),
      pickupDate: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
      deliveryDate: DateTime.now().subtract(const Duration(days: 1)),
      estimatedDelivery: DateTime.now().subtract(const Duration(days: 1)),
      vehicleId: 'VEH-001',
      vehiclePlate: 'KDA 123A',
      cargoType: 'Electronics',
      cargoWeight: 2000.0,
      distance: 160.0,
      estimatedEarnings: 8000.0,
    ),
    Trip(
      id: 'TRP-004',
      driverId: 'DRV-001',
      driverName: 'John Mwangi',
      pickupLocation: 'Thika Highway, Exit 5',
      deliveryLocation: 'Machakos Town, Market Square',
      customerName: 'Machakos Traders',
      customerPhone: '+254745678901',
      status: 'assigned',
      assignedDate: DateTime.now().subtract(const Duration(hours: 1)),
      estimatedDelivery: DateTime.now().add(const Duration(hours: 5)),
      vehicleId: 'VEH-001',
      vehiclePlate: 'KDA 123A',
      cargoType: 'Construction Materials',
      cargoWeight: 8000.0,
      distance: 80.0,
      estimatedEarnings: 6000.0,
    ),
  ];

  @override
  Future<List<Trip>> getTripsByDriverId(String driverId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _trips.where((trip) => trip.driverId == driverId).toList()
      ..sort((a, b) => b.assignedDate.compareTo(a.assignedDate));
  }

  @override
  Future<Trip?> getTripById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return _trips.firstWhere((trip) => trip.id == id);
    } catch (e) {
      throw Exception('Failed to update trip: $e');
    }
  }

  @override
  Future<Trip> updateTripStatus(String tripId, String status) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _trips.indexWhere((trip) => trip.id == tripId);
    if (index != -1) {
      final now = DateTime.now();
      final updatedTrip = _trips[index].copyWith(
        status: status,
        pickupDate: status == 'in_transit' && _trips[index].pickupDate == null
            ? now
            : _trips[index].pickupDate,
        deliveryDate:
            status == 'delivered' && _trips[index].deliveryDate == null
            ? now
            : _trips[index].deliveryDate,
      );
      _trips[index] = updatedTrip;
      return updatedTrip;
    }
    throw Exception('Trip not found');
  }

  @override
  Future<Trip> updateTrip(Trip trip) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _trips.indexWhere((t) => t.id == trip.id);
    if (index != -1) {
      _trips[index] = trip;
    } else {
      _trips.add(trip);
    }
    return trip;
  }

  @override
  Future<Trip> createTrip(Trip trip) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _trips.add(trip);
    return trip;
  }

  @override
  Stream<List<Trip>> streamTrips(String driverId) {
    return Stream.value(
      _trips.where((trip) => trip.driverId == driverId).toList(),
    );
  }
}
