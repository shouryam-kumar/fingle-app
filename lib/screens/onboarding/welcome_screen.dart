import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/glass_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _startAnimationSequence();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _showContent = true);
    _mainController.forward();
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
            // Background orbs
            _buildBackgroundOrbs(),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Progress indicator
                  _buildProgressIndicator(),
                  
                  // Main content
                  Expanded(
                    child: _showContent ? _buildContent() : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundOrbs() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              gradient: AppColors.searchOrbGradient1,
              shape: BoxShape.circle,
            ),
          ).animate().scale(
            duration: 3000.ms,
            curve: Curves.easeInOut,
          ).fadeIn(duration: 2000.ms),
        ),
        Positioned(
          top: 100,
          right: -120,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: AppColors.searchOrbGradient2,
              shape: BoxShape.circle,
            ),
          ).animate().scale(
            duration: 3500.ms,
            curve: Curves.easeInOut,
            delay: 500.ms,
          ).fadeIn(duration: 2000.ms, delay: 500.ms),
        ),
        Positioned(
          bottom: -80,
          left: MediaQuery.of(context).size.width * 0.3,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: AppColors.searchOrbGradient3,
              shape: BoxShape.circle,
            ),
          ).animate().scale(
            duration: 4000.ms,
            curve: Curves.easeInOut,
            delay: 1000.ms,
          ).fadeIn(duration: 2000.ms, delay: 1000.ms),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Back button (disabled on welcome screen)
              IconButton(
                onPressed: null,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.transparent,
                ),
              ),
              
              // Progress bar
              Expanded(
                child: GlassContainer(
                  intensity: GlassIntensity.subtle,
                  borderRadius: 12,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Text(
                        '${provider.currentStepIndex + 1}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        ' of ',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                      Text(
                        '${provider.totalSteps}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: provider.progress,
                          backgroundColor: AppColors.textLight.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Skip button
              TextButton(
                onPressed: () => _showSkipDialog(context),
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Hero section
          _buildHeroSection(),
          
          const SizedBox(height: 40),
          
          // Feature highlights
          _buildFeatureHighlights(),
          
          const SizedBox(height: 40),
          
          // Get started button
          _buildGetStartedButton(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return GlassContainer(
      intensity: GlassIntensity.medium,
      borderRadius: 32,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // App logo/icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.oceanGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 48,
            ),
          ).animate().scale(
            duration: 800.ms,
            delay: 300.ms,
            curve: Curves.elasticOut,
          ),
          
          const SizedBox(height: 24),
          
          // Welcome message
          Text(
            'Welcome to Fingle!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            duration: 800.ms,
            delay: 600.ms,
          ).slideY(
            begin: 0.3,
            end: 0,
            duration: 800.ms,
            delay: 600.ms,
            curve: Curves.easeOutCubic,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Your active lifestyle social platform',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            duration: 800.ms,
            delay: 900.ms,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Let\'s get you set up with a personalized experience that matches your fitness journey',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            duration: 800.ms,
            delay: 1200.ms,
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: 1000.ms,
      delay: 200.ms,
    ).slideY(
      begin: 0.5,
      end: 0,
      duration: 1000.ms,
      delay: 200.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildFeatureHighlights() {
    final features = [
      {
        'icon': Icons.people_outline,
        'title': 'Connect',
        'description': 'Meet like-minded fitness enthusiasts and build your community',
        'gradient': AppColors.oceanGradient,
      },
      {
        'icon': Icons.fitness_center,
        'title': 'Move',
        'description': 'Share your workouts, track progress, and stay motivated',
        'gradient': AppColors.mintGradient,
      },
      {
        'icon': Icons.star_outline,
        'title': 'Inspire',
        'description': 'Motivate others and get inspired by amazing fitness journeys',
        'gradient': AppColors.sunsetGradient,
      },
    ];

    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassContainer(
            intensity: GlassIntensity.subtle,
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Feature icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: feature['gradient'] as LinearGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Feature content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature['description'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(
            duration: 600.ms,
            delay: (1500 + (index * 200)).ms,
          ).slideX(
            begin: 0.3,
            end: 0,
            duration: 600.ms,
            delay: (1500 + (index * 200)).ms,
            curve: Curves.easeOutCubic,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGetStartedButton() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return GlassButton(
          onPressed: provider.isLoading ? null : () async {
            await provider.nextStep();
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/onboarding-profile');
            }
          },
          text: provider.isLoading ? 'Getting Started...' : 'Get Started',
          style: GlassButtonStyle.primary,
          size: GlassButtonSize.large,
          isLoading: provider.isLoading,
          prefixIcon: const Icon(Icons.arrow_forward, color: Colors.white),
        ).animate().fadeIn(
          duration: 800.ms,
          delay: 2200.ms,
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: 800.ms,
          delay: 2200.ms,
          curve: Curves.easeOutCubic,
        );
      },
    );
  }

  void _showSkipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          intensity: GlassIntensity.strong,
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.skip_next_outlined,
                size: 48,
                color: AppColors.warning,
              ),
              const SizedBox(height: 16),
              Text(
                'Skip Onboarding?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'You can complete your profile setup later, but we recommend doing it now for the best experience.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      onPressed: () => Navigator.of(context).pop(),
                      text: 'Continue Setup',
                      style: GlassButtonStyle.primary,
                      size: GlassButtonSize.medium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final provider = Provider.of<OnboardingProvider>(context, listen: false);
                        final success = await provider.skipOnboarding();
                        if (success && mounted) {
                          Navigator.of(context).pushReplacementNamed('/main');
                        }
                      },
                      text: 'Skip',
                      style: GlassButtonStyle.secondary,
                      size: GlassButtonSize.medium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}