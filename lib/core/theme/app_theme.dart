import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Standardized text theme system
  static TextTheme get textTheme => const TextTheme(
    // Headlines - for main titles and section headers
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ), // Main page titles
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ), // App bar titles
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ), // Section headers
    
    // Body text - for main content
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ), // Main content, input text, buttons
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ), // Secondary content, suggestions, chips
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ), // Supporting text, labels
    
    // Labels for interactive elements
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ), // Major buttons, important labels
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ), // Filter chips, medium labels
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ), // Small badges, counts
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // fontFamily: 'SpaceMono', // Commented out to fix white screen issue
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          // fontFamily: 'SpaceMono', // Commented out to fix white screen issue
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            // fontFamily: 'SpaceMono', // Commented out to fix white screen issue
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      //   fontFamily: 'SpaceMono',

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),

      scaffoldBackgroundColor: AppColors.backgroundDark,
    );
  }
}
