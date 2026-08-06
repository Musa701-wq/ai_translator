import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../ads/ad_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/feature_card.dart';
import '../widgets/greeting_widget.dart';
import '../widgets/quick_translator_card.dart';
// ✅ CHANGE THIS IMPORT:
import '../widgets/recent_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // ✅ Load Banner and Interstitial ads when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      
      // Load Banner Ad
      if (!adProvider.isBannerAdLoaded) {
        adProvider.loadBannerAd();
        debugPrint("📺 [Home] Loading banner ad...");
      }
      
      // Preload Interstitial Ad for feature navigation
      if (!adProvider.isInterstitialAdLoaded && !adProvider.isLoadingInterstitialAd) {
        adProvider.loadInterstitialAd();
        debugPrint("📺 [Home] Preloading interstitial ad...");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBarWidget(),
              const GreetingWidget(),
              const QuickTranslateCard(),

              // Banner Ad
              Consumer<AdProvider>(
                builder: (context, adProvider, child) {
                  if (adProvider.isBannerAdLoaded && adProvider.bannerAd != null) {
                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: AppTheme.getResponsivePadding(context, 16),
                        vertical: AppTheme.getResponsiveSpacing(context, 16),
                      ),
                      alignment: Alignment.center,
                      width: adProvider.bannerAd!.size.width.toDouble(),
                      height: adProvider.bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: adProvider.bannerAd!),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 8)),
              const FeaturesGrid(),
              SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),

              // ✅ Recent Translations Section - Widget includes header and View All button
              const RecentTranslations(),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),
            ],
          ),
        ),
      ),
    );
  }
}