import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../models/onboarding_models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/glass_button.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showContent = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _startAnimationSequence();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          top: -120,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: AppColors.mintGradient,
              shape: BoxShape.circle,
            ),
          ).animate().scale(
            duration: 3000.ms,
            curve: Curves.easeInOut,
          ).fadeIn(duration: 2000.ms),
        ),
        Positioned(
          top: 200,
          right: -80,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: AppColors.sunsetGradient,
              shape: BoxShape.circle,
            ),
          ).animate().scale(
            duration: 3500.ms,
            curve: Curves.easeInOut,
            delay: 500.ms,
          ).fadeIn(duration: 2000.ms, delay: 500.ms),
        ),
        Positioned(
          bottom: -100,
          right: MediaQuery.of(context).size.width * 0.2,
          child: Container(
            width: 180,
            height: 180,
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
          
          // Interest selection grid
          _buildInterestGrid(),
          
          const SizedBox(height: 32),
          
          // Selection summary
          _buildSelectionSummary(),
          
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
              gradient: AppColors.mintGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.favorite_outline,
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
            'What interests you?',
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
            'Select your fitness interests to get personalized content and connect with like-minded people',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            duration: 800.ms,
            delay: 600.ms,
          ),
          
          const SizedBox(height: 16),
          
          Consumer<OnboardingProvider>(
            builder: (context, provider, child) {
              final selectedCount = provider.data.selectedInterests.length;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selectedCount >= 3 
                      ? AppColors.veryActiveGreen.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedCount >= 3 
                        ? AppColors.veryActiveGreen
                        : AppColors.primary,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selectedCount >= 3 ? Icons.check_circle : Icons.info_outline,
                      size: 16,
                      color: selectedCount >= 3 
                          ? AppColors.veryActiveGreen
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      selectedCount >= 3 
                          ? 'Great selection! ($selectedCount selected)'
                          : 'Select at least 3 interests ($selectedCount selected)',
                      style: TextStyle(
                        color: selectedCount >= 3 
                            ? AppColors.veryActiveGreen
                            : AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ).animate().fadeIn(
            duration: 800.ms,
            delay: 800.ms,
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

  Widget _buildInterestGrid() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final interests = provider.availableInterests;
        
        return GlassContainer(
          intensity: GlassIntensity.subtle,
          borderRadius: 20,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Interests',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: interests.length,
                itemBuilder: (context, index) {
                  final interest = interests[index];
                  final isSelected = provider.data.selectedInterests.contains(interest.id);
                  
                  return _buildInterestCard(
                    interest: interest,
                    isSelected: isSelected,
                    onTap: () => provider.toggleInterest(interest.id),
                    animationDelay: 1000 + (index * 100),
                  );
                },
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: 800.ms,
          delay: 600.ms,
        ).slideX(
          begin: -0.3,
          end: 0,
          duration: 800.ms,
          delay: 600.ms,
          curve: Curves.easeOutCubic,
        );
      },
    );
  }

  Widget _buildInterestCard({
    required InterestCategory interest,
    required bool isSelected,
    required VoidCallback onTap,
    required int animationDelay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? AppColors.oceanGradient
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary
                : AppColors.textLight.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  interest.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              interest.name,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: 600.ms,
      delay: animationDelay.ms,
    ).scale(
      duration: 600.ms,
      delay: animationDelay.ms,
      curve: Curves.elasticOut,
    );
  }

  Widget _buildSelectionSummary() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final selectedInterests = provider.availableInterests
            .where((interest) => provider.data.selectedInterests.contains(interest.id))
            .toList();
        
        if (selectedInterests.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return GlassContainer(
          intensity: GlassIntensity.subtle,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your Selected Interests',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedInterests.map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.oceanGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          interest.emoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          interest.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
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

  Widget _buildContinueButton() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final hasSelection = provider.data.selectedInterests.isNotEmpty;
        final hasMinimumSelection = provider.data.selectedInterests.length >= 3;
        
        return Column(
          children: [
            GlassButton(
              onPressed: provider.isLoading ? null : _handleContinue,
              text: provider.isLoading 
                  ? 'Saving...' 
                  : hasMinimumSelection 
                      ? 'Continue'
                      : 'Continue Anyway',
              style: hasMinimumSelection 
                  ? GlassButtonStyle.primary 
                  : GlassButtonStyle.secondary,
              size: GlassButtonSize.large,
              isLoading: provider.isLoading,
              prefixIcon: const Icon(Icons.arrow_forward, color: Colors.white),
              width: double.infinity,
            ),
            
            if (hasSelection && !hasMinimumSelection) ...[
              const SizedBox(height: 12),
              Text(
                'We recommend selecting at least 3 interests for better content personalization',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ).animate().fadeIn(
          duration: 800.ms,
          delay: 2000.ms,
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: 800.ms,
          delay: 2000.ms,
          curve: Curves.easeOutCubic,
        );
      },
    );
  }

  void _handleContinue() async {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    await provider.nextStep();
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/onboarding-activity');
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
                'Skip Interest Selection?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Selecting interests helps us personalize your experience and connect you with relevant content.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      onPressed: () => Navigator.of(context).pop(),
                      text: 'Select Interests',
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
                          Navigator.of(context).pushReplacementNamed('/onboarding-activity');
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