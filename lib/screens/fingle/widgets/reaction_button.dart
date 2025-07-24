import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../models/reaction_models.dart';
import 'enhanced_reaction_picker.dart';
import '../constants/button_constants.dart';
import '../constants/reaction_picker_positioning.dart';
import 'dart:async';

class ReactionButton extends StatefulWidget {
  final ReactionSummary reactionSummary;
  final Function(ReactionType) onReactionSelected;
  final VoidCallback? onViewReactions;
  final VoidCallback? onResetTimeout;
  final Function(bool)? onPickerVisibilityChanged;
  final ReactionPickerLayout pickerLayout;
  final bool useHomeSize;

  const ReactionButton({
    super.key,
    required this.reactionSummary,
    required this.onReactionSelected,
    this.onViewReactions,
    this.onResetTimeout,
    this.onPickerVisibilityChanged,
    this.pickerLayout = ReactionPickerLayout.vertical,
    this.useHomeSize = false,
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
  Timer? _hideTimer;
  bool _isButtonHovered = false;
  bool _isPickerHovered = false;
  final GlobalKey _buttonKey = GlobalKey();

  bool get _shouldShowPicker => _isButtonHovered || _isPickerHovered;

  @override
  void initState() {
    super.initState();

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start pulsing if user has already reacted
    if (widget.reactionSummary.userReaction != null) {
      _startPulsing();
    }
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

  @override
  void didUpdateWidget(ReactionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.reactionSummary.userReaction != null &&
        oldWidget.reactionSummary.userReaction == null) {
      _startPulsing();
    } else if (widget.reactionSummary.userReaction == null &&
        oldWidget.reactionSummary.userReaction != null) {
      _stopPulsing();
    }
  }

  void _startPulsing() {
    _pulseController.repeat(reverse: true);
  }

  void _stopPulsing() {
    _pulseController.stop();
    _pulseController.reset();
  }

  void _showReactionPicker() {
    if (_isReactionPickerVisible || _overlayEntry != null) return;

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

    // Notify parent about picker visibility
    widget.onPickerVisibilityChanged?.call(true);

    if (kIsWeb) {
      // Web version: Use existing hover-based implementation
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: ReactionPickerPositioning.calculateOptimalX(
            buttonPosition: position,
            buttonSize: size,
            screenSize: screenSize,
            layout: widget.pickerLayout,
          ),
          top: ReactionPickerPositioning.calculateOptimalY(
            buttonPosition: position,
            buttonSize: size,
            screenSize: screenSize,
            layout: widget.pickerLayout,
          ),
          child: EnhancedReactionPicker(
            isVisible: _isReactionPickerVisible,
            currentReaction: widget.reactionSummary.userReaction,
            onReactionSelected: _handleReactionSelection,
            onDismiss: _hideReactionPicker,
            layout: widget.pickerLayout,
            onPickerHover: _onPickerHover,
          ),
        ),
      );
    } else {
      // Mobile version: Use full-screen overlay for outside tap detection
      _overlayEntry = OverlayEntry(
        builder: (context) => _MobileReactionPickerOverlay(
          buttonPosition: position,
          buttonSize: size,
          screenSize: screenSize,
          currentReaction: widget.reactionSummary.userReaction,
          onReactionSelected: _handleReactionSelection,
          onDismiss: _hideReactionPicker,
          pickerLayout: widget.pickerLayout,
        ),
      );
    }

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideReactionPicker() {
    if (!_isReactionPickerVisible && _overlayEntry == null) return;

    _overlayEntry?.remove();
    _overlayEntry = null;

    if (mounted) {
      setState(() {
        _isReactionPickerVisible = false;
      });

      // Notify parent about picker visibility
      widget.onPickerVisibilityChanged?.call(false);
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
    debugPrint('🎯 ReactionButton: _handleQuickReaction called');
    widget.onResetTimeout?.call();

    final reactionType =
        widget.reactionSummary.userReaction ?? ReactionType.like;
    debugPrint(
        '🎯 ReactionButton: Toggling reaction type: ${reactionType.name}');

    if (widget.reactionSummary.userReaction != null) {
      widget.onReactionSelected(widget.reactionSummary.userReaction!);
    } else {
      widget.onReactionSelected(ReactionType.like);
    }

    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });

    HapticFeedback.lightImpact();
    debugPrint('🎯 ReactionButton: Quick reaction completed');
  }

  void _startHoverTimer() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(const Duration(milliseconds: 300), () {
      if (_shouldShowPicker && !_isReactionPickerVisible) {
        _showReactionPicker();
      }
    });
  }

  // Long press timer removed - using native onLongPress for mobile

  // Pan methods removed - using native onTap and onLongPress for mobile

  void _onHover(bool isHovering) {
    if (kIsWeb) {
      _isButtonHovered = isHovering;
      _updatePickerVisibility();
    }
  }

  void _onPickerHover(bool isHovering) {
    if (kIsWeb) {
      _isPickerHovered = isHovering;
      _updatePickerVisibility();
    }
  }

  void _updatePickerVisibility() {
    _hideTimer?.cancel();

    if (_shouldShowPicker && !_isReactionPickerVisible) {
      _startHoverTimer();
    } else if (!_shouldShowPicker && _isReactionPickerVisible) {
      _hideTimer = Timer(const Duration(milliseconds: 200), () {
        if (!_shouldShowPicker) {
          _hideReactionPicker();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth =
        widget.useHomeSize ? kHomeTotalButtonWidth : kTotalButtonWidth;
    final buttonHeight =
        widget.useHomeSize ? kHomeTotalButtonHeight : kTotalButtonHeight;
    final textIconGap = widget.useHomeSize ? kHomeTextIconGap : kTextIconGap;

    debugPrint(
        '🎯 ReactionButton build - hasReactions: ${widget.reactionSummary.hasReactions}');
    debugPrint('🎯 Container height: $buttonHeight');

    Widget child = Container(
      key: _buttonKey,
      width: buttonWidth,
      height: buttonHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          SizedBox(height: textIconGap),
          _buildReactionCount(),
        ],
      ),
    );

    if (kIsWeb) {
      // Web: Use MouseRegion with overlay positioning
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
      // Mobile: Use simple, reliable gesture detection
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint('🎯 ReactionButton: Quick tap - triggering reaction');
          _handleQuickReaction();
        },
        onLongPress: () {
          debugPrint('🎯 ReactionButton: Long press - showing picker');
          if (!_isReactionPickerVisible) {
            HapticFeedback.mediumImpact();
            _showReactionPicker();
          }
        },
        onTapDown: (_) {
          debugPrint('🎯 ReactionButton: Tap down - animating button');
          _buttonController.forward();
        },
        onTapUp: (_) {
          debugPrint('🎯 ReactionButton: Tap up - reversing animation');
          _buttonController.reverse();
        },
        onTapCancel: () {
          debugPrint('🎯 ReactionButton: Tap cancelled');
          _buttonController.reverse();
        },
        child: Container(
          // Add larger touch area for better gesture detection
          width: kTotalButtonWidth + 20,
          height: kTotalButtonHeight + 20,
          alignment: Alignment.center,
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
    }
  }

  Widget _buildReactionIcon() {
    final containerSize =
        widget.useHomeSize ? kHomeButtonContainerSize : kButtonContainerSize;
    final iconSize = widget.useHomeSize ? kHomeButtonIconSize : kButtonIconSize;
    final borderWidth =
        widget.useHomeSize ? kHomeButtonBorderWidth : kButtonBorderWidth;
    final emojiSize = widget.useHomeSize ? 16.0 : 22.0;

    if (widget.reactionSummary.userReaction != null) {
      final reactionData =
          ReactionData.getReactionData(widget.reactionSummary.userReaction!);
      return Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: reactionData.color.withOpacity(0.15),
          border: Border.all(
            color: reactionData.color.withOpacity(0.4),
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: reactionData.color.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            reactionData.emoji,
            style: TextStyle(fontSize: emojiSize),
          ),
        ),
      );
    } else {
      return Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.favorite_border,
          color: Colors.white,
          size: iconSize,
        ),
      );
    }
  }

  Widget _buildReactionCount() {
    final hasReactions = widget.reactionSummary.hasReactions;
    final userReaction = widget.reactionSummary.userReaction;
    final textColor = userReaction != null
        ? ReactionData.getReactionData(userReaction).color
        : Colors.white;

    final containerSize =
        widget.useHomeSize ? kHomeButtonContainerSize : kButtonContainerSize;
    final textHeight = widget.useHomeSize ? kHomeTextHeight : kTextHeight;
    final buttonTextSize =
        widget.useHomeSize ? kHomeButtonTextSize : kButtonTextSize;
    final smallEmojiSize = widget.useHomeSize ? 5.0 : 6.0;

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque, // Prevent propagation to underlying widgets
      onTapDown: (_) {
        debugPrint('🎯 Reaction count tapped - preventing video tap');
      },
      onTap: widget.onViewReactions,
      child: Container(
        width: containerSize,
        constraints: BoxConstraints(
          minHeight: textHeight,
          maxHeight: textHeight + 4.0, // Allow for overflow
        ),
        alignment: Alignment.center,
        child: hasReactions
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatCount(widget.reactionSummary.totalCount),
                    style: TextStyle(
                      color: textColor,
                      fontSize: buttonTextSize,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                  if (widget.reactionSummary.topReactionTypes.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 1),
                      height: widget.useHomeSize
                          ? 6.0
                          : 8.0, // Fixed height for emoji row
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.reactionSummary.topReactionTypes
                            .take(3)
                            .map((type) {
                          final reactionData =
                              ReactionData.getReactionData(type);
                          return Container(
                            margin: const EdgeInsets.only(right: 1),
                            child: Text(
                              reactionData.emoji,
                              style: TextStyle(fontSize: smallEmojiSize),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              )
            : Text(
                '0',
                style: TextStyle(
                  color: textColor,
                  fontSize: buttonTextSize,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
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
}

// Mobile-specific overlay component for outside tap detection
class _MobileReactionPickerOverlay extends StatelessWidget {
  final Offset buttonPosition;
  final Size buttonSize;
  final Size screenSize;
  final ReactionType? currentReaction;
  final Function(ReactionType) onReactionSelected;
  final VoidCallback onDismiss;
  final ReactionPickerLayout pickerLayout;

  const _MobileReactionPickerOverlay({
    required this.buttonPosition,
    required this.buttonSize,
    required this.screenSize,
    this.currentReaction,
    required this.onReactionSelected,
    required this.onDismiss,
    required this.pickerLayout,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen transparent detector for outside tap
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Reaction picker positioned near button
        Positioned(
          left: ReactionPickerPositioning.calculateOptimalX(
            buttonPosition: buttonPosition,
            buttonSize: buttonSize,
            screenSize: screenSize,
            layout: pickerLayout,
          ),
          top: ReactionPickerPositioning.calculateOptimalY(
            buttonPosition: buttonPosition,
            buttonSize: buttonSize,
            screenSize: screenSize,
            layout: pickerLayout,
          ),
          child: GestureDetector(
            onTap: () {}, // Prevent dismissal when tapping picker
            behavior: HitTestBehavior.opaque,
            child: EnhancedReactionPicker(
              isVisible: true,
              currentReaction: currentReaction,
              onReactionSelected: onReactionSelected,
              onDismiss: onDismiss,
              layout: pickerLayout,
            ),
          ),
        ),
      ],
    );
  }
}
