import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../jobs/jobs_provider.dart';
import '../../jobs/jobs_service.dart';
import '../offline/connectivity_service.dart';
import '../offline/sync_service.dart';

List<SingleChildWidget> buildProviders() {
  final jobsService = JobsService();
  final connectivityService = ConnectivityService();
  final syncService = SyncService(jobsService, connectivityService);

  return [
    Provider.value(value: connectivityService),
    Provider.value(value: syncService),
    Provider.value(value: jobsService),
    ChangeNotifierProvider(
      create: (_) => JobsProvider(jobsService, syncService, connectivityService),
    ),
  ];
}
