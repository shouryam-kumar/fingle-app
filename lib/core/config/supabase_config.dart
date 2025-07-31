import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    await dotenv.load();
    
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 2,
      ),
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static GoTrueClient get auth => client.auth;
  
  static User? get currentUser => auth.currentUser;
  
  static Session? get currentSession => auth.currentSession;
  
  static bool get isAuthenticated => currentUser != null;
}