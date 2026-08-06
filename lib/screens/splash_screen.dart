/*
// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'dart:async';

import '../utils/app_theme.dart' show AppTheme;
import 'home.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return;

    if (hasSeenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = AppTheme.getWidth(context);
    final screenHeight = AppTheme.getHeight(context);
    final isTablet = AppTheme.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: AppTheme.getResponsivePadding(context, 60),
            right: AppTheme.getResponsivePadding(context, 20),
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.3,
                  child: Icon(
                    Icons.translate,
                    size: AppTheme.getResponsiveIconSize(context, 40),
                    color: AppTheme.lightBlue,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: screenHeight * 0.4,
            right: AppTheme.getResponsivePadding(context, 30),
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.25,
                  child: Icon(
                    Icons.language,
                    size: AppTheme.getResponsiveIconSize(context, 50),
                    color: AppTheme.lightBlue,
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.35,
            left: AppTheme.getResponsivePadding(context, 40),
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.2,
                  child: Icon(
                    Icons.g_translate,
                    size: AppTheme.getResponsiveIconSize(context, 35),
                    color: AppTheme.lightBlue,
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.15,
            right: screenWidth * 0.1,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.25,
                  child: Icon(
                    Icons.mic,
                    size: AppTheme.getResponsiveIconSize(context, 30),
                    color: AppTheme.lightBlue,
                  ),
                );
              },
            ),
          ),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo container with gradient background
                        Container(
                          width: AppTheme.getResponsiveIconSize(context, 170),
                          height: AppTheme.getResponsiveIconSize(context, 170),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryBlue,
                                AppTheme.primaryBlue.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.getResponsiveRadius(context, 20),
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
                            child: Image.asset(
                              'assets/images/sample.png',
                              width: AppTheme.getResponsiveIconSize(context, 140),
                              height: AppTheme.getResponsiveIconSize(context, 140),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback icon if image not found
                                return Icon(
                                  Icons.translate_rounded,
                                  size: AppTheme.getResponsiveIconSize(context, 100),
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: AppTheme.getResponsiveSpacing(context, 40)),

                        // App Title
                        Text(
                          'AI Translator',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context, 38),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                            letterSpacing: 0.5,
                          ),
                        ),

                        SizedBox(height: AppTheme.getResponsiveSpacing(context, 12)),

                        // Subtitle
                        Text(
                          'AI-Powered Translation',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context, 16),
                            color: Colors.grey[600],
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}*/
// lib/screens/splash_screen.dart
/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../providers/auth_providers.dart';
import '../utils/app_theme.dart';
import 'home.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check authentication status
    final authProvider = context.read<AuthProvider>();
    final isSignedIn = authProvider.isSignedIn;

    // Check if user has seen onboarding
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return;

    if (isSignedIn) {
      // User is signed in, go to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (hasSeenOnboarding) {
      // User has seen onboarding but not signed in, go to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // First time user, show onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = AppTheme.getWidth(context);
    final screenHeight = AppTheme.getHeight(context);
    final isTablet = AppTheme.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: AppTheme.getResponsivePadding(context, 60),
            right: AppTheme.getResponsivePadding(context, 20),
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.3,
                  child: Icon(
                    Icons.translate,
                    size: AppTheme.getResponsiveIconSize(context, 40),
                    color: AppTheme.lightBlue,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: screenHeight * 0.4,
            right: AppTheme.getResponsivePadding(context, 30),
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.25,
                  child: Icon(
                    Icons.language,
                    size: AppTheme.getResponsiveIconSize(context, 50),
                    color: AppTheme.lightBlue,
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.35,
            left: AppTheme.getResponsivePadding(context, 40),
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.2,
                  child: Icon(
                    Icons.g_translate,
                    size: AppTheme.getResponsiveIconSize(context, 35),
                    color: AppTheme.lightBlue,
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.15,
            right: screenWidth * 0.1,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.25,
                  child: Icon(
                    Icons.mic,
                    size: AppTheme.getResponsiveIconSize(context, 30),
                    color: AppTheme.lightBlue,
                  ),
                );
              },
            ),
          ),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo container with gradient background
                        Container(
                          width: AppTheme.getResponsiveIconSize(context, 170),
                          height: AppTheme.getResponsiveIconSize(context, 170),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryBlue,
                                AppTheme.primaryBlue.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.getResponsiveRadius(context, 20),
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
                            child: Image.asset(
                              'assets/images/sample.png',
                              width: AppTheme.getResponsiveIconSize(context, 140),
                              height: AppTheme.getResponsiveIconSize(context, 140),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback icon if image not found
                                return Icon(
                                  Icons.translate_rounded,
                                  size: AppTheme.getResponsiveIconSize(context, 100),
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: AppTheme.getResponsiveSpacing(context, 40)),

                        // App Title
                        Text(
                          'AI Translator',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context, 38),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                            letterSpacing: 0.5,
                          ),
                        ),

                        SizedBox(height: AppTheme.getResponsiveSpacing(context, 12)),

                        // Subtitle
                        Text(
                          'AI-Powered Translation',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context, 16),
                            color: Colors.grey[600],
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../providers/auth_providers.dart';
import '../utils/app_theme.dart';
import 'home.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Get AuthProvider AFTER the widget is mounted and context is available
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user is signed in
    final isSignedIn = authProvider.isSignedIn;

    debugPrint('🔍 [Splash] Checking auth status: ${isSignedIn ? "Signed In" : "Not Signed In"}');
    debugPrint('🔍 [Splash] User: ${authProvider.getUserEmail()}');

    if (!mounted) return;

    if (isSignedIn) {
      // User is signed in, go directly to home
      debugPrint('✅ [Splash] User is signed in, navigating to Home');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // User is NOT signed in, check if they've seen onboarding
      debugPrint('⚠️ [Splash] User is NOT signed in, checking onboarding status');

      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      if (!mounted) return;

      if (hasSeenOnboarding) {
        // User has seen onboarding but not signed in, go to login
        debugPrint('✅ [Splash] User has seen onboarding, navigating to Login');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        // First time user, show onboarding
        debugPrint('✅ [Splash] First time user, navigating to Onboarding');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = AppTheme.getWidth(context);
    final screenHeight = AppTheme.getHeight(context);
    final isTablet = AppTheme.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: AppTheme.getResponsivePadding(context, 60),
            right: AppTheme.getResponsivePadding(context, 20),
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.3,
                  child: Icon(
                    Icons.translate,
                    size: AppTheme.getResponsiveIconSize(context, 40),
                    color: AppTheme.lightBlue,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: screenHeight * 0.4,
            right: AppTheme.getResponsivePadding(context, 30),
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.25,
                  child: Icon(
                    Icons.language,
                    size: AppTheme.getResponsiveIconSize(context, 50),
                    color: AppTheme.lightBlue,
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.35,
            left: AppTheme.getResponsivePadding(context, 40),
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.2,
                  child: Icon(
                    Icons.g_translate,
                    size: AppTheme.getResponsiveIconSize(context, 35),
                    color: AppTheme.lightBlue,
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.15,
            right: screenWidth * 0.1,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.25,
                  child: Icon(
                    Icons.mic,
                    size: AppTheme.getResponsiveIconSize(context, 30),
                    color: AppTheme.lightBlue,
                  ),
                );
              },
            ),
          ),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo container with gradient background
                        Container(
                          width: AppTheme.getResponsiveIconSize(context, 170),
                          height: AppTheme.getResponsiveIconSize(context, 170),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryBlue,
                                AppTheme.primaryBlue.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.getResponsiveRadius(context, 20),
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
                            child: Image.asset(
                              'assets/images/sample.png',
                              width: AppTheme.getResponsiveIconSize(context, 140),
                              height: AppTheme.getResponsiveIconSize(context, 140),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback icon if image not found
                                return Icon(
                                  Icons.translate_rounded,
                                  size: AppTheme.getResponsiveIconSize(context, 100),
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: AppTheme.getResponsiveSpacing(context, 40)),

                        // App Title
                        Text(
                          'AI Translator',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context, 38),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                            letterSpacing: 0.5,
                          ),
                        ),

                        SizedBox(height: AppTheme.getResponsiveSpacing(context, 12)),

                        // Subtitle
                        Text(
                          'AI-Powered Translation',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context, 16),
                            color: Colors.grey[600],
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}