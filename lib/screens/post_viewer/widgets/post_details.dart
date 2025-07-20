import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';

class PostDetails extends StatelessWidget {
  final Post post;
  final User user;

  const PostDetails({
    super.key,
    required this.post,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Likes count
          Text(
            '${post.likes} likes',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          // Post title and user
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: user.name.toLowerCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(
                  text: ' ',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: post.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Tags
          if (post.tags.isNotEmpty) ...[
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: post.tags.take(3).map((tag) {
                return Text(
                  '#$tag',
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],

          // View all comments
          GestureDetector(
            onTap: () {
              // Show comments
            },
            child: Text(
              'View all 127 comments',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Time ago
          Text(
            _getTimeAgo(post.createdAt),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
