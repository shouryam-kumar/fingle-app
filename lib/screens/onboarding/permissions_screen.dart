import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/onboarding_provider.dart';
import '../../models/onboarding_models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/glass_button.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showContent = false;
  bool _isRequestingPermissions = false;
  
  final List<PermissionInfo> _permissions = [
    PermissionInfo(
      name: 'camera',
      title: 'Camera Access',
      description: 'Take photos and videos to share your fitness journey',
      benefit: 'Share workout moments and progress photos',
      icon: Icons.camera_alt,
      isRequired: true,
    ),
    PermissionInfo(
      name: 'photos',
      title: 'Photo Library',
      description: 'Access your photos to share fitness content',
      benefit: 'Upload photos from your gallery',
      icon: Icons.photo_library,
      isRequired: true,
    ),
    PermissionInfo(
      name: 'microphone',
      title: 'Microphone Access',
      description: 'Record audio for video content',
      benefit: 'Add voice to your workout videos',
      icon: Icons.mic,
      isRequired: false,
    ),
    PermissionInfo(
      name: 'location',
      title: 'Location Services',
      description: 'Find nearby gyms and fitness events',
      benefit: 'Discover local fitness opportunities',
      icon: Icons.location_on,
      isRequired: false,
    ),
    PermissionInfo(
      name: 'notifications',
      title: 'Push Notifications',
      description: 'Stay updated with comments, likes, and messages',
      benefit: 'Never miss important interactions',
      icon: Icons.notifications,
      isRequired: false,
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _startAnimationSequence();
    _checkExistingPermissions();
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

  void _checkExistingPermissions() async {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    
    // Check current permission status
    for (final permission in _permissions) {
      Permission platformPermission;
      
      switch (permission.name) {
        case 'camera':
          platformPermission = Permission.camera;
          break;
        case 'photos':
          platformPermission = Permission.photos;
          break;
        case 'microphone':
          platformPermission = Permission.microphone;
          break;
        case 'location':
          platformPermission = Permission.locationWhenInUse;
          break;
        case 'notifications':
          platformPermission = Permission.notification;
          break;
        default:
          continue;
      }
      
      final status = await platformPermission.status;
      provider.updatePermission(permission.name, status.isGranted);
    }
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
          top: -80,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: AppColors.oceanGradient,
              shape: BoxShape.circle,
            ),
          ).animate().scale(
            duration: 3000.ms,
            curve: Curves.easeInOut,
          ).fadeIn(duration: 2000.ms),
        ),
        Positioned(
          top: 250,
          right: -100,
          child: Container(
            width: 180,
            height: 180,
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
          bottom: -120,
          left: MediaQuery.of(context).size.width * 0.2,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: AppColors.veryActiveGradient,
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
          
          // Permissions list
          _buildPermissionsList(),
          
          const SizedBox(height: 32),
          
          // Grant permissions button
          _buildGrantPermissionsButton(),
          
          const SizedBox(height: 16),
          
          // Complete onboarding button
          _buildCompleteButton(),
          
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
              gradient: AppColors.oceanGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.security,
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
            'Privacy & Permissions',
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
            'We need a few permissions to give you the best Fingle experience',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            duration: 800.ms,
            delay: 600.ms,
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.veryActiveGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.veryActiveGreen, width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: AppColors.veryActiveGreen,
                ),
                SizedBox(width: 4),
                Text(
                  'Your privacy is our priority',
                  style: TextStyle(
                    color: AppColors.veryActiveGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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

  Widget _buildPermissionsList() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Column(
          children: _permissions.asMap().entries.map((entry) {
            final index = entry.key;
            final permission = entry.value;
            final isGranted = provider.data.permissions[permission.name] ?? false;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildPermissionCard(
                permission: permission,
                isGranted: isGranted,
                animationDelay: 1000 + (index * 100),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPermissionCard({
    required PermissionInfo permission,
    required bool isGranted,
    required int animationDelay,
  }) {
    return GlassContainer(
      intensity: GlassIntensity.subtle,
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      customBorder: isGranted 
          ? Border.all(color: AppColors.veryActiveGreen.withOpacity(0.5), width: 1)
          : permission.isRequired 
              ? Border.all(color: AppColors.warning.withOpacity(0.5), width: 1)
              : null,
      child: Row(
        children: [
          // Permission icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: isGranted 
                  ? AppColors.veryActiveGradient
                  : permission.isRequired 
                      ? AppColors.activeGradient
                      : AppColors.oceanGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              permission.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Permission info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      permission.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (permission.isRequired) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Required',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  permission.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  permission.benefit,
                  style: TextStyle(
                    color: AppColors.primary.withOpacity(0.8),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          // Status indicator
          Icon(
            isGranted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isGranted 
                ? AppColors.veryActiveGreen 
                : AppColors.textLight.withOpacity(0.5),
            size: 24,
          ),
        ],
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

  Widget _buildGrantPermissionsButton() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final grantedPermissions = provider.data.permissions.values.where((granted) => granted).length;
        final totalPermissions = _permissions.length;
        final allGranted = grantedPermissions == totalPermissions;
        
        return GlassButton(
          onPressed: _isRequestingPermissions || allGranted ? null : _requestAllPermissions,
          text: _isRequestingPermissions 
              ? 'Requesting Permissions...'
              : allGranted 
                  ? 'All Permissions Granted! ✓'
                  : 'Grant Permissions ($grantedPermissions/$totalPermissions)',
          style: allGranted ? GlassButtonStyle.success : GlassButtonStyle.accent,
          size: GlassButtonSize.large,
          isLoading: _isRequestingPermissions,
          prefixIcon: Icon(
            allGranted ? Icons.verified : Icons.security,
            color: Colors.white,
          ),
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

  Widget _buildCompleteButton() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final requiredPermissions = _permissions.where((p) => p.isRequired).toList();
        final grantedRequiredPermissions = requiredPermissions
            .where((p) => provider.data.permissions[p.name] ?? false)
            .length;
        final canComplete = grantedRequiredPermissions == requiredPermissions.length;
        
        return Column(
          children: [
            GlassButton(
              onPressed: provider.isLoading ? null : _handleComplete,
              text: provider.isLoading 
                  ? 'Completing Setup...'
                  : 'Complete Setup',
              style: GlassButtonStyle.primary,
              size: GlassButtonSize.large,
              isLoading: provider.isLoading,
              prefixIcon: const Icon(Icons.check, color: Colors.white),
              width: double.infinity,
            ),
            
            if (!canComplete) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Required permissions are needed for core app functionality',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
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

  void _requestAllPermissions() async {
    setState(() => _isRequestingPermissions = true);
    
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    
    for (final permission in _permissions) {
      Permission platformPermission;
      
      switch (permission.name) {
        case 'camera':
          platformPermission = Permission.camera;
          break;
        case 'photos':
          platformPermission = Permission.photos;
          break;
        case 'microphone':
          platformPermission = Permission.microphone;
          break;
        case 'location':
          platformPermission = Permission.locationWhenInUse;
          break;
        case 'notifications':
          platformPermission = Permission.notification;
          break;
        default:
          continue;
      }
      
      final status = await platformPermission.request();
      provider.updatePermission(permission.name, status.isGranted);
      
      // Small delay between requests for better UX
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    setState(() => _isRequestingPermissions = false);
  }

  void _handleComplete() async {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final success = await provider.completeOnboarding();
    
    if (success && mounted) {
      // Navigate to main app
      Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to complete onboarding. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
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
                'Skip Permissions?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Some features may not work without the required permissions. You can grant them later in settings.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      onPressed: () => Navigator.of(context).pop(),
                      text: 'Grant Permissions',
                      style: GlassButtonStyle.primary,
                      size: GlassButtonSize.medium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        _handleComplete();
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