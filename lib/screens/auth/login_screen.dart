import 'package:flutter/material.dart';
import '../../services/supabase/auth_service.dart';
import '../../navigation/main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSignUp = false;
  String? _errorMessage;
  
  // Retry mechanism for email resend
  int _resendAttempts = 0;
  DateTime? _lastResendTime;
  static const int _maxResendAttempts = 3;
  static const Duration _resendCooldown = Duration(minutes: 1);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Check Your Email!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We\'ve sent a confirmation link to:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _emailController.text.trim(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please click the link in your email to confirm your account, then sign in.',
              ),
              const SizedBox(height: 8),
              Text(
                AuthService.getEmailProviderAdvice(_emailController.text.trim()),
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
              if (AuthService.isProblematicEmailProvider(_emailController.text.trim())) ...[
                const SizedBox(height: 8),
                const Text(
                  '⚠️ Your email provider may have strict spam filtering. Consider using Gmail for more reliable delivery.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: _canResendEmail() ? () async {
                  print('Attempting to resend confirmation email...');
                  setDialogState(() => _resendAttempts++);
                  setState(() => _lastResendTime = DateTime.now());
                  
                  final success = await AuthService.resendConfirmationEmail(
                    _emailController.text.trim(),
                  );
                  
                  if (mounted) {
                    final message = success 
                        ? 'Confirmation email resent! Check your inbox and spam folder.' 
                        : 'Failed to resend email. Please try again later or contact support.';
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: success ? Colors.green : Colors.red,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                  
                  // Update dialog state
                  setDialogState(() {});
                } : null,
                child: Text(_getResendButtonText()),
              ),
              if (_resendAttempts >= _maxResendAttempts) ...[
                const SizedBox(height: 8),
                const Text(
                  'If you\'re still not receiving emails, please contact support or try a different email address.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Switch to sign in mode
                setState(() {
                  _isSignUp = false;
                  _passwordController.clear();
                  _errorMessage = null;
                });
              },
              child: const Text('OK, I\'ll Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
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

        // Handle sign up result
        if (!signUpResult.success) {
          // Show error
          setState(() {
            _errorMessage = signUpResult.errorMessage;
            _isLoading = false;
          });
          return;
        }

        // Sign up was successful
        if (signUpResult.requiresEmailConfirmation) {
          // Email confirmation required - show success dialog
          setState(() {
            _isLoading = false;
          });
          
          if (mounted) {
            _showEmailConfirmationDialog();
          }
          return;
        }
      } else {
        // Sign in
        await AuthService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }


      // Ensure user profile exists before navigating
      if (mounted) {
        setState(() {
          _errorMessage = 'Setting up your profile...';
        });
      }

      final userProfile = await AuthService.ensureUserProfile(
        fullName: _isSignUp ? _fullNameController.text.trim() : null,
        username: _isSignUp ? _usernameController.text.trim() : null,
      );

      if (userProfile == null && mounted) {
        setState(() {
          _errorMessage = 'Failed to set up user profile. Please try again.';
          _isLoading = false;
        });
        return;
      }

      // Navigate to main app only after profile is confirmed
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Fingle',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp ? 'Create Account' : 'Welcome Back',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
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
                  
                  // Username field (only for signup)
                  if (_isSignUp) ...[
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
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
                    
                    // Full name field
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (_isSignUp && value.length < 6) {
                        return 'Password must be at least 6 characters';
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
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  // Submit button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Toggle between sign in and sign up
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _errorMessage = null;
                            });
                          },
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign In'
                          : "Don't have an account? Sign Up",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}