import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../jobs_service.dart';
import '../../core/offline/connectivity_service.dart';
import '../../core/offline/sync_service.dart';
import '../widgets/part_photo_picker.dart';

class PartsReplacementScreen extends StatefulWidget {
  final String orderId;
  const PartsReplacementScreen({super.key, required this.orderId});

  @override
  State<PartsReplacementScreen> createState() => _PartsReplacementScreenState();
}

class _PartsReplacementScreenState extends State<PartsReplacementScreen> {
  final _jobsService = JobsService();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _brandController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _costController = TextEditingController();
  final _kmController = TextEditingController();
  String? _beforePhotoPath;
  String? _afterPhotoPath;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _brandController.dispose();
    _qtyController.dispose();
    _costController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final staff = context.read<AuthProvider>().staff!;
    final sync = context.read<SyncService>();
    final connectivity = context.read<ConnectivityService>();

    final payload = {
      'order_id': widget.orderId,
      'staff_id': staff.id,
      'part_name': _nameController.text.trim(),
      'part_number': _numberController.text.trim().isEmpty ? null : _numberController.text.trim(),
      'brand': _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      'quantity': int.tryParse(_qtyController.text) ?? 1,
      'cost': double.tryParse(_costController.text),
      'km_reading': int.tryParse(_kmController.text),
      'before_photo_path': _beforePhotoPath,
      'after_photo_path': _afterPhotoPath,
    };

    try {
      if (connectivity.isOnline) {
        await _jobsService.addPart(
          orderId: widget.orderId,
          staffId: staff.id,
          partName: payload['part_name'] as String,
          partNumber: payload['part_number'] as String?,
          brand: payload['brand'] as String?,
          quantity: payload['quantity'] as int,
          cost: payload['cost'] as double?,
          kmReading: payload['km_reading'] as int?,
          beforePhotoPath: _beforePhotoPath,
          afterPhotoPath: _afterPhotoPath,
        );
      } else {
        await sync.enqueue('add_part', payload);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Part added')));
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(TextEditingController controller, String label, {bool required = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: required ? '$label *' : label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parts Replacement')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Record a replaced part for this job',
            style: TextStyle(color: AppTheme.textBody, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _field(_nameController, 'Part Name', required: true),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _field(_numberController, 'Part Number')),
                      const SizedBox(width: 12),
                      Expanded(child: _field(_brandController, 'Brand')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _field(_qtyController, 'Quantity', keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _field(_costController, 'Cost (₹)', keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _field(_kmController, 'KM Reading', keyboardType: TextInputType.number),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Part Photos', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text(
                    'Optional — capture old and new part',
                    style: TextStyle(fontSize: 12, color: AppTheme.textBody),
                  ),
                  const SizedBox(height: 16),
                  PartPhotoPicker(
                    label: 'Before (Old Part)',
                    photoPath: _beforePhotoPath,
                    onPhotoSelected: (path) => setState(() => _beforePhotoPath = path),
                  ),
                  const SizedBox(height: 20),
                  PartPhotoPicker(
                    label: 'After (New Part)',
                    photoPath: _afterPhotoPath,
                    onPhotoSelected: (path) => setState(() => _afterPhotoPath = path),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Add Part'),
          ),
        ],
      ),
    );
  }
}
