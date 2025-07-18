// ===== FILE 6: lib/screens/fingle/widgets/recommend_button.dart =====
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/reaction_models.dart';
import '../../../core/theme/app_colors.dart';

class RecommendButton extends StatefulWidget {
  final int recommendCount;
  final bool isRecommended;
  final VoidCallback onRecommend;
  final VoidCallback? onViewRecommendations;
  final VoidCallback? onResetTimeout;

  const RecommendButton({
    super.key,
    required this.recommendCount,
    required this.isRecommended,
    required this.onRecommend,
    this.onViewRecommendations,
    this.onResetTimeout,
  });

  @override
  State<RecommendButton> createState() => _RecommendButtonState();
}

class _RecommendButtonState extends State<RecommendButton>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late AnimationController _recommendController;
  late Animation<double> _buttonAnimation;
  late Animation<double> _recommendAnimation;
  late Animation<Color?> _colorAnimation;
  
  bool _isRecommendSheetVisible = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _recommendController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _buttonAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _recommendAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _recommendController,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: AppColors.primary,
    ).animate(CurvedAnimation(
      parent: _recommendController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _recommendController.dispose();
    _hideRecommendSheet();
    super.dispose();
  }

  void _showRecommendSheet() {
    if (_overlayEntry != null) return;
    
    widget.onResetTimeout?.call();
    
    setState(() {
      _isRecommendSheetVisible = true;
    });

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          onTap: _hideRecommendSheet,
          child: Material(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: RecommendSheet(
                isVisible: _isRecommendSheetVisible,
                onRecommend: _handleRecommend,
                onRecommendWithMessage: _handleRecommendWithMessage,
                onClose: _hideRecommendSheet,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideRecommendSheet() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    
    setState(() {
      _isRecommendSheetVisible = false;
    });
  }

  void _handleRecommend() {
    widget.onResetTimeout?.call();
    
    _recommendController.forward().then((_) {
      _recommendController.reverse();
    });
    
    HapticFeedback.mediumImpact();
    widget.onRecommend();
    _hideRecommendSheet();
  }

  void _handleRecommendWithMessage(String message) {
    widget.onResetTimeout?.call();
    _handleRecommend();
  }

  void _handleQuickRecommend() {
    widget.onResetTimeout?.call();
    _showRecommendSheet();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleQuickRecommend,
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) => _buttonController.reverse(),
      onTapCancel: () => _buttonController.reverse(),
      child: AnimatedBuilder(
        animation: _buttonAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _recommendAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _recommendAnimation.value,
                        child: _buildRecommendIcon(),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildRecommendCount(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isRecommended 
            ? AppColors.primary.withOpacity(0.1)
            : Colors.white.withOpacity(0.1),
        border: Border.all(
          color: widget.isRecommended 
              ? AppColors.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        widget.isRecommended ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_up_outlined,
        color: widget.isRecommended ? AppColors.primary : Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildRecommendCount() {
    return GestureDetector(
      onTap: widget.onViewRecommendations,
      child: Container(
        constraints: const BoxConstraints(minWidth: 32),
        child: Text(
          _formatCount(widget.recommendCount),
          style: TextStyle(
            color: widget.isRecommended ? AppColors.primary : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
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

class RecommendSheet extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onRecommend;
  final Function(String) onRecommendWithMessage;
  final VoidCallback onClose;

  const RecommendSheet({
    super.key,
    required this.isVisible,
    required this.onRecommend,
    required this.onRecommendWithMessage,
    required this.onClose,
  });

  @override
  State<RecommendSheet> createState() => _RecommendSheetState();
}

class _RecommendSheetState extends State<RecommendSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RecommendSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recommend this post',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Add a message (optional)',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onRecommend,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Recommend'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            final message = _messageController.text.trim();
                            if (message.isNotEmpty) {
                              widget.onRecommendWithMessage(message);
                            } else {
                              widget.onRecommend();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('With Message'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}