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
  List<String> _existingImageUrls = []; // Track existing URLs

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
        _existingImageUrls = vehicle.images;
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

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      // Format as YYYY-MM-DD
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<VehicleProvider>();

    try {
      // 1. Upload new images if any
      List<String> uploadedUrls = [];
      if (_vehicleImages.isNotEmpty) {
        // Use a temporary ID for new vehicles if needed, or generated one
        final tempId = widget.isEdit
            ? widget.vehicleId!
            : 'VEH-${DateTime.now().millisecondsSinceEpoch}';

        uploadedUrls = await provider.uploadVehicleImages(
          tempId,
          _vehicleImages,
        );
      }

      // 2. Combine with existing URLs
      final List<String> finalImageUrls = [
        ..._existingImageUrls,
        ...uploadedUrls,
      ];

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
            ? (await provider.getVehicleById(
                    widget.vehicleId!,
                  ))?.purchaseDate ??
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
        images: finalImageUrls,
      );

      final success = widget.isEdit
          ? await provider.updateVehicle(vehicle)
          : await provider.addVehicle(vehicle);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

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
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Save Failed'),
              content: SingleChildScrollView(
                child: Text(
                  provider.error ?? 'Unknown error occurred',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Failed to Save Vehicle'),
            content: SingleChildScrollView(
              child: Text(
                'System Error: ${e.toString()}\n\nPlease check:\n1. You are logged in as Admin\n2. Database migration (repair_vehicles.sql) was run',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
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
          FilledButton.icon(
            onPressed: _saveVehicle,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
            ),
          ),
      ],
      child: Container(
        color: Colors.grey[50], // Light grey background for the whole page
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Photos Section
                _buildSection(
                  title: 'Vehicle Photos',
                  children: [
                    VehicleImagePicker(
                      vehiclePlate: _registrationController.text.isNotEmpty
                          ? _registrationController.text
                          : 'New Vehicle',
                      currentImageUrls: _existingImageUrls,
                      maxImages: 4,
                      onImagesSelected: (images) {
                        setState(() {
                          _vehicleImages = images;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Basic Information
                _buildSection(
                  title: 'Basic Information',
                  children: [
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
                            decoration: _inputDecoration(
                              label: 'Type',
                              icon: Icons.category,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'truck',
                                child: Text('Truck'),
                              ),
                              DropdownMenuItem(
                                value: 'van',
                                child: Text('Van'),
                              ),
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
                    if (widget.isEdit) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: _inputDecoration(
                          label: 'Status',
                          icon: Icons.info,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'maintenance',
                            child: Text('In Maintenance'),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text('Inactive'),
                          ),
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
                    ],
                  ],
                ),
                const SizedBox(height: 20),

                // Operational Information
                _buildSection(
                  title: 'Operational Information',
                  children: [
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
                  ],
                ),
                const SizedBox(height: 20),

                // Financial Information
                _buildSection(
                  title: 'Financial Information',
                  children: [
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
                  ],
                ),
                const SizedBox(height: 20),

                // Compliance Information
                _buildSection(
                  title: 'Compliance Information',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _insuranceExpiryController,
                            label: 'Insurance Expiry',
                            icon: Icons.security,
                            hintText: 'YYYY-MM-DD',
                            readOnly: true,
                            onTap: () => _selectDate(
                              context,
                              _insuranceExpiryController,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _licenseExpiryController,
                            label: 'License Expiry',
                            icon: Icons.badge,
                            hintText: 'YYYY-MM-DD',
                            readOnly: true,
                            onTap: () =>
                                _selectDate(context, _licenseExpiryController),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _saveVehicle,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            widget.isEdit
                                ? Icons.save_rounded
                                : Icons.add_circle_rounded,
                          ),
                    label: Text(
                      widget.isEdit ? 'Update Vehicle' : 'Add Vehicle to Fleet',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: Icon(icon, color: Colors.blue[700]),
      labelStyle: const TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
      filled: true,
      fillColor:
          Colors.grey[50], // Very slight grey input background for structure
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: _inputDecoration(
        label: label,
        icon: icon,
        hintText: hintText,
      ),
    );
  }
}
