import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';
import '../../../widgets/common/glass_container.dart';

class SearchTabs extends StatefulWidget {
  const SearchTabs({Key? key}) : super(key: key);

  @override
  State<SearchTabs> createState() => _SearchTabsState();
}

class _SearchTabsState extends State<SearchTabs> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    context.read<SearchProvider>().selectTab(index);
    _slideController.forward().then((_) => _slideController.reverse());
  }

  Color _getTabColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.people:
        return AppColors.primary;
      case SearchResultType.topics:
        return AppColors.secondary;
      case SearchResultType.posts:
        return AppColors.accent;
      case SearchResultType.communities:
        return AppColors.success;
    }
  }

  IconData _getTabIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.people:
        return Icons.people;
      case SearchResultType.topics:
        return Icons.topic;
      case SearchResultType.posts:
        return Icons.grid_view;
      case SearchResultType.communities:
        return Icons.groups;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.all(6),
            child: Row(
              children: searchProvider.tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tabType = entry.value;
                final isSelected = index == searchProvider.selectedTabIndex;
                final resultCount = searchProvider.getTabResultCount(tabType);

                return Expanded(
                  child: _buildTab(
                    tabType: tabType,
                    isSelected: isSelected,
                    resultCount: resultCount,
                    onTap: () => _onTabTap(index),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab({
    required SearchResultType tabType,
    required bool isSelected,
    required int resultCount,
    required VoidCallback onTap,
  }) {
    final tabColor = _getTabColor(tabType);
    final tabIcon = _getTabIcon(tabType);
    final displayName =
        context.read<SearchProvider>().getTabDisplayName(tabType);

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        tabColor.withOpacity(0.2),
                        tabColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(14),
              border: isSelected
                  ? Border.all(
                      color: tabColor.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: tabColor.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with animated scale
                Transform.scale(
                  scale: isSelected ? 1.0 + (0.1 * _slideAnimation.value) : 1.0,
                  child: Icon(
                    tabIcon,
                    size: 20,
                    color: isSelected
                        ? tabColor
                        : AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 4),

                // Tab label
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? tabColor : AppColors.textSecondary,
                  ),
                ),

                // Result count indicator
                if (resultCount > 0) ...[
                  const SizedBox(height: 2),
                  Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? tabColor
                          : AppColors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      resultCount > 99 ? '99+' : resultCount.toString(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
