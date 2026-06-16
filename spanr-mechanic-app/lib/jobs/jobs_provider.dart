import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/models/staff_user.dart';
import '../core/offline/connectivity_service.dart';
import '../core/offline/hive_boxes.dart';
import '../core/offline/sync_service.dart';
import 'jobs_service.dart';
import 'models/assigned_job.dart';
import 'models/job_status.dart';

class JobsProvider extends ChangeNotifier {
  final JobsService _jobsService;
  final SyncService _syncService;
  final ConnectivityService _connectivity;

  List<AssignedJob> _jobs = [];
  bool _loading = false;
  String? _error;
  RealtimeChannel? _channel;

  JobsProvider(this._jobsService, this._syncService, this._connectivity) {
    _connectivity.onConnectivityChanged.listen((online) {
      if (online) _syncService.processQueue();
      notifyListeners();
    });
  }

  List<AssignedJob> get jobs => _jobs;
  bool get loading => _loading;
  String? get error => _error;
  int get pendingSyncCount => _syncService.pendingCount;
  bool get isOnline => _connectivity.isOnline;

  Future<void> loadJobs(StaffUser staff) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (_connectivity.isOnline) {
        _jobs = await _jobsService.getAssignedJobs(staff.id);
        await _cacheJobs(_jobs);
        await _syncService.processQueue();
      } else {
        _jobs = _loadCachedJobs();
      }
      _subscribe(staff.id);
    } catch (e) {
      _jobs = _loadCachedJobs();
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(StaffUser staff) => loadJobs(staff);

  AssignedJob? getJob(String orderId) =>
      _jobs.cast<AssignedJob?>().firstWhere((j) => j?.orderId == orderId, orElse: () => null);

  Future<void> updateStatus(String orderId, String status) async {
    if (_connectivity.isOnline) {
      await _jobsService.updateOrderStatus(orderId, status);
    } else {
      await _syncService.enqueue('update_status', {
        'order_id': orderId,
        'status': status,
      });
    }
    final idx = _jobs.indexWhere((j) => j.orderId == orderId);
    if (idx >= 0) {
      final job = _jobs[idx];
      _jobs[idx] = AssignedJob(
        orderId: job.orderId,
        assignmentId: job.assignmentId,
        status: JobStatus.fromDb(status),
        assignedAt: job.assignedAt,
        notes: job.notes,
        customerName: job.customerName,
        customerPhone: job.customerPhone,
        vehicleMake: job.vehicleMake,
        vehicleModel: job.vehicleModel,
        vehicleYear: job.vehicleYear,
        licensePlate: job.licensePlate,
        planName: job.planName,
        specialInstructions: job.specialInstructions,
        scheduledDate: job.scheduledDate,
      );
      await _cacheJobs(_jobs);
    }
    notifyListeners();
  }

  void _subscribe(String staffId) {
    _channel?.unsubscribe();
    _channel = _jobsService.subscribeToAssignments(staffId, () {
      _jobsService.getAssignedJobs(staffId).then((jobs) {
        _jobs = jobs;
        _cacheJobs(jobs);
        notifyListeners();
      });
    });
  }

  Future<void> _cacheJobs(List<AssignedJob> jobs) async {
    final data = jobs.map((j) => j.toCacheJson()).toList();
    await HiveBoxes.jobs.put('assigned_jobs', jsonEncode(data));
  }

  List<AssignedJob> _loadCachedJobs() {
    final raw = HiveBoxes.jobs.get('assigned_jobs');
    if (raw is String) {
      final list = jsonDecode(raw) as List;
      return list.map((e) => AssignedJob.fromCacheJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}
