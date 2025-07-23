import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../widgets/common/glass_button.dart';
import '../../../widgets/common/glass_badge.dart';
import '../../../models/search_models.dart';

/// Premium Glassmorphism Search UI Demonstration
/// This showcases the enhanced glass components and design system
class PremiumSearchDemo extends StatelessWidget {
  const PremiumSearchDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.searchBackgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Title
              const Center(
                child: Text(
                  'Premium Glassmorphism Search UI',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Enhanced Search Header Demo
              _buildSearchHeaderDemo(),
              
              const SizedBox(height: 32),
              
              // Glass Components Demo
              _buildGlassComponentsDemo(),
              
              const SizedBox(height: 32),
              
              // Enhanced People Cards Demo
              _buildPeopleCardsDemo(),
              
              const SizedBox(height: 32),
              
              // Enhanced Topic Cards Demo
              _buildTopicCardsDemo(),
              
              const SizedBox(height: 32),
              
              // Activity Indicators Demo
              _buildActivityIndicatorsDemo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeaderDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enhanced Search Interface',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Enhanced search input
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          borderRadius: 28,
          intensity: GlassIntensity.medium,
          elevation: GlassElevation.medium,
          hasHoverEffect: true,
          child: const Row(
            children: [
              Icon(
                Icons.search,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Search for people, topics, posts...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Icon(
                Icons.mic,
                color: AppColors.secondary,
                size: 20,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Search suggestions
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            'HIIT Workouts',
            'Yoga poses',
            'Open to mingle',
            'Nutrition tips',
            'CrossFit',
          ].map((suggestion) {
            return GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              borderRadius: 20,
              intensity: GlassIntensity.subtle,
              elevation: GlassElevation.low,
              hasRippleEffect: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.trending_up,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGlassComponentsDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Glass Components Showcase',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Glass buttons row
        Row(
          children: [
            Expanded(
              child: GlassButton(
                text: 'Follow',
                style: GlassButtonStyle.primary,
                prefixIcon: const Icon(Icons.add, size: 16, color: Colors.white),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassButton(
                text: 'Mingle',
                style: GlassButtonStyle.mingle,
                prefixIcon: const Icon(Icons.favorite, size: 16, color: Colors.white),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            GlassButton(
              text: 'Message',
              style: GlassButtonStyle.secondary,
              isOutlined: true,
              prefixIcon: const Icon(Icons.message, size: 16),
              onPressed: () {},
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Glass badges showcase
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            GlassBadge.mingle(),
            GlassBadge.trending(text: 'Hot'),
            GlassBadge.activity(level: ActivityLevel.veryActive),
            GlassBadge.activity(level: ActivityLevel.active),
            GlassBadge.activity(level: ActivityLevel.moderate),
            GlassBadge(
              text: '✓ Verified',
              style: GlassBadgeStyle.success,
              hasGlow: true,
            ),
            GlassBadge(
              text: 'Premium',
              style: GlassBadgeStyle.warning,
              isPulsing: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeopleCardsDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enhanced People Cards',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        GlassContainer(
          borderRadius: 24,
          intensity: GlassIntensity.medium,
          elevation: GlassElevation.medium,
          hasHoverEffect: true,
          child: Column(
            children: [
              // Cover with gradient overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  
                  // Mingle badge
                  const Positioned(
                    top: 16,
                    right: 16,
                    child: GlassBadge(
                      text: 'Open to Mingle',
                      style: GlassBadgeStyle.mingle,
                      hasGlow: true,
                    ),
                  ),
                  
                  // Profile avatar
                  Positioned(
                    bottom: -30,
                    left: 24,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.warning],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sarah Johnson, 28',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Yoga instructor & wellness coach',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GlassBadge(
                          text: '✓',
                          style: GlassBadgeStyle.success,
                          size: GlassBadgeSize.small,
                          hasGlow: true,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Stats
                    Row(
                      children: [
                        _buildStat('Posts', '247'),
                        const SizedBox(width: 24),
                        _buildStat('Followers', '12.3K'),
                        const SizedBox(width: 24),
                        _buildStat('Following', '892'),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Interests
                    const Text(
                      'Interests',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: ['Yoga', 'Meditation', 'Nutrition', 'Wellness']
                          .map((interest) => GlassBadge(
                                text: interest,
                                style: GlassBadgeStyle.secondary,
                                size: GlassBadgeSize.small,
                              ))
                          .toList(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: GlassButton(
                            text: 'Follow',
                            style: GlassButtonStyle.primary,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassButton(
                            text: 'Mingle',
                            style: GlassButtonStyle.mingle,
                            prefixIcon: const Icon(Icons.favorite, size: 16, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopicCardsDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enhanced Topic Cards',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        GlassContainer(
          borderRadius: 20,
          intensity: GlassIntensity.medium,
          elevation: GlassElevation.medium,
          hasHoverEffect: true,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Topic icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    gradient: AppColors.veryActiveGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🔥', style: TextStyle(fontSize: 28)),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Topic info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'HIIT Workouts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GlassBadge.trending(text: 'Hot'),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Analytics
                      const Row(
                        children: [
                          Icon(Icons.article, size: 16, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            '127 posts today',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            '2.3K active users',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Activity level
                      Row(
                        children: [
                          GlassBadge.activity(level: ActivityLevel.veryActive),
                          const SizedBox(width: 8),
                          const Text(
                            '↗ +15% this week',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.veryActiveGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Follow button
                Column(
                  children: [
                    GlassButton(
                      text: 'Follow',
                      style: GlassButtonStyle.success,
                      size: GlassButtonSize.small,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityIndicatorsDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Level Indicators',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Activity levels showcase
        Column(
          children: [
            _buildActivityLevelRow(
              ActivityLevel.veryActive,
              'Very Active',
              '5+ posts today, 200+ interactions',
            ),
            const SizedBox(height: 12),
            _buildActivityLevelRow(
              ActivityLevel.active,
              'Active',
              '1-5 posts today, 50+ interactions',
            ),
            const SizedBox(height: 12),
            _buildActivityLevelRow(
              ActivityLevel.moderate,
              'Moderate',
              'Less than 1 post today, <50 interactions',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityLevelRow(
    ActivityLevel level,
    String title,
    String description,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      intensity: GlassIntensity.subtle,
      elevation: GlassElevation.low,
      hasHoverEffect: true,
      child: Row(
        children: [
          GlassBadge.activity(level: level),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}