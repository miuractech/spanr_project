import '../config/supabase_config.dart';
import 'models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = SupabaseConfig.client;

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user');
      }

      // Get user profile (trigger already created it)
      final response = await _client
          .from('users')
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to sign in');
      }

      // Get user profile
      final response = await _client
          .from('users')
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final authResponse = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'spanr://login-callback',
      );

      if (!authResponse) {
        throw Exception('Failed to sign in with Google');
      }

      // Wait for auth state to change
      await Future.delayed(const Duration(seconds: 1));

      return await getCurrentUser();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((data) async {
      if (data.session?.user == null) return null;
      return await getCurrentUser();
    });
  }

  bool get isAuthenticated => _client.auth.currentUser != null;
}

