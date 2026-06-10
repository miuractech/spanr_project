import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/vehicle_model.dart';
import '../vehicles_provider.dart';
import '../../auth/auth_provider.dart';
const _kOrange = Color(0xFFFC8019);
const _kHeading = Color(0xFF1C1C1C);
const _kBody = Color(0xFF696969);
const _kBg = Color(0xFFF2F2F2);

InputDecoration _fieldDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _kOrange, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
  );
}

class AddVehicleScreen extends StatefulWidget {
  final VehicleModel? vehicle;

  const AddVehicleScreen({super.key, this.vehicle});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licensePlateController = TextEditingController();
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _makeController = TextEditingController();
  final _colorController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _isUploadingImage = false;
  bool _isIndianLicensed = true;
  bool _isPrimary = false;
  String _vehicleType = 'car';
  int _year = DateTime.now().year;
  List<File> _newImages = [];
  List<String> _existingImages = [];
  List<String> _originalImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _originalImages = List<String>.from(widget.vehicle!.images);
      _existingImages = List<String>.from(_originalImages);
      _licensePlateController.text = widget.vehicle!.licensePlate;
      _nameController.text = widget.vehicle!.name ?? '';
      _modelController.text = widget.vehicle!.model;
      _makeController.text = widget.vehicle!.make;
      _colorController.text = widget.vehicle!.color ?? '';
      _year = widget.vehicle!.year;
      _vehicleType = widget.vehicle!.vehicleType;
      _isIndianLicensed = widget.vehicle!.isIndianLicensed;
      _isPrimary = widget.vehicle!.isPrimary;
    }
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _nameController.dispose();
    _modelController.dispose();
    _makeController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceActionSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
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
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: _kOrange),
                title: const Text('Take Photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: _kOrange),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: _kBody),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      await _pickImage(source);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      bool hasPermission = false;
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        hasPermission = status.isGranted;
        if (!hasPermission) {
          if (mounted) {
            final shouldOpenSettings = await _showPermissionDeniedDialog('Camera');
            if (shouldOpenSettings) {
              await openAppSettings();
            }
          }
          return;
        }
      } else {
        final status = await Permission.photos.request();
        hasPermission = status.isGranted || status.isLimited;
        if (!hasPermission) {
          if (mounted) {
            final shouldOpenSettings = await _showPermissionDeniedDialog('Photos');
            if (shouldOpenSettings) {
              await openAppSettings();
            }
          }
          return;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _newImages.add(File(image.path));
        });
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$permissionName Permission Required',
            style: const TextStyle(color: _kHeading, fontWeight: FontWeight.w700)),
        content: Text(
          '$permissionName permission is required to add vehicle photos. '
          'Would you like to open settings to enable it?',
          style: const TextStyle(color: _kBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: _kBody)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings',
                style: TextStyle(color: _kOrange, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _deleteExistingImage(String imageUrl) async {
    if (widget.vehicle == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Image',
            style: TextStyle(color: _kHeading, fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to delete this image?',
            style: TextStyle(color: _kBody)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: _kBody)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _existingImages.remove(imageUrl));
    }
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId == null) throw Exception('User not authenticated');

      String vehicleId;

      if (widget.vehicle != null) {
        vehicleId = widget.vehicle!.id;

        final removedUrls = _originalImages
            .where((url) => !_existingImages.contains(url))
            .toList();
        for (final imageUrl in removedUrls) {
          await context.read<VehiclesProvider>().deleteImage(vehicleId, imageUrl);
        }

        await context.read<VehiclesProvider>().updateVehicle(
          vehicleId,
          {
            'name': _nameController.text.trim(),
            'make': _makeController.text.trim(),
            'model': _modelController.text.trim(),
            'year': _year,
            'color': _colorController.text.trim(),
            'license_plate': _licensePlateController.text.trim().toUpperCase(),
            'vehicle_type': _vehicleType,
            'is_primary': _isPrimary,
            'is_indian_licensed': _isIndianLicensed,
          },
        );
      } else {
        final vehicle = VehicleModel(
          id: '',
          userId: userId,
          name: _nameController.text.trim(),
          make: _makeController.text.trim(),
          model: _modelController.text.trim(),
          year: _year,
          color: _colorController.text.trim(),
          licensePlate: _licensePlateController.text.trim().toUpperCase(),
          vehicleType: _vehicleType,
          isPrimary: _isPrimary,
          isIndianLicensed: _isIndianLicensed,
          createdAt: DateTime.now(),
        );

        final newVehicle = await context.read<VehiclesProvider>().addVehicle(vehicle);
        vehicleId = newVehicle.id;
      }

      for (final imageFile in _newImages) {
        await context.read<VehiclesProvider>().uploadImage(vehicleId, imageFile);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save vehicle: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.vehicle != null;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kHeading),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Vehicle Details',
          style: TextStyle(
            color: _kHeading,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildLabel('Registration Plate'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _licensePlateController,
              decoration: _fieldDecoration('RJ 45 9855'),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the license plate';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _isIndianLicensed,
                    onChanged: (value) {
                      setState(() => _isIndianLicensed = value ?? true);
                    },
                    activeColor: _kOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'i have a indian licensed vehicle',
                  style: TextStyle(fontSize: 14, color: _kBody),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildLabel('Vehicle Type'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildTypeButton('car', 'Car', Icons.directions_car)),
                const SizedBox(width: 12),
                Expanded(child: _buildTypeButton('bike', 'Bike', Icons.two_wheeler)),
              ],
            ),
            const SizedBox(height: 24),

            _buildLabel('Name your vehicle'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: _fieldDecoration('Tata'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),

            _buildLabel('Model'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _modelController,
              decoration: _fieldDecoration('2020'),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter the model';
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildLabel('Make'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _makeController,
              decoration: _fieldDecoration('Nexon'),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter the make';
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildLabel('Color'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _colorController,
              decoration: _fieldDecoration('White'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Make Primary Vehicle',
                    style: TextStyle(
                      fontSize: 15,
                      color: _kHeading,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Switch(
                    value: _isPrimary,
                    onChanged: (value) => setState(() => _isPrimary = value),
                    activeColor: _kOrange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_existingImages.isNotEmpty || _newImages.isNotEmpty) ...[
              _buildLabel('Vehicle Images'),
              const SizedBox(height: 8),

              if (_existingImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _existingImages.length,
                    itemBuilder: (context, index) {
                      final imageUrl = _existingImages[index];
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 10),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: InkWell(
                                onTap: () => _deleteExistingImage(imageUrl),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.redAccent),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              if (_newImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _newImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 10),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _newImages[index],
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _newImages.removeAt(index));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.close, size: 14, color: Colors.redAccent),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUploadingImage ? null : _showImageSourceActionSheet,
                icon: const Icon(Icons.add_a_photo, size: 18, color: _kOrange),
                label: const Text('Add Photo',
                    style: TextStyle(color: _kOrange, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: _kOrange.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading || _isUploadingImage ? null : _saveVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOrange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _kOrange.withValues(alpha: 0.5),
                  disabledForegroundColor: Colors.white70,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        isEdit ? 'Update' : 'Add',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _kHeading,
      ),
    );
  }

  Widget _buildTypeButton(String type, String label, IconData icon) {
    final selected = _vehicleType == type;
    return InkWell(
      onTap: () => setState(() => _vehicleType = type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _kOrange : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _kOrange : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: selected ? Colors.white : _kBody),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _kHeading,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
