import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/supabase/user_profile_service.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats.dart';
import 'widgets/sticky_tab_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  
  // State to track expanded categories
  final Map<String, bool> expandedStates = {};
  
  // Current user data
  User? currentUser;
  bool _isLoading = true;
  String? _error;
  
  // Scroll state tracking
  bool _isHeaderCollapsed = false;
  bool _showScrollToTop = false;
  
  // Animation controllers
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    
    // Initialize header animation
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));

    _scrollController.addListener(_onScroll);
    
    // Load current user profile
    _loadCurrentUserProfile();
  }

  Future<void> _loadCurrentUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final userProfile = await UserProfileService.getCurrentUserProfile();
      
      if (mounted) {
        setState(() {
          currentUser = userProfile ?? sampleUser; // Fallback to sample user
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading current user profile: $e');
      
      if (mounted) {
        setState(() {
          currentUser = sampleUser; // Fallback to sample user
          _error = 'Failed to load profile';
          _isLoading = false;
        });
      }
    }
  }

  void _onScroll() {
    const double collapseThreshold = 200.0;
    const double scrollToTopThreshold = 500.0;
    final double offset = _scrollController.offset;
    
    // Header collapse state
    final bool isCollapsed = offset > collapseThreshold;
    if (isCollapsed != _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = isCollapsed;
      });
      
      // Animate header transition
      if (isCollapsed) {
        _headerAnimationController.forward();
      } else {
        _headerAnimationController.reverse();
      }
    }
    
    // Scroll to top button visibility
    final bool showScrollButton = offset > scrollToTopThreshold;
    if (showScrollButton != _showScrollToTop) {
      setState(() {
        _showScrollToTop = showScrollButton;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Unknown error occurred',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadCurrentUserProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Enhanced SliverAppBar with cover image and parallax
            _buildSliverAppBar(),
            
            // Profile Header
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _headerAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -20 * _headerAnimation.value),
                    child: ProfileHeader(
                      user: currentUser!,
                      isCollapsed: _isHeaderCollapsed,
                    ).animate().fadeIn(duration: 600.ms).slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 600.ms,
                        ),
                  );
                },
              ),
            ),

            // Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            // Profile Stats
            SliverToBoxAdapter(
              child: ProfileStats(
                stats: currentUser!.stats,
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
            ),

            // Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            // Sticky Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyTabBarDelegate(
                tabController: _tabController,
              ),
            ),

            // Tab Content
            _buildSliverTabContent(),
          ],
        ),
      ),
      floatingActionButton: _buildScrollToTopButton(),
    );
  }

  // Build enhanced SliverAppBar with parallax effect
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover image with parallax effect
            Image.network(
              currentUser!.coverImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                    ),
                  ),
                );
              },
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Mini profile info when collapsed
            AnimatedBuilder(
              animation: _headerAnimation,
              builder: (context, child) {
                return Positioned(
                  bottom: 16 + (40 * (1 - _headerAnimation.value)),
                  left: 16,
                  right: 16,
                  child: Opacity(
                    opacity: _headerAnimation.value,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(currentUser!.profilePic),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentUser!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${currentUser!.followers} followers',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => _shareProfile(),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit Profile'),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Text('Settings'),
            ),
            const PopupMenuItem(
              value: 'privacy',
              child: Text('Privacy'),
            ),
          ],
        ),
      ],
    );
  }

  // Build sliver content for tabs
  Widget _buildSliverTabContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          // Posts Tab with lazy loading
          _buildPostsTabSliver(),
          // Videos Tab
          _buildVideosTabSliver(),
          // Tagged Tab
          _buildTaggedTabSliver(),
        ],
      ),
    );
  }

  Widget _buildPostsTabSliver() {
    // Group posts by category
    final Map<String, List<Post>> groupedPosts = {};
    for (var post in currentUser!.posts) {
      groupedPosts.putIfAbsent(post.category, () => []).add(post);
    }

    if (groupedPosts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Share your fitness journey!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedPosts.length,
      itemBuilder: (context, index) {
        final category = groupedPosts.keys.elementAt(index);
        final posts = groupedPosts[category]!;
        final isExpanded = expandedStates[category] ?? false;

        return _buildCategorySection(category, posts, isExpanded);
      },
    );
  }

  Widget _buildVideosTabSliver() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'No videos yet',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Upload your first workout video!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaggedTabSliver() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'No tagged posts',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Posts you\'re tagged in will appear here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<Post> posts, bool isExpanded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _getCategoryIcon(category),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Text(
                '${posts.length} posts',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content based on expand state
          if (!isExpanded) ...[
            // Horizontal thumbnail list (first 4 items)
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: posts.length > 4 ? 4 : posts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _buildThumbnailItem(posts[i]),
              ),
            ),
          ] else ...[
            // Expanded grid view with lazy loading
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: posts.length,
              itemBuilder: (_, i) => _buildGridItem(posts[i]),
            ).animate().fadeIn(duration: 500.ms),
          ],

          const SizedBox(height: 12),

          // Show More / Less Button
          Center(
            child: ElevatedButton(
              onPressed: () => _toggleCategoryExpansion(category),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              ),
              child: Text(
                isExpanded ? 'Show Less' : 'Show More',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailItem(Post post) {
    return GestureDetector(
      onTap: () => _viewPost(post),
      child: Hero(
        tag: 'post_${post.id}',
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              post.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(Post post) {
    return GestureDetector(
      onTap: () => _viewPost(post),
      child: Hero(
        tag: 'post_${post.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              post.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Build scroll to top floating action button
  Widget _buildScrollToTopButton() {
    return AnimatedScale(
      scale: _showScrollToTop ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton.small(
        onPressed: _scrollToTop,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.keyboard_arrow_up),
      ),
    );
  }

  // Scroll to top functionality
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Refresh profile functionality
  Future<void> _refreshProfile() async {
    await _loadCurrentUserProfile();
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'gym':
        return '💪';
      case 'sports':
        return '⚽';
      case 'adventure':
        return '🏔️';
      case 'yoga':
        return '🧘‍♀️';
      case 'cardio':
        return '🏃‍♂️';
      default:
        return '🏋️‍♂️';
    }
  }

  void _viewPost(Post post) {
    // Navigate to post viewer - implementation would be similar to existing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing post: ${post.title}')),
    );
  }

  void _toggleCategoryExpansion(String category) {
    setState(() {
      expandedStates[category] = !(expandedStates[category] ?? false);
    });
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile shared!')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        // Navigate to edit profile
        break;
      case 'settings':
        // Navigate to settings
        break;
      case 'privacy':
        // Navigate to privacy settings
        break;
    }
  }
}
