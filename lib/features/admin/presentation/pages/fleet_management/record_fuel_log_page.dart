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

class RecordFuelLogPage extends StatefulWidget {
  const RecordFuelLogPage({super.key});

  @override
  State<RecordFuelLogPage> createState() => _RecordFuelLogPageState();
}

class _RecordFuelLogPageState extends State<RecordFuelLogPage> {
  final _formKey = GlobalKey<FormState>();

  Vehicle? _selectedVehicle;
  Driver? _selectedDriver;
  DateTime _date = DateTime.now();

  final _odometerController = TextEditingController();
  final _litersController = TextEditingController();
  final _costController = TextEditingController();
  final _stationController = TextEditingController();
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
    _litersController.dispose();
    _costController.dispose();
    _stationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
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

    final log = FuelLog(
      id: const Uuid().v4(),
      vehicleId: _selectedVehicle!.id,
      vehicleRegistration: _selectedVehicle!.registrationNumber,
      driverId: _selectedDriver!.id,
      driverName: _selectedDriver!.name,
      date: _date,
      odometer: double.parse(_odometerController.text),
      liters: double.parse(_litersController.text),
      totalCost: double.parse(_costController.text),
      stationName: _stationController.text.trim(),
      notes: _notesController.text.trim(),
    );

    final success = await context.read<VehicleProvider>().recordFuelLog(log);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fuel log recorded successfully')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<VehicleProvider>().error ?? 'Failed to record log',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseModulePage(
      title: 'Record Fuel',
      child: Consumer2<VehicleProvider, DriverProvider>(
        builder: (context, vehicleProvider, driverProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('ASSET INFORMATION'),
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

                  _buildSectionTitle('FUELING DETAILS'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _litersController,
                          label: 'Liters',
                          icon: Icons.local_gas_station,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePickerRow(
                          'Date',
                          _date,
                          () => _selectDate(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _costController,
                    label: 'Total Cost (KES)',
                    icon: Icons.payments,
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _stationController,
                    label: 'Fuel Station',
                    icon: Icons.place,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _notesController,
                    label: 'Additional Notes',
                    icon: Icons.note,
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
      value: _selectedVehicle,
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
      decoration: _inputDecoration(Icons.person, 'Filled By / Driver'),
      value: _selectedDriver,
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

  Widget _buildDatePickerRow(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  Text(
                    date.toString().split(' ')[0],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: _isSubmitting ? null : _handleSubmit,
        icon: const Icon(Icons.save),
        label: Text(_isSubmitting ? 'RECORDING...' : 'RECORD FUEL'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.orange,
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
