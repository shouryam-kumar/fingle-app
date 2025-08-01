import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';
import '../../../widgets/common/glass_container.dart';

class SearchHeader extends StatefulWidget {
  const SearchHeader({Key? key}) : super(key: key);

  @override
  State<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOutSine,
    ));

    _floatingController.repeat(reverse: true);

    // Listen to search provider changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = context.read<SearchProvider>();
      _searchController.text = searchProvider.searchQuery;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    context.read<SearchProvider>().updateSearchQuery(value);
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      context.read<SearchProvider>().performSearch(query: value.trim());
      _searchFocusNode.unfocus();
    }
  }

  void _onSuggestionTap(SearchSuggestion suggestion) {
    _searchController.text = suggestion.text;
    context.read<SearchProvider>().selectSuggestion(suggestion);
    _searchFocusNode.unfocus();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchProvider>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.searchBackgroundGradient,
          ),
          child: Stack(
            children: [
              // Floating orbs background
              _buildFloatingOrbs(),

              // Main search header content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Search input
                      _buildSearchInput(searchProvider),

                      // Search suggestions
                      if (searchProvider.suggestions.isNotEmpty)
                        _buildSearchSuggestions(searchProvider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingOrbs() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return SizedBox(
          height: screenHeight * 0.18,
          child: Stack(
            children: [
              // Purple orb
              Positioned(
                left: -50 + (20 * _floatingAnimation.value),
                top: 20 + (10 * _floatingAnimation.value),
                child: Container(
                  width: screenWidth * 0.28,
                  height: screenWidth * 0.28,
                  decoration: BoxDecoration(
                    gradient: AppColors.searchOrbGradient1,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Pink orb
              Positioned(
                right: -60 + (15 * _floatingAnimation.value),
                top: 40 + (8 * _floatingAnimation.value),
                child: Container(
                  width: screenWidth * 0.24,
                  height: screenWidth * 0.24,
                  decoration: BoxDecoration(
                    gradient: AppColors.searchOrbGradient2,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Green orb
              Positioned(
                left: MediaQuery.of(context).size.width * 0.4,
                top: 10 + (12 * _floatingAnimation.value),
                child: Container(
                  width: screenWidth * 0.19,
                  height: screenWidth * 0.19,
                  decoration: BoxDecoration(
                    gradient: AppColors.searchOrbGradient3,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchInput(SearchProvider searchProvider) {
    return GlassContainer(
      borderRadius: 28,
      padding: EdgeInsets.zero,
      hasRippleEffect: false,
      child: Container(
        height: 56,
        child: Row(
          children: [
            // Search icon
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 12),
              child: Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),

            // Search input field
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmitted,
                decoration: const InputDecoration(
                  hintText: 'Search people, topics, posts...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Clear/Loading button
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: searchProvider.isSearching
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    )
                  : searchProvider.searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: _clearSearch,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : const SizedBox(width: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions(SearchProvider searchProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      constraints: const BoxConstraints(maxHeight: 240),
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: searchProvider.suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = searchProvider.suggestions[index];
            return _buildSuggestionItem(suggestion);
          },
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(SearchSuggestion suggestion) {
    IconData suggestionIcon;
    Color iconColor;

    switch (suggestion.type) {
      case SearchResultType.people:
        suggestionIcon = Icons.person;
        iconColor = AppColors.primary;
        break;
      case SearchResultType.topics:
        suggestionIcon = Icons.topic;
        iconColor = AppColors.secondary;
        break;
      case SearchResultType.posts:
        suggestionIcon = Icons.post_add;
        iconColor = AppColors.accent;
        break;
      case SearchResultType.communities:
        suggestionIcon = Icons.groups;
        iconColor = AppColors.success;
        break;
      case SearchResultType.all:
        suggestionIcon = Icons.search;
        iconColor = AppColors.primary;
        break;
      case SearchResultType.trending:
        suggestionIcon = Icons.trending_up;
        iconColor = AppColors.warning;
        break;
      case SearchResultType.saved:
        suggestionIcon = Icons.bookmark;
        iconColor = AppColors.info;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onSuggestionTap(suggestion),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  suggestionIcon,
                  size: 16,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion.text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.trending_up,
                size: 16,
                color: AppColors.textSecondary.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
