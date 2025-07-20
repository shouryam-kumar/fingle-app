import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';

class FingleVideoProgressIndicator extends StatefulWidget {
  final VideoPlayerController? controller;
  final VoidCallback? onTap;

  const FingleVideoProgressIndicator({
    super.key,
    required this.controller,
    this.onTap,
  });

  @override
  State<FingleVideoProgressIndicator> createState() =>
      _FingleVideoProgressIndicatorState();
}

class _FingleVideoProgressIndicatorState
    extends State<FingleVideoProgressIndicator> {
  bool _isDragging = false;
  Duration _dragPosition = Duration.zero;
  VideoPlayerController? _currentController;

  @override
  void initState() {
    super.initState();
    _setupVideoListener();
  }

  @override
  void didUpdateWidget(FingleVideoProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _setupVideoListener();
    }
  }

  @override
  void dispose() {
    _removeVideoListener();
    super.dispose();
  }

  void _setupVideoListener() {
    _removeVideoListener();
    _currentController = widget.controller;
    if (_currentController != null) {
      _currentController!.addListener(_onVideoUpdate);
    }
  }

  void _removeVideoListener() {
    if (_currentController != null) {
      _currentController!.removeListener(_onVideoUpdate);
    }
  }

  void _onVideoUpdate() {
    if (mounted && !_isDragging) {
      setState(() {
        // This will rebuild the widget with updated position
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null || !widget.controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return _buildProgressBar();
  }

  Widget _buildProgressBar() {
    final controller = widget.controller!;
    final duration = controller.value.duration;
    final position = _isDragging ? _dragPosition : controller.value.position;

    return Container(
      height: 4, // Slightly thicker for better visibility
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Container(
          height: 4,
          decoration: BoxDecoration(
            color:
                Colors.transparent, // Transparent background for better touch
            borderRadius: BorderRadius.circular(2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final progress = duration.inMilliseconds > 0
                  ? position.inMilliseconds / duration.inMilliseconds
                  : 0.0;

              final bufferedProgress = _getBufferedProgress(duration);

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

                  // Buffered progress (shows what's loaded)
                  if (bufferedProgress > 0)
                    Container(
                      width: constraints.maxWidth * bufferedProgress,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),

                  // Progress track (shows current position)
                  Container(
                    width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: AppColors.primary,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  double _getBufferedProgress(Duration duration) {
    if (widget.controller == null || !widget.controller!.value.isInitialized) {
      return 0.0;
    }

    final buffered = widget.controller!.value.buffered;
    if (buffered.isEmpty || duration.inMilliseconds == 0) {
      return 0.0;
    }

    // Find the buffered range that contains the current position
    final currentPosition = widget.controller!.value.position;
    DurationRange? relevantRange;

    for (final range in buffered) {
      if (range.start <= currentPosition && currentPosition <= range.end) {
        relevantRange = range;
        break;
      }
    }

    // If no relevant range found, use the last buffered range
    relevantRange ??= buffered.last;

    final bufferedEnd = relevantRange.end;
    return (bufferedEnd.inMilliseconds / duration.inMilliseconds)
        .clamp(0.0, 1.0);
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
    if (_isDragging) {
      _seekToPosition(details.localPosition);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isDragging) {
      // Actually seek the video to the final position
      widget.controller?.seekTo(_dragPosition);

      setState(() {
        _isDragging = false;
      });
    }
  }

  void _seekToPosition(Offset localPosition) {
    final controller = widget.controller!;
    if (!controller.value.isInitialized) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final double seekWidth = box.size.width;
    final double seekPosition = localPosition.dx.clamp(0.0, seekWidth);
    final double seekPercent = seekPosition / seekWidth;

    final Duration newPosition = Duration(
      milliseconds:
          (controller.value.duration.inMilliseconds * seekPercent).round(),
    );

    setState(() {
      _dragPosition = newPosition;
    });

    // For immediate feedback during tap (not just drag)
    if (!_isDragging) {
      controller.seekTo(newPosition);
    }
  }
}
