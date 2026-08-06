// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../utils/app_theme.dart';
import 'home.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.track_changes,
      iconColor: AppTheme.pinkIcon,
      backgroundColor: AppTheme.lightBlue,
      title: 'Welcome to AI Translator',
      description:
      'Break language barriers with our powerful AI translation technology. Translate anything, anywhere, instantly.',
      features: [],
    ),
    OnboardingPage(
      icon: Icons.edit_note,
      iconColor: AppTheme.primaryBlue,
      backgroundColor: AppTheme.lightBlue,
      title: 'Text Translation',
      description:
      'Instantly translate any text between 100+ languages with perfect accuracy and context awareness.',
      features: [
        '100+ languages',
        'Context-aware translation',
        'Offline capability',
      ],
    ),
    OnboardingPage(
      icon: Icons.camera_alt,
      iconColor: AppTheme.cyanIcon,
      backgroundColor: AppTheme.cyanBg,
      title: 'Scan & Translate',
      description:
      'Point your camera at text in the real world and see translations overlay in real-time. Perfect for signs, menus, and documents.',
      features: [
        'Real-time camera translation',
        'Text detection',
      ],
    ),
    OnboardingPage(
      icon: Icons.mic,
      iconColor: AppTheme.greenIcon,
      backgroundColor: AppTheme.greenBg,
      title: 'Voice Translation',
      description:
      'Speak naturally and get instant translations. Perfect for conversations and learning pronunciation.',
      features: [
        'Speech-to-text',
        'Real-time translation',
        'Voice playback',
      ],
    ),
    OnboardingPage(
      icon: Icons.chat_bubble_outline,
      iconColor: AppTheme.orangeIcon,
      backgroundColor: Color(0xFFFFF8E1),
      title: 'Live Conversation',
      description:
      'Have seamless bilingual conversations with real-time translation for both speakers.',
      features: [
        'Dual-speaker support',
        'Real-time bidirectional translation',
        'Conversation history',
      ],
    ),
    OnboardingPage(
      icon: Icons.image,
      iconColor: AppTheme.purpleIcon,
      backgroundColor: AppTheme.purpleBg,
      title: 'Photo Translation',
      description:
      'Translate text within images while preserving the original layout and design.',
      features: [
        'Image text recognition',
        'Layout preservation',
        'Batch translation',
      ],
    ),
    OnboardingPage(
      icon: Icons.menu_book,
      iconColor: Color(0xFFE91E63),
      backgroundColor: AppTheme.pinkBg,
      title: 'Smart Dictionary',
      description:
      'Get detailed definitions, synonyms, and usage examples for perfect understanding.',
      features: [
        'Detailed definitions',
        'Synonyms & antonyms',
        'Usage examples',
      ],
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: EdgeInsets.only(
                top: AppTheme.getResponsivePadding(context, 16),
                right: AppTheme.getResponsivePadding(context, 16),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Skip',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: AppTheme.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: EdgeInsets.only(
                bottom: AppTheme.getResponsivePadding(context, 20),
              ),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: WormEffect(
                  dotHeight: AppTheme.getResponsiveIconSize(context, 8),
                  dotWidth: AppTheme.getResponsiveIconSize(context, 8),
                  activeDotColor: AppTheme.primaryBlue,
                  dotColor: Colors.grey.shade300,
                  spacing: AppTheme.getResponsiveSpacing(context, 16),
                ),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getResponsivePadding(context, 48),
                vertical: AppTheme.getResponsivePadding(context, 20),
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppTheme.getResponsiveButtonHeight(context, 56),
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.getResponsiveRadius(context, 16),
                      ),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 18),
                      fontWeight: FontWeight.w600,
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

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getResponsivePadding(context, 24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with circular background
          Container(
            width: AppTheme.getResponsiveIconSize(context, 200),
            height: AppTheme.getResponsiveIconSize(context, 200),
            decoration: BoxDecoration(
              color: page.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/sample.png',
                width: AppTheme.getResponsiveIconSize(context, 120),
                height: AppTheme.getResponsiveIconSize(context, 120),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image not found
                  return Icon(
                    page.icon,
                    size: AppTheme.getResponsiveIconSize(context, 80),
                    color: page.iconColor,
                  );
                },
              ),
            ),
          ),

          SizedBox(height: AppTheme.getResponsiveSpacing(context, 60)),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 28),
              fontWeight: FontWeight.bold,
              color: page.iconColor,
              height: 1.2,
            ),
          ),

          SizedBox(height: AppTheme.getResponsiveSpacing(context, 20)),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getResponsivePadding(context, 16),
            ),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),

          // Features list
          if (page.features.isNotEmpty) ...[
            SizedBox(height: AppTheme.getResponsiveSpacing(context, 30)),
            ...page.features.map((feature) => Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppTheme.getResponsiveSpacing(context, 6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryBlue,
                    size: AppTheme.getResponsiveIconSize(context, 20),
                  ),
                  SizedBox(width: AppTheme.getResponsiveSpacing(context, 8)),
                  Text(
                    feature,
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 15),
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String description;
  final List<String> features;

  OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.description,
    required this.features,
  });
}