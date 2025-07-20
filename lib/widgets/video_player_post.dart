import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/home_models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class VideoPlayerPost extends StatefulWidget {
  final MediaItem mediaItem;
  final bool isReel;
  final bool autoPlay;
  final bool isMuted;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const VideoPlayerPost({
    super.key,
    required this.mediaItem,
    this.isReel = false,
    this.autoPlay = false,
    this.isMuted = true, // Default muted for better UX
    this.onTap,
    this.onDoubleTap,
  });

  @override
  State<VideoPlayerPost> createState() => _VideoPlayerPostState();
}

class _VideoPlayerPostState extends State<VideoPlayerPost> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer() {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.mediaItem.url),
      );

      _controller.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isInitialized = true;
          });

          // Set initial volume based on muted preference
          _controller.setVolume(widget.isMuted ? 0 : 1);

          if (widget.autoPlay) {
            _playVideo();
          }
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      });

      _controller.addListener(() {
        if (mounted) {
          final isPlaying = _controller.value.isPlaying;
          if (isPlaying != _isPlaying) {
            setState(() {
              _isPlaying = isPlaying;
            });
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (!_isInitialized || _hasError) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _playVideo();
    }
    widget.onTap?.call();
  }

  void _playVideo() {
    if (!_isInitialized || _hasError) return;
    _controller.play();
  }

  void _toggleMute() {
    if (!_isInitialized || _hasError) return;

    setState(() {
      if (_controller.value.volume > 0) {
        _controller.setVolume(0);
      } else {
        _controller.setVolume(1);
      }
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
    return '0:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildThumbnailFallback() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.mediaItem.thumbnail != null)
          CachedNetworkImage(
            imageUrl: widget.mediaItem.thumbnail!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.black,
              child: Icon(
                Icons.error,
                color: Colors.white,
                size: widget.isReel ? 80 : 60,
              ),
            ),
          )
        else
          Container(
            color: Colors.black,
            child: Icon(
              Icons.videocam_off,
              color: Colors.white,
              size: widget.isReel ? 80 : 60,
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        Icon(
          Icons.play_circle_filled,
          color: Colors.white,
          size: widget.isReel ? 80 : 60,
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),

        // Play/Pause overlay
        if (!_isPlaying)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
            ),
            child: Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: widget.isReel ? 80 : 60,
            ),
          ),

        // Volume control for reels
        if (widget.isReel && _isInitialized)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _controller.value.volume > 0
                      ? Icons.volume_up
                      : Icons.volume_off,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

        // Progress bar for regular videos
        if (!widget.isReel && _isInitialized)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: AppColors.primary,
                bufferedColor: Colors.white.withOpacity(0.3),
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return _buildThumbnailFallback();
  }

  Widget _buildDurationBadge() {
    if (widget.mediaItem.duration == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _formatDuration(Duration(seconds: widget.mediaItem.duration!)),
          style: AppTextStyles.caption.copyWith(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTap: widget.onDoubleTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: widget.isReel ? 400 : 180,
          color: Colors.black,
          child: Stack(
            children: [
              // Video content
              if (_hasError)
                _buildErrorWidget()
              else if (_isLoading)
                _buildThumbnailFallback()
              else
                _buildVideoPlayer(),

              // Duration badge (only show if not playing or for reels)
              if (!_isPlaying || widget.isReel) _buildDurationBadge(),
            ],
          ),
        ),
      ),
    );
  }
}
