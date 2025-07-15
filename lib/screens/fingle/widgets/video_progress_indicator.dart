// lib/screens/fingle/widgets/video_progress_indicator.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';

class FingleVideoProgressIndicator extends StatefulWidget {
  final VideoPlayerController? controller;
  final bool isVisible;
  final VoidCallback? onTap;

  const FingleVideoProgressIndicator({
    super.key,
    required this.controller,
    this.isVisible = true,
    this.onTap,
  });

  @override
  State<FingleVideoProgressIndicator> createState() => _FingleVideoProgressIndicatorState();
}

class _FingleVideoProgressIndicatorState extends State<FingleVideoProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isDragging = false;
  Duration _dragPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _fadeController.forward();
    }
  }

  @override
  void didUpdateWidget(FingleVideoProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _fadeController.forward();
      } else {
        _fadeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null || !widget.controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: _buildProgressBar(),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          _buildSeekBar(),
          
          const SizedBox(height: 8),
          
          // Time indicators
          _buildTimeRow(),
        ],
      ),
    );
  }

  Widget _buildSeekBar() {
    final controller = widget.controller!;
    final duration = controller.value.duration;
    final position = _isDragging ? _dragPosition : controller.value.position;
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        height: 40, // Larger hit area
        child: Center(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.white.withOpacity(0.3),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final progress = duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0.0;
                
                return Stack(
                  children: [
                    // Background track
                    Container(
                      width: constraints.maxWidth,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    
                    // Progress track
                    Container(
                      width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: AppColors.primary,
                      ),
                    ),
                    
                    // Thumb/handle
                    Positioned(
                      left: (constraints.maxWidth * progress.clamp(0.0, 1.0)) - 8,
                      top: -4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow() {
    final controller = widget.controller!;
    final duration = controller.value.duration;
    final position = _isDragging ? _dragPosition : controller.value.position;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatDuration(position),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          _formatDuration(duration),
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _onTapDown(TapDownDetails details) {
    widget.onTap?.call();
    _seekToPosition(details.localPosition);
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _seekToPosition(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _seekToPosition(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    // Actually seek the video to the final position
    widget.controller?.seekTo(_dragPosition);
  }

  void _seekToPosition(Offset localPosition) {
    final controller = widget.controller!;
    if (!controller.value.isInitialized) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final double seekWidth = box.size.width - 32; // Account for margins
    final double seekPosition = (localPosition.dx - 16).clamp(0.0, seekWidth);
    final double seekPercent = seekPosition / seekWidth;
    
    final Duration newPosition = Duration(
      milliseconds: (controller.value.duration.inMilliseconds * seekPercent).round(),
    );

    setState(() {
      _dragPosition = newPosition;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '$minutes:${twoDigits(seconds)}';
    }
  }
}