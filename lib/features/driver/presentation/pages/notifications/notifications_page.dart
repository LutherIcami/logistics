import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/driver_trip_provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverTripProvider>(
      builder: (context, provider, _) {
        // Mock notifications
        final notifications = [
          _NotificationData(
            id: '1',
            title: 'New Trip Assigned',
            message:
                'You have been assigned a new trip to Mombasa. Check your trips tab.',
            time: DateTime.now().subtract(const Duration(minutes: 15)),
            type: NotificationType.tripAssigned,
            isRead: false,
          ),
          _NotificationData(
            id: '2',
            title: 'Payment Received',
            message: 'You have received KES 8,500 for your completed trips.',
            time: DateTime.now().subtract(const Duration(hours: 2)),
            type: NotificationType.payment,
            isRead: false,
          ),
          _NotificationData(
            id: '3',
            title: 'Rating Update',
            message: 'Your customer rating has increased to 4.9! Great job!',
            time: DateTime.now().subtract(const Duration(days: 1)),
            type: NotificationType.rating,
            isRead: true,
          ),
          _NotificationData(
            id: '4',
            title: 'Vehicle Maintenance Due',
            message: 'Your vehicle KAA 123A is due for scheduled maintenance.',
            time: DateTime.now().subtract(const Duration(days: 2)),
            type: NotificationType.maintenance,
            isRead: true,
          ),
          _NotificationData(
            id: '5',
            title: 'Weekly Summary',
            message: 'You completed 8 trips this week earning KES 18,500.',
            time: DateTime.now().subtract(const Duration(days: 3)),
            type: NotificationType.summary,
            isRead: true,
          ),
        ];

        return Column(
          children: [
            _buildHeader(context, notifications),
            Expanded(
              child: notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _NotificationCard(
                          notification: notifications[index],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    List<_NotificationData> notifications,
  ) {
    final unreadCount = notifications.where((n) => !n.isRead).length;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$unreadCount unread notifications',
            style: TextStyle(color: Colors.grey[600]),
          ),
          TextButton(
            onPressed: () {
              // Mark all as read
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                ),
              );
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No notifications', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

enum NotificationType { tripAssigned, payment, rating, maintenance, summary }

class _NotificationData {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  final bool isRead;

  _NotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotificationData notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead ? null : Colors.orange.withValues(alpha: 0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getTypeColor(notification.type).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTypeIcon(notification.type),
            color: _getTypeColor(notification.type),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(notification.time),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.tripAssigned:
        return Icons.local_shipping;
      case NotificationType.payment:
        return Icons.attach_money;
      case NotificationType.rating:
        return Icons.star;
      case NotificationType.maintenance:
        return Icons.build;
      case NotificationType.summary:
        return Icons.summarize;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.tripAssigned:
        return Colors.blue;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.rating:
        return Colors.amber;
      case NotificationType.maintenance:
        return Colors.red;
      case NotificationType.summary:
        return Colors.purple;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
