import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'part_photo_picker.dart';

class PartReplacementFormData {
  final String partName;
  final String? partNumber;
  final String? brand;
  final int quantity;
  final double? cost;
  final int? kmReading;
  final String? beforePhotoPath;
  final String? afterPhotoPath;

  const PartReplacementFormData({
    required this.partName,
    this.partNumber,
    this.brand,
    this.quantity = 1,
    this.cost,
    this.kmReading,
    this.beforePhotoPath,
    this.afterPhotoPath,
  });
}

class PartReplacementForm extends StatefulWidget {
  final bool saving;
  final VoidCallback onCancel;
  final Future<void> Function(PartReplacementFormData data) onSave;

  const PartReplacementForm({
    super.key,
    required this.saving,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<PartReplacementForm> createState() => _PartReplacementFormState();
}

class _PartReplacementFormState extends State<PartReplacementForm> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _brandController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _costController = TextEditingController();
  final _kmController = TextEditingController();
  String? _beforePhotoPath;
  String? _afterPhotoPath;

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

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Part name is required')),
      );
      return;
    }
    await widget.onSave(
      PartReplacementFormData(
        partName: _nameController.text.trim(),
        partNumber: _numberController.text.trim().isEmpty ? null : _numberController.text.trim(),
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        quantity: int.tryParse(_qtyController.text) ?? 1,
        cost: double.tryParse(_costController.text),
        kmReading: int.tryParse(_kmController.text),
        beforePhotoPath: _beforePhotoPath,
        afterPhotoPath: _afterPhotoPath,
      ),
    );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('New Part Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                    IconButton(
                      onPressed: widget.saving ? null : widget.onCancel,
                      icon: const Icon(Icons.close),
                      tooltip: 'Cancel',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: widget.saving ? null : _submit,
          child: widget.saving
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save Part'),
        ),
      ],
    );
  }
}
