import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/driver_model.dart';
import '../../providers/driver_provider.dart';
import '../../providers/settings_provider.dart';
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
  final _passwordController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _licenseExpiryController = TextEditingController();

  String _status = 'active';
  bool _isSubmitting = false;

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
    _passwordController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModulePage(
      title: widget.isEdit ? 'Staff Modification' : 'Staff Onboarding',
      child: Container(
        decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildSectionTitle('Identity Details'),
                const SizedBox(height: 16),
                _buildCard([
                  _buildInputField(
                    controller: _nameController,
                    label: 'Full Legal Name',
                    icon: Icons.person_outline_rounded,
                    hint: 'e.g. John Doe',
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _emailController,
                    label: 'Corporate Email',
                    icon: Icons.email_outlined,
                    hint: 'john.doe@logistics.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Email is required'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _phoneController,
                    label: 'Contact Number',
                    icon: Icons.phone_outlined,
                    hint: '+254 700 000 000',
                    keyboardType: TextInputType.phone,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Phone is required'
                        : null,
                  ),
                ]),
                const SizedBox(height: 32),
                if (!widget.isEdit) ...[
                  _buildSectionTitle('Secure Access Credentials'),
                  const SizedBox(height: 16),
                  _buildCard([
                    _buildInputField(
                      controller: _passwordController,
                      label: 'Account Password',
                      icon: Icons.lock_outline_rounded,
                      hint: 'Assign a secure password',
                      isPassword: true,
                      validator: (value) {
                        if (widget.isEdit) return null;
                        if (value == null || value.isEmpty) {
                          return 'Password is required for new accounts';
                        }
                        if (value.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ensure you communicate this password to the driver securely.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
                _buildSectionTitle('Compliance & Licensing'),
                const SizedBox(height: 16),
                _buildCard([
                  _buildInputField(
                    controller: _licenseNumberController,
                    label: 'NTSA License Number',
                    icon: Icons.badge_outlined,
                    hint: 'DL-XXXXXX',
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _licenseExpiryController,
                    label: 'License Expiry Date',
                    icon: Icons.date_range_outlined,
                    hint: 'YYYY-MM-DD',
                  ),
                ]),
                const SizedBox(height: 32),
                _buildSectionTitle('Operational Status'),
                const SizedBox(height: 16),
                _buildStatusSelector(),
                const SizedBox(height: 48),
                _buildSubmitButton(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isEdit ? 'Update Fleet Personnel' : 'Invite New Pilot',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.isEdit
              ? 'Modify the current deployment records for this staff member.'
              : 'Add a new professional driver to the Logistics Pro ecosystem.',
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          obscureText: isPassword,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return _buildCard([
      DropdownButtonFormField<String>(
        value: _status,
        decoration: InputDecoration(
          labelText: 'Employment Status',
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: const Icon(Icons.shield_outlined, size: 20),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: const [
          DropdownMenuItem(value: 'active', child: Text('Active Duty')),
          DropdownMenuItem(value: 'on_leave', child: Text('On Medical/Leave')),
          DropdownMenuItem(value: 'inactive', child: Text('Decommissioned')),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() => _status = value);
        },
      ),
    ]);
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: _isSubmitting ? null : _onSubmit,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(
                widget.isEdit ? Icons.save_rounded : Icons.person_add_rounded,
              ),
        label: Text(
          widget.isEdit ? 'Update Staff Member' : 'Create Staff Account',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final driverProvider = context.read<DriverProvider>();
    final settingsProvider = context.read<SettingsProvider>();
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
          SnackBar(
            content: Text('Staff record for ${updated.name} synchronized.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else {
        final downloadLink = settingsProvider.systemSettings.driverDownloadLink;
        final userId = await authProvider.inviteDriver(
          email: _emailController.text.trim(),
          fullName: _nameController.text.trim(),
          downloadLink: downloadLink,
          password: _passwordController.text.trim(),
        );

        if (userId == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.error ?? 'Account provisioning failed.',
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

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
            content: Text(
              'Account successfully provisioned for ${newDriver.name}!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('System Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
