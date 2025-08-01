import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../models/onboarding_models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/glass_button.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showContent = false;
  ActivityLevel? _selectedLevel;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _initializeSelection();
    _startAnimationSequence();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeSelection() {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    _selectedLevel = provider.data.activityLevel;
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _showContent = true);
    _animationController.forward();
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
                  // Progress indicator and navigation
                  _buildTopNavigation(),
                  
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
          right: -50,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              gradient: AppColors.veryActiveGradient,
              shape: BoxShape.circle,
            ),
          ).animate().scale(
            duration: 3000.ms,
            curve: Curves.easeInOut,
          ).fadeIn(duration: 2000.ms),
        ),
        Positioned(
          top: 300,
          left: -80,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: AppColors.activeGradient,
              shape: BoxShape.circle,
            ),
          ).animate().scale(
            duration: 3500.ms,
            curve: Curves.easeInOut,
            delay: 500.ms,
          ).fadeIn(duration: 2000.ms, delay: 500.ms),
        ),
        Positioned(
          bottom: -120,
          right: MediaQuery.of(context).size.width * 0.3,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: AppColors.oceanGradient,
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

  Widget _buildTopNavigation() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Back button
              IconButton(
                onPressed: provider.canGoBack ? () async {
                  await provider.previousStep();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                } : null,
                icon: Icon(
                  Icons.arrow_back,
                  color: provider.canGoBack ? Colors.white : Colors.transparent,
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
          
          // Header section
          _buildHeaderSection(),
          
          const SizedBox(height: 32),
          
          // Activity level options
          _buildActivityLevelOptions(),
          
          const SizedBox(height: 32),
          
          // Selected level info
          if (_selectedLevel != null) _buildSelectedLevelInfo(),
          
          const SizedBox(height: 32),
          
          // Continue button
          _buildContinueButton(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return GlassContainer(
      intensity: GlassIntensity.medium,
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.veryActiveGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.trending_up,
              size: 40,
              color: Colors.white,
            ),
          ).animate().scale(
            duration: 800.ms,
            delay: 200.ms,
            curve: Curves.elasticOut,
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'What\'s your activity level?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            duration: 800.ms,
            delay: 400.ms,
          ).slideY(
            begin: 0.3,
            end: 0,
            duration: 800.ms,
            delay: 400.ms,
            curve: Curves.easeOutCubic,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'This helps us personalize your experience and connect you with others at your level',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            duration: 800.ms,
            delay: 600.ms,
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: 1000.ms,
      delay: 100.ms,
    ).slideY(
      begin: 0.5,
      end: 0,
      duration: 1000.ms,
      delay: 100.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildActivityLevelOptions() {
    return Column(
      children: ActivityLevel.values.asMap().entries.map((entry) {
        final index = entry.key;
        final level = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildActivityLevelCard(
            level: level,
            isSelected: _selectedLevel == level,
            onTap: () => _selectActivityLevel(level),
            animationDelay: 800 + (index * 150),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityLevelCard({
    required ActivityLevel level,
    required bool isSelected,
    required VoidCallback onTap,
    required int animationDelay,
  }) {
    LinearGradient levelGradient;
    Color levelColor;
    
    switch (level) {
      case ActivityLevel.beginner:
        levelGradient = AppColors.oceanGradient;
        levelColor = AppColors.primary;
        break;
      case ActivityLevel.intermediate:
        levelGradient = AppColors.activeGradient;
        levelColor = AppColors.activeOrange;
        break;
      case ActivityLevel.advanced:
        levelGradient = AppColors.veryActiveGradient;
        levelColor = AppColors.veryActiveGreen;
        break;
      case ActivityLevel.professional:
        levelGradient = AppColors.mingleGradient;
        levelColor = AppColors.minglePink;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: GlassContainer(
          intensity: isSelected ? GlassIntensity.strong : GlassIntensity.subtle,
          borderRadius: 20,
          padding: const EdgeInsets.all(20),
          customGradient: isSelected ? levelGradient : null,
          customBorder: isSelected 
              ? Border.all(color: levelColor, width: 2)
              : Border.all(color: AppColors.textLight.withOpacity(0.3), width: 1),
          child: Row(
            children: [
              // Level emoji and indicator
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: isSelected 
                      ? LinearGradient(
                          colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : levelGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    level.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          level.title,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.description,
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.9)
                            : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selection indicator
              if (!isSelected)
                Icon(
                  Icons.radio_button_unchecked,
                  color: AppColors.textLight.withOpacity(0.5),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: 600.ms,
      delay: animationDelay.ms,
    ).slideX(
      begin: 0.3,
      end: 0,
      duration: 600.ms,
      delay: animationDelay.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildSelectedLevelInfo() {
    if (_selectedLevel == null) return const SizedBox.shrink();
    
    return GlassContainer(
      intensity: GlassIntensity.subtle,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Perfect Choice!',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getActivityLevelAdvice(_selectedLevel!),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: 800.ms,
      delay: 200.ms,
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: 800.ms,
      delay: 200.ms,
      curve: Curves.easeOutCubic,
    );
  }

  String _getActivityLevelAdvice(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.beginner:
        return 'Great! We\'ll show you beginner-friendly workouts, basic tips, and connect you with others starting their fitness journey.';
      case ActivityLevel.intermediate:
        return 'Awesome! You\'ll see intermediate workouts, progression tips, and connect with people who have established routines.';
      case ActivityLevel.advanced:
        return 'Excellent! We\'ll feature challenging workouts, advanced techniques, and connect you with serious fitness enthusiasts.';
      case ActivityLevel.professional:
        return 'Amazing! You\'ll get access to professional-level content, expert insights, and connect with athletes and trainers.';
    }
  }

  Widget _buildContinueButton() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final hasSelection = _selectedLevel != null;
        
        return GlassButton(
          onPressed: provider.isLoading || !hasSelection ? null : _handleContinue,
          text: provider.isLoading 
              ? 'Saving...' 
              : hasSelection 
                  ? 'Continue'
                  : 'Select Your Level',
          style: hasSelection 
              ? GlassButtonStyle.primary 
              : GlassButtonStyle.secondary,
          size: GlassButtonSize.large,
          isLoading: provider.isLoading,
          prefixIcon: const Icon(Icons.arrow_forward, color: Colors.white),
          width: double.infinity,
        ).animate().fadeIn(
          duration: 800.ms,
          delay: 1800.ms,
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: 800.ms,
          delay: 1800.ms,
          curve: Curves.easeOutCubic,
        );
      },
    );
  }

  void _selectActivityLevel(ActivityLevel level) {
    setState(() => _selectedLevel = level);
    
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    provider.setActivityLevel(level);
  }

  void _handleContinue() async {
    if (_selectedLevel == null) return;
    
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    await provider.nextStep();
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/onboarding-permissions');
    }
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
                'Skip Activity Level?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Setting your activity level helps us recommend appropriate content and connect you with users at your fitness level.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      onPressed: () => Navigator.of(context).pop(),
                      text: 'Select Level',
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
                        await provider.skipStep();
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/onboarding-permissions');
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