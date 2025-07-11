import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';

class PostInteractions extends StatefulWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostInteractions({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  State<PostInteractions> createState() => _PostInteractionsState();
}

class _PostInteractionsState extends State<PostInteractions>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _onLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
    
    widget.onLike();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Like button
          GestureDetector(
            onTap: _onLike,
            child: AnimatedBuilder(
              animation: _likeAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _likeAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.white,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Comment button
          GestureDetector(
            onTap: widget.onComment,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Share button
          GestureDetector(
            onTap: widget.onShare,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Bookmark button
          GestureDetector(
            onTap: () {
              // Bookmark functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post saved!'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.bookmark_border,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}