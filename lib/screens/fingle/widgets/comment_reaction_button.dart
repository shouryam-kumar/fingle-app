import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/reaction_models.dart';
import '../../../core/theme/app_colors.dart';
import 'reaction_picker.dart';

class CommentReactionButton extends StatefulWidget {
  final ReactionSummary reactionSummary;
  final Function(ReactionType) onReactionSelected;
  final VoidCallback? onResetTimeout;

  const CommentReactionButton({
    super.key,
    required this.reactionSummary,
    required this.onReactionSelected,
    this.onResetTimeout,
  });

  @override
  State<CommentReactionButton> createState() => _CommentReactionButtonState();
}

class _CommentReactionButtonState extends State<CommentReactionButton>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late AnimationController _pulseController;
  late Animation<double> _buttonAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isReactionPickerVisible = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _pulseController.dispose();
    _hideReactionPicker();
    super.dispose();
  }

  void _showReactionPicker() {
    if (_overlayEntry != null) return;
    
    widget.onResetTimeout?.call();
    
    setState(() {
      _isReactionPickerVisible = true;
    });

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          onTap: _hideReactionPicker,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Positioned(
                  left: position.dx,
                  top: position.dy - 60,
                  child: ReactionPicker(
                    isVisible: _isReactionPickerVisible,
                    currentReaction: widget.reactionSummary.userReaction,
                    onReactionSelected: _handleReactionSelection,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideReactionPicker() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    
    setState(() {
      _isReactionPickerVisible = false;
    });
  }

  void _handleReactionSelection(ReactionType type) {
    widget.onResetTimeout?.call();
    
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
    
    HapticFeedback.lightImpact();
    widget.onReactionSelected(type);
    _hideReactionPicker();
  }

  void _handleQuickReaction() {
    widget.onResetTimeout?.call();
    
    if (widget.reactionSummary.userReaction != null) {
      widget.onReactionSelected(widget.reactionSummary.userReaction!);
    } else {
      widget.onReactionSelected(ReactionType.like);
    }
    
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
    
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleQuickReaction,
      onLongPress: _showReactionPicker,
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) => _buttonController.reverse(),
      onTapCancel: () => _buttonController.reverse(),
      child: AnimatedBuilder(
        animation: _buttonAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: _buildReactionIcon(),
                      );
                    },
                  ),
                  if (widget.reactionSummary.hasReactions) ...[
                    const SizedBox(height: 1),
                    _buildReactionCount(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReactionIcon() {
    if (widget.reactionSummary.userReaction != null) {
      final reactionData = ReactionData.getReactionData(widget.reactionSummary.userReaction!);
      return Text(
        reactionData.emoji,
        style: const TextStyle(fontSize: 16),
      );
    } else {
      return Icon(
        Icons.favorite_border,
        color: Colors.white.withOpacity(0.6),
        size: 16,
      );
    }
  }

  Widget _buildReactionCount() {
    if (widget.reactionSummary.hasReactions) {
      return Text(
        _formatCount(widget.reactionSummary.totalCount),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}