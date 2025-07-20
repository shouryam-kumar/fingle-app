import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats.dart';
import 'widgets/profile_content_tabs.dart';

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
  final User currentUser = sampleUser;

  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this); // Changed from 4 to 3
    _scrollController = ScrollController();

    _scrollController.addListener(_onScroll);
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

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Custom App Bar with Cover Image
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
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
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              // Profile Header
              ProfileHeader(
                user: currentUser,
                isCollapsed: _isHeaderCollapsed,
              ).animate().fadeIn(duration: 600.ms).slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 600.ms,
                  ),

              const SizedBox(height: 20),

              // Profile Stats
              ProfileStats(
                stats: currentUser.stats,
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

              const SizedBox(height: 20),

              // Content Tabs
              ProfileContentTabs(
                user: currentUser,
                tabController: _tabController,
                expandedStates: expandedStates,
                onExpandToggle: _toggleCategoryExpansion,
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
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
