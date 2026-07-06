import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../jobs_provider.dart';
import '../models/job_status.dart';
import '../widgets/job_info_tile.dart';
import '../widgets/workflow_action_button.dart';

class JobDetailScreen extends StatefulWidget {
  final String orderId;
  const JobDetailScreen({super.key, required this.orderId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Future<void> _updateStatus(String status) async {
    final jobsProvider = context.read<JobsProvider>();
    await jobsProvider.updateStatus(widget.orderId, status);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final jobsProvider = context.watch<JobsProvider>();
    final job = jobsProvider.getJob(widget.orderId);

    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Detail')),
        body: const Center(child: Text('Job not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(job.licensePlate.isNotEmpty ? job.licensePlate : 'Job Detail'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrangeLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              job.status.label,
              style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          JobInfoTile(
            icon: Icons.person_outline,
            title: 'Customer',
            value: job.customerName,
            subtitle: job.customerPhone,
          ),
          JobInfoTile(
            icon: Icons.directions_car_outlined,
            title: 'Vehicle',
            value: job.vehicleDisplay,
            subtitle: job.licensePlate.isNotEmpty && job.vehicleDisplay != job.licensePlate
                ? job.licensePlate
                : null,
          ),
          JobInfoTile(
            icon: Icons.build_outlined,
            title: 'Service',
            value: job.planName,
          ),
          if (job.specialInstructions != null && job.specialInstructions!.isNotEmpty)
            JobInfoTile(
              icon: Icons.report_problem_outlined,
              title: 'Issue Reported',
              value: job.specialInstructions!,
            ),
          const SizedBox(height: 8),
          const Text(
            'Workflow',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textHeading),
          ),
          const SizedBox(height: 4),
          const Text(
            'Complete each step before finishing the job',
            style: TextStyle(fontSize: 13, color: AppTheme.textBody),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (job.status == JobStatus.assigned)
                    WorkflowActionButton(
                      label: 'Start Job',
                      primary: true,
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => _updateStatus('in_progress'),
                    ),
                  if (job.status == JobStatus.inProgress) ...[
                    WorkflowActionButton(
                      label: 'Waiting for Parts',
                      primary: true,
                      icon: Icons.inventory_2_outlined,
                      onPressed: () => _updateStatus('waiting_for_parts'),
                    ),
                    const SizedBox(height: 10),
                    WorkflowActionButton(
                      label: 'Before Inspection',
                      icon: Icons.photo_camera_outlined,
                      onPressed: () => context.push('/jobs/${widget.orderId}/before'),
                    ),
                    const SizedBox(height: 10),
                    WorkflowActionButton(
                      label: 'Parts Replacement',
                      icon: Icons.settings_outlined,
                      onPressed: () => context.push('/jobs/${widget.orderId}/parts'),
                    ),
                    const SizedBox(height: 10),
                    WorkflowActionButton(
                      label: 'Service Notes',
                      icon: Icons.notes_outlined,
                      onPressed: () => context.push('/jobs/${widget.orderId}/notes'),
                    ),
                    const SizedBox(height: 10),
                    WorkflowActionButton(
                      label: 'After Inspection',
                      icon: Icons.photo_camera_back_outlined,
                      onPressed: () => context.push('/jobs/${widget.orderId}/after'),
                    ),
                    const SizedBox(height: 10),
                    WorkflowActionButton(
                      label: 'Request Extra Work',
                      icon: Icons.warning_amber_outlined,
                      onPressed: () => context.push('/jobs/${widget.orderId}/extra-work'),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    WorkflowActionButton(
                      label: 'Complete Job',
                      primary: true,
                      icon: Icons.check_circle_outline,
                      onPressed: () => context.push('/jobs/${widget.orderId}/complete'),
                    ),
                  ],
                  if (job.status == JobStatus.waitingForParts)
                    WorkflowActionButton(
                      label: 'Resume Work',
                      primary: true,
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => _updateStatus('in_progress'),
                    ),
                  if (job.status == JobStatus.onHold) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.hourglass_top_rounded,
                              color: Colors.amber.shade700, size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Order on hold — waiting for customer approval.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textBody,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
