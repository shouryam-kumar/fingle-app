import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/video_models.dart';
import 'video_progress_indicator.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoPost video;
  final VideoPlayerController? controller;
  final bool isActive;
  final bool isTabVisible;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const VideoPlayerWidget({
    super.key,
    required this.video,
    this.controller,
    required this.isActive,
    required this.isTabVisible,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with TickerProviderStateMixin {
  late AnimationController _playPauseAnimationController;
  late AnimationController _controlsAnimationController;
  late Animation<double> _playPauseAnimation;
  late Animation<double> _controlsAnimation;
  
  bool _showPlayPauseIcon = false;
  bool _showControls = false;
  bool _isInitialLoad = true;

  // Timer for hiding controls
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    
    _playPauseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _playPauseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _playPauseAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _controlsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    ));

    // Show controls initially for a short time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isActive && widget.isTabVisible) {
        _showControlsTemporarily();
      }
    });
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Show controls when video becomes active
    if (widget.isActive && !oldWidget.isActive && widget.isTabVisible) {
      _showControlsTemporarily();
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _playPauseAnimationController.dispose();
    _controlsAnimationController.dispose();
    super.dispose();
  }

  void _onTap() {
    widget.onTap?.call();
    _showPlayPauseIndicator();
    _toggleControls();
  }

  void _showPlayPauseIndicator() {
    if (widget.controller == null) return;
    
    setState(() {
      _showPlayPauseIcon = true;
    });
    
    _playPauseAnimationController.forward().then((_) {
      _playPauseAnimationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _showPlayPauseIcon = false;
          });
        }
      });
    });
  }

  void _toggleControls() {
    if (_showControls) {
      _hideControls();
    } else {
      _showControlsTemporarily();
    }
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _controlsAnimationController.forward();
    
    // Reset the timer
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _hideControls();
      }
    });
  }

  void _hideControls() {
    _hideControlsTimer?.cancel();
    _controlsAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _onProgressTap() {
    // Keep controls visible when interacting with progress bar
    _showControlsTemporarily();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video or thumbnail
          _buildVideoContent(),
          
          // Gesture detector
          GestureDetector(
            onTap: _onTap,
            onDoubleTap: widget.onDoubleTap,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          
          // Play/pause indicator
          if (_showPlayPauseIcon)
            Center(
              child: AnimatedBuilder(
                animation: _playPauseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.5 + (_playPauseAnimation.value * 0.5),
                    child: Opacity(
                      opacity: 1.0 - _playPauseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getPlayPauseIcon(),
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // Video progress indicator
          if (widget.isActive && widget.controller != null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _controlsAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _controlsAnimation.value,
                    child: FingleVideoProgressIndicator(
                      controller: widget.controller,
                      isVisible: _showControls,
                      onTap: _onProgressTap,
                    ),
                  );
                },
              ),
            ),
          
          // Loading indicator overlay
          if (widget.controller != null && 
              widget.controller!.value.isInitialized && 
              widget.controller!.value.isBuffering)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Buffering...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    // Improved logic for when to show video vs thumbnail
    final bool isControllerReady = widget.controller != null && 
                                  widget.controller!.value.isInitialized;
    
    // Show video if controller is ready AND video is active AND tab is visible
    final bool shouldShowVideo = isControllerReady && 
                                widget.isActive && 
                                widget.isTabVisible;

    debugPrint('🎬 VideoPlayerWidget - Video: ${widget.video.id}, '
               'Controller Ready: $isControllerReady, '
               'Active: ${widget.isActive}, '
               'Tab Visible: ${widget.isTabVisible}, '
               'Should Show Video: $shouldShowVideo');

    if (shouldShowVideo) {
      // Show video player
      return Center(
        child: AspectRatio(
          aspectRatio: widget.controller!.value.aspectRatio,
          child: VideoPlayer(widget.controller!),
        ),
      );
    } else {
      // Show thumbnail
      return _buildThumbnail();
    }
  }

  Widget _buildThumbnail() {
    return CachedNetworkImage(
      imageUrl: widget.video.thumbnailUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white54,
                size: 48,
              ),
              SizedBox(height: 8),
              Text(
                'Failed to load video',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPlayPauseIcon() {
    if (widget.controller == null || !widget.controller!.value.isInitialized) {
      return Icons.play_arrow;
    }
    return widget.controller!.value.isPlaying ? Icons.pause : Icons.play_arrow;
  }
}