import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';

class SearchHistory extends StatelessWidget {
  const SearchHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final history = searchProvider.searchHistory;
        
        if (history.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.textSecondary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showClearHistoryDialog(context, searchProvider),
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // History items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: history.take(5).length, // Show max 5 recent searches
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: AppColors.textSecondary.withOpacity(0.1),
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  final query = history[index];
                  return ListTile(
                    leading: Icon(
                      Icons.history,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    title: Text(
                      query,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () => searchProvider.removeFromHistory(query),
                      child: Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                    onTap: () => searchProvider.performSearch(query: query),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearHistoryDialog(BuildContext context, SearchProvider searchProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Clear Search History',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to clear all search history? This action cannot be undone.',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              searchProvider.clearHistory();
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}