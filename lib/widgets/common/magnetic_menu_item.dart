import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/post_action.dart';

class MagneticMenuItem extends StatefulWidget {
  final PostAction action;
  final VoidCallback? onExitAnimation;
  final Duration magneticDuration;
  final Duration elasticDuration;
  final double magneticStrength;

  const MagneticMenuItem({
    Key? key,
    required this.action,
    this.onExitAnimation,
    this.magneticDuration = const Duration(milliseconds: 300),
    this.elasticDuration = const Duration(milliseconds: 200),
    this.magneticStrength = 0.12,
  }) : super(key: key);

  @override
  State<MagneticMenuItem> createState() => _MagneticMenuItemState();
}

class _MagneticMenuItemState extends State<MagneticMenuItem>
    with TickerProviderStateMixin {
  late AnimationController _magneticController;
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  Offset _currentOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _magneticController = AnimationController(
      duration: widget.magneticDuration,
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: widget.elasticDuration,
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _magneticController,
      curve: Curves.easeOutQuart,
    ));

    // Create the bounce sequence animation
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.97)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.97, end: 1.03)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.03, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 30,
      ),
    ]).animate(_bounceController);

    _magneticController.addListener(() {
      if (!mounted) return;
      setState(() {
        _currentOffset = Offset.lerp(
              Offset.zero,
              _targetOffset,
              _magneticController.value,
            ) ??
            Offset.zero;
      });
    });
  }

  @override
  void dispose() {
    _magneticController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleHover(PointerEvent event, BoxConstraints constraints) {
    if (!mounted) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    // Ensure constraints are valid
    if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) return;

    try {
      final localPosition = renderBox.globalToLocal(event.position);
      final center = Offset(
        constraints.maxWidth / 2,
        constraints.maxHeight / 2,
      );

      final deltaX = localPosition.dx - center.dx;
      final deltaY = localPosition.dy - center.dy;

      // Ensure values are finite
      if (!deltaX.isFinite || !deltaY.isFinite) return;

      _targetOffset = Offset(
        deltaX * widget.magneticStrength,
        deltaY * widget.magneticStrength,
      );

      if (!_isHovered) {
        _isHovered = true;
        _magneticController.forward();
      } else {
        _magneticController.forward();
      }
    } catch (e) {
      // Handle any transformation errors gracefully
      debugPrint('Magnetic hover error: $e');
    }
  }

  void _handleHoverExit() {
    if (!mounted) return;
    _isHovered = false;
    _targetOffset = Offset.zero;
    _magneticController.reverse();
  }

  void _handleTapDown() {
    setState(() => _isPressed = true);
    _scaleController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp() {
    if (!mounted) return;
    setState(() => _isPressed = false);

    // Reset and start the bounce animation
    _bounceController.reset();
    _bounceController.forward();
  }

  void _handleTap() {
    widget.action.onPressed();
    widget.onExitAnimation?.call();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (event) => _handleHover(event, constraints),
          onExit: (_) => _handleHoverExit(),
          child: AnimatedBuilder(
            animation: Listenable.merge(
                [_scaleAnimation, _magneticController, _bounceAnimation]),
            builder: (context, child) {
              // Ensure offset values are finite
              final safeOffset = Offset(
                _currentOffset.dx.isFinite ? _currentOffset.dx : 0,
                _currentOffset.dy.isFinite ? _currentOffset.dy : 0,
              );

              // Use bounce animation when available, otherwise use scale or pressed state
              final scale = _bounceController.isAnimating
                  ? _bounceAnimation.value
                  : (_isPressed ? 0.97 : _scaleAnimation.value);

              return Transform.translate(
                offset: safeOffset,
                child: Transform.scale(
                  scale: scale,
                  child: GestureDetector(
                    onTapDown: (_) => _handleTapDown(),
                    onTapUp: (_) => _handleTapUp(),
                    onTapCancel: () => _handleTapUp(),
                    onTap: _handleTap,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        // Multi-layer background for better contrast
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _isHovered
                              ? [
                                  Colors.white.withOpacity(0.25),
                                  Colors.white.withOpacity(0.15),
                                ]
                              : [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.08),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isHovered
                              ? Colors.white.withOpacity(0.6)
                              : Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          // Dark underlay for contrast
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(_isHovered ? 0.15 : 0.1),
                            blurRadius: _isHovered ? 12 : 8,
                            spreadRadius: -2,
                            offset: const Offset(0, 2),
                          ),
                          // Inner highlight
                          BoxShadow(
                            color: Colors.white
                                .withOpacity(_isHovered ? 0.3 : 0.2),
                            blurRadius: 1,
                            spreadRadius: -1,
                            offset: const Offset(0, -1),
                          ),
                          // Subtle glow on hover
                          if (_isHovered)
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 0),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.action.icon,
                              color: widget.action.iconColor.withOpacity(0.9),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.action.title,
                                  style: AppTextStyles.body1.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.action.subtitle,
                                  style: AppTextStyles.body2.copyWith(
                                    color: Colors.white.withOpacity(0.85),
                                    fontWeight: FontWeight.w400,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.4),
                                        blurRadius: 1,
                                        offset: const Offset(0, 0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
