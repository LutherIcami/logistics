import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/driver_trip_provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../common/domain/models/notification_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DriverTripProvider, AuthProvider>(
      builder: (context, provider, authProvider, _) {
        final notifications = _generateNotifications(provider, authProvider);

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, notifications),
              if (notifications.isEmpty)
                SizedBox(height: 400, child: _buildEmptyState())
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _NotificationCard(
                      notification: notifications[index],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  List<_NotificationData> _generateNotifications(
    DriverTripProvider provider,
    AuthProvider authProvider,
  ) {
    final List<_NotificationData> list = [];

    // 1. Profile Incomplete Alert
    final user = authProvider.user;
    if (user != null && !user.isProfileComplete) {
      list.add(
        _NotificationData(
          id: 'profile-incomplete',
          title: 'Profile Incomplete',
          message:
              'Please update your profile details (avatar and full name) to ensure full system access.',
          time: DateTime.now(),
          type: NotificationType.summary,
          isRead: false,
        ),
      );
    }

    // 2. Real DB Notifications
    for (final note in provider.notifications) {
      list.add(_mapDbNotification(note));
    }

    // 3. Sort by Date (Latest First)
    list.sort((a, b) => b.time.compareTo(a.time));

    return list;
  }

  _NotificationData _mapDbNotification(AppNotification note) {
    NotificationType type = NotificationType.summary;
    if (note.type == 'trip_assignment') type = NotificationType.tripAssigned;
    if (note.type == 'alert') type = NotificationType.maintenance;
    if (note.type == 'info') type = NotificationType.summary;

    return _NotificationData(
      id: note.id,
      title: note.title,
      message: note.message,
      time: note.createdAt,
      type: type,
      isRead: note.isRead,
      onTap: () {
        // Handle tapping notification (e.g. navigation)
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    List<_NotificationData> notifications,
  ) {
    final unreadCount = notifications
        .where((n) => !n.isRead && n.id != 'profile-incomplete')
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$unreadCount unread notifications',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                final provider = Provider.of<DriverTripProvider>(
                  context,
                  listen: false,
                );
                provider.markAllNotificationsAsRead();

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
  final VoidCallback? onTap;

  _NotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
    this.onTap,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotificationData notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 1 : 2,
      // Use stronger color for unread items
      color: notification.isRead ? Colors.white : Colors.blue.shade50,
      margin: const EdgeInsets.only(
        bottom: 4,
      ), // Add margin back if separated view removes it? No, separated adds space.
      child: InkWell(
        onTap: () {
          if (!notification.isRead && notification.id != 'profile-incomplete') {
            context.read<DriverTripProvider>().markNotificationAsRead(
              notification.id,
            );
          }
          notification.onTap?.call();
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // Increased opacity for better visibility
              color: _getTypeColor(notification.type).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTypeIcon(notification.type),
              color: _getTypeColor(
                notification.type,
              ).withValues(alpha: 1.0), // Full color icon
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
                        ? FontWeight.w600
                        : FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
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
