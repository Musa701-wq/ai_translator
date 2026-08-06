/*
// lib/screens/profile_screen.dart
import 'package:aitranlator/screens/privacy.dart' show PrivacyPolicyPage;
import 'package:aitranlator/screens/settings.dart' show SettingsPage;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_providers.dart';
import '../utils/app_theme.dart';
import 'subscription.dart';

import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getResponsiveRadius(context, 16),
          ),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().signOut();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    // First confirmation
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getResponsiveRadius(context, 16),
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: AppTheme.getResponsiveSpacing(context, 8)),
            Expanded(
              child: Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (firstConfirm != true) return;

    // Second confirmation with re-authentication
    if (!context.mounted) return;

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getResponsiveRadius(context, 16),
          ),
        ),
        title: Text(
          'Final Confirmation',
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Please sign in again to confirm account deletion.',
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Delete Account',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (secondConfirm != true) return;

    if (!context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      ),
    );

    // Re-authenticate
    final reauthSuccess = await authProvider.reauthenticate();

    if (!context.mounted) return;
    Navigator.pop(context); // Close loading

    if (!reauthSuccess) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Re-authentication failed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Delete account
    final deleteSuccess = await authProvider.deleteAccount();

    if (!context.mounted) return;

    if (deleteSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to delete account'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isTablet = AppTheme.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: AppTheme.getResponsiveIconSize(context, 24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTheme.getResponsiveFontSize(context, 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(
            AppTheme.getResponsivePadding(context, 16),
          ),
          child: Column(
            children: [
              SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),

              // Profile Picture
              Container(
                width: isTablet ? 140 : 120,
                height: isTablet ? 140 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryBlue,
                      AppTheme.lightBlue,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: authProvider.getUserPhotoUrl() != null
                    ? ClipOval(
                  child: Image.network(
                    authProvider.getUserPhotoUrl()!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: AppTheme.getResponsiveIconSize(context, 60),
                        color: Colors.white,
                      );
                    },
                  ),
                )
                    : Icon(
                  Icons.person,
                  size: AppTheme.getResponsiveIconSize(context, 60),
                  color: Colors.white,
                ),
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),

              // User Name
              Text(
                authProvider.getUserDisplayName(),
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 28),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 8)),

              // User Email
              Text(
                authProvider.getUserEmail(),
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 32)),

              // Divider
              Divider(
                color: Colors.grey[300],
                thickness: 1,
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 16)),

              // Subscription Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPage(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(
                    AppTheme.getResponsivePadding(context, 20),
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.lightBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      AppTheme.getResponsiveRadius(context, 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          AppTheme.getResponsivePadding(context, 12),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppTheme.getResponsiveRadius(context, 12),
                          ),
                        ),
                        child: Icon(
                          Icons.diamond_outlined,
                          color: Colors.white,
                          size: AppTheme.getResponsiveIconSize(context, 28),
                        ),
                      ),
                      SizedBox(
                        width: AppTheme.getResponsiveSpacing(context, 16),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Go Premium',
                              style: TextStyle(
                                fontSize: AppTheme.getResponsiveFontSize(context, 20),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: AppTheme.getResponsiveSpacing(context, 4),
                            ),
                            Text(
                              'Unlock all premium features',
                              style: TextStyle(
                                fontSize: AppTheme.getResponsiveFontSize(context, 14),
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: AppTheme.getResponsiveIconSize(context, 24),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),

              // Settings Tiles
              _ProfileTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                iconColor: AppTheme.primaryBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 12)),

              _ProfileTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                iconColor: AppTheme.cyanIcon,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage(),
                    ),
                  );
                },
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 12)),

              _ProfileTile(
                icon: Icons.logout_outlined,
                title: 'Logout',
                iconColor: AppTheme.orangeIcon,
                onTap: () => _handleLogout(context),
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 12)),

              _ProfileTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                iconColor: Colors.red,
                onTap: () => _handleDeleteAccount(context),
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AppTheme.getResponsiveRadius(context, 12),
        ),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            AppTheme.getResponsiveRadius(context, 12),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getResponsivePadding(context, 16),
              vertical: AppTheme.getResponsivePadding(context, 16),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    AppTheme.getResponsivePadding(context, 8),
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppTheme.getResponsiveRadius(context, 8),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: AppTheme.getResponsiveIconSize(context, 24),
                  ),
                ),
                SizedBox(
                  width: AppTheme.getResponsiveSpacing(context, 16),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: AppTheme.getResponsiveIconSize(context, 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/
// lib/screens/profile_screen.dart
import 'package:aitranlator/screens/privacy.dart' show PrivacyPolicyPage;
import 'package:aitranlator/screens/settings.dart' show SettingsPage;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit.dart';
import '../providers/auth_providers.dart';
import '../in_app_purchase/credit_manager.dart';
import '../utils/app_theme.dart';
import 'subscription.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getResponsiveRadius(context, 16),
          ),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().signOut();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    // First confirmation
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getResponsiveRadius(context, 16),
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: AppTheme.getResponsiveSpacing(context, 8)),
            Expanded(
              child: Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (firstConfirm != true) return;

    // Second confirmation with re-authentication
    if (!context.mounted) return;

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getResponsiveRadius(context, 16),
          ),
        ),
        title: Text(
          'Final Confirmation',
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Please sign in again to confirm account deletion.',
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Delete Account',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (secondConfirm != true) return;

    if (!context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      ),
    );

    // Re-authenticate
    final reauthSuccess = await authProvider.reauthenticate();

    if (!context.mounted) return;
    Navigator.pop(context); // Close loading

    if (!reauthSuccess) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Re-authentication failed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Delete account
    final deleteSuccess = await authProvider.deleteAccount();

    if (!context.mounted) return;

    if (deleteSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to delete account'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isTablet = AppTheme.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: AppTheme.getResponsiveIconSize(context, 24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTheme.getResponsiveFontSize(context, 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(
            AppTheme.getResponsivePadding(context, 16),
          ),
          child: Column(
            children: [
              SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),

              // Profile Picture
              Container(
                width: isTablet ? 140 : 120,
                height: isTablet ? 140 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryBlue,
                      AppTheme.lightBlue,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: authProvider.getUserPhotoUrl() != null
                    ? ClipOval(
                  child: Image.network(
                    authProvider.getUserPhotoUrl()!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: AppTheme.getResponsiveIconSize(context, 60),
                        color: Colors.white,
                      );
                    },
                  ),
                )
                    : Icon(
                  Icons.person,
                  size: AppTheme.getResponsiveIconSize(context, 60),
                  color: Colors.white,
                ),
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),

              // User Name
              Text(
                authProvider.getUserDisplayName(),
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 28),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 8)),

              // User Email
              Text(
                authProvider.getUserEmail(),
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 32)),

              // ============ ✅ CREDITS CARD ADDED HERE ============
              const CreditsCard(),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),

              // Divider
              Divider(
                color: Colors.grey[300],
                thickness: 1,
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 16)),

              // Subscription Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPage(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(
                    AppTheme.getResponsivePadding(context, 20),
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.lightBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      AppTheme.getResponsiveRadius(context, 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          AppTheme.getResponsivePadding(context, 12),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppTheme.getResponsiveRadius(context, 12),
                          ),
                        ),
                        child: Icon(
                          Icons.diamond_outlined,
                          color: Colors.white,
                          size: AppTheme.getResponsiveIconSize(context, 28),
                        ),
                      ),
                      SizedBox(
                        width: AppTheme.getResponsiveSpacing(context, 16),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Go Premium',
                              style: TextStyle(
                                fontSize: AppTheme.getResponsiveFontSize(
                                  context,
                                  20,
                                ),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: AppTheme.getResponsiveSpacing(context, 4),
                            ),
                            Text(
                              'Unlock all premium features',
                              style: TextStyle(
                                fontSize: AppTheme.getResponsiveFontSize(
                                  context,
                                  14,
                                ),
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: AppTheme.getResponsiveIconSize(context, 24),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),

              // Settings Tiles
              _ProfileTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                iconColor: AppTheme.primaryBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 12)),

              _ProfileTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                iconColor: AppTheme.cyanIcon,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage(),
                    ),
                  );
                },
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 12)),

              _ProfileTile(
                icon: Icons.logout_outlined,
                title: 'Logout',
                iconColor: AppTheme.orangeIcon,
                onTap: () => _handleLogout(context),
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 12)),

              _ProfileTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                iconColor: Colors.red,
                onTap: () => _handleDeleteAccount(context),
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AppTheme.getResponsiveRadius(context, 12),
        ),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            AppTheme.getResponsiveRadius(context, 12),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getResponsivePadding(context, 16),
              vertical: AppTheme.getResponsivePadding(context, 16),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    AppTheme.getResponsivePadding(context, 8),
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppTheme.getResponsiveRadius(context, 8),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: AppTheme.getResponsiveIconSize(context, 24),
                  ),
                ),
                SizedBox(
                  width: AppTheme.getResponsiveSpacing(context, 16),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: AppTheme.getResponsiveIconSize(context, 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}