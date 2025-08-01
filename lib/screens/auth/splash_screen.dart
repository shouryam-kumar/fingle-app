import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/glass_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _taglineOpacity;
  
  bool _showLogo = false;
  bool _showTagline = false;
  bool _showProgress = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _taglineOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));
  }

  void _startSplashSequence() async {
    // Start background animation immediately
    _backgroundController.forward();
    
    // Show logo after a brief delay
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _showLogo = true);
    _logoController.forward();
    
    // Show tagline
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _showTagline = true);
    
    // Show progress indicator
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _showProgress = true);
    
    // Navigate to auth check after total splash duration
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth-check');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.oceanGradient,
        ),
        child: Stack(
          children: [
            // Animated background orbs
            _buildBackgroundOrbs(),
            
            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    
                    // Logo section
                    _buildLogo(),
                    
                    const SizedBox(height: 24),
                    
                    // Tagline
                    _buildTagline(),
                    
                    const Spacer(flex: 2),
                    
                    // Progress indicator
                    _buildProgressIndicator(),
                    
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundOrbs() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          children: [
            // Top-left orb
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  gradient: AppColors.searchOrbGradient1,
                  shape: BoxShape.circle,
                ),
                transform: Matrix4.identity()
                  ..scale(_backgroundController.value * 1.2),
              ).animate().fadeIn(duration: 2000.ms),
            ),
            
            // Top-right orb
            Positioned(
              top: -50,
              right: -150,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  gradient: AppColors.searchOrbGradient2,
                  shape: BoxShape.circle,
                ),
                transform: Matrix4.identity()
                  ..scale(_backgroundController.value * 0.8),
              ).animate().fadeIn(duration: 2500.ms, delay: 300.ms),
            ),
            
            // Bottom center orb
            Positioned(
              bottom: -100,
              left: MediaQuery.of(context).size.width * 0.3,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: AppColors.searchOrbGradient3,
                  shape: BoxShape.circle,
                ),
                transform: Matrix4.identity()
                  ..scale(_backgroundController.value * 0.6),
              ).animate().fadeIn(duration: 3000.ms, delay: 600.ms),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogo() {
    if (!_showLogo) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoOpacity.value,
            child: GlassContainer(
              intensity: GlassIntensity.medium,
              borderRadius: 32,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App logo text
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      'Fingle',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    'Active Lifestyle Social',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagline() {
    if (!_showTagline) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Opacity(
          opacity: _taglineOpacity.value,
          child: Text(
            'Connect • Move • Inspire',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    if (!_showProgress) return const SizedBox.shrink();
    
    return GlassContainer(
      intensity: GlassIntensity.subtle,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading your experience...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(
      begin: 0.3,
      end: 0,
      duration: 800.ms,
      curve: Curves.easeOutCubic,
    );
  }
}