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

  // Premium Glassmorphism Colors
  static final glassBg = Colors.white.withOpacity(0.25);
  static final glassBorder = Colors.white.withOpacity(0.18);
  static final glassInset = Colors.white.withOpacity(0.3);
  static final glassShadowPrimary = const Color(0x1F1F2687).withOpacity(0.37);
  static final glassShadowSecondary = Colors.black.withOpacity(0.1);

  // Enhanced Glass Effects
  static final glassActiveHover = Colors.white.withOpacity(0.4);
  static final glassRipple = Colors.white.withOpacity(0.2);

  // Activity Level Colors
  static const veryActiveGreen = Color(0xFF10b981);
  static const activeOrange = Color(0xFFf97316);
  static const moderateGray = Color(0xFF6b7280);

  // Mingle Colors
  static const minglePink = Color(0xFFec4899);
  static const minglePinkDark = Color(0xFFbe185d);

  // Legacy Glassmorphism Colors - Keep for existing components
  static final glassMorphism = Colors.white.withOpacity(0.08);
  static final glassShadow = Colors.black.withOpacity(0.05);
  static final postCardBackground = Colors.white.withOpacity(0.15);

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

  // Premium Glassmorphism Gradients
  static const searchBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [
      Color(0xFFF8FAFC), // Light gray
      Color(0xFFE2E8F0), // Slightly darker gray
      Color(0xFFF8FAFC), // Back to light
    ],
  );

  // Radial gradients for floating orbs effect
  static final searchOrbGradient1 = RadialGradient(
    center: Alignment.topLeft,
    radius: 0.8,
    colors: [
      const Color(0xFF7877C6).withOpacity(0.3), // Purple
      Colors.transparent,
    ],
  );

  static final searchOrbGradient2 = RadialGradient(
    center: Alignment.topRight,
    radius: 0.8,
    colors: [
      const Color(0xFFFF77C6).withOpacity(0.3), // Pink
      Colors.transparent,
    ],
  );

  static final searchOrbGradient3 = RadialGradient(
    center: Alignment.center,
    radius: 0.6,
    colors: [
      const Color(0xFF10B981).withOpacity(0.2), // Green
      Colors.transparent,
    ],
  );

  // Glass container gradient
  static final glassContainerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      glassBg,
      glassBg.withOpacity(0.1),
    ],
  );

  // Activity level gradients
  static const veryActiveGradient = LinearGradient(
    colors: [Color(0xFF10b981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const activeGradient = LinearGradient(
    colors: [Color(0xFFf97316), Color(0xFFea580c)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const mingleGradient = LinearGradient(
    colors: [Color(0xFFec4899), Color(0xFFbe185d)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
