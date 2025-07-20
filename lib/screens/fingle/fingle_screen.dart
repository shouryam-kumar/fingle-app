import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../providers/video_feed_provider.dart';
import '../../providers/app_provider.dart';
import '../../services/screen_timeout_service.dart';
import 'widgets/video_player_widget.dart';
import 'widgets/video_progress_indicator.dart';
import 'widgets/reaction_button.dart';
import 'widgets/recommend_button.dart';
import 'package:fingle_app/models/video_models.dart';
import 'package:fingle_app/models/reaction_models.dart';
import '../../providers/comments_provider.dart';
import 'widgets/comments_bottom_sheet.dart';
import 'widgets/reaction_details_sheet.dart';
import 'widgets/recommendation_details_sheet.dart';
import 'widgets/share_bottom_sheet.dart';
import 'constants/button_constants.dart';

class FingleScreen extends StatefulWidget {
  const FingleScreen({super.key});

  @override
  State<FingleScreen> createState() => _FingleScreenState();
}

class _FingleScreenState extends State<FingleScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late PageController _pageController;
  late VideoFeedProvider _videoProvider;
  bool _isInitialized = false;
  bool _wasTabVisible = false;

  // Separate state management for different UI categories
  bool _isInteractiveUIVisible =
      true; // User-controlled elements (settings, etc.)
  Timer? _uiHideTimer;
  bool _isReactionPickerVisible = false;
  bool _isCommentsVisible = false;

  // Overlay tracking to prevent duplicates
  OverlayEntry? _playPauseOverlayEntry;
  OverlayEntry? _reactionAnimationOverlayEntry;
  Timer? _playPauseTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController(
      viewportFraction: 1.0,
      keepPage: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideoFeed();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _uiHideTimer?.cancel();
    _clearAllOverlays();
    ScreenTimeoutService.disableExtendedTimeout();
    super.dispose();
  }

  void _clearAllOverlays() {
    _cleanupPlayPauseOverlay();
    _reactionAnimationOverlayEntry?.remove();
    _reactionAnimationOverlayEntry = null;
  }

  void _cleanupPlayPauseOverlay() {
    // Cancel any pending cleanup timer first
    _playPauseTimer?.cancel();
    _playPauseTimer = null;

    // Remove overlay if it exists and is still mounted
    if (_playPauseOverlayEntry != null) {
      try {
        _playPauseOverlayEntry!.remove();
        debugPrint('🎯 Play/pause overlay cleaned up');
      } catch (e) {
        debugPrint('🎯 Error removing play/pause overlay: $e');
      } finally {
        _playPauseOverlayEntry = null;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!_isInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('📱 App resumed - checking tab visibility');
        _checkAndUpdateTabVisibility();
        ScreenTimeoutService.onAppResumed();
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        debugPrint('📱 App paused/inactive - pausing video');
        _videoProvider.pauseCurrentVideo();
        ScreenTimeoutService.onAppPaused();
        break;

      case AppLifecycleState.detached:
        debugPrint('📱 App detached - cleaning up');
        ScreenTimeoutService.dispose();
        break;
    }
  }

  Future<void> _showCommentsSheet(VideoPost video) async {
    _onUserInteraction();

    setState(() {
      _isCommentsVisible = true;
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => CommentsBottomSheet(
        video: video,
        onClose: () {
          _onUserInteraction();
        },
      ),
    );

    setState(() {
      _isCommentsVisible = false;
    });
  }

  Future<void> _showReactionDetailsSheet(VideoPost video) async {
    _onUserInteraction();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ReactionDetailsSheet(
        reactionSummary: video.reactionSummary,
        onClose: () {
          Navigator.of(context).pop();
          _onUserInteraction();
        },
      ),
    );
  }

  Future<void> _showRecommendationDetailsSheet(VideoPost video) async {
    _onUserInteraction();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => RecommendationDetailsSheet(
        recommendations: video.recommendations,
        onClose: () {
          Navigator.of(context).pop();
          _onUserInteraction();
        },
      ),
    );
  }

  Future<void> _showShareSheet(VideoPost video) async {
    _onUserInteraction();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ShareBottomSheet(
        video: video,
        onClose: () {
          Navigator.of(context).pop();
          _onUserInteraction();
        },
      ),
    );
  }

  void _checkAndUpdateTabVisibility() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final isFingleTabActive = appProvider.currentIndex == 2;

    debugPrint(
        '🔍 Tab visibility check: isFingleTabActive=$isFingleTabActive, wasVisible=$_wasTabVisible');

    if (isFingleTabActive && !_wasTabVisible) {
      _onTabVisible();
    } else if (!isFingleTabActive && _wasTabVisible) {
      _onTabInvisible();
    }

    _wasTabVisible = isFingleTabActive;
  }

  void _onTabVisible() {
    debugPrint('🟢 Fingle tab became VISIBLE - enabling screen timeout');
    _videoProvider.setTabVisibility(true);

    ScreenTimeoutService.enableExtendedTimeout();

    if (_isInitialized && _videoProvider.videos.isNotEmpty) {
      if (_videoProvider.currentIndex == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _videoProvider.setCurrentIndex(0);
          await _videoProvider.playCurrentVideo();
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _videoProvider.playCurrentVideo();
        });
      }
    }
  }

  void _onTabInvisible() {
    debugPrint('🔴 Fingle tab became INVISIBLE - disabling screen timeout');
    _videoProvider.setTabVisibility(false);

    ScreenTimeoutService.disableExtendedTimeout();
  }

  Future<void> _initializeVideoFeed() async {
    debugPrint('=== 🚀 INITIALIZING VIDEO FEED ===');

    _videoProvider = Provider.of<VideoFeedProvider>(context, listen: false);
    await _videoProvider.initialize();

    setState(() {
      _isInitialized = true;
    });

    debugPrint(
        '✅ Initialized: $_isInitialized, Videos: ${_videoProvider.videos.length}');

    if (_videoProvider.videos.isNotEmpty) {
      await _videoProvider.setCurrentIndex(0);
      debugPrint('📹 Set current index to 0');

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 1),
          curve: Curves.easeInOut,
        );
      }
    }

    _checkAndUpdateTabVisibility();

    debugPrint('=== ✅ VIDEO FEED INITIALIZATION COMPLETE ===');
  }

  void _onUserInteraction() {
    ScreenTimeoutService.resetTimer();
    debugPrint('👆 User interaction detected - resetting 3min timer');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isInitialized) {
            _checkAndUpdateTabVisibility();
          }
        });

        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: _onUserInteraction,
            child: Consumer<VideoFeedProvider>(
              builder: (context, provider, child) {
                if (!_isInitialized ||
                    provider.isLoading && provider.videos.isEmpty) {
                  return _buildLoadingScreen();
                }

                if (provider.videos.isEmpty) {
                  return _buildEmptyScreen();
                }

                return Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black,
                    ),
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      onPageChanged: _onPageChanged,
                      itemCount: provider.videos.length,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemBuilder: (context, index) {
                        final video = provider.videos[index];
                        final controller = provider.getController(video.id);
                        final isActive = index == provider.currentIndex;

                        return RepaintBoundary(
                          key: ValueKey(video.id),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.black,
                                ),
                                if (isActive) ...[
                                  VideoPlayerWidget(
                                    video: video,
                                    controller: controller,
                                    isActive: isActive,
                                    isTabVisible: provider.isTabVisible,
                                    onTap: _onVideoTap,
                                    onDoubleTap: () => _onVideoDoubleTap(video),
                                  ),

                                  // Combined overlays with separate visibility logic
                                  RepaintBoundary(
                                    child: _buildAllOverlays(video, provider),
                                  ),

                                  // Center play/pause button (visible when UI is hidden)
                                  if (!_isInteractiveUIVisible)
                                    Center(
                                      child: GestureDetector(
                                        onTap: _onVideoPlayPauseTap,
                                        child: AnimatedOpacity(
                                          opacity: !_isInteractiveUIVisible
                                              ? 0.8
                                              : 0.0,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              controller != null &&
                                                      controller.value.isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ] else ...[
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.black,
                                    child: Image.network(
                                      video.thumbnailUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.black,
                                          child: const Center(
                                            child: Icon(
                                              Icons.video_library,
                                              color: Colors.white54,
                                              size: 48,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (provider.isLoading && provider.videos.isNotEmpty)
                      Positioned(
                        bottom: 50,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _onPageChanged(int index) async {
    debugPrint('📄 Page changed to index: $index');

    _onUserInteraction();

    await _videoProvider.setCurrentIndex(index);

    if (_videoProvider.shouldLoadMore) {
      debugPrint('📥 Loading more videos...');
      _videoProvider.loadMoreVideos();
    }
  }

  void _onVideoTap() {
    debugPrint(
        '👆 Video tapped - reactionPickerVisible: $_isReactionPickerVisible, commentsVisible: $_isCommentsVisible');
    _onUserInteraction();

    // Only toggle play/pause if no UI overlays are active
    if (!_isReactionPickerVisible && !_isCommentsVisible) {
      debugPrint('👆 Video tapped - toggling play/pause');
      _videoProvider.togglePlayPause();
      _showPlayPauseIcon();

      // Don't toggle UI visibility when showing play/pause feedback
      // The animated overlay will handle the feedback
      return;
    } else {
      debugPrint(
          '🚫 Video tap ignored - UI overlay active (reactionPicker: $_isReactionPickerVisible, comments: $_isCommentsVisible)');
    }

    // Only toggle interactive UI visibility when NOT showing play/pause feedback
    _toggleInteractiveUIVisibility();
  }

  void _toggleInteractiveUIVisibility() {
    setState(() {
      _isInteractiveUIVisible = !_isInteractiveUIVisible;
    });

    if (_isInteractiveUIVisible) {
      _startInteractiveUIHideTimer();
    } else {
      _uiHideTimer?.cancel();
    }
  }

  void _startInteractiveUIHideTimer() {
    _uiHideTimer?.cancel();
    _uiHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isInteractiveUIVisible = false;
        });
      }
    });
  }

  void _onVideoPlayPauseTap() {
    debugPrint('👆 Video play/pause tapped');
    _onUserInteraction();
    _videoProvider.togglePlayPause();
    _showPlayPauseIcon();
  }

  void _showPlayPauseIcon() {
    debugPrint('🎯 _showPlayPauseIcon called - mounted: $mounted');
    if (!mounted) return;

    final currentVideo = _videoProvider.currentVideo;
    if (currentVideo == null) return;

    final controller = _videoProvider.getController(currentVideo.id);
    if (controller == null) return;

    // Clean up existing overlay
    _cleanupPlayPauseOverlay();

    // Show temporary feedback immediately (handled by overlay)

    final isPlaying = controller.value.isPlaying;
    debugPrint(
        '🎯 Showing play/pause overlay - isPlaying: $isPlaying, will show: ${isPlaying ? 'pause' : 'play'} icon');

    // Create new overlay with error handling
    try {
      _playPauseOverlayEntry = _createPlayPauseOverlay(isPlaying);
      Overlay.of(context).insert(_playPauseOverlayEntry!);

      // Backup cleanup timer (animation completes at 600ms)
      _playPauseTimer = Timer(const Duration(milliseconds: 650), () {
        _cleanupPlayPauseOverlay();
      });
    } catch (e) {
      debugPrint('🎯 Error creating play/pause overlay: $e');
      _cleanupPlayPauseOverlay();
    }
  }

  OverlayEntry _createPlayPauseOverlay(bool isPlaying) {
    return OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            onEnd: () {
              // Remove overlay immediately when animation completes
              _cleanupPlayPauseOverlay();
            },
            builder: (context, value, child) {
              return Opacity(
                opacity: value < 0.5 ? value * 2 : (1 - value) * 2,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onProgressBarTap() {
    debugPrint('👆 Progress bar tapped - seeking only');
    _onUserInteraction();
  }

  void _onVideoDoubleTap(VideoPost video) {
    debugPrint('👆👆 Video double-tapped - adding fire reaction');
    _onUserInteraction();

    // Double tap adds fire reaction
    _videoProvider.toggleReaction(video.id, ReactionType.fire);
    _showReactionAnimation(ReactionType.fire);
  }

  void _showReactionAnimation(ReactionType reactionType) {
    HapticFeedback.mediumImpact();

    final reactionData = ReactionData.getReactionData(reactionType);

    // Remove existing reaction animation if present
    if (_reactionAnimationOverlayEntry != null) {
      _reactionAnimationOverlayEntry!.remove();
      _reactionAnimationOverlayEntry = null;
    }

    _reactionAnimationOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: MediaQuery.of(context).size.width / 2 - 30,
        top: MediaQuery.of(context).size.height / 2 - 30,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1.0 + (value * 0.5),
              child: Opacity(
                opacity: 1.0 - value,
                child: Text(
                  reactionData.emoji,
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            );
          },
          onEnd: () {
            if (_reactionAnimationOverlayEntry != null) {
              _reactionAnimationOverlayEntry!.remove();
              _reactionAnimationOverlayEntry = null;
            }
          },
        ),
      ),
    );

    Overlay.of(context).insert(_reactionAnimationOverlayEntry!);
  }

  Widget _buildAllOverlays(VideoPost video, VideoFeedProvider provider) {
    return Stack(
      children: [
        // Always visible UI elements (permanent)
        _buildAlwaysVisibleElements(video, provider),

        // Interactive UI elements (user-controlled)
        if (_isInteractiveUIVisible) ...[
          _buildTopOverlay(),
        ],
      ],
    );
  }

  Widget _buildAlwaysVisibleElements(
      VideoPost video, VideoFeedProvider provider) {
    return Stack(
      children: [
        // Progress bar at bottom edge (always visible)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 4,
              child: FingleVideoProgressIndicator(
                controller: provider.getController(video.id),
                onTap: _onProgressBarTap,
              ),
            ),
          ),
        ),

        // Left content: Profile + Account info (always visible)
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Left side: Profile + Account info
                  Expanded(
                    child: _buildLeftContent(video, provider),
                  ),

                  // Right side: Action buttons
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildRightActions(video, provider),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fingle',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _onUserInteraction();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Camera feature coming soon!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightActions(VideoPost video, VideoFeedProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // NEW: Reaction Button (replaces like button)
        ReactionButton(
          reactionSummary: video.reactionSummary,
          onReactionSelected: (reactionType) {
            _onUserInteraction();
            provider.toggleReaction(video.id, reactionType);
          },
          onViewReactions: () {
            _onUserInteraction();
            _showReactionDetailsSheet(video);
          },
          onResetTimeout: _onUserInteraction,
          onPickerVisibilityChanged: (isVisible) {
            debugPrint(
                '🎯 FingleScreen: Reaction picker visibility changed to: $isVisible');
            setState(() {
              _isReactionPickerVisible = isVisible;
            });
          },
        ),

        SizedBox(height: kButtonSpacing),

        // NEW: Recommend Button
        RecommendButton(
          recommendCount: video.recommendations.length,
          isRecommended: video.isRecommended,
          onRecommend: () {
            _onUserInteraction();
            provider.toggleRecommendation(video.id);
          },
          onViewRecommendations: () {
            _onUserInteraction();
            _showRecommendationDetailsSheet(video);
          },
          onResetTimeout: _onUserInteraction,
        ),

        SizedBox(height: kButtonSpacing),

        // Comment Button
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          onTap: () {
            _onUserInteraction();
            _showCommentsSheet(video);
          },
          child: Consumer<CommentsProvider>(
            builder: (context, commentsProvider, child) {
              final totalComments = commentsProvider.getTotalComments(video.id);
              return Text(
                _formatCount(
                    totalComments > 0 ? totalComments : video.comments),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: kButtonTextSize,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ),

        SizedBox(height: kButtonSpacing),

        // Share Button
        _buildActionButton(
          icon: Icons.share,
          onTap: () {
            _onUserInteraction();
            _showShareSheet(video);
          },
          child: Text(
            _formatCount(video.shares),
            style: TextStyle(
              color: Colors.white,
              fontSize: kButtonTextSize,
              fontWeight: FontWeight.w600,
              height: 1.0,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 3.0,
                  color: Colors.black.withOpacity(0.8),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLeftContent(VideoPost video, VideoFeedProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile + Username row
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _onUserInteraction();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('View ${video.creator.name}\'s profile'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      video.creator.profilePic,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primary,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '@${video.creator.name.toLowerCase().replaceAll(' ', '')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3.0,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (video.creator.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    if (!video.isFollowing)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: GestureDetector(
                          onTap: () {
                            _onUserInteraction();
                            provider.toggleFollow(video.creator.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              'Follow',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Video caption
          Text(
            video.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3.0,
                  color: Colors.black,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Tags
          if (video.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: video.tags.take(3).map((tag) {
                return Text(
                  '#$tag',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Loading videos...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.video_library_outlined,
            color: Colors.white54,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No videos available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pull to refresh',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _onUserInteraction();
              Provider.of<VideoFeedProvider>(context, listen: false)
                  .refreshFeed();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Refresh'),
          ),
        ],
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

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return _AnimatedActionButton(
      icon: icon,
      onTap: onTap,
      child: child,
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Widget child;

  const _AnimatedActionButton({
    required this.icon,
    required this.onTap,
    required this.child,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kTotalButtonWidth,
      height: kTotalButtonHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon area with primary action
          GestureDetector(
            onTapDown: (_) {
              _controller.forward();
              HapticFeedback.lightImpact();
            },
            onTapUp: (_) {
              _controller.reverse();
              widget.onTap();
            },
            onTapCancel: () => _controller.reverse(),
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: kButtonContainerSize,
                    height: kButtonContainerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: kButtonBorderWidth,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: kButtonIconSize,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: kTextIconGap),
          // Number area - no action, just display
          Container(
            width: kButtonContainerSize,
            height: kTextHeight,
            alignment: Alignment.center,
            child: DefaultTextStyle(
              style: TextStyle(
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
