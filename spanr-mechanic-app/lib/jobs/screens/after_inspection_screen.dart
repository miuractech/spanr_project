import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../jobs_service.dart';
import '../models/inspection_image.dart';
import '../widgets/inspection_photo_grid.dart';
import '../../core/offline/connectivity_service.dart';
import '../../core/offline/sync_service.dart';

class AfterInspectionScreen extends StatefulWidget {
  final String orderId;
  const AfterInspectionScreen({super.key, required this.orderId});

  @override
  State<AfterInspectionScreen> createState() => _AfterInspectionScreenState();
}

class _AfterInspectionScreenState extends State<AfterInspectionScreen> {
  final _jobsService = JobsService();
  final _photos = <InspectionAngle, String>{};
  bool _saving = false;

  String _angleDb(InspectionAngle angle) {
    switch (angle) {
      case InspectionAngle.front: return 'front';
      case InspectionAngle.back: return 'back';
      case InspectionAngle.left: return 'left';
      case InspectionAngle.right: return 'right';
      case InspectionAngle.other: return 'other';
    }
  }

  Future<void> _save() async {
    if (_photos.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture all 4 angles')),
      );
      return;
    }
    setState(() => _saving = true);
    final staff = context.read<AuthProvider>().staff!;
    final sync = context.read<SyncService>();
    final connectivity = context.read<ConnectivityService>();

    try {
      for (final entry in _photos.entries) {
        final payload = {
          'order_id': widget.orderId,
          'staff_id': staff.id,
          'local_path': entry.value,
          'type': 'after',
          'angle': _angleDb(entry.key),
        };
        if (connectivity.isOnline) {
          await _jobsService.uploadInspectionImage(
            orderId: widget.orderId,
            staffId: staff.id,
            localPath: entry.value,
            type: 'after',
            angle: _angleDb(entry.key),
          );
        } else {
          await sync.enqueue('upload_inspection', payload);
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('After inspection saved')));
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('After Inspection')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Capture Front, Back, Left, Right photos', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          InspectionPhotoGrid(
            type: InspectionType.after,
            onPhotoTaken: (angle, path) => _photos[angle] = path,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save After Inspection'),
          ),
        ],
      ),
    );
  }
}
