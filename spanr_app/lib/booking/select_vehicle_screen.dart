import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../vehicles/models/vehicle_model.dart';
import '../vehicles/vehicles_provider.dart';
import '../mechanics/models/mechanic_company.dart';
import '../auth/auth_provider.dart';
import '../cart/cart_provider.dart';

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
  VehicleModel? _selectedVehicle;
  final List<File> _beforeImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

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

  Future<void> _showImageSourceActionSheet() async {
    final option = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.camera_alt,
                      color: Theme.of(context).colorScheme.primary),
                ),
                title: const Text('Take Photo'),
                onTap: () => Navigator.of(context).pop('camera'),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.photo_library,
                      color: Theme.of(context).colorScheme.primary),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.of(context).pop('gallery'),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.photo_library,
                      color: Theme.of(context).colorScheme.primary),
                ),
                title: const Text('Choose Multiple from Gallery'),
                onTap: () => Navigator.of(context).pop('gallery_multiple'),
              ),
            ],
          ),
        ),
      ),
    );

    if (option == null) return;

    try {
      if (option == 'camera') {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          if (mounted) {
            final shouldOpenSettings = await _showPermissionDeniedDialog('Camera');
            if (shouldOpenSettings) {
              await openAppSettings();
            }
          }
          return;
        }

        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (image != null) {
          setState(() {
            _beforeImages.add(File(image.path));
          });
        }
      } else if (option == 'gallery' || option == 'gallery_multiple') {
        final status = await Permission.photos.request();
        if (!status.isGranted && !status.isLimited) {
          if (mounted) {
            final shouldOpenSettings = await _showPermissionDeniedDialog('Photos');
            if (shouldOpenSettings) {
              await openAppSettings();
            }
          }
          return;
        }

        if (option == 'gallery') {
          final XFile? image = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
          );
          if (image != null) {
            setState(() {
              _beforeImages.add(File(image.path));
            });
          }
        } else {
          final List<XFile> images = await _picker.pickMultiImage(
            imageQuality: 80,
          );
          if (images.isNotEmpty) {
            setState(() {
              _beforeImages.addAll(images.map((xFile) => File(xFile.path)));
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<bool> _showPermissionDeniedDialog(String permissionName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(
          '$permissionName permission is required to add vehicle photos. '
          'Would you like to open settings to enable it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _removeImage(int index) {
    setState(() {
      _beforeImages.removeAt(index);
    });
  }

  void _proceedToCheckout() {
    final cartProvider = context.read<CartProvider>();

    if (cartProvider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty. Please add plans first.')),
      );
      return;
    }

    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle')),
      );
      return;
    }

    if (_beforeImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take at least one before picture')),
      );
      return;
    }

    context.push('/checkout', extra: {
      'company': widget.company,
      'vehicle': _selectedVehicle,
      'beforeImages': _beforeImages,
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesProvider = context.watch<VehiclesProvider>();
    final cartProvider = context.watch<CartProvider>();
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Vehicle & Photos'),
        actions: [
          if (cartProvider.itemCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Badge(
                  label: Text('${cartProvider.itemCount}'),
                  child: const Icon(Icons.shopping_cart),
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
              color: primary.withValues(alpha: 0.08),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 14, color: primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${cartProvider.itemCount} plan(s) selected • ₹${cartProvider.total.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: primary,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, Icons.directions_car, 'Select Vehicle',
                      'Choose the vehicle for this service'),
                  const SizedBox(height: 16),

                  if (vehiclesProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    if (vehiclesProvider.vehicles.isNotEmpty)
                      ...vehiclesProvider.vehicles.map((vehicle) => _buildVehicleCard(vehicle)),

                    Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final result = await context.push('/vehicles/add');
                          if (result == true) {
                            _loadVehicles();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.add, size: 26, color: primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Add New Vehicle',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: primary,
                                      ),
                                ),
                              ),
                              Icon(Icons.chevron_right, color: primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  _buildSectionHeader(
                    context,
                    Icons.photo_camera,
                    'Before Service Photos',
                    'Required — take photos of your vehicle before service',
                  ),
                  const SizedBox(height: 16),

                  if (_beforeImages.isNotEmpty) ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _beforeImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _beforeImages[index],
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  OutlinedButton.icon(
                    onPressed: _showImageSourceActionSheet,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add Photos'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _proceedToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 54),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Proceed to Checkout',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, IconData icon, String title, String subtitle) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    final isSelected = _selectedVehicle?.id == vehicle.id;
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: primary, width: 2)
            : BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: isSelected ? primary.withValues(alpha: 0.06) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedVehicle = vehicle;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected ? primary.withValues(alpha: 0.12) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.directions_car,
                  size: 28,
                  color: isSelected ? primary : Colors.grey[500],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.make} ${vehicle.model}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? primary : null,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${vehicle.year} • ${vehicle.licensePlate}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
