import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/video_models.dart';
import '../../../models/comment_models.dart';
import '../../../providers/comments_provider.dart';
import '../../../services/screen_timeout_service.dart';
import 'comment_list.dart';
import 'comment_input.dart';

class CommentsBottomSheet extends StatefulWidget {
  final VideoPost video;
  final VoidCallback? onClose;

  const CommentsBottomSheet({
    super.key,
    required this.video,
    this.onClose,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _backgroundController;
  late Animation<double> _slideAnimation;
  late Animation<double> _backgroundAnimation;

  late ScrollController _scrollController;
  final FocusNode _inputFocusNode = FocusNode();

  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeOut,
    ));

    _scrollController = ScrollController();

    // Listen to keyboard changes
    _inputFocusNode.addListener(_onFocusChange);

    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _backgroundController.forward();

      // Load comments
      final commentsProvider =
          Provider.of<CommentsProvider>(context, listen: false);
      commentsProvider.setCurrentVideoId(widget.video.id);
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _backgroundController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isKeyboardVisible = _inputFocusNode.hasFocus;
    });
  }

  Future<void> _closeSheet() async {
    // Reset screen timeout on close
    ScreenTimeoutService.resetTimer();

    // Clear reply state on close
    final commentsProvider =
        Provider.of<CommentsProvider>(context, listen: false);
    commentsProvider.clearReplyingTo(widget.video.id);

    // Unfocus input to hide keyboard
    _inputFocusNode.unfocus();

    // Animate out
    await Future.wait([
      _slideController.reverse(),
      _backgroundController.reverse(),
    ]);

    if (mounted) {
      widget.onClose?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _closeSheet();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Background overlay
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return GestureDetector(
                  onTap: _closeSheet,
                  child: Container(
                    color: Colors.black.withOpacity(_backgroundAnimation.value),
                  ),
                );
              },
            ),

            // Comments sheet - POSITIONED AT BOTTOM
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.translate(
                    offset: Offset(
                        0,
                        MediaQuery.of(context).size.height *
                            _slideAnimation.value *
                            0.9),
                    child: _buildCommentsSheet(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSheet() {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // ✅ MUCH BETTER POSITIONING - Starts closer to bottom
    double sheetHeight;
    if (_isKeyboardVisible) {
      // When keyboard is visible, take most of the screen
      sheetHeight = screenHeight - 100 - keyboardHeight;
    } else {
      // When keyboard is hidden, take about 65% of screen height
      sheetHeight = screenHeight * 0.65; // Much more reasonable height
    }

    return Container(
      height: sheetHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(16)), // Slightly smaller radius
      ),
      child: Column(
        children: [
          // Minimal header
          _buildMinimalHeader(),

          // Comments list
          Expanded(
            child: CommentList(
              video: widget.video,
              scrollController: _scrollController,
              onResetTimeout: () => ScreenTimeoutService.resetTimer(),
              focusNode: _inputFocusNode,
            ),
          ),

          // Comment input - ALWAYS AT BOTTOM
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: CommentInput(
                video: widget.video,
                focusNode: _inputFocusNode,
                onResetTimeout: () => ScreenTimeoutService.resetTimer(),
                onSubmitted: () {
                  // Scroll to top when new comment is added
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 6, horizontal: 16), // More compact
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 10),

          // Header with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Comments count
              Consumer<CommentsProvider>(
                builder: (context, commentsProvider, child) {
                  final totalComments =
                      commentsProvider.getTotalComments(widget.video.id);
                  return Text(
                    totalComments == 0
                        ? 'Comments'
                        : '$totalComments comment${totalComments == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),

              // Close button
              GestureDetector(
                onTap: _closeSheet,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Minimal divider
          Container(
            height: 0.5,
            color: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}

// Extension to show the comments sheet
extension CommentsSheetExtension on BuildContext {
  Future<void> showCommentsSheet(VideoPost video) async {
    // Reset screen timeout when opening comments
    ScreenTimeoutService.resetTimer();

    await showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(video: video),
    );
  }
}
