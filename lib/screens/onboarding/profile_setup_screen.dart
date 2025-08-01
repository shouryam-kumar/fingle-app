import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/onboarding_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/glass_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _ageController = TextEditingController();
  
  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _bioFocus = FocusNode();
  final FocusNode _ageFocus = FocusNode();
  
  bool _isUsernameAvailable = true;
  bool _isCheckingUsername = false;
  String? _selectedImagePath;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _startAnimationSequence();
    _initializeForm();
    
    // Username availability checking
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _fullNameFocus.dispose();
    _usernameFocus.dispose();
    _bioFocus.dispose();
    _ageFocus.dispose();
    super.dispose();
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _showContent = true);
    _animationController.forward();
  }

  void _initializeForm() {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final data = provider.data;
    
    _fullNameController.text = data.fullName ?? '';
    _usernameController.text = data.username ?? '';
    _bioController.text = data.bio ?? '';
    _ageController.text = data.age?.toString() ?? '';
    _selectedImagePath = data.avatarUrl;
  }

  void _onUsernameChanged() async {
    final username = _usernameController.text.trim();
    if (username.length >= 3) {
      setState(() => _isCheckingUsername = true);
      
      final provider = Provider.of<OnboardingProvider>(context, listen: false);
      final isAvailable = await provider.checkUsernameAvailability(username);
      
      if (mounted) {
        setState(() {
          _isUsernameAvailable = isAvailable;
          _isCheckingUsername = false;
        });
      }
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
          right: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: AppColors.searchOrbGradient2,
              shape: BoxShape.circle,
            ),
          ).animate().scale(
            duration: 3000.ms,
            curve: Curves.easeInOut,
          ).fadeIn(duration: 2000.ms),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              gradient: AppColors.searchOrbGradient1,
              shape: BoxShape.circle,
            ),
          ).animate().scale(
            duration: 3500.ms,
            curve: Curves.easeInOut,
            delay: 500.ms,
          ).fadeIn(duration: 2000.ms, delay: 500.ms),
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Header section
            _buildHeaderSection(),
            
            const SizedBox(height: 32),
            
            // Avatar upload section
            _buildAvatarSection(),
            
            const SizedBox(height: 32),
            
            // Form fields
            _buildFormFields(),
            
            const SizedBox(height: 40),
            
            // Continue button
            _buildContinueButton(),
            
            const SizedBox(height: 20),
          ],
        ),
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
          const Icon(
            Icons.person_add,
            size: 48,
            color: AppColors.primary,
          ).animate().scale(
            duration: 800.ms,
            delay: 200.ms,
            curve: Curves.elasticOut,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Tell us about yourself',
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
          
          const SizedBox(height: 8),
          
          Text(
            'Set up your profile to connect with the Fingle community',
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

  Widget _buildAvatarSection() {
    return GlassContainer(
      intensity: GlassIntensity.subtle,
      borderRadius: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Profile Photo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _selectedImagePath != null 
                    ? null 
                    : AppColors.oceanGradient,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: _selectedImagePath != null
                  ? ClipOval(
                      child: _selectedImagePath!.startsWith('http')
                          ? Image.network(
                              _selectedImagePath!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            )
                          : Image.file(
                              File(_selectedImagePath!),
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            ),
                    )
                  : const Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.white,
                    ),
            ),
          ).animate().scale(
            duration: 800.ms,
            delay: 800.ms,
            curve: Curves.elasticOut,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            _selectedImagePath != null ? 'Tap to change' : 'Tap to add photo',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
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
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Full Name field
        _buildTextField(
          controller: _fullNameController,
          focusNode: _fullNameFocus,
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Full name is required';
            }
            if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
          animationDelay: 1000,
        ),
        
        const SizedBox(height: 16),
        
        // Username field
        _buildTextField(
          controller: _usernameController,
          focusNode: _usernameFocus,
          label: 'Username',
          hint: 'Choose a unique username',
          icon: Icons.alternate_email,
          suffix: _isCheckingUsername
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : _usernameController.text.length >= 3
                  ? Icon(
                      _isUsernameAvailable ? Icons.check_circle : Icons.error,
                      color: _isUsernameAvailable ? AppColors.veryActiveGreen : AppColors.error,
                      size: 20,
                    )
                  : null,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Username is required';
            }
            if (value.trim().length < 3) {
              return 'Username must be at least 3 characters';
            }
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
              return 'Username can only contain letters, numbers, and underscores';
            }
            if (!_isUsernameAvailable) {
              return 'Username is not available';
            }
            return null;
          },
          animationDelay: 1200,
        ),
        
        const SizedBox(height: 16),
        
        // Bio field
        _buildTextField(
          controller: _bioController,
          focusNode: _bioFocus,
          label: 'Bio (Optional)',
          hint: 'Tell us about your fitness journey',
          icon: Icons.edit_note,
          maxLines: 3,
          maxLength: 150,
          animationDelay: 1400,
        ),
        
        const SizedBox(height: 16),
        
        // Age field
        _buildTextField(
          controller: _ageController,
          focusNode: _ageFocus,
          label: 'Age (Optional)',
          hint: 'How old are you?',
          icon: Icons.cake_outlined,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final age = int.tryParse(value);
              if (age == null || age < 13 || age > 120) {
                return 'Please enter a valid age (13-120)';
              }
            }
            return null;
          },
          animationDelay: 1600,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    required int animationDelay,
  }) {
    return GlassContainer(
      intensity: GlassIntensity.subtle,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            validator: validator,
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
              suffixIcon: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textLight.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textLight.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              // Save form data as user types
              _saveFormData();
            },
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

  Widget _buildContinueButton() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return GlassButton(
          onPressed: provider.isLoading ? null : _handleContinue,
          text: provider.isLoading ? 'Saving...' : 'Continue',
          style: GlassButtonStyle.primary,
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

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        intensity: GlassIntensity.strong,
        borderRadius: 20,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Photo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    text: 'Camera',
                    style: GlassButtonStyle.secondary,
                    prefixIcon: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    text: 'Gallery',
                    style: GlassButtonStyle.secondary,
                    prefixIcon: const Icon(Icons.photo_library, color: Colors.white),
                  ),
                ),
              ],
            ),
            if (_selectedImagePath != null) ...[
              const SizedBox(height: 12),
              GlassButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _selectedImagePath = null);
                  _saveFormData();
                },
                text: 'Remove Photo',
                style: GlassButtonStyle.warning,
                prefixIcon: const Icon(Icons.delete, color: Colors.white),
                width: double.infinity,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _pickImage(ImageSource source) async {
    Navigator.pop(context);
    
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _selectedImagePath = pickedFile.path);
      
      // Upload to backend
      final provider = Provider.of<OnboardingProvider>(context, listen: false);
      final avatarUrl = await provider.uploadAvatar(pickedFile.path);
      
      if (avatarUrl != null) {
        setState(() => _selectedImagePath = avatarUrl);
      }
      
      _saveFormData();
    }
  }

  void _saveFormData() {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    provider.updateProfileData(
      fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
      username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      age: _ageController.text.isEmpty ? null : int.tryParse(_ageController.text),
      avatarUrl: _selectedImagePath,
    );
  }

  void _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isUsernameAvailable && _usernameController.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose an available username'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _saveFormData();

    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    await provider.nextStep();
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/onboarding-interests');
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
                'Skip Profile Setup?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Setting up your profile helps others connect with you. You can always complete it later.',
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
                        await provider.skipStep();
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/onboarding-interests');
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