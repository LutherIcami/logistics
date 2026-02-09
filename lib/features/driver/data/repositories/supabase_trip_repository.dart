import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/trip_model.dart';
import 'trip_repository.dart';

class SupabaseTripRepository implements TripRepository {
  final SupabaseClient client;

  SupabaseTripRepository(this.client);

  @override
  Future<List<Trip>> getTripsByDriverId(String driverId) async {
    try {
      final response = await client
          .from('trips')
          .select()
          .eq('driver_id', driverId)
          .order('assigned_date', ascending: false);
      return (response as List).map((json) => Trip.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch trips: $e');
    }
  }

  @override
  Future<Trip?> getTripById(String id) async {
    try {
      final response = await client
          .from('trips')
          .select()
          .eq('id', id)
          .single();
      return Trip.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Trip> updateTripStatus(String tripId, String status) async {
    try {
      final now = DateTime.now().toIso8601String();
      Map<String, dynamic> updateData = {'status': status};

      if (status == 'in_transit') {
        updateData['pickup_date'] = now;
      } else if (status == 'delivered' || status == 'pending_confirmation') {
        updateData['delivery_date'] = now;
      }

      final response = await client
          .from('trips')
          .update(updateData)
          .eq('id', tripId)
          .select()
          .single();
      return Trip.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update trip status: $e');
    }
  }

  @override
  Future<Trip> updateTrip(Trip trip) async {
    try {
      final response = await client
          .from('trips')
          .update(trip.toJson())
          .eq('id', trip.id)
          .select()
          .single();
      return Trip.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update trip: $e');
    }
  }

  @override
  Future<Trip> createTrip(Trip trip) async {
    try {
      final response = await client
          .from('trips')
          .insert(trip.toJson())
          .select()
          .single();
      return Trip.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create trip: $e');
    }
  }

  @override
  Stream<List<Trip>> streamTrips(String driverId) {
    return client
        .from('trips')
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .order('assigned_date', ascending: false)
        .map((data) => data.map((json) => Trip.fromJson(json)).toList());
  }
}
