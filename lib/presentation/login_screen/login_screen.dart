import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import './widgets/biometric_button_widget.dart';
import './widgets/login_form_widget.dart';
import 'package:assignment/core/services/biometric_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final BiometricAuthService _bio = BiometricAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  String? _usernameError;
  String? _passwordError;

  static const String _mockUsername = 'testuser';
  static const String _mockPassword = 'password123';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final ok = await _bio.isAvailable();
    if (!mounted) return;
    setState(() => _isBiometricAvailable = ok);
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username is required';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _handleLogin() async {
    setState(() {
      _usernameError = _validateUsername(_usernameController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });
    if (_usernameError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (_usernameController.text == _mockUsername &&
        _passwordController.text == _mockPassword) {
      HapticFeedback.mediumImpact();
      Navigator.pushReplacementNamed(context, '/product-list-screen');
    } else {
      setState(() => _isLoading = false);
      _showErrorDialog(
        'Invalid Credentials',
        'The username or password you entered is incorrect. Please try again.\n\n'
            'Demo credentials:\nUsername: testuser\nPassword: password123',
      );
    }
  }

  Future<void> _handleBiometricAuth() async {
    if (!_isBiometricAvailable) {
      _showErrorDialog(
        'Biometric Unavailable',
        'Biometric authentication is not available on this device. '
            'Please use username and password to login.',
      );
      return;
    }

    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final didAuthenticate = await _bio.authenticate(
        reason: 'Please authenticate to access your account',
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (didAuthenticate) {
        HapticFeedback.mediumImpact();
        Navigator.pushReplacementNamed(context, '/product-list-screen');
      } else {
        _showErrorDialog(
          'Authentication Failed',
          'Biometric authentication was not successful. '
              'Please try again or use username and password.',
        );
      }
    } on PlatformException catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog(
        'Biometric Error',
        'An error occurred during biometric authentication. '
            'Ensure biometrics are enrolled on this device and try again.',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog(
        'Error',
        'An unexpected error occurred. Please try again or use username and password.',
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title, style: theme.textTheme.titleLarge),
          content: Text(message, style: theme.textTheme.bodyMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'OK',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 4.h),

                        Text(
                          'Secure Login',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Access your biometric product catalog',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        SizedBox(height: 5.h),

                        if (_isBiometricAvailable)
                          BiometricButtonWidget(
                            onPressed: _isLoading ? null : _handleBiometricAuth,
                            isLoading: _isLoading,
                          ),

                        if (_isBiometricAvailable) SizedBox(height: 3.h),

                        if (_isBiometricAvailable)
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                child: Text(
                                  'OR',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),

                        if (_isBiometricAvailable) SizedBox(height: 3.h),

                        LoginFormWidget(
                          formKey: _formKey,
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                          isPasswordVisible: _isPasswordVisible,
                          usernameError: _usernameError,
                          passwordError: _passwordError,
                          isLoading: _isLoading,
                          onPasswordVisibilityToggle: () {
                            setState(() => _isPasswordVisible = !_isPasswordVisible);
                          },
                          onLogin: _handleLogin,
                          onUsernameChanged: (_) {
                            if (_usernameError != null) {
                              setState(() => _usernameError = null);
                            }
                          },
                          onPasswordChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                        ),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
