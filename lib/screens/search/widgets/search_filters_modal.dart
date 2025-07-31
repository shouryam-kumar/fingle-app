import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';
import '../../../widgets/common/glass_container.dart';

class SearchFiltersModal extends StatefulWidget {
  final SearchFilter currentFilter;
  final Function(SearchFilter) onFilterApplied;

  const SearchFiltersModal({
    super.key,
    required this.currentFilter,
    required this.onFilterApplied,
  });

  @override
  State<SearchFiltersModal> createState() => _SearchFiltersModalState();
}

class _SearchFiltersModalState extends State<SearchFiltersModal>
    with TickerProviderStateMixin {
  late AnimationController _modalController;
  late AnimationController _backgroundController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;

  final List<AnimationController> _sectionControllers = [];
  final List<Animation<double>> _sectionAnimations = [];

  late SearchFilter _workingFilter;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _workingFilter = widget.currentFilter;

    _modalController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _modalController, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _modalController, curve: Curves.easeOutQuart),
    );

    _blurAnimation = Tween<double>(begin: 0.0, end: 50.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeOutQuart),
    );

    // Create section animations (staggered effect)
    final sections = ['contentType', 'activityLevel', 'sortOptions', 'specialFilters'];
    for (int i = 0; i < sections.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _sectionControllers.add(controller);

      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
      _sectionAnimations.add(animation);
    }

    _startEntranceAnimation();
  }

  void _startEntranceAnimation() async {
    _backgroundController.forward();
    await Future.delayed(const Duration(milliseconds: 50));
    _modalController.forward();

    // Staggered section animations
    for (int i = 0; i < _sectionControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) _sectionControllers[i].forward();
    }
  }

  void _startExitAnimation() async {
    if (_isExiting) return;
    _isExiting = true;

    // Fast exit sequence
    for (int i = _sectionControllers.length - 1; i >= 0; i--) {
      _sectionControllers[i].reverse();
      await Future.delayed(const Duration(milliseconds: 15));
    }

    _modalController.reverse();
    await Future.delayed(const Duration(milliseconds: 50));
    _backgroundController.reverse();

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _modalController.dispose();
    _backgroundController.dispose();
    for (final controller in _sectionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return WillPopScope(
      onWillPop: () async {
        _startExitAnimation();
        return false;
      },
      child: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                // Backdrop with blur
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _startExitAnimation,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _blurAnimation.value,
                        sigmaY: _blurAnimation.value,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.7 * _opacityAnimation.value),
                              Colors.black.withOpacity(0.6 * _opacityAnimation.value),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Modal content
                Center(
                  child: AnimatedBuilder(
                    animation: _modalController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _opacityAnimation.value,
                          child: GlassContainer(
                            width: isSmallScreen ? screenSize.width * 0.95 : screenSize.width * 0.85,
                            height: screenSize.height * 0.7,
                            intensity: GlassIntensity.medium,
                            elevation: GlassElevation.high,
                            borderRadius: 24,
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                _buildHeader(),
                                Expanded(child: _buildContent()),
                                _buildFooter(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tune,
            size: 24,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Filter Options',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: _startExitAnimation,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.glassBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.close,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedSection(0, _buildContentTypeFilter()),
          const SizedBox(height: 24),
          _buildAnimatedSection(1, _buildActivityLevelFilter()),
          const SizedBox(height: 24),
          _buildAnimatedSection(2, _buildSortOptions()),
          const SizedBox(height: 24),
          _buildAnimatedSection(3, _buildSpecialFilters()),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    if (index >= _sectionAnimations.length) return child;

    return AnimatedBuilder(
      animation: _sectionAnimations[index],
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _sectionAnimations[index].value)),
          child: Opacity(
            opacity: _sectionAnimations[index].value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _clearAllFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.glassBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 1,
                  ),
                ),
                child: Text(
                  'Clear All',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _applyFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Apply Filters',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Filter section builders (reusing logic from advanced_filters.dart)
  Widget _buildContentTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content Type',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SearchResultType.values
              .where((type) => type != SearchResultType.all)
              .map((type) => _buildFilterChip(
                    label: _getTypeDisplayName(type),
                    isSelected: _workingFilter.type == type,
                    onTap: () => _updateContentTypeFilter(type),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActivityLevelFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Level',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ActivityLevel.values
              .map((level) => _buildFilterChip(
                    label: _getActivityLevelName(level),
                    isSelected: _workingFilter.activityLevel == level,
                    onTap: () => _updateActivityLevelFilter(level),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SortType.values
              .map((sort) => _buildFilterChip(
                    label: _getSortTypeName(sort),
                    isSelected: _workingFilter.sortType == sort,
                    onTap: () => _updateSortFilter(sort),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSpecialFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Filters',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildToggleFilter(
              label: 'Open to Mingle Only',
              value: _workingFilter.openToMingleOnly,
              onChanged: (value) => _updateOpenToMingleFilter(value),
            ),
            _buildToggleFilter(
              label: 'Media Content Only',
              value: _workingFilter.showMediaOnly,
              onChanged: (value) => _updateMediaOnlyFilter(value),
            ),
            _buildToggleFilter(
              label: 'Nearby Results',
              value: _workingFilter.nearbyOnly,
              onChanged: (value) => _updateNearbyFilter(value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.glassBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleFilter({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  // Filter update methods
  void _updateContentTypeFilter(SearchResultType? type) {
    setState(() {
      _workingFilter = _workingFilter.copyWith(type: type);
    });
  }

  void _updateActivityLevelFilter(ActivityLevel? level) {
    setState(() {
      _workingFilter = _workingFilter.copyWith(activityLevel: level);
    });
  }

  void _updateSortFilter(SortType sortType) {
    setState(() {
      _workingFilter = _workingFilter.copyWith(sortType: sortType);
    });
  }

  void _updateOpenToMingleFilter(bool value) {
    setState(() {
      _workingFilter = _workingFilter.copyWith(openToMingleOnly: value);
    });
  }

  void _updateMediaOnlyFilter(bool value) {
    setState(() {
      _workingFilter = _workingFilter.copyWith(showMediaOnly: value);
    });
  }

  void _updateNearbyFilter(bool value) {
    setState(() {
      _workingFilter = _workingFilter.copyWith(nearbyOnly: value);
    });
  }

  void _clearAllFilters() {
    setState(() {
      _workingFilter = SearchFilter();
    });
  }

  void _applyFilters() {
    widget.onFilterApplied(_workingFilter);
    _startExitAnimation();
  }

  // Helper methods for display names
  String _getTypeDisplayName(SearchResultType type) {
    switch (type) {
      case SearchResultType.people:
        return 'People';
      case SearchResultType.topics:
        return 'Topics';
      case SearchResultType.posts:
        return 'Posts';
      case SearchResultType.communities:
        return 'Communities';
      case SearchResultType.trending:
        return 'Trending';
      case SearchResultType.saved:
        return 'Saved';
      case SearchResultType.all:
        return 'All';
    }
  }

  String _getActivityLevelName(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.veryActive:
        return 'Very Active';
      case ActivityLevel.active:
        return 'Active';
      case ActivityLevel.moderate:
        return 'Moderate';
    }
  }

  String _getSortTypeName(SortType sort) {
    switch (sort) {
      case SortType.relevance:
        return 'Relevance';
      case SortType.recent:
        return 'Recent';
      case SortType.popular:
        return 'Popular';
      case SortType.trending:
        return 'Trending';
      case SortType.alphabetical:
        return 'Alphabetical';
    }
  }
}