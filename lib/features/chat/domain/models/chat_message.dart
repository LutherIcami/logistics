class ChatMessage {
  final String id;
  final String trackingNumber;
  final String senderId;
  final String? senderName;
  final String senderRole; // 'driver', 'customer', 'admin'
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.trackingNumber,
    required this.senderId,
    this.senderName,
    required this.senderRole,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      trackingNumber: json['tracking_number'] ?? json['trackingNumber'],
      senderId: json['sender_id'] ?? json['senderId'],
      senderName: json['sender_name'] ?? json['senderName'],
      senderRole: json['sender_role'] ?? json['senderRole'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tracking_number': trackingNumber,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'content': content,
      // created_at is usually handled by DB default, but can send if needed
    };
  }

  bool get isMyMessage => false; // Logic handled in UI usually by comparing IDs
}
