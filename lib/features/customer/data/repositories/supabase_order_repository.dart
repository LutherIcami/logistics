import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/order_model.dart';
import 'order_repository.dart';

class SupabaseOrderRepository implements OrderRepository {
  final SupabaseClient client;

  SupabaseOrderRepository(this.client);

  @override
  Future<List<Order>> getOrders() async {
    try {
      final response = await client
          .from('orders')
          .select()
          .order('order_date', ascending: false);
      return (response as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<List<Order>> getOrdersByCustomerId(String customerId) async {
    try {
      final response = await client
          .from('orders')
          .select()
          .eq('customer_id', customerId)
          .order('order_date', ascending: false);
      return (response as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<Order?> getOrderById(String id) async {
    try {
      final response = await client
          .from('orders')
          .select()
          .eq('id', id)
          .single();
      return Order.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Order> createOrder(Order order) async {
    try {
      final response = await client
          .from('orders')
          .insert(order.toJson())
          .select()
          .single();
      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<Order> updateOrder(Order order) async {
    try {
      final response = await client
          .from('orders')
          .update(order.toJson())
          .eq('id', order.id)
          .select()
          .single();
      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  @override
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      final updates = {'status': 'cancelled'};
      if (reason != null) {
        updates['cancellation_reason'] = reason;
      }
      await client.from('orders').update(updates).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  @override
  Stream<List<Order>> streamOrders() {
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('order_date', ascending: false)
        .map((data) => data.map((json) => Order.fromJson(json)).toList());
  }
}
