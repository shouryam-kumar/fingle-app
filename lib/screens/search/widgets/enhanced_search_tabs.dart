import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../widgets/common/glass_badge.dart';

class EnhancedSearchTabs extends StatefulWidget {
  final PageController pageController;

  const EnhancedSearchTabs({super.key, required this.pageController});

  @override
  State<EnhancedSearchTabs> createState() => _EnhancedSearchTabsState();
}

class _EnhancedSearchTabsState extends State<EnhancedSearchTabs>
    with TickerProviderStateMixin {
  late AnimationController _tabSwitchController;
  late Animation<double> _tabSwitchAnimation;

  @override
  void initState() {
    super.initState();

    _tabSwitchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _tabSwitchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tabSwitchController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _tabSwitchController.dispose();
    super.dispose();
  }

  void _onTabTap(int index, SearchProvider searchProvider) {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Animate tab switch
    _tabSwitchController.forward().then((_) {
      _tabSwitchController.reverse();
    });

    // Update selected tab and animate PageView to sync
    searchProvider.selectTab(index);
    widget.pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return Column(
          children: [
            // Main tabs
            _buildTabsContainer(searchProvider),

            // Sub-filters for selected tab
            if (searchProvider.hasSearched) _buildSubFilters(searchProvider),
          ],
        );
      },
    );
  }

  Widget _buildTabsContainer(SearchProvider searchProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 500;
        final horizontalMargin = isSmallScreen ? 12.0 : 16.0;
        final verticalMargin = isSmallScreen ? 8.0 : 12.0;

        return Container(
          margin: EdgeInsets.symmetric(
              horizontal: horizontalMargin, vertical: verticalMargin),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.textSecondary.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: searchProvider.tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tab = entry.value;
                  final isSelected = searchProvider.selectedTabIndex == index;
                  final tabBadge = searchProvider.tabBadges[tab];

                  return _buildTab(
                    tab: tab,
                    isSelected: isSelected,
                    onTap: () => _onTabTap(index, searchProvider),
                    searchProvider: searchProvider,
                    tabBadge: tabBadge,
                    screenWidth: constraints.maxWidth,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab({
    required SearchResultType tab,
    required bool isSelected,
    required VoidCallback onTap,
    required SearchProvider searchProvider,
    required TabBadgeInfo? tabBadge,
    double? screenWidth,
  }) {
    final isSmallScreen = screenWidth != null && screenWidth < 500;
    final tabColor = _getTabColor(tab);
    final displayName = searchProvider.getTabDisplayName(tab);
    final icon = searchProvider.getTabIcon(tab);
    final resultCount = tabBadge?.resultCount ?? 0;

    return AnimatedBuilder(
      animation: _tabSwitchAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 8 : 12,
              horizontal: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [tabColor, tabColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: tabColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        icon,
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),

                    // Trending indicator
                    if (tabBadge?.hasTrending == true)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.veryActiveGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                    // Count badge
                    if (resultCount > 0)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: tabColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatCount(resultCount),
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // Tab name
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isSmallScreen ? 60 : 80,
                      minWidth: 40,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        displayName,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 11,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color:
                              isSelected ? Colors.white : AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubFilters(SearchProvider searchProvider) {
    final currentTab = searchProvider.currentTab;
    final subFilters = _getSubFiltersForTab(currentTab);

    if (subFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final subFilter = subFilters[index];
          final isSelected = searchProvider.filter.subFilter == subFilter.type;

          return _buildSubFilterChip(
            label: subFilter.label,
            isSelected: isSelected,
            onTap: () {
              // Update filter with sub-filter
              searchProvider.updateFilter(
                searchProvider.filter.copyWith(subFilter: subFilter.type),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 20,
      intensity: isSelected ? GlassIntensity.strong : GlassIntensity.subtle,
      elevation: isSelected ? GlassElevation.medium : GlassElevation.low,
      customGradient: isSelected
          ? const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            )
          : null,
      hasRippleEffect: true,
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  Color _getTabColor(SearchResultType tab) {
    switch (tab) {
      case SearchResultType.all:
        return AppColors.primary;
      case SearchResultType.people:
        return AppColors.secondary;
      case SearchResultType.topics:
        return AppColors.accent;
      case SearchResultType.posts:
        return AppColors.info;
      case SearchResultType.communities:
        return AppColors.success;
      case SearchResultType.trending:
        return AppColors.veryActiveGreen;
    }
  }

  String _formatCount(int count) {
    if (count > 999) {
      return '${(count / 1000).toStringAsFixed(0)}K';
    }
    if (count > 99) {
      return '99+';
    }
    return count.toString();
  }

  List<SubFilterOption> _getSubFiltersForTab(SearchResultType tab) {
    switch (tab) {
      case SearchResultType.people:
        return [
          SubFilterOption(SubFilterType.nearby, 'Nearby'),
          SubFilterOption(SubFilterType.following, 'Following'),
          SubFilterOption(SubFilterType.openToMingle, 'Open to Mingle'),
        ];

      case SearchResultType.topics:
        return [
          SubFilterOption(SubFilterType.topicsTrending, 'Trending'),
          SubFilterOption(SubFilterType.topicsFollowing, 'Following'),
          SubFilterOption(SubFilterType.topicsRecommended, 'Recommended'),
        ];

      case SearchResultType.posts:
        return [
          SubFilterOption(SubFilterType.latest, 'Latest'),
          SubFilterOption(SubFilterType.popular, 'Popular'),
          SubFilterOption(SubFilterType.mediaOnly, 'Media Only'),
        ];

      case SearchResultType.communities:
        return [
          SubFilterOption(SubFilterType.joined, 'Joined'),
          SubFilterOption(SubFilterType.recommended, 'Recommended'),
          SubFilterOption(SubFilterType.local, 'Local'),
        ];

      default:
        return [];
    }
  }
}

class SubFilterOption {
  final SubFilterType type;
  final String label;

  SubFilterOption(this.type, this.label);
}

// Widget to support swipe navigation between tabs
class SwipeableTabView extends StatefulWidget {
  final List<Widget> children;
  final int initialIndex;
  final Function(int) onPageChanged;

  const SwipeableTabView({
    super.key,
    required this.children,
    required this.initialIndex,
    required this.onPageChanged,
  });

  @override
  State<SwipeableTabView> createState() => _SwipeableTabViewState();
}

class _SwipeableTabViewState extends State<SwipeableTabView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        HapticFeedback.lightImpact();
        widget.onPageChanged(index);
      },
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return widget.children[index];
      },
    );
  }
}
