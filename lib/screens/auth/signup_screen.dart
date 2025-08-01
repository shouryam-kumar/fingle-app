import 'package:flutter/material.dart';
import '../../services/supabase/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/glass_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  
  // Retry mechanism for email resend
  int _resendAttempts = 0;
  DateTime? _lastResendTime;
  static const int _maxResendAttempts = 3;
  static const Duration _resendCooldown = Duration(minutes: 1);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  bool _canResendEmail() {
    if (_resendAttempts >= _maxResendAttempts) return false;
    if (_lastResendTime == null) return true;
    return DateTime.now().difference(_lastResendTime!) >= _resendCooldown;
  }

  String _getResendButtonText() {
    if (_resendAttempts >= _maxResendAttempts) {
      return 'Max attempts reached';
    }
    
    if (!_canResendEmail() && _lastResendTime != null) {
      final remaining = _resendCooldown - DateTime.now().difference(_lastResendTime!);
      final seconds = remaining.inSeconds;
      return 'Wait ${seconds}s to resend';
    }
    
    return _resendAttempts == 0 
        ? 'Resend confirmation email' 
        : 'Resend again (${_resendAttempts}/$_maxResendAttempts)';
  }

  void _showEmailConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            intensity: GlassIntensity.strong,
            borderRadius: 28,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.oceanGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Check Your Email!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                Text(
                  'We\'ve sent a confirmation link to:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                
                GlassContainer(
                  intensity: GlassIntensity.subtle,
                  borderRadius: 12,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _emailController.text.trim(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Please click the link in your email to confirm your account, then sign in.',
                ),
                const SizedBox(height: 12),
                
                Text(
                  AuthService.getEmailProviderAdvice(_emailController.text.trim()),
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: AppColors.info,
                  ),
                ),
                
                if (AuthService.isProblematicEmailProvider(_emailController.text.trim())) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your email provider may have strict spam filtering. Consider using Gmail for more reliable delivery.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Resend button
                GlassButton(
                  onPressed: _canResendEmail() ? () async {
                    setDialogState(() => _resendAttempts++);
                    setState(() => _lastResendTime = DateTime.now());
                    
                    final success = await AuthService.resendConfirmationEmail(
                      _emailController.text.trim(),
                    );
                    
                    if (mounted) {
                      final message = success 
                          ? 'Confirmation email resent! Check your inbox and spam folder.' 
                          : 'Failed to resend email. Please try again later.';
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: success ? AppColors.success : AppColors.error,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                    
                    setDialogState(() {});
                  } : null,
                  text: _getResendButtonText(),
                  style: GlassButtonStyle.secondary,
                  size: GlassButtonSize.medium,
                ),
                
                if (_resendAttempts >= _maxResendAttempts) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'If you\'re still not receiving emails, please contact support or try a different email address.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GlassButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      text: 'Sign In Instead',
                      style: GlassButtonStyle.primary,
                      size: GlassButtonSize.medium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check username availability first
      final isAvailable = await AuthService.isUsernameAvailable(_usernameController.text);
      if (!isAvailable) {
        setState(() {
          _errorMessage = 'Username is already taken';
          _isLoading = false;
        });
        return;
      }

      // Sign up
      final signUpResult = await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        fullName: _fullNameController.text.trim(),
      );

      if (!signUpResult.success) {
        setState(() {
          _errorMessage = signUpResult.errorMessage;
          _isLoading = false;
        });
        return;
      }

      // Sign up was successful
      setState(() => _isLoading = false);
      
      if (signUpResult.requiresEmailConfirmation) {
        if (mounted) {
          _showEmailConfirmationDialog();
        }
      } else {
        // Direct login successful, navigate to main app
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/main');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
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
            // Background orbs (similar to splash screen)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: AppColors.searchOrbGradient1,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -80,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  gradient: AppColors.searchOrbGradient3,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: GlassContainer(
                    intensity: GlassIntensity.medium,
                    borderRadius: 32,
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Column(
                            children: [
                              Text(
                                'Join Fingle',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Connect with active people worldwide',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Full Name field
                          _buildTextField(
                            controller: _fullNameController,
                            label: 'Full Name',
                            icon: Icons.badge_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Email field
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Username field
                          _buildTextField(
                            controller: _usernameController,
                            label: 'Username',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a username';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                                return 'Username can only contain letters, numbers, and underscores';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Password field
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: !_passwordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Confirm Password field
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            icon: Icons.lock_outline,
                            obscureText: !_confirmPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(_confirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Error message
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.error.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Sign up button
                          GlassButton(
                            onPressed: _isLoading ? null : _handleSignUp,
                            text: _isLoading ? 'Creating Account...' : 'Create Account',
                            style: GlassButtonStyle.primary,
                            size: GlassButtonSize.large,
                            isLoading: _isLoading,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Login link
                          GlassButton(
                            onPressed: _isLoading ? null : () {
                              Navigator.of(context).pushReplacementNamed('/login');
                            },
                            text: 'Already have an account? Sign In',
                            style: GlassButtonStyle.secondary,
                            size: GlassButtonSize.medium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return GlassContainer(
      intensity: GlassIntensity.subtle,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}