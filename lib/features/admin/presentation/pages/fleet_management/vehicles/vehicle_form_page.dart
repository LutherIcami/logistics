import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/vehicle_model.dart';
import '../../../providers/vehicle_provider.dart';
import '../../base_module_page.dart';
import '../../../../../../core/widgets/vehicle_image_picker.dart';

class VehicleFormPage extends StatefulWidget {
  const VehicleFormPage({super.key, this.vehicleId});

  final String? vehicleId;

  bool get isEdit => vehicleId != null;

  @override
  State<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends State<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _registrationController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _fuelCapacityController = TextEditingController();
  final _currentFuelController = TextEditingController();
  final _mileageController = TextEditingController();
  final _locationController = TextEditingController();
  final _loadCapacityController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _insuranceExpiryController = TextEditingController();
  final _licenseExpiryController = TextEditingController();

  String _type = 'truck';
  String _status = 'active';
  bool _isLoading = false;
  List<File> _vehicleImages = [];

  @override
  void initState() {
    super.initState();
    _loadExistingIfEdit();
  }

  Future<void> _loadExistingIfEdit() async {
    if (!widget.isEdit) return;

    final provider = context.read<VehicleProvider>();
    final vehicle = await provider.getVehicleById(widget.vehicleId!);
    if (vehicle != null && mounted) {
      setState(() {
        _registrationController.text = vehicle.registrationNumber;
        _makeController.text = vehicle.make;
        _modelController.text = vehicle.model;
        _yearController.text = vehicle.year.toString();
        _type = vehicle.type;
        _status = vehicle.status;
        _fuelCapacityController.text = vehicle.fuelCapacity.toString();
        _currentFuelController.text = vehicle.currentFuelLevel.toString();
        _mileageController.text = vehicle.mileage.toString();
        _locationController.text = vehicle.currentLocation ?? '';
        _loadCapacityController.text = vehicle.loadCapacity?.toString() ?? '';
        _purchasePriceController.text = vehicle.purchasePrice?.toString() ?? '';
        _currentValueController.text = vehicle.currentValue?.toString() ?? '';
        _insuranceExpiryController.text = vehicle.insuranceExpiry ?? '';
        _licenseExpiryController.text = vehicle.licenseExpiry ?? '';
      });
    }
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _fuelCapacityController.dispose();
    _currentFuelController.dispose();
    _mileageController.dispose();
    _locationController.dispose();
    _loadCapacityController.dispose();
    _purchasePriceController.dispose();
    _currentValueController.dispose();
    _insuranceExpiryController.dispose();
    _licenseExpiryController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<VehicleProvider>();

    // TODO: Upload _vehicleImages to server and get URLs
    // For now, we'll just save the vehicle data

    final vehicle = Vehicle(
      id: widget.isEdit
          ? widget.vehicleId!
          : 'VEH-${DateTime.now().millisecondsSinceEpoch}',
      registrationNumber: _registrationController.text.trim(),
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text),
      type: _type,
      status: _status,
      fuelCapacity: double.parse(_fuelCapacityController.text),
      currentFuelLevel: double.tryParse(_currentFuelController.text) ?? 0.0,
      mileage: double.tryParse(_mileageController.text) ?? 0.0,
      purchaseDate: widget.isEdit
          ? (await provider.getVehicleById(widget.vehicleId!))?.purchaseDate ??
                DateTime.now()
          : DateTime.now(),
      currentLocation: _locationController.text.isEmpty
          ? null
          : _locationController.text.trim(),
      loadCapacity: _loadCapacityController.text.isEmpty
          ? null
          : double.parse(_loadCapacityController.text),
      purchasePrice: _purchasePriceController.text.isEmpty
          ? null
          : double.parse(_purchasePriceController.text),
      currentValue: _currentValueController.text.isEmpty
          ? null
          : double.parse(_currentValueController.text),
      insuranceExpiry: _insuranceExpiryController.text.isEmpty
          ? null
          : _insuranceExpiryController.text.trim(),
      licenseExpiry: _licenseExpiryController.text.isEmpty
          ? null
          : _licenseExpiryController.text.trim(),
    );

    final success = widget.isEdit
        ? await provider.updateVehicle(vehicle)
        : await provider.addVehicle(vehicle);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? 'Vehicle updated successfully'
                  : 'Vehicle added successfully',
            ),
          ),
        );
        context.go('/admin/fleet');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to save vehicle')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseModulePage(
      title: widget.isEdit ? 'Edit Vehicle' : 'Add Vehicle',
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
          IconButton(icon: const Icon(Icons.check), onPressed: _saveVehicle),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Photos Section
              VehicleImagePicker(
                vehiclePlate: _registrationController.text.isNotEmpty
                    ? _registrationController.text
                    : 'New Vehicle',
                currentImageUrls: null, // TODO: Get from vehicle model
                maxImages: 4,
                onImagesSelected: (images) {
                  setState(() {
                    _vehicleImages = images;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Basic Information
              Text(
                'Basic Information',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _registrationController,
                label: 'Registration Number',
                icon: Icons.badge,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter registration number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _makeController,
                      label: 'Make',
                      icon: Icons.build,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter make';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _modelController,
                      label: 'Model',
                      icon: Icons.directions_car,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter model';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _yearController,
                      label: 'Year',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter year';
                        }
                        final year = int.tryParse(value);
                        if (year == null ||
                            year < 1900 ||
                            year > DateTime.now().year + 1) {
                          return 'Please enter a valid year';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: const [
                        DropdownMenuItem(value: 'truck', child: Text('Truck')),
                        DropdownMenuItem(value: 'van', child: Text('Van')),
                        DropdownMenuItem(
                          value: 'pickup',
                          child: Text('Pickup'),
                        ),
                        DropdownMenuItem(
                          value: 'trailer',
                          child: Text('Trailer'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _type = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a type';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  prefixIcon: const Icon(Icons.info),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(
                    value: 'maintenance',
                    child: Text('In Maintenance'),
                  ),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  DropdownMenuItem(value: 'sold', child: Text('Sold')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // Operational Information
              Text(
                'Operational Information',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _fuelCapacityController,
                      label: 'Fuel Capacity (L)',
                      icon: Icons.local_gas_station,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter fuel capacity';
                        }
                        final capacity = double.tryParse(value);
                        if (capacity == null || capacity <= 0) {
                          return 'Please enter a valid capacity';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _currentFuelController,
                      label: 'Current Fuel (L)',
                      icon: Icons.local_gas_station,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _mileageController,
                      label: 'Mileage (km)',
                      icon: Icons.speed,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _loadCapacityController,
                      label: 'Load Capacity (tons)',
                      icon: Icons.scale,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Current Location',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 24),

              // Financial Information
              Text(
                'Financial Information',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _purchasePriceController,
                      label: 'Purchase Price (KES)',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _currentValueController,
                      label: 'Current Value (KES)',
                      icon: Icons.trending_up,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Compliance Information
              Text(
                'Compliance Information',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _insuranceExpiryController,
                      label: 'Insurance Expiry',
                      icon: Icons.security,
                      hintText: 'YYYY-MM-DD',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _licenseExpiryController,
                      label: 'License Expiry',
                      icon: Icons.badge,
                      hintText: 'YYYY-MM-DD',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              FilledButton.icon(
                onPressed: _isLoading ? null : _saveVehicle,
                icon: const Icon(Icons.save),
                label: const Text('Save Vehicle'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
