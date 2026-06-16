import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? dotenv.env['VITE_SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      dotenv.env['VITE_SUPABASE_ANON_KEY'] ??
      '';

  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('Missing Supabase env vars in .env');
    }
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
