import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomAppBarVariant {
  standard,
  authentication,
  productList,
  search,
  minimal,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final CustomAppBarVariant variant;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onLogoutPressed;
  final VoidCallback? onSearchPressed;
  final bool centerTitle;
  final String? subtitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.standard,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.onLogoutPressed,
    this.onSearchPressed,
    this.centerTitle = false,
    this.subtitle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      leading: _buildLeading(context),
      title: _buildTitle(context),
      actions: _buildActions(context),
      centerTitle: centerTitle,
      elevation: 1.0,
      shadowColor: theme.brightness == Brightness.light
          ? Colors.black.withValues(alpha: 0.04)
          : Colors.white.withValues(alpha: 0.08),
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
    );
  }
  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    switch (variant) {
      case CustomAppBarVariant.authentication:
      case CustomAppBarVariant.minimal:
        return null;

      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.search:
      case CustomAppBarVariant.productList:
        if (showBackButton && Navigator.of(context).canPop()) {
          return IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            tooltip: 'Back',
            iconSize: 24.0,
          );
        }
        return null;
    }
  }
  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    if (subtitle != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              letterSpacing: 0.4,
            ),
          ),
        ],
      );
    }

    return Text(
      title,
      style: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.onSurface,
        letterSpacing: 0.15,
      ),
    );
  }
  List<Widget>? _buildActions(BuildContext context) {
    if (actions != null) return actions;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomAppBarVariant.productList:
        return [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Refreshing product data...',
                    style: GoogleFonts.roboto(),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Refresh',
            iconSize: 24.0,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogoutPressed ??
                () {
                  _showLogoutDialog(context);
                },
            tooltip: 'Logout',
            iconSize: 24.0,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
        ];

      case CustomAppBarVariant.search:
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearchPressed ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Search functionality',
                        style: GoogleFonts.roboto(),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
            tooltip: 'Search',
            iconSize: 24.0,
          ),
          const SizedBox(width: 8),
        ];

      case CustomAppBarVariant.authentication:
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.minimal:
        return null;
    }
  }
  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            'Are you sure you want to logout? You will need to authenticate again to access your products.',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login-screen',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

extension CustomAppBarFactory on CustomAppBar {
  static CustomAppBar forLogin() {
    return const CustomAppBar(
      title: 'Secure Login',
      variant: CustomAppBarVariant.authentication,
      centerTitle: true,
    );
  }

  static CustomAppBar forProductList({
    VoidCallback? onLogoutPressed,
  }) {
    return CustomAppBar(
      title: 'Product Catalog',
      subtitle: 'Updated: Nov 26, 2025',
      variant: CustomAppBarVariant.productList,
      onLogoutPressed: onLogoutPressed,
    );
  }

  static CustomAppBar standard({
    required String title,
    String? subtitle,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      title: title,
      subtitle: subtitle,
      variant: CustomAppBarVariant.standard,
      onBackPressed: onBackPressed,
      actions: actions,
    );
  }

  static CustomAppBar minimal({
    required String title,
    bool centerTitle = false,
  }) {
    return CustomAppBar(
      title: title,
      variant: CustomAppBarVariant.minimal,
      centerTitle: centerTitle,
    );
  }
}
