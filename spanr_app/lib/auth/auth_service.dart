import 'dart:async';

import '../config/supabase_config.dart';
import 'models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = SupabaseConfig.client;

  Future<UserModel?> _fetchUserProfile(String userId) async {
    final response = await _client.from('users').select().eq('id', userId).maybeSingle();
    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  Future<UserModel> _upsertAndFetchUserProfile({
    required String userId,
    required String email,
    String? name,
    String? phone,
  }) async {
    await _client.from('users').upsert({
      'id': userId,
      'email': email,
      'name': (name == null || name.trim().isEmpty) ? email : name.trim(),
      'phone': phone?.trim() ?? '',
    });

    final profile = await _fetchUserProfile(userId);
    if (profile == null) {
      throw Exception('Unable to load your profile. Please try again.');
    }
    return profile;
  }

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

      final authUser = authResponse.user;
      if (authUser == null) {
        throw Exception('Failed to create user');
      }

      if (authResponse.session == null) {
        // Email confirmation is enabled; the user is not signed in yet.
        return null;
      }

      // Trigger-created profile can be delayed in some environments.
      for (var attempt = 0; attempt < 3; attempt++) {
        final profile = await _fetchUserProfile(authUser.id);
        if (profile != null) return profile;
        await Future.delayed(Duration(milliseconds: 300 * (attempt + 1)));
      }

      return await _upsertAndFetchUserProfile(
        userId: authUser.id,
        email: email,
        name: name,
        phone: phone,
      );
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

      final authUser = authResponse.user;
      if (authUser == null) {
        throw Exception('Failed to sign in');
      }

      for (var attempt = 0; attempt < 3; attempt++) {
        final profile = await _fetchUserProfile(authUser.id);
        if (profile != null) return profile;
        await Future.delayed(Duration(milliseconds: 300 * (attempt + 1)));
      }

      return await _upsertAndFetchUserProfile(
        userId: authUser.id,
        email: authUser.email ?? email,
        name: authUser.userMetadata?['name'] as String?,
        phone: authUser.userMetadata?['phone'] as String?,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final didLaunch = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'spanr://login-callback',
      );

      if (!didLaunch) {
        throw Exception('Failed to sign in with Google');
      }

      final existingUser = _client.auth.currentUser;
      if (existingUser == null) {
        await _client.auth.onAuthStateChange
            .map((event) => event.session?.user)
            .firstWhere((user) => user != null)
            .timeout(const Duration(minutes: 2));
      }

      return await getCurrentUser();
    } on TimeoutException {
      throw Exception('Google sign-in timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> updateProfile({
    required String userId,
    required String name,
    required String phone,
  }) async {
    await _client.from('users').update({
      'name': name.trim(),
      'phone': phone.trim(),
    }).eq('id', userId);
    final profile = await _fetchUserProfile(userId);
    if (profile == null) throw Exception('Failed to load updated profile');
    return profile;
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final profile = await _fetchUserProfile(user.id);
      if (profile != null) return profile;

      return await _upsertAndFetchUserProfile(
        userId: user.id,
        email: user.email ?? '',
        name: user.userMetadata?['name'] as String?,
        phone: user.userMetadata?['phone'] as String?,
      );
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

