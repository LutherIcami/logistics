import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projo/features/customer/domain/models/order_model.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';
import '../../../providers/finance_provider.dart';
import '../../../../domain/models/finance_models.dart';

/// Page to select a completed order and generate invoice from it
class OrderSelectionPage extends StatefulWidget {
  const OrderSelectionPage({super.key});

  @override
  State<OrderSelectionPage> createState() => _OrderSelectionPageState();
}

class _OrderSelectionPageState extends State<OrderSelectionPage> {
  List<Order> _completedOrders = [];
  List<Order> _filteredOrders = [];
  Set<String> _invoicedOrderIds = {};
  bool _isLoading = true;
  String? _error;

  // Filters
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _hideInvoiced = true;

  @override
  void initState() {
    super.initState();
    _loadCompletedOrders();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetch orders with status 'delivered' that don't have invoices yet
  Future<void> _loadCompletedOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final supabase = Supabase.instance.client;

      // Fetch delivered orders
      final response = await supabase
          .from('orders')
          .select()
          .eq('status', 'delivered')
          .order('delivery_date', ascending: false);

      // Convert to Order objects
      final orders = (response as List)
          .map((json) => Order.fromJson(json))
          .toList();

      // Get invoiced order IDs from provider
      final financeProvider = context.read<FinanceProvider>();
      final invoicedIds = financeProvider.invoices
          .where((inv) => inv.orderId != null)
          .map((inv) => inv.orderId!)
          .toSet();

      setState(() {
        _completedOrders = orders;
        _invoicedOrderIds = invoicedIds;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load orders: $e';
        _isLoading = false;
      });
    }
  }

  /// Apply search and date filters
  void _applyFilters() {
    List<Order> filtered = List.from(_completedOrders);

    // Search filter (customer name or order ID)
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        return order.customerName.toLowerCase().contains(searchQuery) ||
            order.id.toLowerCase().contains(searchQuery);
      }).toList();
    }

    // Date range filter
    if (_startDate != null) {
      filtered = filtered.where((order) {
        return order.deliveryDate != null &&
            order.deliveryDate!.isAfter(
              _startDate!.subtract(const Duration(days: 1)),
            );
      }).toList();
    }
    if (_endDate != null) {
      filtered = filtered.where((order) {
        return order.deliveryDate != null &&
            order.deliveryDate!.isBefore(
              _endDate!.add(const Duration(days: 1)),
            );
      }).toList();
    }

    // Hide already invoiced orders
    if (_hideInvoiced) {
      filtered = filtered.where((order) {
        return !_invoicedOrderIds.contains(order.id);
      }).toList();
    }

    setState(() {
      _filteredOrders = filtered;
    });
  }

  /// Generate invoice from order
  Future<void> _generateInvoiceFromOrder(Order order) async {
    final financeProvider = context.read<FinanceProvider>();

    // Create invoice from order details
    final invoice = Invoice(
      id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      customerId: order.customerId,
      customerName: order.customerName,
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      status: InvoiceStatus.draft,
      notes: _buildInvoiceNotes(order),
      items: _buildInvoiceItems(order),
      orderId: order.id, // Link to the order
    );

    // Add invoice to provider
    final success = await financeProvider.addInvoice(invoice);

    // Show success message
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice ${invoice.id} created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate directly to the newly created invoice detail page
      context.pushReplacement('/admin/finance/invoices/${invoice.id}');
    } else if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            financeProvider.error ??
                'Failed to create invoice. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Build invoice items from order details
  List<InvoiceItem> _buildInvoiceItems(Order order) {
    final items = <InvoiceItem>[];

    // Main delivery service
    items.add(
      InvoiceItem(
        description:
            'Delivery Service - ${order.cargoType}\n'
            'From: ${order.pickupLocation}\n'
            'To: ${order.deliveryLocation}',
        quantity: 1,
        unitPrice: order.totalCost,
      ),
    );

    // Add distance-based item if available
    if (order.distance != null && order.distance! > 0) {
      items.add(
        InvoiceItem(
          description: 'Distance Covered',
          quantity: order.distance!.toInt(),
          unitPrice: 0, // Already included in total
        ),
      );
    }

    // Add weight-based item if available
    if (order.cargoWeight != null && order.cargoWeight! > 0) {
      items.add(
        InvoiceItem(
          description: 'Cargo Weight',
          quantity: order.cargoWeight!.toInt(),
          unitPrice: 0, // Already included in total
        ),
      );
    }

    return items;
  }

  /// Build invoice notes from order details
  String _buildInvoiceNotes(Order order) {
    final notes = StringBuffer();
    notes.writeln('Order Reference: ${order.id}');
    notes.writeln('Tracking Number: ${order.trackingNumber ?? "N/A"}');
    notes.writeln('Vehicle: ${order.vehiclePlate ?? "N/A"}');
    notes.writeln('Driver: ${order.driverName ?? "N/A"}');
    notes.writeln('Pickup Date: ${_formatDate(order.pickupDate)}');
    notes.writeln('Delivery Date: ${_formatDate(order.deliveryDate)}');

    if (order.specialInstructions != null &&
        order.specialInstructions!.isNotEmpty) {
      notes.writeln('\nSpecial Instructions:');
      notes.writeln(order.specialInstructions);
    }

    return notes.toString();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _applyFilters();
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _applyFilters();
    });
  }

  /// Export filtered orders to CSV
  Future<void> _exportToCSV() async {
    try {
      if (_filteredOrders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No orders to export'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Build CSV data
      List<List<dynamic>> csvData = [
        [
          'Order ID',
          'Customer',
          'Pickup Location',
          'Delivery Location',
          'Cargo Type',
          'Cargo Weight (kg)',
          'Distance (km)',
          'Total Cost (KES)',
          'Delivery Date',
          'Tracking Number',
          'Driver',
          'Vehicle',
          'Status',
          'Invoiced',
        ],
      ];

      for (var order in _filteredOrders) {
        final isInvoiced = _invoicedOrderIds.contains(order.id);
        csvData.add([
          order.id,
          order.customerName,
          order.pickupLocation,
          order.deliveryLocation,
          order.cargoType,
          order.cargoWeight?.toStringAsFixed(1) ?? 'N/A',
          order.distance?.toStringAsFixed(1) ?? 'N/A',
          order.totalCost.toStringAsFixed(2),
          _formatDate(order.deliveryDate),
          order.trackingNumber ?? 'N/A',
          order.driverName ?? 'N/A',
          order.vehiclePlate ?? 'N/A',
          order.statusDisplayText,
          isInvoiced ? 'Yes' : 'No',
        ]);
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);

      // Get downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access downloads directory');
      }

      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'completed_orders_$timestamp.csv';
      final filePath = '${directory.path}/$filename';

      // Write file
      final file = File(filePath);
      await file.writeAsString(csv);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Exported ${_filteredOrders.length} orders to Downloads',
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OPEN',
              textColor: Colors.white,
              onPressed: () {
                OpenFile.open(filePath);
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Order for Invoice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export to CSV',
            onPressed: _filteredOrders.isEmpty ? null : _exportToCSV,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCompletedOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by customer or order ID...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Date range filter
                      FilterChip(
                        label: Text(
                          _startDate != null && _endDate != null
                              ? '${_formatDate(_startDate)} - ${_formatDate(_endDate)}'
                              : 'Date Range',
                        ),
                        selected: _startDate != null,
                        onSelected: (_) => _pickDateRange(),
                        avatar: Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: _startDate != null ? Colors.blue : null,
                        ),
                      ),
                      if (_startDate != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: _clearDateRange,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                      const SizedBox(width: 8),

                      // Hide invoiced toggle
                      FilterChip(
                        label: Text(
                          _hideInvoiced ? 'Hiding Invoiced' : 'Showing All',
                        ),
                        selected: _hideInvoiced,
                        onSelected: (selected) {
                          setState(() {
                            _hideInvoiced = selected;
                            _applyFilters();
                          });
                        },
                        avatar: Icon(
                          _hideInvoiced
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18,
                          color: _hideInvoiced ? Colors.blue : null,
                        ),
                      ),
                    ],
                  ),
                ),

                // Results count
                if (!_isLoading) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${_filteredOrders.length} of ${_completedOrders.length} orders',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),

          // Orders List
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[300]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadCompletedOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _completedOrders.isEmpty
                  ? 'No completed orders available'
                  : 'No orders match your filters',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _completedOrders.isEmpty
                  ? 'Complete some orders first to generate invoices'
                  : 'Try adjusting your search or filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOrders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        final isInvoiced = _invoicedOrderIds.contains(order.id);
        return _OrderCard(
          order: order,
          isInvoiced: isInvoiced,
          onTap: isInvoiced ? null : () => _generateInvoiceFromOrder(order),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final bool isInvoiced;
  final VoidCallback? onTap;

  const _OrderCard({required this.order, required this.isInvoiced, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: isInvoiced ? Colors.grey[100] : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 8)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isInvoiced ? Colors.grey : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.customerName,
                          style: TextStyle(
                            color: isInvoiced ? Colors.grey : Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isInvoiced)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 14,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Invoiced',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          Text(
                            order.statusIcon,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.statusDisplayText,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Divider(height: 24),

              // Delivery details
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Route',
                value: '${order.pickupLocation} → ${order.deliveryLocation}',
                isDisabled: isInvoiced,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.inventory_2_outlined,
                label: 'Cargo',
                value:
                    order.cargoType +
                    (order.cargoWeight != null
                        ? ' (${order.cargoWeight!.toStringAsFixed(1)} kg)'
                        : ''),
                isDisabled: isInvoiced,
              ),
              if (order.distance != null) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.route_outlined,
                  label: 'Distance',
                  value: '${order.distance!.toStringAsFixed(1)} km',
                  isDisabled: isInvoiced,
                ),
              ],
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Delivered',
                value: _formatDate(order.deliveryDate),
                isDisabled: isInvoiced,
              ),
              const Divider(height: 24),

              // Total and action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          color: isInvoiced ? Colors.grey : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KES ${order.totalCost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: isInvoiced ? Colors.grey : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  if (isInvoiced)
                    OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Already Invoiced'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.receipt_long, size: 18),
                      label: const Text('Generate Invoice'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDisabled;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDisabled ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: isDisabled ? Colors.grey[400] : Colors.grey[600],
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: isDisabled ? Colors.grey : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
