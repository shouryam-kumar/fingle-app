import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Soft Lavender Theme
  static const primary = Color(0xFF8B7AB8); // soft lavender
  static const primaryLight = Color(0xFFA592CC);
  static const primaryDark = Color(0xFF6B5A98);

  // Secondary Colors - Sage Green
  static const secondary = Color(0xFF87B79F); // sage green
  static const secondaryLight = Color(0xFFA4CCB9);
  static const secondaryDark = Color(0xFF6A9681);

  // Accent Colors
  static const accent = Color(0xFFD4A5A5); // dusty rose
  static const success = Color(0xFF7FC8A9); // soft teal
  static const warning = Color(0xFFF5C99B); // peach

  // Neutral Colors
  static const background = Color(0xFFFAFAF8); // warm white
  static const backgroundDark = Color(0xFF1A1A1A);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF2D2D2D);

  // Text Colors - Much darker for better readability
  static const textPrimary = Color(0xFF1A1A1A); // near black
  static const textSecondary = Color(0xFF4A4A4A); // dark gray
  static const textLight = Color(0xFF6B6B6B); // medium gray
  static const textDark = Color(0xFFFAFAF8);

  // Status Colors
  static const error = Color(0xFFE17055);
  static const info = Color(0xFF74B9FF);

  // Glassmorphism Colors - Softer effect
  static final glassMorphism = Colors.white.withOpacity(0.08);
  static final glassBorder = Colors.white.withOpacity(0.12);
  static final glassShadow = Colors.black.withOpacity(0.05);

  // Gradients - Subtle versions
  static const oceanGradient = LinearGradient(
    colors: [Color(0xFF8B7AB8), Color(0xFF87B79F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const sunsetGradient = LinearGradient(
    colors: [Color(0xFFD4A5A5), Color(0xFFF5C99B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const purpleGradient = LinearGradient(
    colors: [Color(0xFF8B7AB8), Color(0xFFD4A5A5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const mintGradient = LinearGradient(
    colors: [Color(0xFF87B79F), Color(0xFF7FC8A9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
