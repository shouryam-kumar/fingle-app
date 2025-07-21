import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/post_action.dart';
import '../../painters/glass_ripple_painter.dart';
import 'magnetic_menu_item.dart';

class EnhancedGlassmorphicModal extends StatefulWidget {
  final List<PostAction> actions;
  final VoidCallback onClose;
  final String userName;
  final bool isVisible;
  
  const EnhancedGlassmorphicModal({
    Key? key,
    required this.actions,
    required this.onClose,
    required this.userName,
    this.isVisible = true,
  }) : super(key: key);
  
  @override
  State<EnhancedGlassmorphicModal> createState() => _EnhancedGlassmorphicModalState();
}

class _EnhancedGlassmorphicModalState extends State<EnhancedGlassmorphicModal>
    with TickerProviderStateMixin {
  late AnimationController _modalController;
  late AnimationController _backgroundController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _rotationAnimation;
  
  final List<AnimationController> _itemControllers = [];
  final List<Animation<double>> _itemAnimations = [];
  
  @override
  void initState() {
    super.initState();
    
    _modalController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _modalController,
      curve: Curves.fastOutSlowIn,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _modalController,
      curve: Curves.easeOutCubic,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _modalController,
      curve: Curves.easeInOutQuad,
    ));
    
    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 16.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOutQuad,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: -0.015,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _modalController,
      curve: Curves.fastOutSlowIn,
    ));
    
    // Create staggered animations for menu items
    for (int i = 0; i < widget.actions.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));
      
      _itemControllers.add(controller);
      _itemAnimations.add(animation);
    }
    
    _startEntranceAnimation();
  }
  
  void _startEntranceAnimation() async {
    _backgroundController.forward();
    await Future.delayed(const Duration(milliseconds: 50));
    _modalController.forward();
    
    // Stagger menu item animations with tighter timing
    for (int i = 0; i < _itemControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 150 + (80 * i)), () {
        if (mounted && i < _itemControllers.length) {
          _itemControllers[i].forward();
        }
      });
    }
  }
  
  void _startExitAnimation() async {
    // Reverse menu items quickly
    for (int i = _itemControllers.length - 1; i >= 0; i--) {
      if (i < _itemControllers.length) {
        _itemControllers[i].reverse();
        await Future.delayed(const Duration(milliseconds: 30));
      }
    }
    
    await Future.delayed(const Duration(milliseconds: 50));
    _modalController.reverse();
    await Future.delayed(const Duration(milliseconds: 100));
    _backgroundController.reverse();
    
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) widget.onClose();
  }
  
  @override
  void dispose() {
    _modalController.dispose();
    _backgroundController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Animated background blur
          AnimatedBuilder(
            animation: _blurAnimation,
            builder: (context, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _blurAnimation.value,
                  sigmaY: _blurAnimation.value,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              );
            },
          ),
          
          // Tap to dismiss
          GestureDetector(
            onTap: _startExitAnimation,
            behavior: HitTestBehavior.translucent,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          
          // Modal content
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _scaleAnimation,
                _slideAnimation,
                _opacityAnimation,
                _rotationAnimation,
              ]),
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // perspective
                    ..rotateZ(_rotationAnimation.value)
                    ..scale(_scaleAnimation.value),
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: GlassRippleEffect(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.85,
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                          ),
                          margin: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.25),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 25,
                                spreadRadius: 0,
                                offset: const Offset(0, 25),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                              child: _buildModalContent(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModalContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.glassBorder,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Post Actions',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _startExitAnimation,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.glassMorphism,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Menu items with staggered animation
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: widget.actions.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _itemAnimations[index],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      20 * (1 - _itemAnimations[index].value),
                      0,
                    ),
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * _itemAnimations[index].value),
                      child: Opacity(
                        opacity: _itemAnimations[index].value.clamp(0.0, 1.0),
                        child: MagneticMenuItem(
                          action: PostAction(
                            type: widget.actions[index].type,
                            title: widget.actions[index].title,
                            subtitle: widget.actions[index].subtitle,
                            icon: widget.actions[index].icon,
                            iconColor: widget.actions[index].iconColor,
                            onPressed: () {
                              widget.actions[index].onPressed();
                              _startExitAnimation();
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}