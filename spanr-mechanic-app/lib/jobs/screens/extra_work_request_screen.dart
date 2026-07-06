import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../jobs_provider.dart';

class ExtraWorkRequestScreen extends StatefulWidget {
  final String orderId;
  const ExtraWorkRequestScreen({super.key, required this.orderId});

  @override
  State<ExtraWorkRequestScreen> createState() => _ExtraWorkRequestScreenState();
}

class _ExtraWorkRequestScreenState extends State<ExtraWorkRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _costController = TextEditingController();
  File? _photoFile;
  bool _loading = false;
  String? _error;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _photoFile = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cost = double.tryParse(_costController.text.trim());
    if (cost == null || cost < 0) {
      setState(() => _error = 'Enter a valid cost');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final provider = context.read<JobsProvider>();
      await provider.submitExtraWorkRequest(
        orderId: widget.orderId,
        description: _descController.text.trim(),
        estimatedCost: cost,
        photoPath: _photoFile?.path,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Extra work request submitted. Order is now on hold.'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Extra Work')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Describe the additional work needed. The customer will be notified to approve before you proceed.',
                style: TextStyle(color: AppTheme.textBody, fontSize: 13),
              ),
              const SizedBox(height: 20),

              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),

              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description of extra work *',
                  hintText: 'e.g. Front brake pads worn out, need replacement',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Estimated cost (₹) *',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Cost is required';
                  if (double.tryParse(v.trim()) == null) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'Photo (optional)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (_photoFile != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _photoFile!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => setState(() => _photoFile = null),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Remove photo'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ] else
                OutlinedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Take Photo'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Request',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
