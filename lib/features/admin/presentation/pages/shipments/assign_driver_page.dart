import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/shipment_provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../../domain/models/driver_model.dart';
import '../../../domain/models/vehicle_model.dart';
import '../base_module_page.dart';

class AssignDriverPage extends StatefulWidget {
  final String shipmentId;

  const AssignDriverPage({super.key, required this.shipmentId});

  @override
  State<AssignDriverPage> createState() => _AssignDriverPageState();
}

class _AssignDriverPageState extends State<AssignDriverPage> {
  Driver? _selectedDriver;
  Vehicle? _selectedVehicle;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().loadInitialDrivers();
      context.read<VehicleProvider>().loadInitialVehicles();
    });
  }

  Future<void> _handleAssign() async {
    if (_selectedDriver == null || _selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selection Required'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await context.read<ShipmentProvider>().assignDriver(
      shipmentId: widget.shipmentId,
      driverId: _selectedDriver!.id,
      driverName: _selectedDriver!.name,
      vehiclePlate: _selectedVehicle!.registrationNumber,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Deployment active: Driver dispatched'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<ShipmentProvider>().error ??
                  'Deployment failed: Link unstable',
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseModulePage(
      title: 'Assign Driver',
      backRoute: '/admin/shipments/${widget.shipmentId}',
      child: Consumer3<ShipmentProvider, DriverProvider, VehicleProvider>(
        builder:
            (context, shipmentProvider, driverProvider, vehicleProvider, _) {
              final shipment = shipmentProvider.getShipmentById(
                widget.shipmentId,
              );

              if (shipment == null) {
                return const Center(
                  child: Text('Shipment record lost in terminal'),
                );
              }

              if (driverProvider.isLoading || vehicleProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final availableDrivers = driverProvider.drivers
                  .where((d) => d.status == 'active')
                  .toList();
              final availableVehicles = vehicleProvider.vehicles
                  .where((v) => v.status == 'active')
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('MISSION BRIEF'),
                    _buildShipmentSummary(shipment),
                    const SizedBox(height: 32),

                    _buildSectionTitle('PERSONNEL ASSIGNMENT'),
                    _buildDriverDropdown(availableDrivers, availableVehicles),
                    const SizedBox(height: 24),

                    _buildSectionTitle('ASSET DEPLOYMENT'),
                    _buildVehicleDropdown(availableVehicles),
                    const SizedBox(height: 48),

                    _buildDeployButton(),
                    const SizedBox(height: 60),
                  ],
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

  Widget _buildShipmentSummary(dynamic shipment) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: #${shipment.id.substring(shipment.id.length - 6).toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    shipment.customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _buildInfoRow(
            Icons.trip_origin_rounded,
            'Pickup',
            shipment.pickupLocation,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on_rounded,
            'Delivery',
            shipment.deliveryLocation,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverDropdown(List<Driver> drivers, List<Vehicle> vehicles) {
    if (drivers.isEmpty) {
      return const _ErrorContainer(
        message: 'No active drivers found in roster',
      );
    }

    return Container(
      decoration: _dropdownDecoration(),
      child: DropdownButtonFormField<Driver>(
        decoration: _inputDecoration(
          Icons.person_search_rounded,
          'Select Driver',
        ),
        value: _selectedDriver,
        items: drivers.map((driver) {
          return DropdownMenuItem(
            value: driver,
            child: Text('${driver.name} • ${driver.id}'),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDriver = value;
            if (value?.currentVehicle != null) {
              try {
                _selectedVehicle = vehicles.firstWhere(
                  (v) => v.registrationNumber == value!.currentVehicle,
                );
              } catch (_) {}
            }
          });
        },
      ),
    );
  }

  Widget _buildVehicleDropdown(List<Vehicle> vehicles) {
    if (vehicles.isEmpty) {
      return const _ErrorContainer(message: 'No units available for dispatch');
    }

    return Container(
      decoration: _dropdownDecoration(),
      child: DropdownButtonFormField<Vehicle>(
        decoration: _inputDecoration(
          Icons.local_shipping_rounded,
          'Select Unit',
        ),
        value: _selectedVehicle,
        items: vehicles.map((vehicle) {
          return DropdownMenuItem(
            value: vehicle,
            child: Text(
              '${vehicle.registrationNumber} • ${vehicle.make} ${vehicle.model}',
            ),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedVehicle = value),
      ),
    );
  }

  Widget _buildDeployButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _handleAssign,
        icon: const Icon(Icons.rocket_launch_rounded),
        label: Text(_isSubmitting ? 'INITIATING...' : 'EXECUTE MISSION'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  BoxDecoration _dropdownDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _ErrorContainer extends StatelessWidget {
  final String message;
  const _ErrorContainer({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.redAccent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
