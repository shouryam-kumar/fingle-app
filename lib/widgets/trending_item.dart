import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/home_models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class TrendingItem extends StatefulWidget {
  final TrendingTopic topic;
  final VoidCallback? onTap;

  const TrendingItem({
    super.key,
    required this.topic,
    this.onTap,
  });

  @override
  State<TrendingItem> createState() => _TrendingItemState();
}

class _TrendingItemState extends State<TrendingItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: widget.topic.gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.glassShadow,
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.glassMorphism,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.glassBorder,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.topic.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.topic.name,
                          style: AppTextStyles.trendingTitle.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatCount(widget.topic.postCount)} posts',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textDark.withOpacity(0.8),
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
