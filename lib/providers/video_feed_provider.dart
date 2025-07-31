import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/video_models.dart';
import '../models/reaction_models.dart';
import '../services/supabase/video_feed_service.dart';
import '../services/supabase/user_profile_service.dart';
import '../services/mock_video_data.dart';

class VideoFeedProvider with ChangeNotifier {
  List<VideoPost> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _hasReachedEnd = false;
  bool _isTabVisible = true;
  String _feedType = 'for_you'; // Default feed type

  final Map<String, VideoPlayerController> _controllers = {};

  // Getters
  List<VideoPost> get videos => _videos;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get hasReachedEnd => _hasReachedEnd;
  bool get isTabVisible => _isTabVisible;
  String get feedType => _feedType;
  bool get shouldLoadMore =>
      _currentIndex >= _videos.length - 3 && !_hasReachedEnd;

  VideoPost? get currentVideo =>
      _videos.isNotEmpty && _currentIndex < _videos.length
          ? _videos[_currentIndex]
          : null;

  VideoPlayerController? getController(String videoId) {
    return _controllers[videoId];
  }

  Future<void> initialize() async {
    debugPrint('🎬 VideoFeedProvider: Initializing...');

    _isLoading = true;
    notifyListeners();

    try {
      await _loadInitialVideos();
      debugPrint('✅ VideoFeedProvider: Initialization complete');
    } catch (e) {
      debugPrint('❌ VideoFeedProvider: Initialization failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadInitialVideos() async {
    try {
      // Try loading from Supabase first
      final videos = await VideoFeedService.getVideoFeed(
        feedType: _feedType,
        limit: 10,
        offset: 0,
      );

      if (videos.isNotEmpty) {
        _videos = videos;
        debugPrint('✅ Loaded ${videos.length} videos from Supabase');
      } else {
        // Fallback to mock data if no videos from API
        final mockVideos = MockVideoData.getMockVideos();
        _videos = mockVideos.take(10).toList();
        debugPrint('📝 Using mock videos as fallback');
      }

      if (_videos.isNotEmpty) {
        await _preloadVideos();
      }
    } catch (e) {
      debugPrint('❌ Error loading videos, using mock data: $e');
      // Fallback to mock data on error
      final mockVideos = MockVideoData.getMockVideos();
      _videos = mockVideos.take(10).toList();
      
      if (_videos.isNotEmpty) {
        await _preloadVideos();
      }
    }
  }

  Future<void> loadMoreVideos() async {
    if (_isLoading || _hasReachedEnd) return;

    debugPrint('📥 Loading more videos...');

    _isLoading = true;
    notifyListeners();

    try {
      // Try loading from Supabase first
      final additionalVideos = await VideoFeedService.getVideoFeed(
        feedType: _feedType,
        limit: 5,
        offset: _videos.length,
      );

      if (additionalVideos.isEmpty) {
        // Fallback to mock data if no more videos from API
        final mockVideos = MockVideoData.getMockVideos().skip(_videos.length).take(5).toList();
        
        if (mockVideos.isEmpty) {
          _hasReachedEnd = true;
          debugPrint('🏁 Reached end of videos');
        } else {
          _videos.addAll(mockVideos);
          await _preloadVideos();
          debugPrint('✅ Loaded ${mockVideos.length} more videos (mock fallback)');
        }
      } else {
        _videos.addAll(additionalVideos);
        await _preloadVideos();
        debugPrint('✅ Loaded ${additionalVideos.length} more videos from Supabase');
      }
    } catch (e) {
      debugPrint('❌ Error loading more videos: $e');
      
      // Fallback to mock data on error
      final mockVideos = MockVideoData.getMockVideos().skip(_videos.length).take(5).toList();
      if (mockVideos.isNotEmpty) {
        _videos.addAll(mockVideos);
        await _preloadVideos();
        debugPrint('✅ Loaded ${mockVideos.length} more videos (error fallback)');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _preloadVideos() async {
    final indicesToPreload = [
      _currentIndex,
      if (_currentIndex + 1 < _videos.length) _currentIndex + 1,
      if (_currentIndex + 2 < _videos.length) _currentIndex + 2,
    ];

    for (final index in indicesToPreload) {
      if (index >= 0 && index < _videos.length) {
        final video = _videos[index];
        if (!_controllers.containsKey(video.id)) {
          await _createController(video);
        }
      }
    }
  }

  Future<void> _createController(VideoPost video) async {
    try {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(video.videoUrl));
      await controller.initialize();

      controller.setLooping(true);
      controller.setVolume(1.0);

      _controllers[video.id] = controller;

      debugPrint('🎬 Controller created for video: ${video.id}');
    } catch (e) {
      debugPrint('❌ Failed to create controller for video ${video.id}: $e');
    }
  }

  Future<void> setCurrentIndex(int index) async {
    if (index == _currentIndex || index < 0 || index >= _videos.length) return;

    debugPrint('📹 Setting current index to: $index');

    await pauseCurrentVideo();

    _currentIndex = index;
    notifyListeners();

    await _preloadVideos();

    if (_isTabVisible) {
      await playCurrentVideo();
    }
  }

  Future<void> playCurrentVideo() async {
    if (!_isTabVisible ||
        _currentIndex < 0 ||
        _currentIndex >= _videos.length) {
      return;
    }

    final video = _videos[_currentIndex];
    final controller = _controllers[video.id];

    if (controller != null && controller.value.isInitialized) {
      await controller.play();
      debugPrint('▶️ Playing video: ${video.id}');
    }
  }

  Future<void> pauseCurrentVideo() async {
    if (_currentIndex < 0 || _currentIndex >= _videos.length) return;

    final video = _videos[_currentIndex];
    final controller = _controllers[video.id];

    if (controller != null && controller.value.isInitialized) {
      await controller.pause();
      debugPrint('⏸️ Paused video: ${video.id}');
    }
  }

  void togglePlayPause() {
    if (_currentIndex < 0 || _currentIndex >= _videos.length) return;

    final video = _videos[_currentIndex];
    final controller = _controllers[video.id];

    if (controller != null && controller.value.isInitialized) {
      if (controller.value.isPlaying) {
        controller.pause();
        debugPrint('⏸️ Paused video: ${video.id}');
      } else {
        controller.play();
        debugPrint('▶️ Playing video: ${video.id}');
      }
    }
  }

  void setTabVisibility(bool isVisible) {
    if (_isTabVisible == isVisible) return;

    _isTabVisible = isVisible;
    debugPrint('👁️ Tab visibility changed: $isVisible');

    if (isVisible) {
      playCurrentVideo();
    } else {
      pauseCurrentVideo();
    }
  }

  // NEW: Reaction handling methods
  Future<void> toggleReaction(String videoId, ReactionType reactionType) async {
    final videoIndex = _videos.indexWhere((v) => v.id == videoId);
    if (videoIndex == -1) return;

    final video = _videos[videoIndex];
    final currentUserReaction = video.reactionSummary.userReaction;

    if (currentUserReaction == reactionType) {
      // Remove reaction
      await _removeReaction(videoId, reactionType);
    } else {
      // Add/change reaction
      await _addReaction(videoId, reactionType);
    }
  }

  Future<void> _addReaction(String videoId, ReactionType reactionType) async {
    final videoIndex = _videos.indexWhere((v) => v.id == videoId);
    if (videoIndex == -1) return;

    final video = _videos[videoIndex];
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? 'current_user_id';

    // Optimistic update - update UI immediately
    final newReaction = Reaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUserId,
      userName: 'You',
      userAvatar: 'https://example.com/avatar.jpg',
      type: reactionType,
      createdAt: DateTime.now(),
    );

    final existingReactions = video.reactionSummary.reactions.values
        .expand((list) => list)
        .where((r) => r.userId != currentUserId)
        .toList();

    existingReactions.add(newReaction);

    final updatedSummary =
        ReactionSummary.fromReactions(existingReactions, currentUserId);

    _videos[videoIndex] = video.copyWith(reactionSummary: updatedSummary);
    notifyListeners();

    debugPrint('✅ Added reaction: ${reactionType.name} to video: $videoId (optimistic)');

    // Try to update on backend
    try {
      final success = await VideoFeedService.toggleVideoReaction(videoId, reactionType);
      if (!success) {
        debugPrint('⚠️ Failed to sync reaction to backend, keeping optimistic update');
      } else {
        debugPrint('✅ Reaction synced to backend');
      }
    } catch (e) {
      debugPrint('❌ Error syncing reaction to backend: $e');
    }
  }

  Future<void> _removeReaction(
      String videoId, ReactionType reactionType) async {
    final videoIndex = _videos.indexWhere((v) => v.id == videoId);
    if (videoIndex == -1) return;

    final video = _videos[videoIndex];
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? 'current_user_id';

    // Optimistic update - update UI immediately
    final existingReactions = video.reactionSummary.reactions.values
        .expand((list) => list)
        .where((r) => r.userId != currentUserId)
        .toList();

    final updatedSummary =
        ReactionSummary.fromReactions(existingReactions, currentUserId);

    _videos[videoIndex] = video.copyWith(reactionSummary: updatedSummary);
    notifyListeners();

    debugPrint('❌ Removed reaction: ${reactionType.name} from video: $videoId (optimistic)');

    // Try to update on backend
    try {
      final success = await VideoFeedService.toggleVideoReaction(videoId, reactionType);
      if (!success) {
        debugPrint('⚠️ Failed to sync reaction removal to backend, keeping optimistic update');
      } else {
        debugPrint('✅ Reaction removal synced to backend');
      }
    } catch (e) {
      debugPrint('❌ Error syncing reaction removal to backend: $e');
    }
  }

  // NEW: Recommendation handling methods
  Future<void> toggleRecommendation(String videoId) async {
    final videoIndex = _videos.indexWhere((v) => v.id == videoId);
    if (videoIndex == -1) return;

    final video = _videos[videoIndex];

    if (video.isRecommended) {
      await _removeRecommendation(videoId);
    } else {
      await _addRecommendation(videoId);
    }
  }

  Future<void> _addRecommendation(String videoId) async {
    final videoIndex = _videos.indexWhere((v) => v.id == videoId);
    if (videoIndex == -1) return;

    final video = _videos[videoIndex];

    // Create new recommendation
    final newRecommendation = Recommendation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id',
      userName: 'You',
      userAvatar: 'https://example.com/avatar.jpg',
      createdAt: DateTime.now(),
    );

    final updatedRecommendations =
        List<Recommendation>.from(video.recommendations)
          ..add(newRecommendation);

    _videos[videoIndex] = video.copyWith(
      recommendations: updatedRecommendations,
      isRecommended: true,
    );

    notifyListeners();

    debugPrint('✅ Added recommendation to video: $videoId');
  }

  Future<void> _removeRecommendation(String videoId) async {
    final videoIndex = _videos.indexWhere((v) => v.id == videoId);
    if (videoIndex == -1) return;

    final video = _videos[videoIndex];

    // Remove user's recommendation
    final updatedRecommendations = video.recommendations
        .where((r) => r.userId != 'current_user_id')
        .toList();

    _videos[videoIndex] = video.copyWith(
      recommendations: updatedRecommendations,
      isRecommended: false,
    );

    notifyListeners();

    debugPrint('❌ Removed recommendation from video: $videoId');
  }

  // Legacy method for backward compatibility
  Future<void> toggleLike(String videoId) async {
    await toggleReaction(videoId, ReactionType.like);
  }

  Future<void> toggleFollow(String userId) async {
    final videoIndex = _videos.indexWhere((v) => v.creator.id == userId);
    if (videoIndex == -1) return;

    final video = _videos[videoIndex];
    final isCurrentlyFollowing = video.creator.isFollowing;

    // Optimistic update - update UI immediately
    final updatedCreator = video.creator.copyWith(
      isFollowing: !isCurrentlyFollowing,
    );

    _videos[videoIndex] = video.copyWith(
      creator: updatedCreator,
      isFollowing: !video.isFollowing,
    );

    notifyListeners();

    debugPrint('✅ Toggled follow for user: $userId (optimistic)');

    // Try to update on backend
    try {
      bool success;
      if (isCurrentlyFollowing) {
        success = await UserProfileService.unfollowUser(userId);
      } else {
        success = await UserProfileService.followUser(userId);
      }

      if (!success) {
        // Revert on failure
        final revertedCreator = updatedCreator.copyWith(
          isFollowing: isCurrentlyFollowing,
        );
        _videos[videoIndex] = video.copyWith(
          creator: revertedCreator,
          isFollowing: video.isFollowing,
        );
        notifyListeners();
        debugPrint('❌ Failed to sync follow status, reverted');
      } else {
        debugPrint('✅ Follow status synced to backend');
      }
    } catch (e) {
      // Revert on error
      final revertedCreator = updatedCreator.copyWith(
        isFollowing: isCurrentlyFollowing,
      );
      _videos[videoIndex] = video.copyWith(
        creator: revertedCreator,
        isFollowing: video.isFollowing,
      );
      notifyListeners();
      debugPrint('❌ Error syncing follow status: $e');
    }
  }

  /// Change feed type and reload videos
  Future<void> changeFeedType(String feedType) async {
    if (_feedType == feedType) return;

    debugPrint('🔄 Changing feed type to: $feedType');
    
    _feedType = feedType;
    await refreshFeed();
  }

  Future<void> refreshFeed() async {
    debugPrint('🔄 Refreshing feed...');

    _videos.clear();
    _currentIndex = 0;
    _hasReachedEnd = false;

    // Dispose all controllers
    for (final controller in _controllers.values) {
      await controller.dispose();
    }
    _controllers.clear();

    await initialize();
  }

  @override
  void dispose() {
    debugPrint('🗑️ VideoFeedProvider: Disposing...');

    // Dispose all video controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();

    super.dispose();
  }
}
