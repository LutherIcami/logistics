import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Consumer2<AuthProvider, VehicleProvider>(
        builder: (context, authProvider, vehicleProvider, _) {
          final notifications = _generateNotifications(
            authProvider,
            vehicleProvider,
          );

          return Column(
            children: [
              _buildHeader(context, notifications),
              Expanded(
                child: notifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifications.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
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
      ),
    );
  }

  List<_NotificationData> _generateNotifications(
    AuthProvider authProvider,
    VehicleProvider vehicleProvider,
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
          isRead: authProvider.isNotificationRead('profile-incomplete'),
        ),
      );
    }

    // 2. Urgent Maintenance Alerts
    final overdueVehicles = vehicleProvider.vehicles
        .where((v) => v.isMaintenanceOverdue)
        .toList();
    for (final v in overdueVehicles) {
      list.add(
        _NotificationData(
          id: 'maintenance-overdue-${v.id}',
          title: 'Urgent Maintenance: ${v.registrationNumber}',
          message:
              'Service for ${v.make} ${v.model} is overdue since ${v.nextMaintenanceDate?.toString().split(' ')[0]}. Safety risk detected.',
          time: v.nextMaintenanceDate ?? DateTime.now(),
          type: NotificationType.error,
          isRead: authProvider.isNotificationRead(
            'maintenance-overdue-${v.id}',
          ),
        ),
      );
    }

    // 3. Upcoming Maintenance Alerts (within 3 days)
    final upcomingVehicles = vehicleProvider.vehicles.where((v) {
      if (v.nextMaintenanceDate == null || v.isMaintenanceOverdue) return false;
      final diff = v.nextMaintenanceDate!.difference(DateTime.now()).inDays;
      return diff >= 0 && diff <= 3;
    }).toList();
    for (final v in upcomingVehicles) {
      list.add(
        _NotificationData(
          id: 'maintenance-upcoming-${v.id}',
          title: 'Upcoming Service: ${v.registrationNumber}',
          message:
              'Scheduled maintenance for ${v.make} ${v.model} is due in ${v.nextMaintenanceDate!.difference(DateTime.now()).inDays} days.',
          time: DateTime.now(),
          type: NotificationType.warning,
          isRead: authProvider.isNotificationRead(
            'maintenance-upcoming-${v.id}',
          ),
        ),
      );
    }

    // 4. Low Fuel Alerts (below 15%)
    final lowFuelVehicles = vehicleProvider.vehicles
        .where((v) => v.fuelLevelPercentage < 15 && v.isActive)
        .toList();
    for (final v in lowFuelVehicles) {
      list.add(
        _NotificationData(
          id: 'low-fuel-${v.id}',
          title: 'Low Fuel Alert: ${v.registrationNumber}',
          message:
              'Vehicle is running low on fuel (${v.fuelLevelPercentage.toStringAsFixed(1)}%). Refill recommended before next deployment.',
          time: DateTime.now(),
          type: NotificationType.warning,
          isRead: authProvider.isNotificationRead('low-fuel-${v.id}'),
        ),
      );
    }

    // Sort by time (newest first)
    list.sort((a, b) => b.time.compareTo(a.time));

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
              final ids = notifications.map((n) => n.id).toList();
              // Access the provider instance we're already consuming if possible, or lookup
              // Since we are in a build method with context, context.read is fine,
              // but we are also inside a Consumer builder which gives us 'authProvider'.
              // However, check if 'authProvider' is in scope here.
              // The _buildHeader is called from the consumer in build method. passed context
              // but we need the provider.
              // Better to pass the function callback or use context.read<AuthProvider>()
              Provider.of<AuthProvider>(
                context,
                listen: false,
              ).markAllNotificationsAsRead(ids);

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

enum NotificationType { info, warning, error, summary }

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
      elevation: notification.isRead ? 1 : 2,
      color: notification.isRead ? Colors.white : Colors.blue.shade50,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getTypeColor(notification.type).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTypeIcon(notification.type),
            color: _getTypeColor(notification.type).withValues(alpha: 1.0),
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
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.summary:
        return Icons.summarize;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
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
