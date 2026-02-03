import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../../domain/models/vehicle_model.dart';
import '../../domain/models/fleet_models.dart';
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
      final threshold = DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String();
      final response = await client
          .from('vehicles')
          .select()
          .lt('nextMaintenanceDate', threshold);
      return (response as List).map((json) => Vehicle.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch vehicles needing maintenance: $e');
    }
  }

  @override
  Future<List<String>> uploadVehicleImages(
    String vehicleId,
    List<File> images,
  ) async {
    try {
      final List<String> imageUrls = [];

      for (var i = 0; i < images.length; i++) {
        final file = images[i];
        final fileExt = path.extension(file.path);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i$fileExt';
        final filePath = '$vehicleId/$fileName';

        await client.storage
            .from('vehicle-images')
            .upload(
              filePath,
              file,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );

        final String imageUrl = client.storage
            .from('vehicle-images')
            .getPublicUrl(filePath);

        imageUrls.add(imageUrl);
      }

      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload vehicle images: $e');
    }
  }

  @override
  Future<List<FuelLog>> getFuelLogs({String? vehicleId}) async {
    try {
      var query = client.from('fuel_logs').select();
      if (vehicleId != null) {
        query = query.eq('vehicle_id', vehicleId);
      }
      final response = await query.order('date', ascending: false);
      return (response as List).map((json) => FuelLog.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch fuel logs: $e');
    }
  }

  @override
  Future<FuelLog> addFuelLog(FuelLog log) async {
    try {
      final response = await client
          .from('fuel_logs')
          .insert(log.toJson())
          .select()
          .single();
      return FuelLog.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add fuel log: $e');
    }
  }

  @override
  Future<List<MaintenanceLog>> getMaintenanceLogs({String? vehicleId}) async {
    try {
      var query = client.from('maintenance_logs').select();
      if (vehicleId != null) {
        query = query.eq('vehicle_id', vehicleId);
      }
      final response = await query.order('date', ascending: false);
      return (response as List)
          .map((json) => MaintenanceLog.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch maintenance logs: $e');
    }
  }

  @override
  Future<MaintenanceLog> addMaintenanceLog(MaintenanceLog log) async {
    try {
      final response = await client
          .from('maintenance_logs')
          .insert(log.toJson())
          .select()
          .single();
      return MaintenanceLog.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add maintenance log: $e');
    }
  }
}
