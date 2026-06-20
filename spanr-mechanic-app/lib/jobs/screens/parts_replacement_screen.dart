import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../jobs_service.dart';
import '../models/part_replacement.dart';
import '../../core/offline/connectivity_service.dart';
import '../../core/offline/sync_service.dart';
import '../widgets/part_replacement_card.dart';
import '../widgets/part_replacement_form.dart';
import '../widgets/workflow_action_button.dart';

class PartsReplacementScreen extends StatefulWidget {
  final String orderId;
  const PartsReplacementScreen({super.key, required this.orderId});

  @override
  State<PartsReplacementScreen> createState() => _PartsReplacementScreenState();
}

class _PartsReplacementScreenState extends State<PartsReplacementScreen> {
  final _jobsService = JobsService();
  List<PartReplacement> _parts = [];
  bool _loading = true;
  bool _showForm = false;
  bool _saving = false;
  int _formKey = 0;

  @override
  void initState() {
    super.initState();
    _loadParts();
  }

  Future<void> _loadParts() async {
    setState(() => _loading = true);
    try {
      final parts = await _jobsService.getPartsReplaced(widget.orderId);
      if (mounted) setState(() => _parts = parts);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _savePart(PartReplacementFormData data) async {
    setState(() => _saving = true);
    final staff = context.read<AuthProvider>().staff!;
    final sync = context.read<SyncService>();
    final connectivity = context.read<ConnectivityService>();

    final payload = {
      'order_id': widget.orderId,
      'staff_id': staff.id,
      'part_name': data.partName,
      'part_number': data.partNumber,
      'brand': data.brand,
      'quantity': data.quantity,
      'cost': data.cost,
      'km_reading': data.kmReading,
      'before_photo_path': data.beforePhotoPath,
      'after_photo_path': data.afterPhotoPath,
    };

    try {
      if (connectivity.isOnline) {
        await _jobsService.addPart(
          orderId: widget.orderId,
          staffId: staff.id,
          partName: data.partName,
          partNumber: data.partNumber,
          brand: data.brand,
          quantity: data.quantity,
          cost: data.cost,
          kmReading: data.kmReading,
          beforePhotoPath: data.beforePhotoPath,
          afterPhotoPath: data.afterPhotoPath,
        );
      } else {
        await sync.enqueue('add_part', payload);
      }
      await _loadParts();
      if (mounted) {
        setState(() {
          _showForm = false;
          _formKey++;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Part saved')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parts Replacement')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Record replaced parts for this job',
                  style: TextStyle(color: AppTheme.textBody, fontSize: 14),
                ),
                const SizedBox(height: 16),
                if (_parts.isNotEmpty) ...[
                  const Text(
                    'Replaced Parts',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textHeading),
                  ),
                  const SizedBox(height: 8),
                  ..._parts.map(
                    (part) => PartReplacementCard(
                      part: part,
                      onTap: () {
                        if (part.id != null) {
                          context.push('/jobs/${widget.orderId}/parts/${part.id}');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (_showForm)
                  PartReplacementForm(
                    key: ValueKey(_formKey),
                    saving: _saving,
                    onCancel: () => setState(() => _showForm = false),
                    onSave: _savePart,
                  )
                else
                  WorkflowActionButton(
                    label: 'Add Part Replacement',
                    icon: Icons.add_circle_outline,
                    onPressed: () => setState(() => _showForm = true),
                  ),
              ],
            ),
    );
  }
}
