import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/video_feed_provider.dart';
import '../../providers/app_provider.dart';
import '../../services/screen_timeout_service.dart';
import 'widgets/video_player_widget.dart';
import 'widgets/video_progress_indicator.dart';
import 'widgets/reaction_button.dart';
import 'widgets/recommend_button.dart';
import 'widgets/comment_reaction_button.dart';
import 'package:fingle_app/models/video_models.dart';
import 'package:fingle_app/models/reaction_models.dart';
import '../../providers/comments_provider.dart';
import 'widgets/comments_bottom_sheet.dart';
import 'widgets/reaction_details_sheet.dart';
import 'widgets/recommendation_details_sheet.dart';
import 'widgets/share_bottom_sheet.dart';

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
    ScreenTimeoutService.disableExtendedTimeout();
    super.dispose();
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
    
    debugPrint('🔍 Tab visibility check: isFingleTabActive=$isFingleTabActive, wasVisible=$_wasTabVisible');
    
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
    
    debugPrint('✅ Initialized: $_isInitialized, Videos: ${_videoProvider.videos.length}');
    
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
                if (!_isInitialized || provider.isLoading && provider.videos.isEmpty) {
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
                                  
                                  RepaintBoundary(
                                    child: _buildVideoOverlays(video, provider),
                                  ),
                                ] else ...[
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.black,
                                    child: Image.network(
                                      video.thumbnailUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
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
    debugPrint('👆 Video tapped - toggling play/pause');
    _onUserInteraction();
    _videoProvider.togglePlayPause();
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
    
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
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
          onEnd: () => overlayEntry?.remove(),
        ),
      ),
    );
    
    Overlay.of(context).insert(overlayEntry);
  }

  Widget _buildVideoOverlays(VideoPost video, VideoFeedProvider provider) {
    return Stack(
      children: [
        _buildTopOverlay(),
        
        Positioned(
          right: 12,
          bottom: 100,
          child: _buildRightActions(video, provider),
        ),
        
        Positioned(
          bottom: 30,
          left: 0,
          right: 100,
          child: _buildBottomInfo(video, provider),
        ),
        
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: FingleVideoProgressIndicator(
                  controller: provider.getController(video.id),
                  onTap: _onProgressBarTap,
                ),
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
        // Creator Avatar with Follow Button
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
            width: 50,
            height: 50,
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
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
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
        ),
        
        const SizedBox(height: 24),
        
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
        
        const SizedBox(height: 24),
        
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
                _formatCount(totalComments > 0 ? totalComments : video.comments),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Share Button
        _buildActionButton(
          icon: Icons.share,
          onTap: () {
            _onUserInteraction();
            _showShareSheet(video);
          },
          child: Text(
            _formatCount(video.shares),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo(VideoPost video, VideoFeedProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.6),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '@${video.creator.name.toLowerCase().replaceAll(' ', '')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                const SizedBox(width: 12),
                if (!video.isFollowing)
                  GestureDetector(
                    onTap: () {
                      _onUserInteraction();
                      provider.toggleFollow(video.creator.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              video.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
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
              Provider.of<VideoFeedProvider>(context, listen: false).refreshFeed();
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
    return GestureDetector(
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
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  widget.child,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}