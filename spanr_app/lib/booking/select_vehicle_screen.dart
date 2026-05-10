import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../vehicles/models/vehicle_model.dart';
import '../vehicles/vehicles_provider.dart';
import '../mechanics/models/mechanic_company.dart';
import '../auth/auth_provider.dart';
import '../cart/cart_provider.dart';

const _kOrange = Color(0xFFFC8019);
const _kHeading = Color(0xFF1C1C1C);
const _kBody = Color(0xFF696969);
const _kBg = Color(0xFFF2F2F2);

class SelectVehicleScreen extends StatefulWidget {
  final MechanicCompany company;

  const SelectVehicleScreen({
    super.key,
    required this.company,
  });

  @override
  State<SelectVehicleScreen> createState() => _SelectVehicleScreenState();
}

class _SelectVehicleScreenState extends State<SelectVehicleScreen> {
  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final authProvider = context.read<AuthProvider>();
    final vehiclesProvider = context.read<VehiclesProvider>();

    if (authProvider.user?.id != null) {
      await vehiclesProvider.loadVehicles(authProvider.user!.id);
    }
  }

  void _openPhotos(VehicleModel vehicle) {
    context.push('/select-vehicle-photos', extra: {
      'company': widget.company,
      'vehicle': vehicle,
    });
  }

  String _vehicleTitle(VehicleModel v) =>
      v.name?.trim().isNotEmpty == true ? v.name!.trim() : '${v.make} ${v.model}';

  @override
  Widget build(BuildContext context) {
    final vehiclesProvider = context.watch<VehiclesProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kHeading),
        title: const Text(
          'Select Vehicle',
          style:
              TextStyle(color: _kHeading, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          if (cartProvider.itemCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Badge(
                  backgroundColor: _kOrange,
                  label: Text('${cartProvider.itemCount}',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 11)),
                  child: const Icon(Icons.shopping_cart_outlined,
                      color: _kOrange, size: 24),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (cartProvider.itemCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: _kOrange,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${cartProvider.itemCount} plan(s) selected • ₹${cartProvider.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(Icons.directions_car, 'Select Vehicle',
                      'Choose the vehicle for this service'),
                  const SizedBox(height: 16),
                  if (vehiclesProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(color: _kOrange),
                      ),
                    )
                  else ...[
                    if (vehiclesProvider.vehicles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No vehicles yet. ${_subtleAddHint()}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _kBody.withValues(alpha: 0.9), fontSize: 14),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 28,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.88,
                        ),
                        itemCount: vehiclesProvider.vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = vehiclesProvider.vehicles[index];
                          return _vehicleTile(vehicle);
                        },
                      ),
                    const SizedBox(height: 12),
                    Center(child: _addVehicleSubtle()),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _subtleAddHint() => 'Tap below to add one.';

  Widget _vehicleTile(VehicleModel vehicle) {
    final imageUrl = vehicle.images.isNotEmpty ? vehicle.images.first : null;

    return InkWell(
      onTap: () => _openPhotos(vehicle),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _kOrange.withValues(alpha: 0.8),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _vehicleTitle(vehicle),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: _kHeading,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return ColoredBox(
      color: const Color(0xFFE8E8E8),
      child: Center(
        child: Icon(
          Icons.directions_car_outlined,
          size: 44,
          color: _kBody.withValues(alpha: 0.35),
        ),
      ),
    );
  }

  Widget _addVehicleSubtle() {
    return TextButton.icon(
      onPressed: () async {
        final result = await context.push('/vehicles/add');
        if (result == true && mounted) {
          _loadVehicles();
        }
      },
      icon: Icon(Icons.add, size: 18, color: _kBody.withValues(alpha: 0.75)),
      label: Text(
        'Add new vehicle',
        style: TextStyle(
          color: _kBody.withValues(alpha: 0.85),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: _kBody,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _kOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: _kOrange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _kHeading,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: _kBody, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
