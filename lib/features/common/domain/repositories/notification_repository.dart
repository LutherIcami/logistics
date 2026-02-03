import '../models/notification_model.dart';
import 'dart:async';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> sendNotification(AppNotification notification);
  Stream<List<AppNotification>> streamNotifications(String userId);
}
