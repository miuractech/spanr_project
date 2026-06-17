import 'package:uuid/uuid.dart';
import '../../jobs/jobs_service.dart';
import 'connectivity_service.dart';
import 'hive_boxes.dart';
import 'sync_queue_item.dart';

class SyncService {
  final JobsService _jobsService;
  final ConnectivityService _connectivity;
  final _uuid = const Uuid();
  bool _processing = false;

  SyncService(this._jobsService, this._connectivity);

  Future<void> enqueue(String type, Map<String, dynamic> payload) async {
    final item = SyncQueueItem(
      id: _uuid.v4(),
      type: type,
      payload: payload,
      createdAt: DateTime.now(),
    );
    final queue = _getQueue();
    queue.add(item.toJson());
    await HiveBoxes.syncQueue.put('items', queue);
    if (_connectivity.isOnline) await processQueue();
  }

  List<Map<String, dynamic>> _getQueue() {
    final raw = HiveBoxes.syncQueue.get('items');
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<void> processQueue() async {
    if (_processing || !_connectivity.isOnline) return;
    _processing = true;
    try {
      var queue = _getQueue();
      final remaining = <Map<String, dynamic>>[];

      for (final itemMap in queue) {
        final item = SyncQueueItem.fromJson(itemMap);
        try {
          await _processItem(item);
        } catch (_) {
          remaining.add(itemMap);
        }
      }

      await HiveBoxes.syncQueue.put('items', remaining);
    } finally {
      _processing = false;
    }
  }

  Future<void> _processItem(SyncQueueItem item) async {
    switch (item.type) {
      case 'update_status':
        await _jobsService.updateOrderStatus(
          item.payload['order_id'] as String,
          item.payload['status'] as String,
        );
      case 'upload_inspection':
        await _jobsService.uploadInspectionImage(
          orderId: item.payload['order_id'] as String,
          staffId: item.payload['staff_id'] as String,
          localPath: item.payload['local_path'] as String,
          type: item.payload['type'] as String,
          angle: item.payload['angle'] as String,
        );
      case 'add_part':
        await _jobsService.addPart(
          orderId: item.payload['order_id'] as String,
          staffId: item.payload['staff_id'] as String,
          partName: item.payload['part_name'] as String,
          partNumber: item.payload['part_number'] as String?,
          brand: item.payload['brand'] as String?,
          quantity: item.payload['quantity'] as int? ?? 1,
          cost: (item.payload['cost'] as num?)?.toDouble(),
          kmReading: item.payload['km_reading'] as int?,
          beforePhotoPath: item.payload['before_photo_path'] as String?,
          afterPhotoPath: item.payload['after_photo_path'] as String? ?? item.payload['photo_path'] as String?,
        );
      case 'save_notes':
        await _jobsService.saveServiceNotes(
          item.payload['order_id'] as String,
          item.payload['notes'] as String,
          description: item.payload['description'] as String?,
        );
      case 'complete_job':
        await _jobsService.completeJob(
          orderId: item.payload['order_id'] as String,
          staffId: item.payload['staff_id'] as String,
          odometer: item.payload['odometer'] as int?,
          serviceNotes: item.payload['service_notes'] as String?,
          servicesPerformed: item.payload['services_performed'] as String?,
        );
    }
  }

  int get pendingCount => _getQueue().length;
}
