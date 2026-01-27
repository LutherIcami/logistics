import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/driver_trip_provider.dart';
import '../../../../../core/widgets/profile_image_picker.dart';

class DriverEditFormPage extends StatefulWidget {
  const DriverEditFormPage({super.key});

  @override
  State<DriverEditFormPage> createState() => _DriverEditFormPageState();
}

class _DriverEditFormPageState extends State<DriverEditFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _licenseNumberController;
  late TextEditingController _licenseExpiryController;
  late TextEditingController _currentLocationController;
  late TextEditingController _currentVehicleController;

  String _status = 'active';
  bool _isLoading = false;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _licenseNumberController = TextEditingController();
    _licenseExpiryController = TextEditingController();
    _currentLocationController = TextEditingController();
    _currentVehicleController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDriverData();
    });
  }

  void _loadDriverData() {
    final provider = context.read<DriverTripProvider>();
    final driver = provider.currentDriver;
    if (driver != null) {
      setState(() {
        _nameController.text = driver.name;
        _emailController.text = driver.email;
        _phoneController.text = driver.phone;
        _licenseNumberController.text = driver.licenseNumber ?? '';
        _licenseExpiryController.text = driver.licenseExpiry ?? '';
        _currentLocationController.text = driver.currentLocation ?? '';
        _currentVehicleController.text = driver.currentVehicle ?? '';
        _status = driver.status;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    _currentLocationController.dispose();
    _currentVehicleController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<DriverTripProvider>();
    final currentDriver = provider.currentDriver;
    if (currentDriver == null) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Driver data not found')));
      }
      return;
    }

    // TODO: Upload _profileImage to server and get URL
    // For now, we'll just update the other fields

    final updatedDriver = currentDriver.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      licenseNumber: _licenseNumberController.text.trim().isEmpty
          ? null
          : _licenseNumberController.text.trim(),
      licenseExpiry: _licenseExpiryController.text.trim().isEmpty
          ? null
          : _licenseExpiryController.text.trim(),
      currentLocation: _currentLocationController.text.trim().isEmpty
          ? null
          : _currentLocationController.text.trim(),
      currentVehicle: _currentVehicleController.text.trim().isEmpty
          ? null
          : _currentVehicleController.text.trim(),
      status: _status,
    );

    final success = await provider.updateDriver(updatedDriver);
    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.orangeAccent,
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
            IconButton(icon: const Icon(Icons.check), onPressed: _saveChanges),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Center(
                child: ProfileImagePicker(
                  currentImageUrl: null, // TODO: Get from driver model
                  placeholderText: _getInitials(
                    _nameController.text.isNotEmpty
                        ? _nameController.text
                        : 'Driver',
                  ),
                  backgroundColor: Colors.orangeAccent,
                  onImageSelected: (file) {
                    setState(() {
                      _profileImage = file;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Personal Information
              Text(
                'Personal Information',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // License Information
              Text(
                'License Information',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _licenseNumberController,
                label: 'License Number',
                icon: Icons.badge,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _licenseExpiryController,
                label: 'License Expiry Date',
                icon: Icons.calendar_today,
                hintText: 'YYYY-MM-DD',
              ),
              const SizedBox(height: 24),

              // Work Information
              Text(
                'Work Information',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _currentLocationController,
                label: 'Current Location',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _currentVehicleController,
                label: 'Current Vehicle',
                icon: Icons.local_shipping,
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
                  DropdownMenuItem(value: 'on_leave', child: Text('On Leave')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              FilledButton.icon(
                onPressed: _isLoading ? null : _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.orangeAccent,
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
