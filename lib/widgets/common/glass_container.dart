import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';

enum GlassIntensity { subtle, medium, strong }
enum GlassElevation { low, medium, high, floating }

class GlassContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final GlassIntensity intensity;
  final GlassElevation elevation;
  final bool hasHoverEffect;
  final bool hasRippleEffect;
  final VoidCallback? onTap;
  final Color? customTint;
  final Gradient? customGradient;
  final Border? customBorder;
  final bool enableShimmerEffect;
  final Duration animationDuration;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.intensity = GlassIntensity.medium,
    this.elevation = GlassElevation.medium,
    this.hasHoverEffect = true,
    this.hasRippleEffect = false,
    this.onTap,
    this.customTint,
    this.customGradient,
    this.customBorder,
    this.enableShimmerEffect = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> 
    with TickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late AnimationController _shimmerController;
  
  late Animation<double> _hoverAnimation;
  late Animation<double> _pressAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
    
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeOut,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
    
    if (widget.enableShimmerEffect) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (!widget.hasHoverEffect) return;
    
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    
    setState(() {
      _isPressed = true;
    });
    
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    
    _pressController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    
    _pressController.reverse();
  }

  double get _blurStrength {
    switch (widget.intensity) {
      case GlassIntensity.subtle:
        return 10.0;
      case GlassIntensity.medium:
        return 20.0;
      case GlassIntensity.strong:
        return 30.0;
    }
  }

  double get _opacity {
    switch (widget.intensity) {
      case GlassIntensity.subtle:
        return 0.15;
      case GlassIntensity.medium:
        return 0.25;
      case GlassIntensity.strong:
        return 0.35;
    }
  }

  List<BoxShadow> get _shadows {
    switch (widget.elevation) {
      case GlassElevation.low:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ];
      case GlassElevation.medium:
        return [
          BoxShadow(
            color: AppColors.glassShadowPrimary,
            offset: const Offset(0, 8),
            blurRadius: 32,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            offset: const Offset(0, 1),
            blurRadius: 0,
          ),
        ];
      case GlassElevation.high:
        return [
          BoxShadow(
            color: AppColors.glassShadowPrimary,
            offset: const Offset(0, 16),
            blurRadius: 48,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.4),
            offset: const Offset(0, 1),
            blurRadius: 0,
          ),
        ];
      case GlassElevation.floating:
        return [
          BoxShadow(
            color: AppColors.glassShadowPrimary.withOpacity(0.5),
            offset: const Offset(0, 24),
            blurRadius: 64,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            offset: const Offset(0, 1),
            blurRadius: 0,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _hoverAnimation,
        _pressAnimation,
        if (widget.enableShimmerEffect) _shimmerAnimation,
      ]),
      builder: (context, child) {
        final transform = Matrix4.identity()
          ..scale(_pressAnimation.value)
          ..translate(0.0, _isHovered ? -8.0 : 0.0, 0.0);

        return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedContainer(
              duration: widget.animationDuration,
              curve: Curves.easeOutCubic,
              width: widget.width,
              height: widget.height,
              margin: widget.margin,
              transform: transform,
              constraints: BoxConstraints(
                minWidth: widget.width ?? 0,
                minHeight: widget.height ?? 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _blurStrength,
                    sigmaY: _blurStrength,
                  ),
                  child: Container(
                    padding: widget.padding,
                    decoration: BoxDecoration(
                      gradient: widget.customGradient ?? 
                        LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            (widget.customTint ?? Colors.white).withOpacity(
                              _opacity + (_hoverAnimation.value * 0.1)
                            ),
                            (widget.customTint ?? Colors.white).withOpacity(
                              _opacity * 0.5 + (_hoverAnimation.value * 0.05)
                            ),
                          ],
                        ),
                      border: widget.customBorder ?? 
                        Border.all(
                          color: Colors.white.withOpacity(
                            0.18 + (_hoverAnimation.value * 0.12)
                          ),
                          width: 1.0,
                        ),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      boxShadow: _shadows.map((shadow) {
                        if (_isHovered) {
                          return shadow.copyWith(
                            blurRadius: shadow.blurRadius * 1.5,
                            color: shadow.color.withOpacity(
                              (shadow.color.opacity * 1.5).clamp(0.0, 1.0)
                            ),
                          );
                        }
                        return shadow;
                      }).toList(),
                    ),
                    child: Stack(
                      children: [
                        widget.child,
                        if (widget.enableShimmerEffect)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(widget.borderRadius),
                              child: Transform.translate(
                                offset: Offset(_shimmerAnimation.value * 300, 0),
                                child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                      transform: const GradientRotation(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (widget.hasRippleEffect && widget.onTap != null)
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(widget.borderRadius),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(widget.borderRadius),
                                splashColor: AppColors.glassRipple,
                                highlightColor: AppColors.glassActiveHover,
                                onTap: widget.onTap,
                              ),
                            ),
                          ),
                      ],
                    ),
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