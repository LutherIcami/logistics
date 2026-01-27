import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/vehicle_model.dart';
import 'vehicle_repository.dart';

class SupabaseVehicleRepository implements VehicleRepository {
  final SupabaseClient client;

  SupabaseVehicleRepository(this.client);

  @override
  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await client.from('vehicles').select();
      return (response as List).map((json) => Vehicle.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch vehicles: $e');
    }
  }

  @override
  Future<Vehicle?> getVehicleById(String id) async {
    try {
      final response = await client
          .from('vehicles')
          .select()
          .eq('id', id)
          .single();
      return Vehicle.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    try {
      final response = await client
          .from('vehicles')
          .insert(vehicle.toJson())
          .select()
          .single();
      return Vehicle.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  @override
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    try {
      final response = await client
          .from('vehicles')
          .update(vehicle.toJson())
          .eq('id', vehicle.id)
          .select()
          .single();
      return Vehicle.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await client.from('vehicles').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  @override
  Future<List<Vehicle>> getVehiclesByStatus(String status) async {
    try {
      final response = await client
          .from('vehicles')
          .select()
          .eq('status', status);
      return (response as List).map((json) => Vehicle.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch vehicles by status: $e');
    }
  }

  @override
  Future<List<Vehicle>> getVehiclesNeedingMaintenance() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await client
          .from('vehicles')
          .select()
          .lt('nextMaintenanceDate', now);
      return (response as List).map((json) => Vehicle.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch vehicles needing maintenance: $e');
    }
  }
}
