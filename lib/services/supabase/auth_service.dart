import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../models/user_model.dart' as app_models;

// Sign up result class to handle different scenarios
class SignUpResult {
  final bool success;
  final bool requiresEmailConfirmation;
  final User? user;
  final String? errorMessage;

  SignUpResult({
    required this.success,
    required this.requiresEmailConfirmation,
    this.user,
    this.errorMessage,
  });

  factory SignUpResult.success({
    required User user,
    required bool requiresEmailConfirmation,
  }) {
    return SignUpResult(
      success: true,
      requiresEmailConfirmation: requiresEmailConfirmation,
      user: user,
    );
  }

  factory SignUpResult.error(String message) {
    return SignUpResult(
      success: false,
      requiresEmailConfirmation: false,
      errorMessage: message,
    );
  }
}

class AuthService {
  static final _client = SupabaseConfig.client;
  
  // Sign up with email and password
  static Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      print('Starting sign up process for email: $email');
      print('Username: $username, Full name: $fullName');
      
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'full_name': fullName,
        },
      );
      
      // Comprehensive logging for debugging
      print('Sign up response received:');
      print('  User ID: ${response.user?.id}');
      print('  User Email: ${response.user?.email}');
      print('  Email Confirmed: ${response.user?.emailConfirmedAt}');
      print('  Session exists: ${response.session != null}');
      print('  Session ID: ${response.session?.accessToken.substring(0, 20)}...');
      
      // Check if sign up was successful
      if (response.user != null) {
        // Email confirmation is required if user exists but no session
        final requiresConfirmation = response.session == null;
        print('Sign up successful. Requires email confirmation: $requiresConfirmation');
        
        if (requiresConfirmation) {
          print('Confirmation email should have been sent to: $email');
        }
        
        return SignUpResult.success(
          user: response.user!,
          requiresEmailConfirmation: requiresConfirmation,
        );
      }
      
      // This shouldn't happen, but handle it just in case
      print('Sign up failed: No user created in response');
      return SignUpResult.error('Sign up failed: No user created');
    } on AuthException catch (e) {
      print('Sign up AuthException caught:');
      print('  Message: ${e.message}');
      print('  Status Code: ${e.statusCode}');
      
      // Handle specific auth errors
      if (e.message.contains('User already registered')) {
        print('User already exists error');
        return SignUpResult.error('An account with this email already exists');
      } else if (e.message.contains('Password should be at least')) {
        print('Password too short error');
        return SignUpResult.error('Password must be at least 6 characters');
      } else if (e.message.contains('Invalid email')) {
        print('Invalid email format error');
        return SignUpResult.error('Please enter a valid email address');
      } else if (e.message.contains('rate limit')) {
        print('Rate limit exceeded error');
        return SignUpResult.error('Too many attempts. Please wait a moment and try again.');
      }
      
      print('Unhandled AuthException: ${e.message}');
      return SignUpResult.error('Sign up failed: ${e.message}');
    } catch (e) {
      print('Sign up unexpected error: $e');
      print('Error type: ${e.runtimeType}');
      return SignUpResult.error('Sign up failed: $e');
    }
  }
  
  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Starting sign in process for email: $email');
      
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // Comprehensive logging for debugging
      print('Sign in response received:');
      print('  User ID: ${response.user?.id}');
      print('  User Email: ${response.user?.email}');
      print('  Email Confirmed: ${response.user?.emailConfirmedAt}');
      print('  Session exists: ${response.session != null}');
      print('Sign in successful');
      
      return response;
    } on AuthException catch (e) {
      print('Sign in AuthException caught:');
      print('  Message: ${e.message}');
      print('  Status Code: ${e.statusCode}');
      
      // Handle specific auth errors
      if (e.message.contains('Invalid login credentials')) {
        print('Invalid credentials error');
        throw Exception('Invalid email or password');
      } else if (e.message.contains('Email not confirmed')) {
        print('Email not confirmed error');
        throw Exception('Please confirm your email before signing in');
      } else if (e.message.contains('rate limit')) {
        print('Rate limit exceeded error');
        throw Exception('Too many attempts. Please wait a moment and try again.');
      }
      
      print('Unhandled sign in AuthException: ${e.message}');
      throw Exception('Sign in failed: ${e.message}');
    } catch (e) {
      print('Sign in unexpected error: $e');
      print('Error type: ${e.runtimeType}');
      throw Exception('Sign in failed: $e');
    }
  }
  
  // Sign out
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }
  
  // Get current user profile
  static Future<app_models.User?> getCurrentUserProfile() async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) return null;
      
      final response = await _client
          .rpc('api_get_user_profile', params: {
            'p_user_id': userId,
            'p_viewer_id': userId,
          });
      
      if (response != null) {
        return app_models.User.fromSupabaseJson(response);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
  
  // Update user profile
  static Future<app_models.User?> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
    List<String>? interests,
    bool? openToMingle,
  }) async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) return null;
      
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (interests != null) updates['interests'] = interests;
      if (openToMingle != null) updates['open_to_mingle'] = openToMingle;
      
      final response = await _client
          .rpc('api_update_user_profile', params: {
            'user_uuid': userId,
            'updates': updates,
          });
      
      if (response != null) {
        return app_models.User.fromSupabaseJson(response);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
  
  // Check if username is available
  static Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _client
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();
      
      return response == null;
    } catch (e) {
      throw Exception('Failed to check username: $e');
    }
  }
  
  // Get auth state changes stream
  static Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange;
  }
  
  // Create fallback profile if trigger failed
  static Future<app_models.User?> createFallbackProfile({
    required String fullName,
    required String username,
  }) async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      final email = SupabaseConfig.currentUser?.email;
      if (userId == null || email == null) return null;
      
      // Create a basic profile directly in the database
      await _client.from('users').insert({
        'auth_id': userId,
        'email': email,
        'name': fullName,
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'joined_at': DateTime.now().toIso8601String(),
      });
      
      // Return the created profile
      return await getCurrentUserProfile();
    } catch (e) {
      throw Exception('Failed to create fallback profile: $e');
    }
  }
  
  // Ensure user profile exists (with fallback creation)
  static Future<app_models.User?> ensureUserProfile({
    String? fullName,
    String? username,
  }) async {
    try {
      // First, try to get existing profile
      final existingProfile = await getCurrentUserProfile();
      if (existingProfile != null) {
        return existingProfile;
      }
      
      // If no profile exists, create a fallback one
      if (fullName != null && username != null) {
        return await createFallbackProfile(
          fullName: fullName,
          username: username,
        );
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to ensure user profile: $e');
    }
  }

  // Resend confirmation email
  static Future<bool> resendConfirmationEmail(String email) async {
    try {
      print('Attempting to resend confirmation email to: $email');
      print('Email provider: ${email.split('@').last}');
      
      // Use the proper Supabase resend method
      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      
      print('Resend confirmation email request sent successfully');
      print('Email should arrive within 1-5 minutes');
      return true;
    } on AuthException catch (e) {
      print('Resend confirmation AuthException: ${e.message}');
      print('Error details: ${e.statusCode}');
      
      // Handle specific error cases
      if (e.message.contains('already confirmed')) {
        print('User already confirmed - they can sign in now');
        return true;
      } else if (e.message.contains('already registered') || 
                 e.message.contains('already signed up')) {
        print('User exists - confirmation email sent');
        return true;
      } else if (e.message.contains('rate limit') || e.message.contains('too many')) {
        print('Rate limit hit - user should wait before requesting again');
        return false;
      } else if (e.message.contains('not found') || e.message.contains('invalid email')) {
        print('Email not found in system');
        return false;
      }
      
      print('Unhandled resend error - treating as failure');
      return false;
    } catch (e) {
      print('Resend confirmation unexpected error: $e');
      return false;
    }
  }

  // Check if email is from a potentially problematic provider
  static bool isProblematicEmailProvider(String email) {
    final domain = email.split('@').last.toLowerCase();
    final problematicDomains = [
      'outlook.com', 'hotmail.com', 'live.com', // Microsoft often filters
      'yahoo.com', 'ymail.com', // Yahoo has strict filtering
      'icloud.com', 'me.com', // Apple can be restrictive
      'protonmail.com', 'proton.me', // Proton has strict spam filters
    ];
    return problematicDomains.contains(domain);
  }

  // Get email provider-specific advice
  static String getEmailProviderAdvice(String email) {
    final domain = email.split('@').last.toLowerCase();
    
    switch (domain) {
      case 'outlook.com':
      case 'hotmail.com':
      case 'live.com':
        return 'Outlook/Hotmail users: Check your Junk folder and add noreply@supabase.io to your safe senders list.';
      case 'yahoo.com':
      case 'ymail.com':
        return 'Yahoo users: Check your Spam folder and look for emails from supabase.io.';
      case 'icloud.com':
      case 'me.com':
        return 'iCloud users: Check your Junk folder and ensure your Mail settings allow emails from unknown senders.';
      case 'gmail.com':
        return 'Gmail users: Check your Spam/Promotions tabs. Gmail usually delivers these emails reliably.';
      default:
        return 'Check your spam/junk folder and look for emails from supabase.io or noreply@supabase.io.';
    }
  }

  // Password reset
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }
}