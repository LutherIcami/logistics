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
      title: widget.isEdit ? 'Edit Fleet Asset' : 'New Fleet Deployment',
      actions: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          )
        else
          TextButton.icon(
            onPressed: _saveVehicle,
            icon: const Icon(Icons.save_rounded, color: Colors.white),
            label: const Text(
              'SAVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header/Status Banner if editing
              _buildHeaderSelection(),
              const SizedBox(height: 24),

              // Vehicle Photos Section
              _buildSection(
                title: 'Media & Documentation',
                subtitle: 'Add up to 4 high-quality photos',
                icon: Icons.photo_library_rounded,
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
                    onExistingImagesChanged: (urls) {
                      setState(() {
                        _existingImageUrls = urls;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Basic Information
              _buildSection(
                title: 'Identification',
                subtitle: 'Core vehicle registration details',
                icon: Icons.assignment_rounded,
                children: [
                  _buildTextField(
                    controller: _registrationController,
                    label: 'Registration Number',
                    hintText: 'e.g. KDA 123A',
                    icon: Icons.style_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter registration number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _makeController,
                          label: 'Manufacturer',
                          hintText: 'e.g. Toyota',
                          icon: Icons.warehouse_rounded,
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
                          label: 'Model / Series',
                          hintText: 'e.g. HINO 300',
                          icon: Icons.local_shipping_rounded,
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _yearController,
                          label: 'Manufacture Year',
                          icon: Icons.event_note_rounded,
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
                          value: _type,
                          decoration: _inputDecoration(
                            label: 'Fleet Category',
                            icon: Icons.category_rounded,
                          ),
                          dropdownColor: Colors.white,
                          items: const [
                            DropdownMenuItem(
                              value: 'truck',
                              child: Text('Heavy Truck'),
                            ),
                            DropdownMenuItem(
                              value: 'van',
                              child: Text('Delivery Van'),
                            ),
                            DropdownMenuItem(
                              value: 'pickup',
                              child: Text('Pickup / Utility'),
                            ),
                            DropdownMenuItem(
                              value: 'trailer',
                              child: Text('Container Trailer'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _type = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Operational Information
              _buildSection(
                title: 'Operational Specs',
                subtitle: 'Performance and capacity data',
                icon: Icons.analytics_rounded,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _fuelCapacityController,
                          label: 'Fuel Tank (L)',
                          icon: Icons.local_gas_station_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter capacity';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _loadCapacityController,
                          label: 'Payload (Tons)',
                          icon: Icons.scale_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _mileageController,
                          label: 'Odometer (km)',
                          icon: Icons.speed_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _currentFuelController,
                          label: 'Current Level (L)',
                          icon: Icons.ev_station_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _locationController,
                    label: 'Dispatch / Current Location',
                    icon: Icons.location_on_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Financial Information
              _buildSection(
                title: 'Compliance & Safety',
                subtitle: 'Documents and expiry tracking',
                icon: Icons.verified_user_rounded,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _insuranceExpiryController,
                          label: 'Insurance Validity',
                          icon: Icons.shield_rounded,
                          hintText: 'Select date',
                          readOnly: true,
                          onTap: () =>
                              _selectDate(context, _insuranceExpiryController),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _licenseExpiryController,
                          label: 'Permit Validity',
                          icon: Icons.badge_rounded,
                          hintText: 'Select date',
                          readOnly: true,
                          onTap: () =>
                              _selectDate(context, _licenseExpiryController),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Financial Intelligence
              _buildSection(
                title: 'Asset Valuation',
                subtitle: 'Economic data for financial logs',
                icon: Icons.account_balance_wallet_rounded,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _purchasePriceController,
                          label: 'Cost Basis (KES)',
                          icon: Icons.payments_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _currentValueController,
                          label: 'Fair Value (KES)',
                          icon: Icons.show_chart_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Action Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _saveVehicle,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                widget.isEdit
                                    ? 'UPDATE FLEET ASSET'
                                    : 'DEPLOY TO FLEET',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 0.8,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'Discard and return',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSelection() {
    if (!widget.isEdit) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(_status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(_status).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getStatusColor(_status),
            child: const Icon(Icons.info_outline_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Operational Status',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  _status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _getStatusColor(_status),
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: _status,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'maintenance', child: Text('Repair')),
              DropdownMenuItem(value: 'inactive', child: Text('Off Duty')),
              DropdownMenuItem(value: 'sold', child: Text('Retired')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _status = val);
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF475569), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                  ],
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
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      labelStyle: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF1E293B),
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF1E293B), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
        fontSize: 15,
      ),
      decoration: _inputDecoration(
        label: label,
        icon: icon,
        hintText: hintText,
      ),
    );
  }
}
