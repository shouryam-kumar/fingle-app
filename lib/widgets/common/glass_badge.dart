import 'package:flutter/material.dart';
import 'glass_container.dart';
import '../../core/theme/app_colors.dart';
import '../../models/search_models.dart';

enum GlassBadgeStyle { 
  primary, 
  secondary, 
  success, 
  warning, 
  error, 
  mingle, 
  trending,
  activity,
  custom 
}

enum GlassBadgeSize { small, medium, large }

class GlassBadge extends StatelessWidget {
  final String text;
  final GlassBadgeStyle style;
  final GlassBadgeSize size;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPulsing;
  final bool hasGlow;
  final ActivityLevel? activityLevel;
  final Color? customColor;
  final VoidCallback? onTap;

  const GlassBadge({
    super.key,
    required this.text,
    this.style = GlassBadgeStyle.primary,
    this.size = GlassBadgeSize.medium,
    this.prefixIcon,
    this.suffixIcon,
    this.isPulsing = false,
    this.hasGlow = false,
    this.activityLevel,
    this.customColor,
    this.onTap,
  });

  factory GlassBadge.trending({
    required String text,
    GlassBadgeSize size = GlassBadgeSize.medium,
    VoidCallback? onTap,
  }) {
    return GlassBadge(
      text: text,
      style: GlassBadgeStyle.trending,
      size: size,
      prefixIcon: const Icon(
        Icons.trending_up,
        size: 12,
        color: Colors.white,
      ),
      isPulsing: true,
      hasGlow: true,
      onTap: onTap,
    );
  }

  factory GlassBadge.mingle({
    String text = 'Open to Mingle',
    GlassBadgeSize size = GlassBadgeSize.medium,
    VoidCallback? onTap,
  }) {
    return GlassBadge(
      text: text,
      style: GlassBadgeStyle.mingle,
      size: size,
      prefixIcon: const Icon(
        Icons.favorite,
        size: 12,
        color: Colors.white,
      ),
      hasGlow: true,
      onTap: onTap,
    );
  }

  factory GlassBadge.activity({
    required ActivityLevel level,
    GlassBadgeSize size = GlassBadgeSize.small,
    bool showDot = true,
    VoidCallback? onTap,
  }) {
    String text;
    switch (level) {
      case ActivityLevel.veryActive:
        text = 'Very Active';
        break;
      case ActivityLevel.active:
        text = 'Active';
        break;
      case ActivityLevel.moderate:
        text = 'Moderate';
        break;
    }

    return GlassBadge(
      text: text,
      style: GlassBadgeStyle.activity,
      size: size,
      activityLevel: level,
      prefixIcon: showDot ? Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getActivityColor(level),
        ),
      ) : null,
      isPulsing: level == ActivityLevel.veryActive,
      hasGlow: level != ActivityLevel.moderate,
      onTap: onTap,
    );
  }

  static Color _getActivityColor(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.veryActive:
        return AppColors.veryActiveGreen;
      case ActivityLevel.active:
        return AppColors.activeOrange;
      case ActivityLevel.moderate:
        return AppColors.moderateGray;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case GlassBadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case GlassBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case GlassBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  double get _fontSize {
    switch (size) {
      case GlassBadgeSize.small:
        return 10;
      case GlassBadgeSize.medium:
        return 12;
      case GlassBadgeSize.large:
        return 14;
    }
  }

  double get _borderRadius {
    switch (size) {
      case GlassBadgeSize.small:
        return 12;
      case GlassBadgeSize.medium:
        return 16;
      case GlassBadgeSize.large:
        return 20;
    }
  }

  Color get _backgroundColor {
    if (customColor != null) return customColor!;
    
    switch (style) {
      case GlassBadgeStyle.primary:
        return AppColors.primary;
      case GlassBadgeStyle.secondary:
        return AppColors.secondary;
      case GlassBadgeStyle.success:
        return AppColors.veryActiveGreen;
      case GlassBadgeStyle.warning:
        return AppColors.activeOrange;
      case GlassBadgeStyle.error:
        return AppColors.error;
      case GlassBadgeStyle.mingle:
        return AppColors.minglePink;
      case GlassBadgeStyle.trending:
        return AppColors.info;
      case GlassBadgeStyle.activity:
        return activityLevel != null ? _getActivityColor(activityLevel!) : AppColors.primary;
      case GlassBadgeStyle.custom:
        return customColor ?? AppColors.primary;
    }
  }

  Gradient get _backgroundGradient {
    final baseColor = _backgroundColor;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor,
        HSLColor.fromColor(baseColor).withLightness(
          (HSLColor.fromColor(baseColor).lightness - 0.1).clamp(0.0, 1.0)
        ).toColor(),
      ],
    );
  }

  List<BoxShadow> get _glowEffect {
    if (!hasGlow) return [];
    
    final glowColor = _backgroundColor;
    return [
      BoxShadow(
        color: glowColor.withOpacity(0.3),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: glowColor.withOpacity(0.1),
        blurRadius: 16,
        spreadRadius: 2,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget badge = GlassContainer(
      padding: _padding,
      borderRadius: _borderRadius,
      customGradient: _backgroundGradient,
      intensity: GlassIntensity.strong,
      elevation: hasGlow ? GlassElevation.medium : GlassElevation.low,
      hasRippleEffect: onTap != null,
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Handle infinite or invalid constraints
          final availableWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
              ? constraints.maxWidth
              : 200.0; // Fallback width
          
          // Calculate space needed for icons with minimum requirements
          final iconSpace = (prefixIcon != null ? 20 : 0) + (suffixIcon != null ? 20 : 0);
          final minTextWidth = 20.0; // Minimum text width for readability
          final calculatedMaxWidth = availableWidth - iconSpace;
          
          // Ensure we have at least minimum text width
          final safeMaxWidth = calculatedMaxWidth > minTextWidth 
              ? calculatedMaxWidth 
              : minTextWidth;
          
          return IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prefixIcon != null) ...[
                  Flexible(
                    flex: 0,
                    child: prefixIcon!,
                  ),
                  const SizedBox(width: 4),
                ],
                
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 0,
                      maxWidth: safeMaxWidth,
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _fontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                if (suffixIcon != null) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    flex: 0,
                    child: suffixIcon!,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );

    if (hasGlow) {
      badge = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_borderRadius),
          boxShadow: _glowEffect,
        ),
        child: badge,
      );
    }

    if (isPulsing) {
      badge = _PulseBadgeWrapper(child: badge);
    }

    return badge;
  }
}

class _PulseBadgeWrapper extends StatefulWidget {
  final Widget child;

  const _PulseBadgeWrapper({required this.child});

  @override
  State<_PulseBadgeWrapper> createState() => _PulseBadgeWrapperState();
}

class _PulseBadgeWrapperState extends State<_PulseBadgeWrapper> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.veryActiveGreen.withOpacity(_glowAnimation.value),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class GlassBadgeGroup extends StatelessWidget {
  final List<GlassBadge> badges;
  final MainAxisAlignment alignment;
  final double spacing;
  final bool wrap;

  const GlassBadgeGroup({
    super.key,
    required this.badges,
    this.alignment = MainAxisAlignment.start,
    this.spacing = 8.0,
    this.wrap = false,
  });

  @override
  Widget build(BuildContext context) {
    if (wrap) {
      return Wrap(
        alignment: WrapAlignment.start,
        spacing: spacing,
        runSpacing: spacing / 2,
        children: badges,
      );
    }
    
    return Row(
      mainAxisAlignment: alignment,
      children: badges.asMap().entries.map((entry) {
        final index = entry.key;
        final badge = entry.value;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            badge,
            if (index < badges.length - 1) SizedBox(width: spacing),
          ],
        );
      }).toList(),
    );
  }
}