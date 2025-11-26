import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Login form widget containing username and password fields with validation
class LoginFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final String? usernameError;
  final String? passwordError;
  final bool isLoading;
  final VoidCallback onPasswordVisibilityToggle;
  final VoidCallback onLogin;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onPasswordChanged;

  const LoginFormWidget({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.usernameError,
    required this.passwordError,
    required this.isLoading,
    required this.onPasswordVisibilityToggle,
    required this.onLogin,
    required this.onUsernameChanged,
    required this.onPasswordChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Username Field
          TextField(
            controller: usernameController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: onUsernameChanged,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'Enter your email',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'person',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 5.w,
                ),
              ),
              errorText: usernameError,
              errorMaxLines: 2,
            ),
          ),

          SizedBox(height: 2.h),

          // Password Field
          TextField(
            controller: passwordController,
            enabled: !isLoading,
            obscureText: !isPasswordVisible,
            textInputAction: TextInputAction.done,
            onChanged: onPasswordChanged,
            onSubmitted: (_) {
              if (!isLoading) {
                onLogin();
              }
            },
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 5.w,
                ),
              ),
              suffixIcon: IconButton(
                icon: CustomIconWidget(
                  iconName: isPasswordVisible ? 'visibility' : 'visibility_off',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 5.w,
                ),
                onPressed: isLoading ? null : onPasswordVisibilityToggle,
              ),
              errorText: passwordError,
              errorMaxLines: 2,
            ),
          ),

          SizedBox(height: 4.h),

          // Login Button
          SizedBox(
            height: 6.h,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                disabledBackgroundColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.12),
                disabledForegroundColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      'Login',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
