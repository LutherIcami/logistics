import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';

abstract class PaymentRepository {
  Future<Map<String, dynamic>> initiateMpesaStkPush({
    required String phoneNumber,
    required double amount,
    required String orderId,
  });

  Future<String> checkPaymentStatus(String checkoutRequestId);
}

class SupabasePaymentRepository implements PaymentRepository {
  final SupabaseClient client;
  final Dio dio;

  SupabasePaymentRepository(this.client, this.dio);

  @override
  Future<Map<String, dynamic>> initiateMpesaStkPush({
    required String phoneNumber,
    required double amount,
    required String orderId,
  }) async {
    try {
      // Formats phone number to 2547XXXXXXXX
      String formattedPhone = phoneNumber.replaceAll('+', '');
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '254${formattedPhone.substring(1)}';
      } else if (formattedPhone.startsWith('7') ||
          formattedPhone.startsWith('1')) {
        formattedPhone = '254$formattedPhone';
      }

      // Call Supabase Edge Function
      final response = await client.functions.invoke(
        'mpesa-stk-push',
        body: {
          'phone': formattedPhone,
          'amount': amount.toInt(),
          'orderId': orderId,
        },
      );

      if (response.status != 200) {
        throw Exception(
          response.data['error'] ?? 'Failed to initiate M-Pesa payment',
        );
      }

      return response.data;
    } catch (e) {
      throw Exception('M-Pesa Error: $e');
    }
  }

  @override
  Future<String> checkPaymentStatus(String checkoutRequestId) async {
    try {
      final response = await client
          .from('payments')
          .select('status')
          .eq('checkout_request_id', checkoutRequestId)
          .maybeSingle();

      return response?['status'] ?? 'pending';
    } catch (e) {
      return 'pending';
    }
  }
}
