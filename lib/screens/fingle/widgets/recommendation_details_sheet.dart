import 'package:flutter/material.dart';
import '../../../models/reaction_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../user_profile/user_profile_screen.dart';

class RecommendationDetailsSheet extends StatelessWidget {
  final List<Recommendation> recommendations;
  final VoidCallback onClose;

  const RecommendationDetailsSheet({
    super.key,
    required this.recommendations,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final sortedRecommendations = List<Recommendation>.from(recommendations)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          Expanded(
            child: sortedRecommendations.isEmpty
                ? _buildEmptyState()
                : _buildRecommendationsList(sortedRecommendations),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recommendations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${recommendations.length} ${recommendations.length == 1 ? 'person' : 'people'} recommended this',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(List<Recommendation> recommendations) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: recommendations.length,
      separatorBuilder: (context, index) => Container(
        height: 1,
        color: Colors.white.withOpacity(0.1),
        margin: const EdgeInsets.symmetric(horizontal: 16),
      ),
      itemBuilder: (context, index) {
        final recommendation = recommendations[index];
        return _buildRecommendationItem(context, recommendation);
      },
    );
  }

  Widget _buildRecommendationItem(BuildContext context, Recommendation recommendation) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(
                        userId: recommendation.userId,
                        userName: recommendation.userName,
                        userAvatar: recommendation.userAvatar,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(recommendation.userAvatar),
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  onBackgroundImageError: (_, __) {},
                  child: const Icon(
                    Icons.person,
                    color: Colors.white54,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => UserProfileScreen(
                                    userId: recommendation.userId,
                                    userName: recommendation.userName,
                                    userAvatar: recommendation.userAvatar,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              recommendation.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          _formatTimeAgo(recommendation.createdAt),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.repeat,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Recommended this workout',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    if (recommendation.message != null && recommendation.message!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          recommendation.message!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Follow feature coming soon!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text(
                  'Follow',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.repeat_outlined,
            color: Colors.white.withOpacity(0.3),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No recommendations yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to recommend this workout!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    }
  }
}