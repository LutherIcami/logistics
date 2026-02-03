class ChatMessage {
  final String id;
  final String orderId;
  final String senderId;
  final String? senderName;
  final String senderRole; // 'driver', 'customer', 'admin'
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.orderId,
    required this.senderId,
    this.senderName,
    required this.senderRole,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      orderId: json['order_id'] ?? json['orderId'],
      senderId: json['sender_id'] ?? json['senderId'],
      senderName: json['sender_name'] ?? json['senderName'],
      senderRole: json['sender_role'] ?? json['senderRole'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'content': content,
    };
  }
}
