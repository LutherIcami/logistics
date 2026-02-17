import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/customer_order_provider.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerOrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerOrderProvider>(
      builder: (context, provider, _) {
        if (provider.orders.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order Details')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final order = provider.orders.firstWhere(
          (o) => o.id == widget.orderId,
          orElse: () => throw Exception('Order not found'),
        );

        final showPayment = !order.isPaid && !order.isCancelled;
        final showConfirmation = order.isPendingConfirmation;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Order Details'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          bottomNavigationBar: (showPayment || showConfirmation)
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showPayment)
                          FilledButton.icon(
                            onPressed: provider.isLoading
                                ? null
                                : () => _processMpesaPayment(
                                    context,
                                    order.id,
                                    order.totalCost,
                                  ),
                            icon: provider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.account_balance_wallet),
                            label: const Text('Pay with M-Pesa'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              backgroundColor: Colors.green.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        if (showPayment && showConfirmation)
                          const SizedBox(height: 12),
                        if (showConfirmation)
                          FilledButton.icon(
                            onPressed: () =>
                                _confirmDelivery(context, order.id),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Confirm Delivery Received'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : null,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        order.statusColor.withValues(alpha: 0.1),
                        order.statusColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: order.statusColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Status',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  order.statusIcon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  order.statusDisplayText,
                                  style: TextStyle(
                                    color: order.statusColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: order.statusColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Order Information
                Text(
                  'Order Details',
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
                        _InfoRow(label: 'Order ID', value: order.id),
                        const Divider(),
                        _InfoRow(
                          label: 'Order Date',
                          value: DateFormat(
                            'MMM dd, yyyy • hh:mm a',
                          ).format(order.orderDate),
                        ),
                        if (order.estimatedDelivery != null) ...[
                          const Divider(),
                          _InfoRow(
                            label: 'Estimated Delivery',
                            value: DateFormat(
                              'MMM dd, yyyy • hh:mm a',
                            ).format(order.estimatedDelivery!),
                          ),
                        ],
                        const Divider(),
                        _InfoRow(label: 'Cargo Type', value: order.cargoType),
                        if (order.cargoWeight != null)
                          _InfoRow(
                            label: 'Weight',
                            value:
                                '${order.cargoWeight!.toStringAsFixed(0)} kg',
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Route Information
                Text(
                  'Route',
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
                        _RouteLine(
                          label: 'Pickup',
                          value: order.pickupLocation,
                          isPickup: true,
                        ),
                        const SizedBox(height: 16),
                        _RouteLine(
                          label: 'Delivery',
                          value: order.deliveryLocation,
                          isPickup: false,
                        ),
                      ],
                    ),
                  ),
                ),
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
                          label: 'Order Placed',
                          date: order.orderDate,
                          isCompleted: true,
                        ),
                        _TimelineItem(
                          label: 'Picked Up',
                          date: order.pickupDate,
                          isCompleted: order.pickupDate != null,
                        ),
                        _TimelineItem(
                          label: 'Delivered',
                          date: order.deliveryDate,
                          isCompleted: order.deliveryDate != null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Financial Summary
                Card(
                  color: Colors.green.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Cost',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'KES ${order.totalCost.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Payment Status'),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: order.isPaid
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order.paymentStatus.toUpperCase(),
                                style: TextStyle(
                                  color: order.isPaid
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Secondary Actions
                if (order.isPending || order.isConfirmed || order.isAssigned)
                  TextButton.icon(
                    onPressed: () => _cancelOrder(context, order.id),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      'Cancel Order',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to My Orders'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _processMpesaPayment(
    BuildContext context,
    String orderId,
    double amount,
  ) async {
    final provider = context.read<CustomerOrderProvider>();
    final phoneController = TextEditingController(
      text: provider.currentCustomer?.phone,
    );

    final String? phoneNumber = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('M-Pesa Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the phone number that will receive the M-Pesa prompt:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '2547XXXXXXXX',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_android),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: KES ${amount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final phone = phoneController.text.trim();
              if (phone.isEmpty) return;
              Navigator.pop(context, phone);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Send Prompt'),
          ),
        ],
      ),
    );

    if (phoneNumber == null || phoneNumber.isEmpty) return;

    if (!context.mounted) return;
    final success = await provider.processPayment(
      orderId,
      amount,
      phoneNumber: phoneNumber,
    );

    if (context.mounted) {
      if (success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text('STK Push Sent'),
              ],
            ),
            content: const Text(
              'Please check your phone for the M-Pesa pin prompt to complete the payment.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to initiate payment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelivery(BuildContext context, String orderId) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delivery'),
            content: const Text(
              'Have you received your cargo in good condition?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Confirm Received'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    if (!context.mounted) return;
    final provider = context.read<CustomerOrderProvider>();
    final success = await provider.confirmDelivery(orderId);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery confirmed! Thank you.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to confirm delivery.')),
        );
      }
    }
  }

  Future<void> _cancelOrder(BuildContext context, String orderId) async {
    final reasonController = TextEditingController();
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancel Order'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Are you sure you want to cancel this order?'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason (Optional)',
                    hintText: 'e.g., Changed my mind, schedule conflict',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    if (!context.mounted) return;
    final provider = context.read<CustomerOrderProvider>();
    final success = await provider.cancelOrder(
      orderId,
      reason: reasonController.text.trim().isEmpty
          ? null
          : reasonController.text.trim(),
    );
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to cancel order')));
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({
    required this.label,
    required this.value,
    required this.isPickup,
  });
  final String label;
  final String value;
  final bool isPickup;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: isPickup ? Colors.blue : Colors.green,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.label,
    required this.date,
    required this.isCompleted,
  });

  final String label;
  final DateTime? date;
  final bool isCompleted;

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
              color: isCompleted ? Colors.green : Colors.grey[300],
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
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
                  const Text(
                    'Pending',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
