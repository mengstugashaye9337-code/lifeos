import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'];
    final publishableKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null ||
        url.isEmpty ||
        publishableKey == null ||
        publishableKey.isEmpty) {
      throw Exception(
        'Missing Supabase config in .env file. '
        'Make sure SUPABASE_URL and SUPABASE_ANON_KEY are set.',
      );
    }

    try {
      await Supabase.initialize(url: url, publishableKey: publishableKey);
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }
}
