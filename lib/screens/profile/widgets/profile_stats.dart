import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';

class ProfileStats extends StatelessWidget {
  final UserStats stats;

  const ProfileStats({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.photo_library,
                  label: 'Posts',
                  value: stats.totalPosts.toString(),
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.people,
                  label: 'Followers',
                  value: _formatNumber(stats.followers),
                  color: AppColors.secondary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.person_add,
                  label: 'Following',
                  value: _formatNumber(stats.following),
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.visibility,
                  label: 'Views',
                  value: _formatNumber(stats.totalViews),
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 26,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
