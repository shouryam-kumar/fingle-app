// lib/screens/profile/widgets/profile_content_tabs.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart'; // ✅ Added missing import
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_provider.dart'; // ✅ Added missing import
import '../../post_viewer/post_viewer_screen.dart';

class ProfileContentTabs extends StatefulWidget {
  final User user;
  final TabController tabController;
  final Map<String, bool> expandedStates;
  final Function(String) onExpandToggle;

  const ProfileContentTabs({
    super.key,
    required this.user,
    required this.tabController,
    required this.expandedStates,
    required this.onExpandToggle,
  });

  @override
  State<ProfileContentTabs> createState() => _ProfileContentTabsState();
}

class _ProfileContentTabsState extends State<ProfileContentTabs> {
  @override
  Widget build(BuildContext context) {
    // Group posts by category
    final Map<String, List<Post>> groupedPosts = {};
    for (var post in widget.user.posts) {
      groupedPosts.putIfAbsent(post.category, () => []).add(post);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab Bar (removed Likes tab)
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: widget.tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              labelPadding: EdgeInsets.zero,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library, size: 16),
                      SizedBox(width: 6),
                      Text('Posts'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle, size: 16),
                      SizedBox(width: 6),
                      Text('Videos'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_offer, size: 16),
                      SizedBox(width: 6),
                      Text('Tagged'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Content (removed Likes tab content)
          SizedBox(
            height: 600, // Fixed height for the tab content
            child: TabBarView(
              controller: widget.tabController,
              children: [
                // Posts Tab
                _buildPostsTab(groupedPosts),

                // Videos Tab
                _buildVideosTab(),

                // Tagged Tab (moved to position 2)
                _buildTaggedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab(Map<String, List<Post>> groupedPosts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: groupedPosts.entries.map((entry) {
          final category = entry.key;
          final posts = entry.value;
          final isExpanded = widget.expandedStates[category] ?? false;

          return _buildCategorySection(category, posts, isExpanded);
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySection(
      String category, List<Post> posts, bool isExpanded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            // Expanded grid view
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
              onPressed: () => widget.onExpandToggle(category),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
        tag: 'post_${post.id}', // Added hero tag
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
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),

              // Tags overlay (top)
              if (post.tags.isNotEmpty)
                Positioned(
                  top: 4,
                  left: 4,
                  right: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#${post.tags.first}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

              // Stats overlay (bottom)
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${post.likes}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(Post post) {
    return GestureDetector(
      onTap: () => _viewPost(post),
      child: Hero(
        tag: 'post_${post.id}', // Added hero tag
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
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Tags overlay (top)
              if (post.tags.isNotEmpty)
                Positioned(
                  top: 4,
                  left: 4,
                  right: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#${post.tags.first}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

              // Stats overlay (bottom)
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${post.likes}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${post.views}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideosTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library,
            size: 64,
            color: AppColors.textLight,
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
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaggedTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: AppColors.textLight,
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
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
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
    final postIndex = widget.user.posts.indexOf(post);

    // 🐛 DEBUG: Log navigation (✅ Fixed Provider usage)
    debugPrint('🚀 Navigating to PostViewerScreen');
    debugPrint(
        '  📊 Current app tab: ${Provider.of<AppProvider>(context, listen: false).currentIndex}');
    debugPrint('  📹 Post index: $postIndex');

    Navigator.of(context)
        .push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PostViewerScreen(
          posts: widget.user.posts,
          initialIndex: postIndex,
          user: widget.user,
          useAppTheme: false, // Use black background for better media viewing
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    )
        .then((_) {
      // 🐛 DEBUG: Log return from navigation (✅ Fixed Provider usage)
      debugPrint('🔙 Returned from PostViewerScreen');
      debugPrint(
          '  📊 Current app tab: ${Provider.of<AppProvider>(context, listen: false).currentIndex}');
      debugPrint('  📊 Expected tab: Profile (4)');
    });
  }
}
