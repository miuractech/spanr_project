import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/assigned_job.dart';

class JobPlanDetails extends StatelessWidget {
  final AssignedJob job;
  const JobPlanDetails({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    if (!job.hasPlanDetails) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan details',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textBody,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (job.planDurationDisplay.isNotEmpty ||
              job.planLocationDisplay.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (job.planDurationDisplay.isNotEmpty)
                  _chip(Icons.schedule, job.planDurationDisplay),
                if (job.planLocationDisplay.isNotEmpty)
                  _chip(Icons.place_outlined, job.planLocationDisplay),
                if ((job.planVehicleType ?? '').isNotEmpty)
                  _chip(Icons.directions_car_outlined, job.planVehicleType!),
              ],
            ),
          ],
          if ((job.planWarranty ?? '').isNotEmpty)
            _meta('Warranty', job.planWarranty!),
          if ((job.planGuarantee ?? '').isNotEmpty)
            _meta('Guarantee', job.planGuarantee!),
          _section('Included jobs', job.planJobs),
          _section("What's included", job.planFeatures),
          _section('Service steps', job.planSteps),
          _section('Additional services', job.planAdditionalServices),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryOrangeLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryOrange),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textHeading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textHeading,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontSize: 13, color: AppTheme.textBody),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textHeading,
            ),
          ),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppTheme.textHeading,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
