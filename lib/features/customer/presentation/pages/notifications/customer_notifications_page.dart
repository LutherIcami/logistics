import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_order_provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../domain/models/order_model.dart';

class CustomerNotificationsPage extends StatelessWidget {
  const CustomerNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerOrderProvider, AuthProvider>(
      builder: (context, provider, authProvider, _) {
        final notifications = _generateNotifications(provider, authProvider);

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

  List<_NotificationData> _generateNotifications(
    CustomerOrderProvider provider,
    AuthProvider authProvider,
  ) {
    final List<_NotificationData> list = [];

    // Add Profile Incomplete Alert
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

    // Sort all orders by date to get the late events
    final allOrders = List<Order>.from(provider.orders)
      ..sort((a, b) {
        final dateA = b.orderDate;
        final dateB = a.orderDate;
        return dateA.compareTo(dateB);
      });

    for (final order in allOrders) {
      if (order.isDelivered) {
        list.add(
          _NotificationData(
            id: 'del-${order.id}',
            title: 'Order Delivered',
            message:
                'Your order to ${order.deliveryLocation} has been successfully delivered.',
            time: order.deliveryDate ?? DateTime.now(),
            type: NotificationType.delivery,
            isRead: true,
          ),
        );
      } else if (order.isPending) {
        list.add(
          _NotificationData(
            id: 'pnd-${order.id}',
            title: 'Order Placed',
            message: 'Your order for ${order.cargoType} is being processed.',
            time: order.orderDate,
            type: NotificationType.orderInfo,
            isRead: false,
          ),
        );
      } else if (order.isInTransit) {
        list.add(
          _NotificationData(
            id: 'trn-${order.id}',
            title: 'Order In Transit',
            message: 'Your cargo is on the way to ${order.deliveryLocation}.',
            time: DateTime.now(), // Approximate
            type: NotificationType.tracking,
            isRead: false,
          ),
        );
      }
    }

    return list;
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

enum NotificationType { orderInfo, tracking, delivery, summary }

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
      color: notification.isRead ? null : Colors.green.withValues(alpha: 0.05),
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
                  color: Colors.green,
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
      case NotificationType.orderInfo:
        return Icons.shopping_bag;
      case NotificationType.tracking:
        return Icons.location_on;
      case NotificationType.delivery:
        return Icons.check_circle;
      case NotificationType.summary:
        return Icons.summarize;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.orderInfo:
        return Colors.blue;
      case NotificationType.tracking:
        return Colors.orange;
      case NotificationType.delivery:
        return Colors.green;
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
