import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/shipment_provider.dart';
import '../../../../customer/domain/models/order_model.dart';

class ShipmentFormPage extends StatefulWidget {
  final String? shipmentId;

  const ShipmentFormPage({super.key, this.shipmentId});

  @override
  State<ShipmentFormPage> createState() => _ShipmentFormPageState();
}

class _ShipmentFormPageState extends State<ShipmentFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _customerNameController;
  late TextEditingController _pickupLocationController;
  late TextEditingController _deliveryLocationController;
  late TextEditingController _cargoTypeController;
  late TextEditingController _weightController;
  late TextEditingController _costController;

  String _status = 'pending';
  DateTime _pickupDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController();
    _pickupLocationController = TextEditingController();
    _deliveryLocationController = TextEditingController();
    _cargoTypeController = TextEditingController();
    _weightController = TextEditingController();
    _costController = TextEditingController();

    if (widget.shipmentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<ShipmentProvider>();
        final shipment = provider.getShipmentById(widget.shipmentId!);
        if (shipment != null) {
          setState(() {
            _customerNameController.text = shipment.customerName;
            _pickupLocationController.text = shipment.pickupLocation;
            _deliveryLocationController.text = shipment.deliveryLocation;
            _cargoTypeController.text = shipment.cargoType;
            _weightController.text = shipment.cargoWeight?.toString() ?? '';
            _costController.text = shipment.totalCost.toString();
            _status = shipment.status;
            if (shipment.pickupDate != null) _pickupDate = shipment.pickupDate!;
            if (shipment.deliveryDate != null) {
              _deliveryDate = shipment.deliveryDate!;
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _pickupLocationController.dispose();
    _deliveryLocationController.dispose();
    _cargoTypeController.dispose();
    _weightController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.shipmentId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Shipment' : 'New Shipment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Customer Info'),
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Route Details'),
              TextFormField(
                controller: _pickupLocationController,
                decoration: const InputDecoration(
                  labelText: 'Pickup Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deliveryLocationController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Location',
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Pickup Date',
                      date: _pickupDate,
                      onChanged: (d) => setState(() => _pickupDate = d),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DatePickerField(
                      label: 'Delivery Date',
                      date: _deliveryDate,
                      onChanged: (d) => setState(() => _deliveryDate = d),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Cargo Details'),
              TextFormField(
                controller: _cargoTypeController,
                decoration: const InputDecoration(
                  labelText: 'Cargo Type',
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        prefixIcon: Icon(Icons.scale),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total Cost',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Status'),
              DropdownButtonFormField<String>(
                initialValue: _status,
                items: ShipmentProvider.availableStatuses.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s.toUpperCase().replaceAll('_', ' ')),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _status = v);
                },
                decoration: const InputDecoration(
                  labelText: 'Current Status',
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveShipment,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(isEditing ? 'Update Shipment' : 'Create Shipment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  void _saveShipment() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<ShipmentProvider>();

      final shipment = Order(
        id: widget.shipmentId ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        customerId: 'CUST-000', // Mock customer ID for manual entry
        customerName: _customerNameController.text,
        pickupLocation: _pickupLocationController.text,
        deliveryLocation: _deliveryLocationController.text,
        status: _status,
        orderDate: DateTime.now(), // Simplified
        pickupDate: _pickupDate,
        deliveryDate: _deliveryDate,
        cargoType: _cargoTypeController.text,
        cargoWeight: double.tryParse(_weightController.text),
        totalCost: double.tryParse(_costController.text) ?? 0.0,
        trackingNumber: 'TRK-${DateTime.now().millisecondsSinceEpoch}',
      );

      if (widget.shipmentId != null) {
        final original = provider.getShipmentById(widget.shipmentId!);
        if (original != null) {
          provider.updateShipment(
            original.copyWith(
              customerName: _customerNameController.text,
              pickupLocation: _pickupLocationController.text,
              deliveryLocation: _deliveryLocationController.text,
              status: _status,
              pickupDate: _pickupDate,
              deliveryDate: _deliveryDate,
              cargoType: _cargoTypeController.text,
              cargoWeight: double.tryParse(_weightController.text),
              totalCost: double.tryParse(_costController.text) ?? 0.0,
            ),
          );
        }
      } else {
        provider.addShipment(shipment);
      }

      context.pop();
    }
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text('${date.day}/${date.month}/${date.year}'),
      ),
    );
  }
}
