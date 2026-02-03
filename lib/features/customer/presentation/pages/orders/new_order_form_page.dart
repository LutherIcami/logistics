import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_order_provider.dart';
import '../../../domain/models/order_model.dart';
import '/../../../features/auth/presentation/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

class NewOrderFormPage extends StatefulWidget {
  const NewOrderFormPage({super.key});

  @override
  State<NewOrderFormPage> createState() => _NewOrderFormPageState();
}

class _NewOrderFormPageState extends State<NewOrderFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _pickupLocationController = TextEditingController();
  final _deliveryLocationController = TextEditingController();
  final _cargoTypeController = TextEditingController();
  final _cargoWeightController = TextEditingController();
  final _distanceController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _specialInstructionsController = TextEditingController();

  bool _isLoading = false;
  bool _autoCalculateCost = true;

  @override
  void initState() {
    super.initState();
    // Initialize customer data when the form loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCustomerIfNeeded();
    });
  }

  Future<void> _initializeCustomerIfNeeded() async {
    final provider = context.read<CustomerOrderProvider>();
    if (provider.currentCustomer == null) {
      // Try to get customer ID from auth provider or use a default
      try {
        // This assumes there's an AuthProvider - adjust as needed
        final authProvider = context.read<AuthProvider>();
        if (authProvider.user != null) {
          await provider.initializeCustomer(authProvider.user!.id);
        }
      } catch (e) {
        debugPrint('DEBUG: Failed to initialize customer: $e');
        // If auth provider is not available, you might want to show a login prompt
      }
    }
  }

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _deliveryLocationController.dispose();
    _cargoTypeController.dispose();
    _cargoWeightController.dispose();
    _distanceController.dispose();
    _totalCostController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  void _calculateCost() {
    if (!_autoCalculateCost) return;

    final distance = double.tryParse(_distanceController.text);
    final weight = double.tryParse(_cargoWeightController.text);

    if (distance != null) {
      // Simple cost calculation: base rate + distance rate + weight rate
      double cost = 2000.0; // Base rate
      cost += distance * 25.0; // Distance rate (KES 25 per km)
      if (weight != null) {
        cost += weight * 0.5; // Weight rate (KES 0.5 per kg)
      }
      _totalCostController.text = cost.toStringAsFixed(0);
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<CustomerOrderProvider>();
    final customer = provider.currentCustomer;

    // Debug: Print customer status
    debugPrint('DEBUG: Customer is null: ${customer == null}');
    debugPrint('DEBUG: Customer ID: ${customer?.id}');
    debugPrint('DEBUG: Customer name: ${customer?.name}');
    debugPrint('DEBUG: Provider error: ${provider.error}');

    if (customer == null) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer data not found. Please log in again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final distance = double.tryParse(_distanceController.text);
    final weight = double.tryParse(_cargoWeightController.text);
    final totalCost = double.tryParse(_totalCostController.text) ?? 0.0;

    // Calculate estimated delivery (rough estimate: 1 hour per 50km)
    DateTime? estimatedDelivery;
    if (distance != null) {
      final hours = (distance / 50).ceil();
      estimatedDelivery = DateTime.now().add(Duration(hours: hours));
    }

    final newOrder = Order(
      id: const Uuid().v4(), // Generate a valid UUID for the new order
      customerId: customer.id,
      customerName: customer.name,
      pickupLocation: _pickupLocationController.text.trim(),
      deliveryLocation: _deliveryLocationController.text.trim(),
      status: 'pending',
      orderDate: DateTime.now(),
      estimatedDelivery: estimatedDelivery,
      cargoType: _cargoTypeController.text.trim(),
      cargoWeight: weight,
      specialInstructions: _specialInstructionsController.text.trim().isEmpty
          ? null
          : _specialInstructionsController.text.trim(),
      distance: distance,
      totalCost: totalCost,
    );

    final success = await provider.createOrder(newOrder);
    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        final errorMessage = provider.error ?? 'Failed to create order';
        debugPrint('DEBUG: Order creation failed: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _submitOrder,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Order'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _submitOrder),
        ],
      ),
      body: Consumer<CustomerOrderProvider>(
        builder: (context, provider, child) {
          if (provider.currentCustomer == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Customer Data Not Available',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please ensure you are logged in to create an order.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        _initializeCustomerIfNeeded();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        context.go('/login');
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Go to Login'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create New Order',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Fill in the details below',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Route Information
                  Text(
                    'Route Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _pickupLocationController,
                    label: 'Pickup Location',
                    icon: Icons.location_on,
                    hintText: 'Enter pickup address',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter pickup location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _deliveryLocationController,
                    label: 'Delivery Location',
                    icon: Icons.location_on,
                    hintText: 'Enter delivery address',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter delivery location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _distanceController,
                          label: 'Distance (km)',
                          icon: Icons.straighten,
                          keyboardType: TextInputType.number,
                          hintText: 'Optional',
                          onChanged: (_) => _calculateCost(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Auto Calculate Cost'),
                          value: _autoCalculateCost,
                          onChanged: (value) {
                            setState(() {
                              _autoCalculateCost = value;
                              if (value) {
                                _calculateCost();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Cargo Information
                  Text(
                    'Cargo Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _cargoTypeController,
                    label: 'Cargo Type',
                    icon: Icons.inventory_2,
                    hintText: 'e.g., General Cargo, Electronics, Perishable',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter cargo type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _cargoWeightController,
                    label: 'Weight (kg)',
                    icon: Icons.scale,
                    keyboardType: TextInputType.number,
                    hintText: 'Optional',
                    onChanged: (_) => _calculateCost(),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _specialInstructionsController,
                    label: 'Special Instructions',
                    icon: Icons.info_outline,
                    hintText: 'Any special handling requirements...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Cost Information
                  Text(
                    'Cost Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _totalCostController,
                    label: 'Total Cost (KES)',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter total cost';
                      }
                      final cost = double.tryParse(value);
                      if (cost == null || cost <= 0) {
                        return 'Please enter a valid cost';
                      }
                      return null;
                    },
                    enabled: !_autoCalculateCost,
                  ),
                  if (_autoCalculateCost)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Cost will be calculated based on distance and weight',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _submitOrder,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Create Order'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hintText,
    int maxLines = 1,
    bool enabled = true,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? Colors.green.shade700 : Colors.grey.shade500,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? Colors.green.shade600 : Colors.grey.shade400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade500, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      style: TextStyle(
        color: enabled ? Colors.grey.shade800 : Colors.grey.shade600,
        fontSize: 16,
      ),
    );
  }
}
