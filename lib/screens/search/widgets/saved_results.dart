import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';

class SavedResults extends StatelessWidget {
  const SavedResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final savedResults = searchProvider.savedResults;

        if (savedResults.isEmpty) {
          return _buildEmptyState();
        }

        return CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(savedResults.length),
            ),

            // Saved results list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final result = savedResults[index];
                  return _buildSavedResultCard(result, searchProvider);
                },
                childCount: savedResults.length,
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Saved Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookmark interesting search results to find them here later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                // Navigate back to search
              },
              child: Text(
                'Start Searching',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.bookmark,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Saved Results ($count)',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedResultCard(SearchResult result, SearchProvider searchProvider) {
    final typeColor = _getContentTypeColor(result.type);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getContentTypeIcon(result.type),
                color: typeColor,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _getResultTitle(result),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Subtitle/Description
                  Text(
                    _getResultSubtitle(result),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getContentTypeName(result.type),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: typeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Actions
            Column(
              children: [
                // Remove bookmark
                GestureDetector(
                  onTap: () => searchProvider.toggleBookmark(result.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.bookmark_remove,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Share
                GestureDetector(
                  onTap: () => _shareResult(result),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.share,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getResultTitle(SearchResult result) {
    switch (result.type) {
      case SearchResultType.people:
        return result.user?.name ?? 'Unknown User';
      case SearchResultType.topics:
        return result.topic?.name ?? 'Unknown Topic';
      case SearchResultType.posts:
        return result.post?.content ?? result.video?.title ?? 'Unknown Post';
      case SearchResultType.communities:
        return result.community?.name ?? 'Unknown Community';
      default:
        return 'Unknown Result';
    }
  }

  String _getResultSubtitle(SearchResult result) {
    switch (result.type) {
      case SearchResultType.people:
        return result.user?.bio ?? 'No bio available';
      case SearchResultType.topics:
        return result.topic?.description ?? 'No description';
      case SearchResultType.posts:
        return result.post?.userName ?? result.video?.creator.name ?? 'Unknown author';
      case SearchResultType.communities:
        return '${result.community?.memberCount ?? 0} members';
      default:
        return '';
    }
  }

  Color _getContentTypeColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.people:
        return AppColors.secondary;
      case SearchResultType.topics:
        return AppColors.accent;
      case SearchResultType.posts:
        return AppColors.info;
      case SearchResultType.communities:
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _getContentTypeIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.people:
        return Icons.person;
      case SearchResultType.topics:
        return Icons.tag;
      case SearchResultType.posts:
        return Icons.article;
      case SearchResultType.communities:
        return Icons.groups;
      default:
        return Icons.search;
    }
  }

  String _getContentTypeName(SearchResultType type) {
    switch (type) {
      case SearchResultType.people:
        return 'Person';
      case SearchResultType.topics:
        return 'Topic';
      case SearchResultType.posts:
        return 'Post';
      case SearchResultType.communities:
        return 'Community';
      default:
        return 'Result';
    }
  }

  void _shareResult(SearchResult result) {
    // Implement sharing functionality
    // Could integrate with Flutter's share plugin
  }
}