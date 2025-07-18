import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../models/reaction_models.dart';
import '../../../core/theme/app_colors.dart';
import 'reaction_picker.dart';
import 'dart:async';

class ReactionButton extends StatefulWidget {
  final ReactionSummary reactionSummary;
  final Function(ReactionType) onReactionSelected;
  final VoidCallback? onViewReactions;
  final VoidCallback? onResetTimeout;

  const ReactionButton({
    super.key,
    required this.reactionSummary,
    required this.onReactionSelected,
    this.onViewReactions,
    this.onResetTimeout,
  });

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late AnimationController _pulseController;
  late Animation<double> _buttonAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isReactionPickerVisible = false;
  OverlayEntry? _overlayEntry;
  Timer? _hoverTimer;
  Timer? _longPressTimer;
  Timer? _hideTimer;
  bool _isHovering = false;
  bool _isLongPressing = false;

  @override
  void initState() {
    super.initState();
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _pulseController.dispose();
    _hoverTimer?.cancel();
    _longPressTimer?.cancel();
    _hideTimer?.cancel();
    _hideReactionPicker();
    super.dispose();
  }

  void _showReactionPicker() {
    if (_isReactionPickerVisible) return;
    
    widget.onResetTimeout?.call();
    
    setState(() {
      _isReactionPickerVisible = true;
    });
  }

  void _hideReactionPicker() {
    if (!_isReactionPickerVisible) return;
    
    if (mounted) {
      setState(() {
        _isReactionPickerVisible = false;
      });
    }
  }

  void _handleReactionSelection(ReactionType type) {
    widget.onResetTimeout?.call();
    
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
    
    HapticFeedback.mediumImpact();
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

  void _startHoverTimer() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(const Duration(milliseconds: 500), () {
      if (_isHovering && !_isReactionPickerVisible) {
        _showReactionPicker();
      }
    });
  }

  void _startLongPressTimer() {
    _longPressTimer?.cancel();
    _longPressTimer = Timer(const Duration(milliseconds: 500), () {
      if (_isLongPressing && !_isReactionPickerVisible) {
        _showReactionPicker();
      }
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!kIsWeb) {
      _isLongPressing = true;
      _startLongPressTimer();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!kIsWeb) {
      _isLongPressing = false;
      bool wasActive = _longPressTimer?.isActive ?? false;
      _longPressTimer?.cancel();
      
      // If the timer was still active, this is a quick tap
      if (wasActive && !_isReactionPickerVisible) {
        _handleQuickReaction();
      }
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!kIsWeb) {
      _isLongPressing = false;
      _longPressTimer?.cancel();
    }
  }

  void _onHover(bool isHovering) {
    if (kIsWeb) {
      _isHovering = isHovering;
      if (isHovering) {
        _hideTimer?.cancel(); // Cancel any pending hide
        if (!_isReactionPickerVisible) {
          _startHoverTimer();
        }
      } else {
        _hoverTimer?.cancel();
        _hideTimer?.cancel();
        if (_isReactionPickerVisible) {
          _hideReactionPicker();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      padding: const EdgeInsets.all(8),
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
          const SizedBox(height: 4),
          _buildReactionCount(),
        ],
      ),
    );

    if (kIsWeb) {
      // Web: Use Stack with positioned picker instead of overlay
      return MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              // Minimal padding to avoid layout distortion
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: _handleQuickReaction,
                onTapDown: (_) => _buttonController.forward(),
                onTapUp: (_) => _buttonController.reverse(),
                onTapCancel: () => _buttonController.reverse(),
                child: AnimatedBuilder(
                  animation: _buttonAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _buttonAnimation.value,
                      child: child,
                    );
                  },
                  child: child,
                ),
              ),
            ),
            // Position the picker within the Stack - closer to the button
            if (_isReactionPickerVisible)
              Positioned(
                right: 45,
                top: 5,
                child: ReactionPicker(
                  isVisible: _isReactionPickerVisible,
                  currentReaction: widget.reactionSummary.userReaction,
                  onReactionSelected: _handleReactionSelection,
                  onDismiss: _hideReactionPicker,
                ),
              ),
          ],
        ),
      );
    } else {
      // Mobile: Use Listener for pointer events with stack
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Listener(
            onPointerDown: _onPointerDown,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            child: GestureDetector(
              onTapDown: (_) => _buttonController.forward(),
              onTapUp: (_) => _buttonController.reverse(),
              onTapCancel: () => _buttonController.reverse(),
              child: AnimatedBuilder(
                animation: _buttonAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonAnimation.value,
                    child: child,
                  );
                },
                child: child,
              ),
            ),
          ),
          // Position the picker within the Stack for mobile too
          if (_isReactionPickerVisible)
            Positioned(
              right: 40,
              top: 5,
              child: ReactionPicker(
                isVisible: _isReactionPickerVisible,
                currentReaction: widget.reactionSummary.userReaction,
                onReactionSelected: _handleReactionSelection,
                onDismiss: _hideReactionPicker,
              ),
            ),
        ],
      );
    }
  }

  Widget _buildReactionIcon() {
    if (widget.reactionSummary.userReaction != null) {
      final reactionData = ReactionData.getReactionData(widget.reactionSummary.userReaction!);
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: reactionData.color.withOpacity(0.1),
          border: Border.all(
            color: reactionData.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            reactionData.emoji,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      );
    } else {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.favorite_border,
          color: Colors.white,
          size: 20,
        ),
      );
    }
  }

  Widget _buildReactionCount() {
    if (widget.reactionSummary.hasReactions) {
      return GestureDetector(
        onTap: widget.onViewReactions,
        child: Container(
          constraints: const BoxConstraints(minWidth: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatCount(widget.reactionSummary.totalCount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.reactionSummary.topReactionTypes.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.reactionSummary.topReactionTypes
                        .take(3)
                        .map((type) {
                      final reactionData = ReactionData.getReactionData(type);
                      return Container(
                        margin: const EdgeInsets.only(right: 1),
                        child: Text(
                          reactionData.emoji,
                          style: const TextStyle(fontSize: 8),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        constraints: const BoxConstraints(minWidth: 32),
        child: const Text(
          '0',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}