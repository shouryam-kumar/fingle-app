import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlassRipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Offset center;
  final double maxRadius;

  GlassRipplePainter({
    required this.animation,
    required this.center,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value == 0) return;

    final radius = maxRadius * animation.value;
    final opacity = (1.0 - animation.value) * 0.3; // Fade from 30% to 0%

    final paint = Paint()
      ..color = AppColors.secondary.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    // Add a subtle border ripple
    final borderPaint = Paint()
      ..color = AppColors.secondary.withOpacity(opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(GlassRipplePainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
        oldDelegate.center != center;
  }
}

class GlassRippleEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const GlassRippleEffect({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<GlassRippleEffect> createState() => _GlassRippleEffectState();
}

class _GlassRippleEffectState extends State<GlassRippleEffect>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Offset> _rippleCenters = [];
  double _maxRadius = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    _maxRadius = size.width * 0.6; // Max ripple size
  }

  void _addRipple(Offset position) {
    final controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _controllers.add(controller);
    _rippleCenters.add(position);

    controller.forward().then((_) {
      _removeRipple(controller);
    });

    setState(() {});
  }

  void _removeRipple(AnimationController controller) {
    if (!mounted) return;
    final index = _controllers.indexOf(controller);
    if (index >= 0) {
      _controllers.removeAt(index);
      _rippleCenters.removeAt(index);
      controller.dispose();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _addRipple(details.localPosition);
      },
      child: CustomPaint(
        painter: _RipplesPainter(
          controllers: _controllers,
          centers: _rippleCenters,
          maxRadius: _maxRadius,
        ),
        child: widget.child,
      ),
    );
  }
}

class _RipplesPainter extends CustomPainter {
  final List<AnimationController> controllers;
  final List<Offset> centers;
  final double maxRadius;

  _RipplesPainter({
    required this.controllers,
    required this.centers,
    required this.maxRadius,
  }) : super(repaint: Listenable.merge(controllers));

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < controllers.length; i++) {
      final painter = GlassRipplePainter(
        animation: controllers[i],
        center: centers[i],
        maxRadius: maxRadius,
      );
      painter.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_RipplesPainter oldDelegate) {
    return oldDelegate.controllers.length != controllers.length;
  }
}
