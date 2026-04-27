import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/vehicle_model.dart';
import '../vehicles_provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
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
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
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

  Future<void> _deleteExistingImage(String imageUrl) async {
    if (widget.vehicle == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isUploadingImage = true);
      try {
        await context
            .read<VehiclesProvider>()
            .deleteImage(widget.vehicle!.id, imageUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete image: $e')),
          );
        }
      } finally {
        setState(() => _isUploadingImage = false);
      }
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
        await context.read<VehiclesProvider>().updateVehicle(
          widget.vehicle!.id,
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
        vehicleId = widget.vehicle!.id;
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

      // Upload new images
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
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkGrey),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Vehicle Details',
          style: const TextStyle(
            color: AppTheme.darkGrey,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Registration Plate
            Text(
              'Registration Plate',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _licensePlateController,
              decoration: InputDecoration(
                hintText: 'RJ 45 9855',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the license plate';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            // Indian Licensed Checkbox
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _isIndianLicensed,
                    onChanged: (value) {
                      setState(() {
                        _isIndianLicensed = value ?? true;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'i have a indian licensed vehicle',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Vehicle Type Selection
            Text(
              'Vehicle Type',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _vehicleType = 'car'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _vehicleType == 'car'
                            ? AppTheme.primaryBlack
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _vehicleType == 'car'
                              ? AppTheme.primaryBlack
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Car',
                          style: TextStyle(
                            color: _vehicleType == 'car'
                                ? Colors.white
                                : AppTheme.darkGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _vehicleType = 'bike'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _vehicleType == 'bike'
                            ? AppTheme.primaryBlack
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _vehicleType == 'bike'
                              ? AppTheme.primaryBlack
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Bike',
                          style: TextStyle(
                            color: _vehicleType == 'bike'
                                ? Colors.white
                                : AppTheme.darkGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Name your vehicle
            Text(
              'Name your vehicle',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Tata',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),
            
            // Model
            Text(
              'Model',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _modelController,
              decoration: InputDecoration(
                hintText: '2020',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the model';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Make
            Text(
              'Make',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _makeController,
              decoration: InputDecoration(
                hintText: 'Nexon',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the make';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Color
            Text(
              'Color',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _colorController,
              decoration: InputDecoration(
                hintText: 'White',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),
            
            // Make Primary Vehicle Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Make Primary Vehicle',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Switch(
                    value: _isPrimary,
                    onChanged: (value) {
                      setState(() {
                        _isPrimary = value;
                      });
                    },
                    activeColor: AppTheme.primaryBlack,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Images Section
            if (widget.vehicle?.images.isNotEmpty == true ||
                _newImages.isNotEmpty) ...[
              Text(
                'Vehicle Images',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.darkGrey,
                ),
              ),
              const SizedBox(height: 8),
              
              // Existing Images
              if (widget.vehicle?.images.isNotEmpty == true)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.vehicle!.images.length,
                    itemBuilder: (context, index) {
                      final imageUrl = widget.vehicle!.images[index];
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
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
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              
              // New Images
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
                          margin: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
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
                                    setState(() {
                                      _newImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.red,
                                    ),
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
            
            // Add Photo Button
            OutlinedButton.icon(
              onPressed: _isUploadingImage ? null : _showImageSourceActionSheet,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add Photo'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(height: 32),
            
            // Add Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading || _isUploadingImage ? null : _saveVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEdit ? 'Update' : 'Add',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
