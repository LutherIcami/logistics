class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'info', 'trip_assignment', 'alert'
  final String? relatedEntityId;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedEntityId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'] ?? 'info',
      relatedEntityId: json['related_entity_id'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'related_entity_id': relatedEntityId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
