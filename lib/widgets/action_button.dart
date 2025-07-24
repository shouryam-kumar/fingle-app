import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../screens/fingle/constants/button_constants.dart';

class ActionButton extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final int? count;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback? onTap;
  final String? label;
  final bool showAnimation;

  const ActionButton({
    super.key,
    required this.icon,
    this.activeIcon,
    this.count,
    this.isActive = false,
    this.activeColor,
    this.onTap,
    this.label,
    this.showAnimation = false,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.showAnimation) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
    widget.onTap?.call();
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Better design philosophy: Use contrasting colors when active
    final iconColor = widget.isActive
        ? Colors.white // White icon on colored background for better contrast
        : AppColors.textSecondary;

    final textColor = widget.isActive
        ? (widget.activeColor ?? AppColors.primary)
        : AppColors.textSecondary;

    Widget child = SizedBox(
      width: kHomeTotalButtonWidth,
      height: kHomeTotalButtonHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: kHomeButtonContainerSize,
            height: kHomeButtonContainerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isActive
                  ? (widget.activeColor ??
                      AppColors.primary) // Solid color background when active
                  : Colors.white.withOpacity(0.1),
              border: Border.all(
                color: widget.isActive
                    ? (widget.activeColor ??
                        AppColors.primary) // Solid color border when active
                    : Colors.white.withOpacity(0.25),
                width: kHomeButtonBorderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
                if (widget.isActive)
                  BoxShadow(
                    color: (widget.activeColor ?? AppColors.primary)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Center(
              child: Icon(
                widget.isActive && widget.activeIcon != null
                    ? widget.activeIcon!
                    : widget.icon,
                color: iconColor,
                size: kHomeButtonIconSize,
              ),
            ),
          ),

          SizedBox(height: kHomeTextIconGap),

          // Count/Label text
          Container(
            width: kHomeButtonContainerSize,
            constraints: BoxConstraints(
              minHeight: kHomeTextHeight,
              maxHeight: kHomeTextHeight + 4.0,
            ),
            alignment: Alignment.center,
            child: widget.count != null
                ? Text(
                    _formatCount(widget.count!),
                    style: TextStyle(
                      color: textColor,
                      fontSize: kHomeButtonTextSize,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  )
                : (widget.label != null
                    ? Text(
                        widget.label!,
                        style: TextStyle(
                          color: textColor,
                          fontSize: kHomeButtonTextSize,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      )
                    : const SizedBox()),
          ),
        ],
      ),
    );

    if (widget.showAnimation) {
      child = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: child,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      onTapDown: (_) {
        // Small visual feedback on tap
        if (!widget.showAnimation) {
          _animationController.forward();
        }
      },
      onTapUp: (_) {
        if (!widget.showAnimation) {
          _animationController.reverse();
        }
      },
      onTapCancel: () {
        if (!widget.showAnimation) {
          _animationController.reverse();
        }
      },
      child: child,
    );
  }
}
