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
  double _keyboardHeight = 0;

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
      final commentsProvider = Provider.of<CommentsProvider>(context, listen: false);
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
            
            // Comments sheet
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
                  child: _buildCommentsSheet(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar and header
          _buildHeader(),
          
          // Comments list
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: CommentList(
                video: widget.video,
                scrollController: _scrollController,
                onResetTimeout: () => ScreenTimeoutService.resetTimer(),
              ),
            ),
          ),
          
          // Comment input
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Header with title and close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Comments count
                Consumer<CommentsProvider>(
                  builder: (context, commentsProvider, child) {
                    final totalComments = commentsProvider.getTotalComments(widget.video.id);
                    return Text(
                      totalComments == 0 
                          ? 'No comments yet' 
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
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