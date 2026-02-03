import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../../domain/models/customer_model.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers();
  Future<Customer?> getCustomerById(String id);
  Future<Customer> updateCustomer(Customer customer);
  Future<String> uploadProfileImage(String customerId, File image);
}

class SupabaseCustomerRepository implements CustomerRepository {
  final SupabaseClient client;

  SupabaseCustomerRepository(this.client);

  @override
  Future<List<Customer>> getCustomers() async {
    try {
      final response = await client.from('customers').select().order('name');
      return (response as List).map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      // Fallback: get from profiles with role=customer
      final response = await client
          .from('profiles')
          .select()
          .eq('role', 'customer')
          .order('full_name');
      return (response as List)
          .map(
            (json) => Customer(
              id: json['id'],
              name: json['full_name'] ?? '',
              email: json['email'] ?? '',
              phone: '',
              joinDate: DateTime.now(),
            ),
          )
          .toList();
    }
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    try {
      // First try to get from customers table
      final response = await client
          .from('customers')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response != null) {
        return Customer.fromJson(response);
      }

      // If not in customers table, try to get basic info from profiles
      final profileResponse = await client
          .from('profiles')
          .select()
          .eq('id', id)
          .single();
      return Customer(
        id: id,
        name: profileResponse['full_name'] ?? '',
        email: profileResponse['email'] ?? '',
        phone: '',
        joinDate: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    try {
      final response = await client
          .from('customers')
          .upsert(customer.toJson())
          .select()
          .single();
      return Customer.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String customerId, File image) async {
    try {
      final fileExt = path.extension(image.path);
      final fileName =
          '$customerId${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = '$customerId/$fileName';

      await client.storage
          .from('customer-profiles')
          .upload(
            filePath,
            image,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String imageUrl = client.storage
          .from('customer-profiles')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
}
