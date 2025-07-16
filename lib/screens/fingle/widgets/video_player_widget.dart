import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/video_models.dart';

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
  late Animation<double> _playPauseAnimation;
  
  bool _showPlayPauseIcon = false;

  @override
  void initState() {
    super.initState();
    
    _playPauseAnimationController = AnimationController(
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
  }

  @override
  void dispose() {
    _playPauseAnimationController.dispose();
    super.dispose();
  }

  void _onTap() {
    widget.onTap?.call();
    _showPlayPauseIndicator();
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