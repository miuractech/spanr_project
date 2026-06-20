import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/part_replacement.dart';

class PartReplacementCard extends StatelessWidget {
  final PartReplacement part;
  final VoidCallback onTap;

  const PartReplacementCard({
    super.key,
    required this.part,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[];
    if (part.partNumber != null) subtitleParts.add('No. ${part.partNumber}');
    subtitleParts.add('Qty: ${part.quantity}');
    if (part.brand != null) subtitleParts.add(part.brand!);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrangeLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.settings_outlined, color: AppTheme.primaryOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part.partName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.textHeading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitleParts.join(' · '),
                      style: const TextStyle(color: AppTheme.textBody, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (part.cost != null)
                Text(
                  '₹${part.cost!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryOrange,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppTheme.textBody, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
