import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/chat_message.dart';

class ChatRepository {
  final SupabaseClient client;

  ChatRepository(this.client);

  // Stream of messages for a specific shipment/trip
  Stream<List<ChatMessage>> getMessagesStream(String trackingNumber) {
    return client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('tracking_number', trackingNumber)
        .order('created_at', ascending: true) // Oldest first (chat style)
        .map((maps) => maps.map((map) => ChatMessage.fromJson(map)).toList());
  }

  Future<void> sendMessage({
    required String trackingNumber,
    required String content,
    required String senderRole,
    String? senderName,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await client.from('chat_messages').insert({
      'tracking_number': trackingNumber,
      'sender_id': user.id,
      'content': content,
      'sender_role': senderRole,
      'sender_name': senderName,
    });
  }
}
