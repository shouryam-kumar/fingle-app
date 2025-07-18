import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/video_models.dart';
import '../profile/widgets/profile_stats.dart';
import '../profile/widgets/profile_content_tabs.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String? userName;
  final String? userAvatar;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.userName,
    this.userAvatar,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  
  User? _user;
  bool _isLoading = true;
  bool _isHeaderCollapsed = false;
  bool _isFollowing = false;
  final Map<String, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    
    _scrollController.addListener(_onScroll);
    _loadUserProfile();
  }

  void _onScroll() {
    const double threshold = 200.0;
    final bool isCollapsed = _scrollController.offset > threshold;
    
    if (isCollapsed != _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = isCollapsed;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    // Simulate loading user data
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() {
        _user = _createMockUser();
        _isLoading = false;
      });
    }
  }

  User _createMockUser() {
    return User(
      id: widget.userId,
      name: widget.userName ?? 'User ${widget.userId}',
      age: 26,
      bio: 'Fitness enthusiast 💪 | Yoga lover 🧘‍♀️ | Healthy lifestyle advocate 🌿',
      profilePic: widget.userAvatar ?? 'https://picsum.photos/200/200?random=${widget.userId}',
      coverImage: 'https://picsum.photos/800/400?random=${widget.userId}',
      isVerified: widget.userId == 'verified_user',
      isFollowing: false,
      joinedAt: DateTime.now().subtract(const Duration(days: 100)),
      interests: ['Fitness', 'Yoga', 'Wellness'],
      followers: 1234,
      following: 567,
      stats: UserStats(
        totalPosts: 3,
        followers: 1234,
        following: 567,
        totalViews: 12345,
      ),
      achievements: [],
      posts: [
        Post(
          id: '1',
          imageUrl: 'https://picsum.photos/400/600?random=1',
          category: 'Fitness',
          title: 'Morning workout session',
          description: 'Started my day with an intense HIIT workout!',
          tags: ['HIIT', 'morning', 'fitness'],
          likes: 45,
          comments: 12,
          shares: 3,
          views: 234,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Post(
          id: '2',
          imageUrl: 'https://picsum.photos/400/600?random=2',
          category: 'Yoga',
          title: 'Yoga flow',
          description: 'Finding peace through movement',
          tags: ['yoga', 'mindfulness', 'wellness'],
          likes: 67,
          comments: 8,
          shares: 5,
          views: 345,
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        Post(
          id: '3',
          imageUrl: 'https://picsum.photos/400/600?random=3',
          category: 'Nutrition',
          title: 'Healthy meal prep',
          description: 'Preparing nutritious meals for the week',
          tags: ['nutrition', 'mealprep', 'healthy'],
          likes: 89,
          comments: 15,
          shares: 7,
          views: 456,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFollowing ? 'Following ${_user?.name}!' : 'Unfollowed ${_user?.name}'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Profile Picture & Basic Info
          Row(
            children: [
              // Profile Picture
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: NetworkImage(_user!.profilePic),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  if (_user!.isVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 24),
              
              // Name & Bio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${_user!.name.toLowerCase().replaceAll(' ', '')}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _user!.bio,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Follow Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowing ? Colors.grey[700] : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                _isFollowing ? 'Following' : 'Follow',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? _buildLoadingState()
          : _buildProfileContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 100), // Space for app bar
                  _buildUserHeader(),
                  const SizedBox(height: 20),
                  ProfileStats(stats: _user!.stats),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            SliverFillRemaining(
              child: ProfileContentTabs(
                user: _user!,
                tabController: _tabController,
                expandedStates: _expandedStates,
                onExpandToggle: (String key) {
                  setState(() {
                    _expandedStates[key] = !(_expandedStates[key] ?? false);
                  });
                },
              ),
            ),
          ],
        ),
        _buildAppBar(),
      ],
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.6),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              if (_isHeaderCollapsed) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(_user?.profilePic ?? ''),
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _user?.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else ...[
                const Expanded(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              IconButton(
                onPressed: () {
                  // Show more options
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('More options coming soon!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}