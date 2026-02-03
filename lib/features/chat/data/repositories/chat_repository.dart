import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/chat_message.dart';

class ChatRepository {
  final SupabaseClient client;

  ChatRepository(this.client);

  // Stream of messages for a specific order
  Stream<List<ChatMessage>> getMessagesStream(String orderId) {
    return client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('order_id', orderId)
        .order('created_at', ascending: true) // Oldest first (chat style)
        .map((maps) => maps.map((map) => ChatMessage.fromJson(map)).toList());
  }

  Future<void> sendMessage({
    required String orderId,
    required String content,
    required String senderRole,
    String? senderName,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await client.from('chat_messages').insert({
      'order_id': orderId,
      'sender_id': user.id,
      'content': content,
      'sender_role': senderRole,
      'sender_name': senderName,
    });
  }
}
