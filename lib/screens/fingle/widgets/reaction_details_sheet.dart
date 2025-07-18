import 'package:flutter/material.dart';
import '../../../models/reaction_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../user_profile/user_profile_screen.dart';

class ReactionDetailsSheet extends StatefulWidget {
  final ReactionSummary reactionSummary;
  final VoidCallback onClose;

  const ReactionDetailsSheet({
    super.key,
    required this.reactionSummary,
    required this.onClose,
  });

  @override
  State<ReactionDetailsSheet> createState() => _ReactionDetailsSheetState();
}

class _ReactionDetailsSheetState extends State<ReactionDetailsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ReactionType? _selectedReactionType;
  
  @override
  void initState() {
    super.initState();
    
    final reactionTypes = widget.reactionSummary.counts.keys.toList();
    _tabController = TabController(
      length: reactionTypes.length + 1,
      vsync: this,
    );
    
    if (reactionTypes.isNotEmpty) {
      _selectedReactionType = widget.reactionSummary.topReactionTypes.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reactionTypes = widget.reactionSummary.counts.keys.toList()
      ..sort((a, b) => widget.reactionSummary.getCount(b)
          .compareTo(widget.reactionSummary.getCount(a)));

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          _buildTabs(reactionTypes),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllReactionsView(),
                ...reactionTypes.map((type) => _buildReactionTypeView(type)),
              ],
            ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatCount(widget.reactionSummary.totalCount),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(List<ReactionType> reactionTypes) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: [
          _buildTab(null, widget.reactionSummary.totalCount),
          ...reactionTypes.map((type) => _buildTab(
            type,
            widget.reactionSummary.getCount(type),
          )),
        ],
      ),
    );
  }

  Widget _buildTab(ReactionType? type, int count) {
    final isAll = type == null;
    final label = isAll ? 'All' : ReactionData.getReactionData(type!).label;
    final emoji = isAll ? '💕' : ReactionData.getReactionData(type!).emoji;

    return Tab(
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatCount(count),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllReactionsView() {
    final allReactions = widget.reactionSummary.reactions.values
        .expand((list) => list)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (allReactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: allReactions.length,
      itemBuilder: (context, index) {
        final reaction = allReactions[index];
        return _buildReactionItem(reaction);
      },
    );
  }

  Widget _buildReactionTypeView(ReactionType type) {
    final reactions = widget.reactionSummary.getReactions(type)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (reactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: reactions.length,
      itemBuilder: (context, index) {
        final reaction = reactions[index];
        return _buildReactionItem(reaction);
      },
    );
  }

  Widget _buildReactionItem(Reaction reaction) {
    final reactionData = ReactionData.getReactionData(reaction.type);
    
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(reaction.userAvatar),
            backgroundColor: AppColors.primary.withOpacity(0.2),
            onBackgroundImageError: (_, __) {},
            child: const Icon(
              Icons.person,
              color: Colors.white54,
              size: 24,
            ),
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: reactionData.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Text(
                reactionData.emoji,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        reaction.userName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        _formatTimeAgo(reaction.createdAt),
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
      trailing: OutlinedButton(
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
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(
              userId: reaction.userId,
              userName: reaction.userName,
              userAvatar: reaction.userAvatar,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            color: Colors.white.withOpacity(0.3),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No reactions yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
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