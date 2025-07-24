import 'package:flutter/material.dart';
import 'glass_container.dart';
import '../../core/theme/app_colors.dart';

enum GlassButtonStyle { primary, secondary, accent, mingle, success, warning }

enum GlassButtonSize { small, medium, large }

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final GlassButtonStyle style;
  final GlassButtonSize size;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isLoading;
  final bool isOutlined;
  final bool enablePulseEffect;
  final double? width;
  final String? tooltip;

  const GlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = GlassButtonStyle.primary,
    this.size = GlassButtonSize.medium,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.isOutlined = false,
    this.enablePulseEffect = false,
    this.width,
    this.tooltip,
  });

  EdgeInsets get _padding {
    switch (size) {
      case GlassButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case GlassButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case GlassButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double get _fontSize {
    switch (size) {
      case GlassButtonSize.small:
        return 13;
      case GlassButtonSize.medium:
        return 14;
      case GlassButtonSize.large:
        return 16;
    }
  }

  double get _borderRadius {
    switch (size) {
      case GlassButtonSize.small:
        return 16;
      case GlassButtonSize.medium:
        return 20;
      case GlassButtonSize.large:
        return 24;
    }
  }

  Color get _textColor {
    if (isOutlined) {
      switch (style) {
        case GlassButtonStyle.primary:
          return AppColors.primary;
        case GlassButtonStyle.secondary:
          return AppColors.secondary;
        case GlassButtonStyle.accent:
          return AppColors.accent;
        case GlassButtonStyle.mingle:
          return AppColors.minglePink;
        case GlassButtonStyle.success:
          return AppColors.veryActiveGreen;
        case GlassButtonStyle.warning:
          return AppColors.activeOrange;
      }
    }
    return Colors.white;
  }

  Gradient get _backgroundGradient {
    if (isOutlined) {
      return AppColors.glassContainerGradient;
    }

    switch (style) {
      case GlassButtonStyle.primary:
        return const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case GlassButtonStyle.secondary:
        return const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case GlassButtonStyle.accent:
        return const LinearGradient(
          colors: [AppColors.accent, AppColors.warning],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case GlassButtonStyle.mingle:
        return AppColors.mingleGradient;
      case GlassButtonStyle.success:
        return AppColors.veryActiveGradient;
      case GlassButtonStyle.warning:
        return AppColors.activeGradient;
    }
  }

  Border? get _customBorder {
    if (!isOutlined) return null;

    switch (style) {
      case GlassButtonStyle.primary:
        return Border.all(
            color: AppColors.primary.withOpacity(0.5), width: 1.5);
      case GlassButtonStyle.secondary:
        return Border.all(
            color: AppColors.secondary.withOpacity(0.5), width: 1.5);
      case GlassButtonStyle.accent:
        return Border.all(color: AppColors.accent.withOpacity(0.5), width: 1.5);
      case GlassButtonStyle.mingle:
        return Border.all(
            color: AppColors.minglePink.withOpacity(0.5), width: 1.5);
      case GlassButtonStyle.success:
        return Border.all(
            color: AppColors.veryActiveGreen.withOpacity(0.5), width: 1.5);
      case GlassButtonStyle.warning:
        return Border.all(
            color: AppColors.activeOrange.withOpacity(0.5), width: 1.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = GlassContainer(
      width: width,
      padding: _padding,
      borderRadius: _borderRadius,
      customGradient: _backgroundGradient,
      customBorder: _customBorder,
      intensity: isOutlined ? GlassIntensity.medium : GlassIntensity.strong,
      elevation: onPressed != null ? GlassElevation.medium : GlassElevation.low,
      hasRippleEffect: true,
      onTap: onPressed,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Handle infinite or invalid constraints
          final availableWidth =
              constraints.maxWidth.isFinite && constraints.maxWidth > 0
                  ? constraints.maxWidth
                  : 150.0; // Fallback width for buttons

          // Ensure minimum button functionality
          if (availableWidth < 30) {
            // Very constrained space - show minimal version
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                    ),
                  )
                else
                  Text(
                    text.length > 4 ? '${text.substring(0, 4)}...' : text,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            );
          }

          return IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (prefixIcon != null && !isLoading) ...[
                  Flexible(
                    flex: 0,
                    child: prefixIcon!,
                  ),
                  const SizedBox(width: 8),
                ],
                if (isLoading)
                  Flexible(
                    flex: 0,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: _fontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (suffixIcon != null && !isLoading) ...[
                  const SizedBox(width: 8),
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

    if (enablePulseEffect) {
      return _PulseWrapper(child: button);
    }

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

class _PulseWrapper extends StatefulWidget {
  final Widget child;

  const _PulseWrapper({required this.child});

  @override
  State<_PulseWrapper> createState() => _PulseWrapperState();
}

class _PulseWrapperState extends State<_PulseWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.05,
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
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}
