import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/driver_model.dart';
import '../../providers/driver_provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../base_module_page.dart';

class DriverFormPage extends StatefulWidget {
  const DriverFormPage({super.key, this.driverId});

  final String? driverId;

  bool get isEdit => driverId != null;

  @override
  State<DriverFormPage> createState() => _DriverFormPageState();
}

class _DriverFormPageState extends State<DriverFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _licenseExpiryController = TextEditingController();

  String _status = 'active';

  @override
  void initState() {
    super.initState();
    _loadExistingIfEdit();
  }

  Future<void> _loadExistingIfEdit() async {
    if (!widget.isEdit) return;
    final provider = context.read<DriverProvider>();
    final driver = await provider.getDriverById(widget.driverId!);
    if (driver != null && mounted) {
      setState(() {
        _nameController.text = driver.name;
        _emailController.text = driver.email;
        _phoneController.text = driver.phone;
        _licenseNumberController.text = driver.licenseNumber ?? '';
        _licenseExpiryController.text = driver.licenseExpiry ?? '';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModulePage(
      title: widget.isEdit ? 'Edit Driver' : 'Add Driver',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Email is required'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Phone is required'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _licenseNumberController,
                      label: 'License Number',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _licenseExpiryController,
                      label: 'License Expiry',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'on_leave', child: Text('On Leave')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _status = value);
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.send),
                  label: Text(
                    widget.isEdit ? 'Update Driver' : 'Send Invitation Email',
                  ),
                  onPressed: _onSubmit,
                ),
              ),
              if (!widget.isEdit) ...[
                const SizedBox(height: 16),
                const Text(
                  'A professional welcome email will be sent to the driver with instructions to set their password and download the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final driverProvider = context.read<DriverProvider>();
    final authProvider = context.read<AuthProvider>();
    final now = DateTime.now();

    try {
      if (widget.isEdit) {
        final existing = await driverProvider.getDriverById(widget.driverId!);
        if (existing == null) return;

        final updated = existing.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          licenseNumber: _licenseNumberController.text.trim().isEmpty
              ? null
              : _licenseNumberController.text.trim(),
          licenseExpiry: _licenseExpiryController.text.trim().isEmpty
              ? null
              : _licenseExpiryController.text.trim(),
          status: _status,
        );
        await driverProvider.updateDriver(updated);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Driver ${updated.name} updated')),
        );
        context.pop();
      } else {
        // 1. Professional Onboarding: Call Edge Function to Invite
        final userId = await authProvider.inviteDriver(
          email: _emailController.text.trim(),
          fullName: _nameController.text.trim(),
        );

        if (userId == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Onboarding failed'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // 2. Create the internal Driver record
        final newDriver = Driver(
          id: userId,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          licenseNumber: _licenseNumberController.text.trim(),
          licenseExpiry: _licenseExpiryController.text.trim(),
          status: _status,
          rating: 0,
          totalTrips: 0,
          joinDate: now,
        );

        await driverProvider.addDriver(newDriver);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome email sent to ${newDriver.name}!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
