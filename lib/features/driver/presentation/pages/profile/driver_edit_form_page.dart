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

    String? profileImageUrl = currentDriver.profileImage;
    if (_profileImage != null) {
      final url = await provider.uploadProfileImage(_profileImage!);
      if (url != null) {
        profileImageUrl = url;
      }
    }

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
      profileImage: profileImageUrl,
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
    final driverProvider = context.watch<DriverTripProvider>();
    final currentDriver = driverProvider.currentDriver;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Edit Profile Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveChanges,
              child: const Text(
                'SAVE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Center(
                child: ProfileImagePicker(
                  currentImageUrl: currentDriver?.profileImage,
                  placeholderText: _getInitials(
                    _nameController.text.isNotEmpty
                        ? _nameController.text
                        : 'Driver',
                  ),
                  backgroundColor: const Color(0xFF0F172A),
                  onImageSelected: (file) {
                    setState(() {
                      _profileImage = file;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Personal Information
              const Row(
                children: [
                  Icon(Icons.person_rounded, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'PERSONAL INFORMATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_rounded,
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
                icon: Icons.email_rounded,
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
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // License Information
              const Row(
                children: [
                  Icon(Icons.badge_rounded, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'LICENSE INFORMATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _licenseNumberController,
                label: 'License Number',
                icon: Icons.badge_rounded,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _licenseExpiryController,
                label: 'License Expiry Date',
                icon: Icons.calendar_today_rounded,
                hintText: 'YYYY-MM-DD',
                readOnly: true,
                onTap: () => _selectDate(context, _licenseExpiryController),
              ),
              const SizedBox(height: 32),

              // Work Information
              const Row(
                children: [
                  Icon(Icons.work_rounded, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'WORK INFORMATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _currentLocationController,
                label: 'Current Location',
                icon: Icons.location_on_rounded,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _currentVehicleController,
                label: 'Current Vehicle',
                icon: Icons.local_shipping_rounded,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: 'Availability Status',
                  labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.info_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
              const SizedBox(height: 48),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'SUBMIT UPDATES',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'DISCARD CHANGES',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        hintText: hintText,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }
}
