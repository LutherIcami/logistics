import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/driver_trip_provider.dart';
import '../../../domain/models/trip_model.dart';

import '../../../../chat/presentation/pages/chat_page.dart';

class TripDetailPage extends StatefulWidget {
  final String tripId;

  const TripDetailPage({super.key, required this.tripId});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DriverTripProvider>().loadTrips();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              final provider = context.read<DriverTripProvider>();
              try {
                final trip = provider.trips.firstWhere(
                  (t) => t.id == widget.tripId,
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatPage(
                      trackingNumber: trip.trackingNumber ?? trip.id,
                      currentUserRole: 'driver',
                      currentUserName: trip.driverName,
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trip data not available')),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<DriverTripProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.trips.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          Trip? trip;
          try {
            trip = provider.trips.firstWhere((t) => t.id == widget.tripId);
          } catch (_) {
            // If not found in loaded list, maybe show error or loading
            return const Center(child: Text('Trip not found or loading...'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Card(
                  color: trip.statusColor.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              trip.statusDisplayText,
                              style: TextStyle(
                                color: trip.statusColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: trip.statusColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Customer Info
                Text(
                  'Customer Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Name', value: trip.customerName),
                        if (trip.customerPhone != null)
                          _InfoRow(
                            label: 'Phone',
                            value: trip.customerPhone!,
                            icon: Icons.phone,
                            onTap: () {
                              // TODO: Make phone call
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Route Information
                Text(
                  'Route Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pickup Location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    trip.pickupLocation,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Delivery Location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    trip.deliveryLocation,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (trip.distance != null) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Distance',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${trip.distance!.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Cargo Information
                Text(
                  'Cargo Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Type', value: trip.cargoType),
                        if (trip.cargoWeight != null)
                          _InfoRow(
                            label: 'Weight',
                            value: '${trip.cargoWeight!.toStringAsFixed(0)} kg',
                          ),
                        if (trip.vehiclePlate != null)
                          _InfoRow(label: 'Vehicle', value: trip.vehiclePlate!),
                      ],
                    ),
                  ),
                ),
                if (trip.specialInstructions != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.orange.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Special Instructions',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(trip.specialInstructions!),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Timeline
                Text(
                  'Timeline',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _TimelineItem(
                          label: 'Assigned',
                          date: trip.assignedDate,
                          isCompleted: true,
                        ),
                        _TimelineItem(
                          label: 'Picked Up',
                          date: trip.pickupDate,
                          isCompleted: trip.pickupDate != null,
                        ),
                        _TimelineItem(
                          label: 'Delivered',
                          date: trip.deliveryDate,
                          isCompleted: trip.deliveryDate != null,
                        ),
                        if (trip.estimatedDelivery != null)
                          _TimelineItem(
                            label: 'Estimated Delivery',
                            date: trip.estimatedDelivery,
                            isCompleted: false,
                            isEstimate: true,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Add padding for bottom bar
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<DriverTripProvider>(
        builder: (context, provider, _) {
          if (provider.trips.isEmpty) return const SizedBox.shrink();

          Trip? trip;
          try {
            trip = provider.trips.firstWhere((t) => t.id == widget.tripId);
          } catch (_) {
            return const SizedBox.shrink();
          }

          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: _buildBottomActions(context, trip),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, Trip trip) {
    if (trip.isAssigned) {
      return FilledButton.icon(
        onPressed: () => _startTrip(context, trip.id),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Trip'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: Colors.blue,
        ),
      );
    }

    if (trip.isInTransit) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            onPressed: () => _completeTrip(context, trip.id),
            icon: const Icon(Icons.check_circle),
            label: const Text('Mark as Delivered'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Colors.green,
            ),
          ),
        ],
      );
    }

    if (trip.isDelivered || trip.isCancelled) {
      return OutlinedButton.icon(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Back to Dashboard'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _startTrip(BuildContext context, String tripId) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Start Trip'),
            content: const Text('Are you ready to start this trip?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Start'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    if (!context.mounted) return;
    final provider = context.read<DriverTripProvider>();
    final success = await provider.updateTripStatus(tripId, 'in_transit');
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip started successfully')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to start trip')));
      }
    }
  }

  Future<void> _completeTrip(BuildContext context, String tripId) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Complete Trip'),
            content: const Text(
              'Mark this trip as delivered? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Confirm Delivery'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    if (!context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final provider = context.read<DriverTripProvider>();
    final success = await provider.updateTripStatus(tripId, 'delivered');

    if (context.mounted) {
      Navigator.of(context).pop(); // Hide loading

      if (success) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Trip Completed'),
            content: const Text(
              'Great job! The trip has been marked as delivered.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  context.pop(); // Go back to list/dashboard
                },
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to complete trip. Please try again.'),
          ),
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                ],
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.label,
    required this.date,
    required this.isCompleted,
    this.isEstimate = false,
  });

  final String label;
  final DateTime? date;
  final bool isCompleted;
  final bool isEstimate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? Colors.green
                  : isEstimate
                  ? Colors.orange
                  : Colors.grey[300],
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : isEstimate
                ? const Icon(Icons.schedule, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: isCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                if (date != null)
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(date!),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  )
                else
                  Text(
                    'Not yet',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
