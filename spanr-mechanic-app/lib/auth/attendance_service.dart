import '../config/supabase_config.dart';

class AttendanceService {
  final _client = SupabaseConfig.client;

  Future<void> markAttendance({
    required String staffId,
    required String companyId,
  }) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    await _client.from('staff_attendance').upsert(
      {
        'staff_id': staffId,
        'company_id': companyId,
        'check_in_date': today,
        'check_in_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'staff_id,check_in_date',
    );
  }
}
