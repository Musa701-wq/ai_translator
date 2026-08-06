// lib/ads/ad_helper.dart
import 'package:flutter/foundation.dart';

class AdHelper {
  // ACTUAL PRODUCTION ADS IDs - Yeh add karein
  static const String nativeAdId = 'ca-app-pub-3774337907915828/2562455201';
  static const String rewardedAdId = 'ca-app-pub-3774337907915828/2754026899';
  static const String bannerAdId = 'ca-app-pub-3774337907915828/9079158280'; // Replace with your actual Banner ID
  static const String interstitialAdId = 'ca-app-pub-3774337907915828/1234567890'; // Replace with your actual Interstitial ID

  // Test ads (debug mode mai use honge)
  static const String testNativeId = 'ca-app-pub-3940256099942544/3986624511';
  static const String testRewardedId = 'ca-app-pub-3940256099942544/1712485313';
  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  // Debug mode mai test ads, release mode mai production ads
  static bool get useTestAds => kDebugMode;

  static String getNative() {
    return useTestAds ? testNativeId : nativeAdId;
  }

  static String getRewarded() {
    return useTestAds ? testRewardedId : rewardedAdId;
  }

  static String getBanner() {
    return useTestAds ? testBannerId : bannerAdId;
  }

  static String getInterstitial() {
    return useTestAds ? testInterstitialId : interstitialAdId;
  }
}