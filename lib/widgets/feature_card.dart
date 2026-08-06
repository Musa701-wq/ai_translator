import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ads/ad_provider.dart';
import '../screens/conversation_screen.dart';
import '../screens/dictionary_page.dart';
import '../screens/live_translation.dart';
import '../screens/photo_translate_page.dart';
import '../screens/text_translate_page.dart';
import '../screens/voice_translation_page.dart';
import '../services/analytics_service.dart';
import '../utils/app_theme.dart';

class FeaturesGrid extends StatelessWidget {
  const FeaturesGrid({super.key});

  Future<void> _navigateToFeature(BuildContext context, String featureTitle) async {
    // Show interstitial ad before navigation
    final adProvider = context.read<AdProvider>();

    // ✅ Ensure interstitial ad is loaded before showing
    if (!adProvider.isInterstitialAdLoaded && !adProvider.isLoadingInterstitialAd) {
      debugPrint("📺 [Feature] Interstitial ad not loaded, loading now...");
      await adProvider.loadInterstitialAd();
      // Wait a bit for ad to load
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    if (adProvider.isInterstitialAdLoaded) {
      debugPrint("📺 [Feature] Showing interstitial ad...");
      await adProvider.showInterstitialAd();
      // Small delay to ensure ad is dismissed before navigation
      await Future.delayed(const Duration(milliseconds: 500));
    } else {
      debugPrint("⚠️ [Feature] Interstitial ad not available, navigating without ad");
    }

    if (!context.mounted) return;

    switch (featureTitle) {
      case 'Text Translation':
        // Track analytics
        AnalyticsService.trackTextTranslationClicked();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TextTranslationPage(),
          ),
        );
        break;
      case 'Scan & Translate':
        // Track analytics
        AnalyticsService.trackScanTranslateClicked();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ScanTranslatePage(),
          ),
        );
        break;
      case 'Voice Translate':
        // Track analytics
        AnalyticsService.trackVoiceTranslateClicked();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VoiceTranslatePage(),
          ),
        );
        break;
      case 'Live Conversation':
        // Track analytics
        AnalyticsService.trackLiveConversationClicked();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LiveConversationPage(),
          ),
        );
        break;
      case 'Smart Dictionary':
        // Track analytics
        AnalyticsService.trackSmartDictionaryClicked();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SmartDictionaryPage(),
          ),
        );
        break;
      case 'Live Translation':
        // Track analytics
        AnalyticsService.trackLiveTranslationClicked();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PhotoTranslatePage(),
          ),
        );
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'title': 'Text Translation',
        'bgColor': AppTheme.pinkBg,
        'iconBgColor': AppTheme.pinkIconBg,
        'icon': Icons.translate,
        'iconColor': AppTheme.pinkIcon,
      },
      {
        'title': 'Scan & Translate',
        'bgColor': AppTheme.cyanBg,
        'iconBgColor': AppTheme.cyanIconBg,
        'icon': Icons.camera_alt,
        'iconColor': AppTheme.cyanIcon,
      },
      {
        'title': 'Voice Translate',
        'bgColor': AppTheme.greenBg,
        'iconBgColor': AppTheme.greenIconBg,
        'icon': Icons.mic,
        'iconColor': AppTheme.greenIcon,
      },
      {
        'title': 'Live Conversation',
        'bgColor': AppTheme.orangeBg,
        'iconBgColor': AppTheme.orangeIconBg,
        'icon': Icons.people,
        'iconColor': AppTheme.orangeIcon,
      },
      {
        'title': 'Smart Dictionary',
        'bgColor': AppTheme.pinkBg,
        'iconBgColor': AppTheme.pinkIconBg,
        'icon': Icons.menu_book,
        'iconColor': AppTheme.pinkIcon,
      },
      {
        'title': 'Live Translation',
        'bgColor': AppTheme.purpleBg,
        'iconBgColor': AppTheme.purpleIconBg,
        'icon': Icons.image,
        'iconColor': AppTheme.purpleIcon,
      },
    ];

    final isTablet = AppTheme.isTablet(context);

    return Padding(
      padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features',
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 32),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 3 : 2,
              crossAxisSpacing: isTablet ? 20 : 16,
              mainAxisSpacing: isTablet ? 20 : 16,
              childAspectRatio: 1.0,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Container(
                decoration: BoxDecoration(
                  color: feature['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _navigateToFeature(context, feature['title'] as String),
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 28.0 : 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: isTablet ? 72 : 64,
                            height: isTablet ? 72 : 64,
                            decoration: BoxDecoration(
                              color: feature['iconBgColor'] as Color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              feature['icon'] as IconData,
                              color: feature['iconColor'] as Color,
                              size: isTablet ? 32 : 28,
                            ),
                          ),
                          SizedBox(height: isTablet ? 16 : 12),
                          Text(
                            feature['title'] as String,
                            style: TextStyle(
                              fontSize: AppTheme.getResponsiveFontSize(context, 16),
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}