import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../vehicles_provider.dart';
import '../../auth/auth_provider.dart';
import '../widgets/vehicle_card.dart';
import 'add_vehicle_screen.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId != null) {
      await context.read<VehiclesProvider>().loadVehicles(userId);
    }
  }

  Future<void> _navigateToAddVehicle() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
    );
    if (result == true) _loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Consumer<VehiclesProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My Vehicles',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            if (provider.vehicles.isNotEmpty)
                              Text(
                                '${provider.vehicles.length} vehicle${provider.vehicles.length == 1 ? '' : 's'} registered',
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _navigateToAddVehicle,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 42),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _buildContent(context, provider, primary),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, VehiclesProvider provider, Color primary) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator(color: primary));
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.error_outline,
                  size: 40, color: Colors.red.shade400),
            ),
            const SizedBox(height: 16),
            const Text('Something went wrong',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF424242))),
            const SizedBox(height: 8),
            Text(provider.error!,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _loadVehicles, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (provider.vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.directions_car_outlined, size: 48, color: primary),
            ),
            const SizedBox(height: 20),
            const Text('No vehicles yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 6),
            Text('Add your vehicle to book a service',
                style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAddVehicle,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Vehicle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVehicles,
      color: primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = provider.vehicles[index];
          return VehicleCard(
            vehicle: vehicle,
            onDelete: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Text('Delete Vehicle'),
                  content: const Text(
                      'Are you sure you want to delete this vehicle?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && mounted) {
                try {
                  await context
                      .read<VehiclesProvider>()
                      .deleteVehicle(vehicle.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Vehicle deleted successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete vehicle: $e')),
                    );
                  }
                }
              }
            },
            onEdit: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddVehicleScreen(vehicle: vehicle),
                ),
              );
              if (result == true) _loadVehicles();
            },
          );
        },
      ),
    );
  }
}
