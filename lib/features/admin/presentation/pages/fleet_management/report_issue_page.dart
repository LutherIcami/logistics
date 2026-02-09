import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/fleet_models.dart';
import '../../../domain/models/vehicle_model.dart';
import '../../../domain/models/driver_model.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/driver_provider.dart';
import '../base_module_page.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();

  Vehicle? _selectedVehicle;
  Driver? _selectedDriver;
  DiagnosticSeverity _selectedSeverity = DiagnosticSeverity.low;
  final DateTime _date = DateTime.now();

  final _odometerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().loadInitialVehicles();
      context.read<DriverProvider>().loadInitialDrivers();
    });
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedVehicle == null ||
        _selectedDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final report = DiagnosticReport(
      id: const Uuid().v4(),
      vehicleId: _selectedVehicle!.id,
      vehicleRegistration: _selectedVehicle!.registrationNumber,
      reporterId: _selectedDriver!.id,
      reporterName: _selectedDriver!.name,
      date: _date,
      odometer: double.parse(_odometerController.text),
      issueDescription: _descriptionController.text.trim(),
      severity: _selectedSeverity,
      status: DiagnosticStatus.reported,
      notes: _notesController.text.trim(),
    );

    final success = await context.read<VehicleProvider>().reportDiagnosticIssue(
      report,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Issue reported successfully')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<VehicleProvider>().error ?? 'Failed to report issue',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseModulePage(
      title: 'Report Vehicle Issue',
      child: Consumer2<VehicleProvider, DriverProvider>(
        builder: (context, vehicleProvider, driverProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('VEHICLE & REPORTER'),
                  _buildVehicleDropdown(vehicleProvider.vehicles),
                  const SizedBox(height: 16),
                  _buildDriverDropdown(driverProvider.drivers),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _odometerController,
                    label: 'Current Odometer (km)',
                    icon: Icons.speed,
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('ISSUE DETAILS'),
                  _buildSeverityDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description of Issue',
                    icon: Icons.error_outline,
                    maxLines: 4,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _notesController,
                    label: 'Additional Notes (Optional)',
                    icon: Icons.note_add_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 48),

                  _buildSubmitButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildVehicleDropdown(List<Vehicle> vehicles) {
    return DropdownButtonFormField<Vehicle>(
      decoration: _inputDecoration(Icons.local_shipping, 'Select Vehicle'),
      initialValue: _selectedVehicle,
      items: vehicles
          .map(
            (v) => DropdownMenuItem(
              value: v,
              child: Text(v.displayName, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (v) {
        setState(() {
          _selectedVehicle = v;
          if (v != null) {
            _odometerController.text = v.mileage.toStringAsFixed(0);
          }
        });
      },
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildDriverDropdown(List<Driver> drivers) {
    return DropdownButtonFormField<Driver>(
      decoration: _inputDecoration(Icons.person, 'Reporter / Driver'),
      initialValue: _selectedDriver,
      items: drivers
          .map(
            (d) => DropdownMenuItem(
              value: d,
              child: Text(d.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedDriver = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildSeverityDropdown() {
    return DropdownButtonFormField<DiagnosticSeverity>(
      decoration: _inputDecoration(Icons.priority_high, 'Severity Level'),
      initialValue: _selectedSeverity,
      items: DiagnosticSeverity.values
          .map(
            (s) =>
                DropdownMenuItem(value: s, child: Text(s.name.toUpperCase())),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedSeverity = v!),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: _inputDecoration(icon, label),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: _isSubmitting ? null : _handleSubmit,
        icon: const Icon(Icons.send),
        label: Text(_isSubmitting ? 'REPORTING...' : 'REPORT ISSUE'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon, String label) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
