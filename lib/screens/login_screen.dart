// lib/screens/login_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_providers.dart';
import '../utils/app_theme.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apple Sign In is only available on iOS and macOS'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signInWithApple();

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getResponsivePadding(context, 24),
            ),
            child: Column(
              children: [
                SizedBox(height: AppTheme.getResponsiveSpacing(context, 60)),

                // Logo and Title Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Logo Container
                      Container(
                        width: AppTheme.getResponsiveIconSize(context, 140),
                        height: AppTheme.getResponsiveIconSize(context, 140),
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
                            AppTheme.getResponsiveRadius(context, 24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.translate_rounded,
                            size: AppTheme.getResponsiveIconSize(context, 80),
                            color: Colors.white,
                          ),
                        ),
                      ),

                      SizedBox(height: AppTheme.getResponsiveSpacing(context, 32)),

                      // Title
                      Text(
                        'Welcome to',
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 24),
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: AppTheme.getResponsiveSpacing(context, 8)),

                      Text(
                        'AI Translator',
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 42),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),

                      SizedBox(height: AppTheme.getResponsiveSpacing(context, 16)),

                      // Subtitle
                      Text(
                        'AI-Powered Translation Made Simple',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppTheme.getResponsiveSpacing(context, 60)),

                // Sign In Buttons
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Sign in with Google Button
                        _SignInButton(
                          onTap: authProvider.isLoading ? null : _handleGoogleSignIn,
                          backgroundColor: Colors.white,
                          borderColor: Colors.grey[300]!,
                          icon: Image.asset(
                            'assets/images/google_logo.png',
                            width: AppTheme.getResponsiveIconSize(context, 24),
                            height: AppTheme.getResponsiveIconSize(context, 24),
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.g_mobiledata,
                                size: AppTheme.getResponsiveIconSize(context, 28),
                                color: Colors.red,
                              );
                            },
                          ),
                          text: 'Continue with Google',
                          textColor: Colors.black87,
                        ),

                        SizedBox(height: AppTheme.getResponsiveSpacing(context, 16)),

                        // Sign in with Apple Button (only show on iOS/macOS)
                        if (Platform.isIOS || Platform.isMacOS)
                          _SignInButton(
                            onTap: authProvider.isLoading ? null : _handleAppleSignIn,
                            backgroundColor: Colors.black,
                            borderColor: Colors.black,
                            icon: Icon(
                              Icons.apple,
                              size: AppTheme.getResponsiveIconSize(context, 28),
                              color: Colors.white,
                            ),
                            text: 'Continue with Apple',
                            textColor: Colors.white,
                          ),

                        if (authProvider.isLoading) ...[
                          SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),
                          const CircularProgressIndicator(
                            color: AppTheme.primaryBlue,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppTheme.getResponsiveSpacing(context, 40)),

                // Terms and Privacy
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getResponsivePadding(context, 16),
                    ),
                    child: Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppTheme.getResponsiveFontSize(context, 12),
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppTheme.getResponsiveSpacing(context, 40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Widget icon;
  final String text;
  final Color textColor;

  const _SignInButton({
    required this.onTap,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppTheme.getResponsiveButtonHeight(context, 56),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          AppTheme.getResponsiveRadius(context, 16),
        ),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            AppTheme.getResponsiveRadius(context, 16),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getResponsivePadding(context, 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                SizedBox(width: AppTheme.getResponsiveSpacing(context, 12)),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}