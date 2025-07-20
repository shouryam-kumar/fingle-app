import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../models/reaction_models.dart';
import '../../../core/theme/app_colors.dart';
import 'enhanced_reaction_picker.dart';
import 'dart:async';

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
  GlobalKey _buttonKey = GlobalKey();
  Timer? _hoverTimer;
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
    _hoverTimer?.cancel();
    _hideTimer?.cancel();
    _hideReactionPicker();
    super.dispose();
  }

  void _showReactionPicker() {
    if (_overlayEntry != null || _isReactionPickerVisible) return;

    widget.onResetTimeout?.call();

    // Get precise button position
    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    setState(() {
      _isReactionPickerVisible = true;
    });

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: _calculateOptimalX(position, size, screenSize),
        top: _calculateOptimalY(position, size, screenSize),
        child: EnhancedReactionPicker(
          isVisible: _isReactionPickerVisible,
          currentReaction: widget.reactionSummary.userReaction,
          onReactionSelected: _handleReactionSelection,
          onDismiss: _hideReactionPicker,
          layout: ReactionPickerLayout.horizontal,
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

  double _calculateOptimalX(Offset position, Size size, Size screenSize) {
    const pickerWidth = 280.0; // Approximate horizontal picker width
    double left = position.dx -
        (pickerWidth / 2) +
        (size.width / 2); // Center horizontally

    // Ensure picker stays on screen
    if (left < 10) {
      left = 10;
    }
    if (left + pickerWidth > screenSize.width - 10) {
      left = screenSize.width - pickerWidth - 10;
    }

    return left;
  }

  double _calculateOptimalY(Offset position, Size size, Size screenSize) {
    const pickerHeight = 60.0; // Approximate horizontal picker height
    double top = position.dy - pickerHeight - 10; // Position above button

    // If there's no space above, position below
    if (top < 50) {
      top = position.dy + size.height + 10; // Position below button
    }

    return top;
  }

  void _startHoverTimer() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(const Duration(milliseconds: 300), () {
      if (_isHovering && !_isReactionPickerVisible) {
        _showReactionPicker();
      }
    });
  }

  void _onHover(bool isHovering) {
    if (kIsWeb) {
      _isHovering = isHovering;
      if (isHovering) {
        _hideTimer?.cancel();
        if (!_isReactionPickerVisible) {
          _startHoverTimer();
        }
      } else {
        _hoverTimer?.cancel();
        _hideTimer?.cancel();
        _hideTimer = Timer(const Duration(milliseconds: 200), () {
          if (!_isHovering && _isReactionPickerVisible) {
            _hideReactionPicker();
          }
        });
      }
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (!kIsWeb) {
      _isLongPressing = true;
      Timer(const Duration(milliseconds: 400), () {
        if (_isLongPressing && !_isReactionPickerVisible) {
          _showReactionPicker();
        }
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!kIsWeb) {
      _isLongPressing = false;
      if (!_isReactionPickerVisible) {
        _handleQuickReaction();
      }
    }
  }

  void _onPanCancel() {
    if (!kIsWeb) {
      _isLongPressing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      key: _buttonKey,
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
    );

    if (kIsWeb) {
      // Web: Use MouseRegion with hover detection
      return MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
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
      );
    } else {
      // Mobile: Use GestureDetector with pan events
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: _onPanStart,
        onPanEnd: _onPanEnd,
        onPanCancel: _onPanCancel,
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
      );
    }
  }

  Widget _buildReactionIcon() {
    if (widget.reactionSummary.userReaction != null) {
      final reactionData =
          ReactionData.getReactionData(widget.reactionSummary.userReaction!);
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
