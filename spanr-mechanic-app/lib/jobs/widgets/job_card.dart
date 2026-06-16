import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assigned_job.dart';
import '../../core/theme/app_theme.dart';

class JobCard extends StatelessWidget {
  final AssignedJob job;
  final VoidCallback onTap;

  const JobCard({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(job.licensePlate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrangeLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(job.status.label, style: const TextStyle(color: AppTheme.primaryOrange, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(job.vehicleDisplay),
              Text(job.customerName, style: const TextStyle(color: AppTheme.textBody)),
              const SizedBox(height: 8),
              Text(job.planName, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(job.scheduledDate),
                style: const TextStyle(fontSize: 12, color: AppTheme.textBody),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
