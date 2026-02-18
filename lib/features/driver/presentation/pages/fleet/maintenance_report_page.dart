import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../admin/presentation/providers/vehicle_provider.dart';
import '../../../../admin/domain/models/fleet_models.dart';
import '../../providers/driver_trip_provider.dart';

class MaintenanceReportPage extends StatefulWidget {
  const MaintenanceReportPage({super.key});

  @override
  State<MaintenanceReportPage> createState() => _MaintenanceReportPageState();
}

class _MaintenanceReportPageState extends State<MaintenanceReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _providerController = TextEditingController();
  final _notesController = TextEditingController();

  MaintenanceType _type = MaintenanceType.routine;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _odometerController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _providerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final vehicleProvider = context.read<VehicleProvider>();
      final tripProvider = context.read<DriverTripProvider>();

      final vehicle = tripProvider.assignedVehicle;
      final driver = tripProvider.currentDriver;

      if (vehicle == null || driver == null) {
        throw Exception('No assigned vehicle or driver profile found');
      }

      final log = MaintenanceLog(
        id: 'MAIN-${DateTime.now().millisecondsSinceEpoch}',
        vehicleId: vehicle.id,
        vehicleRegistration: vehicle.registrationNumber,
        driverId: driver.id,
        driverName: driver.name,
        date: DateTime.now(),
        odometer: double.parse(_odometerController.text),
        type: _type,
        description: _descriptionController.text,
        totalCost: double.parse(_amountController.text),
        serviceProvider: _providerController.text.isEmpty
            ? null
            : _providerController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      final success = await vehicleProvider.recordMaintenanceLog(log);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maintenance report submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vehicleProvider.error ?? 'Failed to submit report'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<DriverTripProvider>();
    final vehicle = tripProvider.assignedVehicle;
    final driver = tripProvider.currentDriver;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Maintenance Report'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Auto-filled Info Section
              const Text(
                'Report Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildReadOnlyField(
                      label: 'Vehicle',
                      value: vehicle?.registrationNumber ?? 'No Vehicle',
                      icon: Icons.directions_car_filled_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildReadOnlyField(
                      label: 'Reported By',
                      value: driver?.name ?? 'Unknown Driver',
                      icon: Icons.person_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const Text(
                'Service Info',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 24),

              // Maintenance Type Dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<MaintenanceType>(
                    value: _type,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.arrow_drop_down_circle_rounded,
                      color: Colors.blue,
                    ),
                    onChanged: (v) {
                      if (v != null) setState(() => _type = v);
                    },
                    items: MaintenanceType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.name.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Odometer
              _buildTextField(
                controller: _odometerController,
                label: 'Current Odometer (KM)',
                icon: Icons.speed_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'What was fixed/serviced?',
                icon: Icons.description_rounded,
                maxLines: 2,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Cost & Provider
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _amountController,
                      label: 'Total Cost (KES)',
                      icon: Icons.payments_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _providerController,
                      label: 'Garage/Mechanic',
                      icon: Icons.house_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notes
              _buildTextField(
                controller: _notesController,
                label: 'Additional Comments',
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 48),

              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submitReport,
                  icon: _isSubmitting
                      ? const SizedBox.shrink()
                      : const Icon(Icons.send_rounded),
                  label: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'SUBMIT REPORT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0, // Shadow handled by Container
                  ),
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
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.blue),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
