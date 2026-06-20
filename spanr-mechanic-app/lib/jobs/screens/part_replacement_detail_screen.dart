import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../jobs_service.dart';
import '../models/part_replacement.dart';

class PartReplacementDetailScreen extends StatefulWidget {
  final String partId;

  const PartReplacementDetailScreen({super.key, required this.partId});

  @override
  State<PartReplacementDetailScreen> createState() => _PartReplacementDetailScreenState();
}

class _PartReplacementDetailScreenState extends State<PartReplacementDetailScreen> {
  final _jobsService = JobsService();
  PartReplacement? _part;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPart();
  }

  Future<void> _loadPart() async {
    setState(() => _loading = true);
    try {
      final part = await _jobsService.getPartReplacementById(widget.partId);
      if (mounted) setState(() => _part = part);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _detailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppTheme.textBody, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _photoSection(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: url,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              height: 180,
              color: AppTheme.borderLight,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (_, __, ___) => Container(
              height: 180,
              color: AppTheme.borderLight,
              child: const Icon(Icons.broken_image_outlined, color: AppTheme.textBody),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Part Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _part == null
              ? const Center(child: Text('Part not found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _part!.partName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppTheme.textHeading,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_part!.partNumber != null)
                              _detailTile('Part Number', _part!.partNumber!),
                            if (_part!.brand != null) _detailTile('Brand', _part!.brand!),
                            _detailTile('Quantity', '${_part!.quantity}'),
                            if (_part!.cost != null)
                              _detailTile('Cost', '₹${_part!.cost!.toStringAsFixed(0)}'),
                            if (_part!.kmReading != null)
                              _detailTile('KM Reading', '${_part!.kmReading} km'),
                          ],
                        ),
                      ),
                    ),
                    if (_part!.beforePhotoUrl != null || _part!.photoUrl != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Photos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              const SizedBox(height: 16),
                              if (_part!.beforePhotoUrl != null)
                                _photoSection('Before (Old Part)', _part!.beforePhotoUrl!),
                              if (_part!.beforePhotoUrl != null && _part!.photoUrl != null)
                                const SizedBox(height: 16),
                              if (_part!.photoUrl != null)
                                _photoSection('After (New Part)', _part!.photoUrl!),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}
