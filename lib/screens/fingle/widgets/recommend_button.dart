// ===== FILE 6: lib/screens/fingle/widgets/recommend_button.dart =====
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/reaction_models.dart';
import '../../../core/theme/app_colors.dart';
import '../constants/button_constants.dart';

class RecommendButton extends StatefulWidget {
  final int recommendCount;
  final bool isRecommended;
  final VoidCallback onRecommend;
  final VoidCallback? onViewRecommendations;
  final VoidCallback? onResetTimeout;

  const RecommendButton({
    super.key,
    required this.recommendCount,
    required this.isRecommended,
    required this.onRecommend,
    this.onViewRecommendations,
    this.onResetTimeout,
  });

  @override
  State<RecommendButton> createState() => _RecommendButtonState();
}

class _RecommendButtonState extends State<RecommendButton>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late AnimationController _recommendController;
  late Animation<double> _buttonAnimation;
  late Animation<double> _recommendAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _recommendController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _buttonAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _recommendAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _recommendController,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: AppColors.primary,
    ).animate(CurvedAnimation(
      parent: _recommendController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _recommendController.dispose();
    super.dispose();
  }

  void _handleRecommend() {
    widget.onResetTimeout?.call();

    // Add bounce animation
    _recommendController.forward().then((_) {
      _recommendController.reverse();
    });

    HapticFeedback.mediumImpact();
    widget.onRecommend();

    // Show feedback for new recommendation
    _showRecommendationFeedback(true);
  }

  void _showRecommendationFeedback(bool isRecommending) {
    final message = isRecommending ? 'Recommended!' : 'Recommendation removed';
    final color = isRecommending ? AppColors.primary : Colors.grey;

    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _SophisticatedRecommendationAnimation(
        isRecommending: isRecommending,
        message: message,
        color: color,
        onComplete: () => overlayEntry?.remove(),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  void _handleQuickRecommend() {
    widget.onResetTimeout?.call();

    if (widget.isRecommended) {
      // Direct removal - no confirmation needed
      _handleDirectRemove();
    } else {
      // Direct recommendation - no sheet needed
      _handleRecommend();
    }
  }

  void _handleDirectRemove() {
    debugPrint('🔄 Removing recommendation');

    // Visual feedback for removal
    _recommendController.forward().then((_) {
      _recommendController.reverse();
    });

    // Remove recommendation immediately
    widget.onRecommend();

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Show brief feedback
    _showRecommendationFeedback(false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleQuickRecommend,
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) => _buttonController.reverse(),
      onTapCancel: () => _buttonController.reverse(),
      child: AnimatedBuilder(
        animation: _buttonAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonAnimation.value,
            child: Container(
              width: kTotalButtonWidth,
              height: kTotalButtonHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _recommendAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _recommendAnimation.value,
                        child: _buildRecommendIcon(),
                      );
                    },
                  ),
                  SizedBox(height: kTextIconGap),
                  _buildRecommendCount(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendIcon() {
    return Container(
      width: kButtonContainerSize,
      height: kButtonContainerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isRecommended
            ? AppColors.primary.withOpacity(0.15)
            : Colors.white.withOpacity(0.1),
        border: Border.all(
          color: widget.isRecommended
              ? AppColors.primary.withOpacity(0.4)
              : Colors.white.withOpacity(0.25),
          width: kButtonBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          if (widget.isRecommended)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Icon(
        widget.isRecommended
            ? Icons.keyboard_arrow_up
            : Icons.keyboard_arrow_up_outlined,
        color: widget.isRecommended ? AppColors.primary : Colors.white,
        size: kButtonIconSize,
      ),
    );
  }

  Widget _buildRecommendCount() {
    return GestureDetector(
      behavior:
          HitTestBehavior.opaque, // Prevent propagation to underlying widgets
      onTapDown: (_) {
        debugPrint('🎯 Recommend count tapped - preventing video tap');
      },
      onTap: widget.onViewRecommendations,
      child: Container(
        width: kButtonContainerSize,
        height: kTextHeight,
        alignment: Alignment.center,
        child: Text(
          _formatCount(widget.recommendCount),
          style: TextStyle(
            color: widget.isRecommended ? AppColors.primary : Colors.white,
            fontSize: kButtonTextSize,
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

// Sophisticated recommendation animation widget
class _SophisticatedRecommendationAnimation extends StatefulWidget {
  final bool isRecommending;
  final String message;
  final Color color;
  final VoidCallback onComplete;

  const _SophisticatedRecommendationAnimation({
    required this.isRecommending,
    required this.message,
    required this.color,
    required this.onComplete,
  });

  @override
  State<_SophisticatedRecommendationAnimation> createState() =>
      _SophisticatedRecommendationAnimationState();
}

class _SophisticatedRecommendationAnimationState
    extends State<_SophisticatedRecommendationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late AnimationController _scaleController;
  late AnimationController _opacityController;

  late Animation<double> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Create synchronized animation controllers
    _positionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _opacityController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Configure animations based on recommendation state
    if (widget.isRecommending) {
      // Recommended: Bottom to top, scale up
      _positionAnimation = Tween<double>(
        begin: 1.0, // Start below screen
        end: 0.5, // End at middle
      ).animate(CurvedAnimation(
        parent: _positionController,
        curve: Curves.easeOut,
      ));

      _scaleAnimation = Tween<double>(
        begin: 0.8,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ));
    } else {
      // Unrecommended: Top to bottom, scale down
      _positionAnimation = Tween<double>(
        begin: 0.0, // Start above screen
        end: 0.5, // End at middle
      ).animate(CurvedAnimation(
        parent: _positionController,
        curve: Curves.easeIn,
      ));

      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 0.6,
      ).animate(CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeIn,
      ));
    }

    // Opacity animation (same for both)
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _opacityController,
      curve: Curves.easeOut,
    ));

    // Start all animations simultaneously
    _startAnimations();
  }

  void _startAnimations() {
    _positionController.forward();
    _scaleController.forward();
    _opacityController.forward();

    // Complete when all animations finish
    _positionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge(
          [_positionController, _scaleController, _opacityController]),
      builder: (context, child) {
        // Calculate position based on animation progress
        final yPosition = _positionAnimation.value * screenSize.height;

        return Positioned(
          left: screenSize.width / 2 - 60, // Center horizontally
          top: yPosition - 20, // Adjust for text height
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
