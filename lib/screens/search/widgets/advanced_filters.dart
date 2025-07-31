import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';
import 'search_filters_modal.dart';

class AdvancedFilters extends StatefulWidget {
  const AdvancedFilters({super.key});

  @override
  State<AdvancedFilters> createState() => _AdvancedFiltersState();
}

class _AdvancedFiltersState extends State<AdvancedFilters> {

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return _buildFilterToggle(context, searchProvider);
      },
    );
  }

  Widget _buildFilterToggle(BuildContext context, SearchProvider searchProvider) {
    final hasActiveFilters = _hasActiveFilters(searchProvider.filter);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showFiltersModal(context, searchProvider),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: hasActiveFilters 
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasActiveFilters 
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tune,
                          color: hasActiveFilters 
                              ? AppColors.primary 
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: hasActiveFilters 
                                ? AppColors.primary 
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (hasActiveFilters) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Icon(
                      Icons.open_in_new,
                      color: hasActiveFilters 
                          ? AppColors.primary 
                          : AppColors.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasActiveFilters) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _clearAllFilters(searchProvider),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.clear,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFiltersModal(BuildContext context, SearchProvider searchProvider) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (context) => SearchFiltersModal(
        currentFilter: searchProvider.filter,
        onFilterApplied: (newFilter) {
          searchProvider.updateFilter(newFilter);
          if (searchProvider.hasSearched) {
            searchProvider.performSearch();
          }
        },
      ),
    );
  }

  bool _hasActiveFilters(SearchFilter filter) {
    return filter.type != null ||
           filter.category != null ||
           filter.tags.isNotEmpty ||
           filter.difficulty != null ||
           filter.openToMingleOnly ||
           filter.activityLevel != null ||
           filter.subFilter != null ||
           filter.sortType != SortType.relevance ||
           filter.showMediaOnly ||
           filter.nearbyOnly;
  }

  void _clearAllFilters(SearchProvider searchProvider) {
    searchProvider.updateFilter(SearchFilter());
    if (searchProvider.hasSearched) {
      searchProvider.performSearch();
    }
  }
}