import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../mechanics/models/mechanic_company.dart';
import '../vehicles/models/vehicle_model.dart';
import 'widgets/dashed_rect_painter.dart';

const _kOrange = Color(0xFFFC8019);
const _kHeading = Color(0xFF1C1C1C);
const _kBody = Color(0xFF696969);
const _kBg = Color(0xFFF2F2F2);

enum _VehicleAngle {
  leftSide,
  rightSide,
  front,
  back;

  String get label => switch (this) {
        _VehicleAngle.leftSide => 'Left side',
        _VehicleAngle.rightSide => 'Right side',
        _VehicleAngle.front => 'Front side',
        _VehicleAngle.back => 'Back side',
      };
}

class SelectVehiclePhotosScreen extends StatefulWidget {
  final MechanicCompany company;
  final VehicleModel vehicle;

  const SelectVehiclePhotosScreen({
    super.key,
    required this.company,
    required this.vehicle,
  });

  @override
  State<SelectVehiclePhotosScreen> createState() =>
      _SelectVehiclePhotosScreenState();
}

class _SelectVehiclePhotosScreenState extends State<SelectVehiclePhotosScreen> {
  final Map<_VehicleAngle, File?> _angles = {};
  final ImagePicker _picker = ImagePicker();

  bool get _allSidesCaptured =>
      _VehicleAngle.values.every((a) => _angles[a] != null);

  Future<void> _takePhoto(_VehicleAngle angle) async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          final openSettings = await _showPermissionDeniedDialog();
          if (openSettings) await openAppSettings();
        }
        return;
      }
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() => _angles[angle] = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture photo: $e')),
        );
      }
    }
  }

  Future<bool> _showPermissionDeniedDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Camera Permission Required',
            style: TextStyle(color: _kHeading)),
        content: const Text(
          'Camera access is needed to photograph your vehicle.',
          style: TextStyle(color: _kBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: _kOrange),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _proceedToCheckout() {
    for (final a in _VehicleAngle.values) {
      if (_angles[a] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please capture: ${a.label}')),
        );
        return;
      }
    }

    final beforeImages = [
      _angles[_VehicleAngle.leftSide]!,
      _angles[_VehicleAngle.rightSide]!,
      _angles[_VehicleAngle.front]!,
      _angles[_VehicleAngle.back]!,
    ];

    context.push('/checkout', extra: {
      'company': widget.company,
      'vehicle': widget.vehicle,
      'beforeImages': beforeImages,
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = '${widget.vehicle.make} ${widget.vehicle.model}';

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kHeading),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle photos',
              style: TextStyle(
                color: _kHeading,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: _kBody,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Take one photo each: left side, right side, front side and back side.',
                style: TextStyle(
                  color: _kBody.withValues(alpha: 0.95),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.88,
                ),
                itemCount: _VehicleAngle.values.length,
                itemBuilder: (context, index) {
                  final angle = _VehicleAngle.values[index];
                  final file = _angles[angle];
                  return _angleSlot(angle, file);
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _allSidesCaptured ? _proceedToCheckout : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kOrange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE0E0E0),
                    disabledForegroundColor: _kBody,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                  ),
                  child: Text(
                    _allSidesCaptured
                        ? 'Proceed to Checkout'
                        : 'Capture all 4 sides to continue',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _angleSlot(_VehicleAngle angle, File? file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => _takePhoto(angle),
              borderRadius: BorderRadius.circular(4),
              child: CustomPaint(
                painter: DashedRectPainter(
                  color: _kBody.withValues(alpha: file != null ? 0.2 : 0.4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: file != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(file, fit: BoxFit.cover),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    'Retake',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 36,
                              color: _kBody.withValues(alpha: 0.35),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          angle.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _kHeading.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
