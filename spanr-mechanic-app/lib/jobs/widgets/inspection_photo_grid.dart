import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/inspection_image.dart';
import '../../core/theme/app_theme.dart';

class InspectionPhotoGrid extends StatefulWidget {
  final InspectionType type;
  final void Function(InspectionAngle angle, String localPath) onPhotoTaken;

  const InspectionPhotoGrid({
    super.key,
    required this.type,
    required this.onPhotoTaken,
  });

  @override
  State<InspectionPhotoGrid> createState() => _InspectionPhotoGridState();
}

class _InspectionPhotoGridState extends State<InspectionPhotoGrid> {
  final _picker = ImagePicker();
  final Map<InspectionAngle, String> _photos = {};

  static const _angles = [
    InspectionAngle.front,
    InspectionAngle.back,
    InspectionAngle.left,
    InspectionAngle.right,
  ];

  Future<void> _capture(InspectionAngle angle) async {
    final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image == null) return;
    setState(() => _photos[angle] = image.path);
    widget.onPhotoTaken(angle, image.path);
  }

  String _label(InspectionAngle angle) {
    switch (angle) {
      case InspectionAngle.front: return 'Front';
      case InspectionAngle.back: return 'Back';
      case InspectionAngle.left: return 'Left';
      case InspectionAngle.right: return 'Right';
      case InspectionAngle.other: return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: _angles.map((angle) {
        final path = _photos[angle];
        return GestureDetector(
          onTap: () => _capture(angle),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: path != null ? AppTheme.primaryOrange : AppTheme.borderLight, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: path != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(File(path), fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt, color: AppTheme.textBody),
                      const SizedBox(height: 8),
                      Text(_label(angle), style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
          ),
        );
      }).toList(),
    );
  }
}
