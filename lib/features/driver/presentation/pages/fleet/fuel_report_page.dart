import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../admin/presentation/providers/vehicle_provider.dart';
import '../../../../admin/domain/models/fleet_models.dart';
import '../../providers/driver_trip_provider.dart';

class FuelReportPage extends StatefulWidget {
  const FuelReportPage({super.key});

  @override
  State<FuelReportPage> createState() => _FuelReportPageState();
}

class _FuelReportPageState extends State<FuelReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _litersController = TextEditingController();
  final _amountController = TextEditingController();
  final _stationController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _odometerController.dispose();
    _litersController.dispose();
    _amountController.dispose();
    _stationController.dispose();
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

      final log = FuelLog(
        id: 'FUEL-${DateTime.now().millisecondsSinceEpoch}',
        vehicleId: vehicle.id,
        vehicleRegistration: vehicle.registrationNumber,
        driverId: driver.id,
        driverName: driver.name,
        date: DateTime.now(),
        odometer: double.parse(_odometerController.text),
        liters: double.parse(_litersController.text),
        totalCost: double.parse(_amountController.text),
        stationName: _stationController.text.isEmpty
            ? null
            : _stationController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      final success = await vehicleProvider.recordFuelLog(log);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fuel report submitted successfully!'),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Report Fuel'),
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
              // Vehicle Info Card
              if (vehicle != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_shipping,
                          color: Colors.orange,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.registrationNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${vehicle.make} ${vehicle.model}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              const Text(
                'Fueling Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 24),

              // Odometer
              _buildTextField(
                controller: _odometerController,
                label: 'Odometer Reading (KM)',
                icon: Icons.speed_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  if (vehicle != null && double.parse(v) < vehicle.mileage) {
                    return 'Cannot be less than current mileage (${vehicle.mileage.toInt()} KM)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Liters & Amount
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _litersController,
                      label: 'Liters',
                      icon: Icons.local_gas_station_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
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
                ],
              ),
              const SizedBox(height: 16),

              // Station Name
              _buildTextField(
                controller: _stationController,
                label: 'Petrol Station (Optional)',
                icon: Icons.store_rounded,
              ),
              const SizedBox(height: 24),

              // Notes
              _buildTextField(
                controller: _notesController,
                label: 'Additional Notes',
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Fuel Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
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
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }
}
