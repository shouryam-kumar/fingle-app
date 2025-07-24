import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../models/reaction_models.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:async';

enum ReactionPickerLayout { vertical, horizontal }

class EnhancedReactionPicker extends StatefulWidget {
  final Function(ReactionType) onReactionSelected;
  final ReactionType? currentReaction;
  final bool isVisible;
  final VoidCallback? onDismiss;
  final ReactionPickerLayout layout;
  final Function(bool)? onPickerHover;

  const EnhancedReactionPicker({
    super.key,
    required this.onReactionSelected,
    this.currentReaction,
    required this.isVisible,
    this.onDismiss,
    this.layout = ReactionPickerLayout.vertical,
    this.onPickerHover,
  });

  @override
  State<EnhancedReactionPicker> createState() => _EnhancedReactionPickerState();
}

class _EnhancedReactionPickerState extends State<EnhancedReactionPicker>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _backgroundController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _backgroundOpacityAnimation;

  final List<AnimationController> _reactionControllers = [];
  final List<Animation<double>> _reactionAnimations = [];
  final List<bool> _isHovering = [];
  Timer? _hideTimer;
  bool _isPickerHovered = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
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
        duration: Duration(milliseconds: 200 + (i * 40)),
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
      _isHovering.add(false);
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
    _hideTimer?.cancel();
    for (final controller in _reactionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(EnhancedReactionPicker oldWidget) {
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
      Future.delayed(Duration(milliseconds: i * 40), () {
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

  void _handlePickerHover(bool isHovering) {
    if (kIsWeb) {
      _isPickerHovered = isHovering;

      // Notify parent about hover state change
      widget.onPickerHover?.call(isHovering);

      if (!isHovering) {
        _hideTimer?.cancel();
        _hideTimer = Timer(const Duration(milliseconds: 200), () {
          if (!_isPickerHovered && !_isHovering.any((h) => h)) {
            widget.onDismiss?.call();
          }
        });
      } else {
        _hideTimer?.cancel();
      }
    }
  }

  void _handleReactionHover(int index, bool isHovering) {
    if (kIsWeb) {
      setState(() {
        _isHovering[index] = isHovering;
      });

      // Notify parent about overall hover state
      bool anyHovered = _isPickerHovered || _isHovering.any((h) => h);
      widget.onPickerHover?.call(anyHovered);

      if (isHovering) {
        _hideTimer?.cancel();
      } else {
        _hideTimer?.cancel();
        _hideTimer = Timer(const Duration(milliseconds: 200), () {
          if (!_isPickerHovered && !_isHovering.any((h) => h)) {
            widget.onDismiss?.call();
          }
        });
      }
    }
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
                child: widget.isVisible
                    ? _buildReactionContainer()
                    : const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReactionContainer() {
    final isVertical = widget.layout == ReactionPickerLayout.vertical;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main picker container
        MouseRegion(
          onEnter: (_) => _handlePickerHover(true),
          onExit: (_) => _handlePickerHover(false),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isVertical
                  ? (isSmallScreen ? 6 : 8)
                  : (isSmallScreen
                      ? 6
                      : 8), // Reduced horizontal padding for horizontal layout
              vertical: isVertical
                  ? (isSmallScreen ? 8 : 12)
                  : (isSmallScreen
                      ? 4
                      : 6), // Reduced vertical padding for horizontal layout
            ),
            decoration: BoxDecoration(
              color: Colors.grey[900]?.withOpacity(0.95),
              borderRadius: BorderRadius.circular(
                  isVertical ? 20 : 15), // Smaller radius for horizontal
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child:
                isVertical ? _buildVerticalLayout() : _buildHorizontalLayout(),
          ),
        ),
        // Hover bridge - invisible area connecting picker to button
        if (isVertical)
          Positioned(
            right: -8, // Extend to the right to bridge the gap
            top: 0,
            bottom: 0,
            child: MouseRegion(
              onEnter: (_) => _handlePickerHover(true),
              onExit: (_) => _handlePickerHover(false),
              child: Container(
                width: 12, // Bridge width (4px gap + 8px buffer)
                color: Colors.transparent,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: ReactionData.reactions.values
          .toList()
          .asMap()
          .entries
          .map((entry) => _buildReactionButton(entry.value, entry.key))
          .toList(),
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ReactionData.reactions.values
          .toList()
          .asMap()
          .entries
          .map((entry) => _buildReactionButton(entry.value, entry.key))
          .toList(),
    );
  }

  Widget _buildReactionButton(ReactionData reactionData, int index) {
    final isSelected = widget.currentReaction == reactionData.type;
    final isHovered = _isHovering[index];
    final isVertical = widget.layout == ReactionPickerLayout.vertical;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // Smaller emoji sizes for horizontal layout (home feed)
    final emojiSize = isVertical
        ? (isSmallScreen ? 24.0 : 28.0)
        : (isSmallScreen ? 18.0 : 20.0);

    return AnimatedBuilder(
      animation: _reactionAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _reactionAnimations[index].value,
          child: MouseRegion(
            onEnter: (_) => _handleReactionHover(index, true),
            onExit: (_) => _handleReactionHover(index, false),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleReactionTap(reactionData.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: EdgeInsets.symmetric(
                  vertical: isVertical ? (isSmallScreen ? 3 : 4) : 0,
                  horizontal: isVertical
                      ? 0
                      : (isSmallScreen
                          ? 2
                          : 3), // Tighter spacing for horizontal
                ),
                padding: EdgeInsets.all(isVertical
                    ? (isSmallScreen ? 6 : 8)
                    : (isSmallScreen
                        ? 4
                        : 6)), // Smaller padding for horizontal
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            reactionData.color.withOpacity(0.3),
                            reactionData.color.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected
                      ? null
                      : isHovered
                          ? Colors.white.withOpacity(0.08)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? reactionData.color.withOpacity(0.6)
                        : isHovered
                            ? Colors.white.withOpacity(0.3)
                            : Colors.white.withOpacity(0.15),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                    if (isSelected)
                      BoxShadow(
                        color: reactionData.color.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    if (isHovered && !isSelected)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: _ReactionEmoji(
                  emoji: reactionData.emoji,
                  color: reactionData.color,
                  size: emojiSize, // Use calculated size based on layout
                  isSelected: isSelected,
                  isHovered: isHovered,
                ),
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
  final bool isHovered;

  const _ReactionEmoji({
    required this.emoji,
    required this.color,
    required this.size,
    required this.isSelected,
    required this.isHovered,
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

    if ((widget.isSelected && !oldWidget.isSelected) ||
        (widget.isHovered && !oldWidget.isHovered)) {
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
              boxShadow: widget.isSelected || widget.isHovered
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
