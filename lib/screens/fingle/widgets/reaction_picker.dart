import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../models/reaction_models.dart';
import '../../../core/theme/app_colors.dart';

class ReactionPicker extends StatefulWidget {
  final Function(ReactionType) onReactionSelected;
  final ReactionType? currentReaction;
  final bool isVisible;
  final VoidCallback? onDismiss;

  const ReactionPicker({
    super.key,
    required this.onReactionSelected,
    this.currentReaction,
    required this.isVisible,
    this.onDismiss,
  });

  @override
  State<ReactionPicker> createState() => _ReactionPickerState();
}

class _ReactionPickerState extends State<ReactionPicker>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _backgroundController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _backgroundOpacityAnimation;

  final List<AnimationController> _reactionControllers = [];
  final List<Animation<double>> _reactionAnimations = [];

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _backgroundOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeOut,
    ));

    // Create individual animation controllers for each reaction
    for (int i = 0; i < ReactionData.reactions.length; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 150 + (i * 50)),
        vsync: this,
      );
      
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));

      _reactionControllers.add(controller);
      _reactionAnimations.add(animation);
    }

    // If the widget is initially visible, start the animations
    if (widget.isVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPicker();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _backgroundController.dispose();
    for (final controller in _reactionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(ReactionPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible && !oldWidget.isVisible) {
      _showPicker();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _hidePicker();
    }
  }

  void _showPicker() {
    _backgroundController.forward();
    _controller.forward();
    
    // Staggered animation for reactions
    for (int i = 0; i < _reactionControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) {
          _reactionControllers[i].forward();
        }
      });
    }
  }

  void _hidePicker() {
    _backgroundController.reverse();
    _controller.reverse();
    
    for (final controller in _reactionControllers) {
      controller.reverse();
    }
  }

  void _handleReactionTap(ReactionType type) {
    HapticFeedback.lightImpact();
    widget.onReactionSelected(type);
    _hidePicker();
  }

  void _handleDismiss() {
    widget.onDismiss?.call();
    _hidePicker();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: widget.isVisible ? _buildReactionContainer() : const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReactionContainer() {
    final container = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ReactionData.reactions.values
            .toList()
            .asMap()
            .entries
            .map((entry) => _buildReactionButton(entry.value, entry.key))
            .toList(),
      ),
    );

    return container;
  }

  Widget _buildReactionButton(ReactionData reactionData, int index) {
    final isSelected = widget.currentReaction == reactionData.type;
    
    return AnimatedBuilder(
      animation: _reactionAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _reactionAnimations[index].value,
          child: GestureDetector(
            onTap: () => _handleReactionTap(reactionData.type),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? reactionData.color.withOpacity(0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: reactionData.color.withOpacity(0.5),
                        width: 2,
                      )
                    : null,
              ),
              child: _ReactionEmoji(
                emoji: reactionData.emoji,
                color: reactionData.color,
                size: 28,
                isSelected: isSelected,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReactionEmoji extends StatefulWidget {
  final String emoji;
  final Color color;
  final double size;
  final bool isSelected;

  const _ReactionEmoji({
    required this.emoji,
    required this.color,
    required this.size,
    required this.isSelected,
  });

  @override
  State<_ReactionEmoji> createState() => _ReactionEmojiState();
}

class _ReactionEmojiState extends State<_ReactionEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ReactionEmoji oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isSelected && !oldWidget.isSelected) {
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                widget.emoji,
                style: TextStyle(
                  fontSize: widget.size * 0.8,
                  height: 1.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}