import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? dotenv.env['VITE_SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      dotenv.env['VITE_SUPABASE_ANON_KEY'] ??
      dotenv.env['VITE_SUPABASE_PUBLISHABLE_KEY'] ??
      '';
  static String get razorpayKeyId => dotenv.env['RAZORPAY_KEY_ID'] ?? '';

  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'Missing Supabase env vars. Set SUPABASE_URL and SUPABASE_ANON_KEY (or VITE_* equivalents) in spanr_app/.env',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

