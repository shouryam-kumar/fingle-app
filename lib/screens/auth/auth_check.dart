import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/config/supabase_config.dart';
import '../../navigation/main_navigation.dart';
import '../../services/supabase/onboarding_service.dart';
import '../../providers/onboarding_provider.dart';
import '../onboarding/welcome_screen.dart';
import 'login_screen_new.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isCheckingOnboarding = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseConfig.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting || _isCheckingOnboarding) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user is authenticated
        final session = SupabaseConfig.currentSession;
        if (session != null) {
          return FutureBuilder<bool>(
            future: _checkOnboardingStatus(),
            builder: (context, onboardingSnapshot) {
              if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (onboardingSnapshot.hasError) {
                // If there's an error checking onboarding, assume completed
                return const MainNavigation();
              }

              final hasCompletedOnboarding = onboardingSnapshot.data ?? false;
              if (hasCompletedOnboarding) {
                return const MainNavigation();
              } else {
                // Initialize onboarding and navigate to welcome screen
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _initializeOnboarding();
                });
                return const WelcomeScreen();
              }
            },
          );
        } else {
          return const LoginScreenNew();
        }
      },
    );
  }

  Future<bool> _checkOnboardingStatus() async {
    final currentUser = SupabaseConfig.currentUser;
    if (currentUser == null) return false;
    
    try {
      return await OnboardingService.hasCompletedOnboarding(currentUser.id);
    } catch (e) {
      print('Error checking onboarding status: $e');
      return false; // If error, assume onboarding needed
    }
  }

  void _initializeOnboarding() {
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    onboardingProvider.initializeOnboarding();
  }
}