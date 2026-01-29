import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/shipment_provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../../domain/models/driver_model.dart';
import '../../../domain/models/vehicle_model.dart';

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
        const SnackBar(
          content: Text('Please select both a driver and a vehicle'),
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
          const SnackBar(content: Text('Driver assigned successfully')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<ShipmentProvider>().error ??
                  'Failed to assign driver',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Driver')),
      body: Consumer3<ShipmentProvider, DriverProvider, VehicleProvider>(
        builder: (context, shipmentProvider, driverProvider, vehicleProvider, _) {
          final shipment = shipmentProvider.getShipmentById(widget.shipmentId);

          if (shipment == null) {
            return const Center(child: Text('Shipment not found'));
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shipment Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shipment #${shipment.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('From: ${shipment.pickupLocation}'),
                        Text('To: ${shipment.deliveryLocation}'),
                        Text('Cargo: ${shipment.cargoType}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Driver Selection
                const Text(
                  'Select Driver',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (availableDrivers.isEmpty)
                  const Text(
                    'No active drivers available',
                    style: TextStyle(color: Colors.red),
                  )
                else
                  DropdownButtonFormField<Driver>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select a driver',
                    ),
                    value: _selectedDriver,
                    items: availableDrivers.map((driver) {
                      return DropdownMenuItem(
                        value: driver,
                        child: Text('${driver.name} (${driver.phone})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDriver = value;
                        // Auto-select vehicle if driver is assigned to one
                        if (value?.currentVehicle != null) {
                          try {
                            _selectedVehicle = availableVehicles.firstWhere(
                              (v) =>
                                  v.registrationNumber == value!.currentVehicle,
                            );
                          } catch (_) {}
                        }
                      });
                    },
                  ),
                const SizedBox(height: 24),

                // Vehicle Selection
                const Text(
                  'Select Vehicle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (availableVehicles.isEmpty)
                  const Text(
                    'No active vehicles available',
                    style: TextStyle(color: Colors.red),
                  )
                else
                  DropdownButtonFormField<Vehicle>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select a vehicle',
                    ),
                    value: _selectedVehicle,
                    items: availableVehicles.map((vehicle) {
                      return DropdownMenuItem(
                        value: vehicle,
                        child: Text(
                          '${vehicle.registrationNumber} - ${vehicle.make} ${vehicle.model}',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedVehicle = value),
                  ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleAssign,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Assign & Start Trip'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
