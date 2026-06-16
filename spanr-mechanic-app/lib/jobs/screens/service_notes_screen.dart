import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../jobs_service.dart';
import '../../core/offline/connectivity_service.dart';
import '../../core/offline/sync_service.dart';

class ServiceNotesScreen extends StatefulWidget {
  final String orderId;
  const ServiceNotesScreen({super.key, required this.orderId});

  @override
  State<ServiceNotesScreen> createState() => _ServiceNotesScreenState();
}

class _ServiceNotesScreenState extends State<ServiceNotesScreen> {
  final _jobsService = JobsService();
  final _notesController = TextEditingController();
  final _descController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _notesController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final sync = context.read<SyncService>();
    final connectivity = context.read<ConnectivityService>();

    final payload = {
      'order_id': widget.orderId,
      'notes': _notesController.text.trim(),
      'description': _descController.text.trim().isEmpty ? null : _descController.text.trim(),
    };

    try {
      if (connectivity.isOnline) {
        await _jobsService.saveServiceNotes(
          widget.orderId,
          payload['notes'] as String,
          description: payload['description'] is String ? payload['description'] as String : null,
        );
      } else {
        await sync.enqueue('save_notes', payload);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notes saved')));
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Notes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Work Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Service / Repair Notes'),
              maxLines: 5,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Notes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
