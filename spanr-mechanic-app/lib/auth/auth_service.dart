import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../core/utils/phone_util.dart';
import 'models/staff_user.dart';

class AuthService {
  final _client = SupabaseConfig.client;

  Future<StaffUser> signInWithPhone(String phone, String password) async {
    final authEmail = PhoneUtil.toAuthEmail(phone);
    final response = await _client.auth.signInWithPassword(
      email: authEmail,
      password: password,
    );
    if (response.user == null) {
      throw Exception('Invalid mobile number or password');
    }
    return resolveStaff();
  }

  Future<StaffUser> resolveStaff() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client
        .from('staff')
        .select('*, staff_profiles(*)')
        .eq('auth_user_id', userId)
        .eq('enabled', true)
        .maybeSingle();

    if (response == null) {
      final email = _client.auth.currentUser?.email;
      if (email != null) {
        final byEmail = await _client
            .from('staff')
            .select('*, staff_profiles(*)')
            .eq('email', email)
            .eq('enabled', true)
            .maybeSingle();
        if (byEmail != null) {
          await _client.from('staff').update({'auth_user_id': userId}).eq('id', byEmail['id']);
          return StaffUser.fromJson(byEmail);
        }
      }
      throw Exception('No staff account found for this login');
    }

    return StaffUser.fromJson(response);
  }

  Future<void> changePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
    await _client.rpc('complete_staff_password_change');
  }

  Future<void> signOut() => _client.auth.signOut();

  bool get isAuthenticated => _client.auth.currentSession != null;
}
