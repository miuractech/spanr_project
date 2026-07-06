import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'models/assigned_job.dart';
import 'models/extra_work_request.dart';
import 'models/part_replacement.dart';

class JobsService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<AssignedJob>> getAssignedJobs(String staffId) async {
    final response = await _client
        .from('order_assignments')
        .select('''
          *,
          orders (
            *,
            users (name, phone),
            vehicles (make, model, year, license_plate),
            plans (name)
          )
        ''')
        .eq('staff_id', staffId)
        .eq('status', 'active')
        .order('assigned_at', ascending: false);

    return (response as List)
        .map((e) => AssignedJob.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AssignedJob?> getJobByOrderId(String staffId, String orderId) async {
    final response = await _client
        .from('order_assignments')
        .select('''
          *,
          orders (
            *,
            users (name, phone),
            vehicles (make, model, year, license_plate),
            plans (name)
          )
        ''')
        .eq('staff_id', staffId)
        .eq('order_id', orderId)
        .eq('status', 'active')
        .maybeSingle();

    if (response == null) return null;
    return AssignedJob.fromJson(response);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _client.from('orders').update({'status': status}).eq('id', orderId);
    if (status == 'in_progress') {
      await _client
          .from('staff_profiles')
          .update({'availability': 'busy'})
          .eq('staff_id', await _currentStaffId());
    }
  }

  Future<String> uploadInspectionImage({
    required String orderId,
    required String staffId,
    required String localPath,
    required String type,
    required String angle,
  }) async {
    final file = File(localPath);
    final ext = localPath.split('.').last;
    final path = '$orderId/$type/$angle/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _client.storage.from('inspection-images').upload(path, file);
    final url = _client.storage.from('inspection-images').getPublicUrl(path);

    await _client.from('inspection_images').insert({
      'order_id': orderId,
      'type': type,
      'angle': angle,
      'image_url': url,
      'uploaded_by': staffId,
    });

    return url;
  }

  Future<List<PartReplacement>> getPartsReplaced(String orderId) async {
    final response = await _client
        .from('parts_replaced')
        .select('*')
        .eq('order_id', orderId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((e) => PartReplacement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PartReplacement?> getPartReplacementById(String partId) async {
    final response = await _client
        .from('parts_replaced')
        .select('*')
        .eq('id', partId)
        .maybeSingle();

    if (response == null) return null;
    return PartReplacement.fromJson(response);
  }

  Future<void> addPart({
    required String orderId,
    required String staffId,
    required String partName,
    String? partNumber,
    String? brand,
    int quantity = 1,
    double? cost,
    int? kmReading,
    String? beforePhotoPath,
    String? afterPhotoPath,
    String? photoPath,
  }) async {
    String? beforePhotoUrl;
    String? afterPhotoUrl;

    if (beforePhotoPath != null) {
      beforePhotoUrl = await _uploadPartPhoto(orderId, beforePhotoPath, 'before');
    }
    if (afterPhotoPath != null) {
      afterPhotoUrl = await _uploadPartPhoto(orderId, afterPhotoPath, 'after');
    } else if (photoPath != null) {
      afterPhotoUrl = await _uploadPartPhoto(orderId, photoPath, 'after');
    }

    await _client.from('parts_replaced').insert({
      'order_id': orderId,
      'part_name': partName,
      'part_number': partNumber,
      'brand': brand,
      'quantity': quantity,
      'cost': cost,
      'km_reading': kmReading,
      'before_photo_url': beforePhotoUrl,
      'photo_url': afterPhotoUrl,
      'created_by': staffId,
    });
  }

  Future<String> _uploadPartPhoto(String orderId, String localPath, String label) async {
    final file = File(localPath);
    final ext = localPath.split('.').last;
    final path = '$orderId/parts/$label/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from('inspection-images').upload(path, file);
    return _client.storage.from('inspection-images').getPublicUrl(path);
  }

  Future<void> saveServiceNotes(
    String orderId,
    String notes, {
    String? description,
  }) async {
    await _client.from('order_service_details').upsert({
      'order_id': orderId,
      'notes': notes,
      if (description != null) 'description': description,
    });
  }

  Future<String> completeJob({
    required String orderId,
    required String staffId,
    int? odometer,
    String? serviceNotes,
    String? servicesPerformed,
  }) async {
    final result = await _client.rpc('complete_job', params: {
      'p_order_id': orderId,
      'p_staff_id': staffId,
      'p_odometer': odometer,
      'p_service_notes': serviceNotes,
      'p_services_performed': servicesPerformed,
    });
    return result as String;
  }

  RealtimeChannel subscribeToAssignments(
    String staffId,
    void Function() onChange,
  ) {
    return _client
        .channel('assignments_$staffId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'order_assignments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'staff_id',
            value: staffId,
          ),
          callback: (_) => onChange(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          callback: (_) => onChange(),
        )
        .subscribe();
  }

  Future<String> _currentStaffId() async {
    final email = _client.auth.currentUser?.email;
    final res = await _client.from('staff').select('id').eq('email', email!).single();
    return res['id'] as String;
  }

  Future<String> currentStaffId() async => _currentStaffId();

  Future<List<ExtraWorkRequest>> getExtraWorkRequests(String orderId) async {
    final response = await _client
        .from('extra_work_requests')
        .select('*')
        .eq('order_id', orderId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => ExtraWorkRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitExtraWorkRequest({
    required String orderId,
    required String staffId,
    required String description,
    required double estimatedCost,
    String? photoPath,
  }) async {
    String? photoUrl;
    if (photoPath != null) {
      final file = File(photoPath);
      final ext = photoPath.split('.').last;
      final path = '$orderId/extra-work/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _client.storage.from('extra-work-photos').upload(path, file);
      photoUrl = _client.storage.from('extra-work-photos').getPublicUrl(path);
    }

    await _client.from('extra_work_requests').insert({
      'order_id': orderId,
      'mechanic_id': staffId,
      'description': description,
      'estimated_cost': estimatedCost,
      'photo_url': photoUrl,
      'status': 'pending',
    });

    // Put order on hold
    await _client.from('orders').update({'status': 'on_hold'}).eq('id', orderId);
  }
}
