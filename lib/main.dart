import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/config/supabase_config.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/auth_check.dart';
import 'screens/auth/login_screen_new.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/profile_setup_screen.dart';
import 'screens/onboarding/interests_screen.dart';
import 'screens/onboarding/activity_level_screen.dart';
import 'screens/onboarding/permissions_screen.dart';
import 'navigation/main_navigation.dart';
import 'providers/app_provider.dart';
import 'providers/comments_provider.dart';
import 'providers/video_feed_provider.dart';
import 'providers/onboarding_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const FingleApp());
}

class FingleApp extends StatelessWidget {
  const FingleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => VideoFeedProvider()),
        ChangeNotifierProvider(create: (_) => CommentsProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'Fingle',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            home: const SplashScreen(),
            routes: {
              '/auth-check': (context) => const AuthCheck(),
              '/login': (context) => const LoginScreenNew(),
              '/signup': (context) => const SignupScreen(),
              '/onboarding-welcome': (context) => const WelcomeScreen(),
              '/onboarding-profile': (context) => const ProfileSetupScreen(),
              '/onboarding-interests': (context) => const InterestsScreen(),
              '/onboarding-activity': (context) => const ActivityLevelScreen(),
              '/onboarding-permissions': (context) => const PermissionsScreen(),
              '/main': (context) => const MainNavigation(),
            },
          );
        },
      ),
    );
  }
}
