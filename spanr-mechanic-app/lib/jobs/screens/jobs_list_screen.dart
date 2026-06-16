import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../jobs_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/sync_status_banner.dart';
import '../../core/widgets/app_empty_view.dart';
import '../../core/widgets/app_loading_view.dart';

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({super.key});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final staff = context.read<AuthProvider>().staff;
    if (staff != null) context.read<JobsProvider>().loadJobs(staff);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobsProvider = context.watch<JobsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Jobs'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SyncStatusBanner(
            isOnline: jobsProvider.isOnline,
            pendingCount: jobsProvider.pendingSyncCount,
          ),
          Expanded(
            child: jobsProvider.loading
                ? const AppLoadingView(message: 'Loading jobs...')
                : jobsProvider.jobs.isEmpty
                    ? const AppEmptyView(
                        title: 'No assigned jobs',
                        subtitle: 'New jobs from your shop owner will appear here.',
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          final staff = auth.staff;
                          if (staff != null) await jobsProvider.refresh(staff);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: jobsProvider.jobs.length,
                          itemBuilder: (_, i) {
                            final job = jobsProvider.jobs[i];
                            return JobCard(
                              job: job,
                              onTap: () => context.push('/jobs/${job.orderId}'),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
