import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../../domain/models/driver_model.dart';
import 'driver_repository.dart';

class SupabaseDriverRepository implements DriverRepository {
  final SupabaseClient client;

  SupabaseDriverRepository(this.client);

  @override
  Future<List<Driver>> getDrivers() async {
    try {
      final response = await client.from('drivers').select();
      return (response as List).map((json) => Driver.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch drivers: $e');
    }
  }

  @override
  Future<Driver?> getDriverById(String id) async {
    try {
      final response = await client
          .from('drivers')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Driver.fromJson(response);
    } catch (e) {
      throw Exception('Database error while fetching driver profile: $e');
    }
  }

  @override
  Future<Driver> addDriver(Driver driver) async {
    try {
      final response = await client
          .from('drivers')
          .insert(driver.toJson())
          .select()
          .single();
      return Driver.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add driver: $e');
    }
  }

  @override
  Future<Driver> updateDriver(Driver driver) async {
    try {
      final response = await client
          .from('drivers')
          .update(driver.toJson())
          .eq('id', driver.id)
          .select()
          .single();
      return Driver.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update driver: $e');
    }
  }

  @override
  Future<void> deleteDriver(String id) async {
    try {
      await client.from('drivers').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete driver: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String driverId, File image) async {
    try {
      final fileExt = path.extension(image.path);
      final fileName =
          '$driverId${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = '$driverId/$fileName';

      await client.storage
          .from('driver-profiles')
          .upload(
            filePath,
            image,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String imageUrl = client.storage
          .from('driver-profiles')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
}
