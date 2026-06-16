import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../jobs_provider.dart';
import '../jobs_service.dart';
import '../../core/offline/connectivity_service.dart';
import '../../core/offline/sync_service.dart';

class CompleteJobScreen extends StatefulWidget {
  final String orderId;
  const CompleteJobScreen({super.key, required this.orderId});

  @override
  State<CompleteJobScreen> createState() => _CompleteJobScreenState();
}

class _CompleteJobScreenState extends State<CompleteJobScreen> {
  final _jobsService = JobsService();
  final _kmController = TextEditingController();
  final _notesController = TextEditingController();
  final _servicesController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _kmController.dispose();
    _notesController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    setState(() => _saving = true);
    final staff = context.read<AuthProvider>().staff!;
    final sync = context.read<SyncService>();
    final connectivity = context.read<ConnectivityService>();
    final jobsProvider = context.read<JobsProvider>();

    final payload = {
      'order_id': widget.orderId,
      'staff_id': staff.id,
      'odometer': int.tryParse(_kmController.text),
      'service_notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      'services_performed': _servicesController.text.trim().isEmpty ? null : _servicesController.text.trim(),
    };

    try {
      if (connectivity.isOnline) {
        await _jobsService.completeJob(
          orderId: widget.orderId,
          staffId: staff.id,
          odometer: payload['odometer'] as int?,
          serviceNotes: payload['service_notes'] as String?,
          servicesPerformed: payload['services_performed'] as String?,
        );
      } else {
        await sync.enqueue('complete_job', payload);
      }
      await jobsProvider.refresh(staff);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job completed — service history created')),
        );
        context.go('/jobs');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Job')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _kmController,
              decoration: const InputDecoration(labelText: 'Odometer Reading (KM) *'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _servicesController,
              decoration: const InputDecoration(labelText: 'Services Performed'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Final Notes'),
              maxLines: 4,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _complete,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Mark Work Completed'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
