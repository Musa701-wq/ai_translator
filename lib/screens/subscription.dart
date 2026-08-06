import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ads/ad_provider.dart';

import '../in_app_purchase/credit_manager.dart' show CreditManager;
import '../in_app_purchase/i_ap_manager.dart';
import '../utils/app_theme.dart';


class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final IAPManager _iapManager = IAPManager();
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;
  String? _currentPurchasingProductId;
  int selectedPlan = 0; // 0 for weekly, 1 for yearly

  @override
  void initState() {
    super.initState();
    _initIAP();

    // Rewarded ad preload
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adProvider = context.read<AdProvider>();
      if (!adProvider.isRewardedAdLoaded && !adProvider.isLoadingRewardedAd) {
        adProvider.loadRewardedAd();
      }
    });
  }

  Future<void> _initIAP() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final creditManager = context.read<CreditManager>();
      await _iapManager.init(creditManager);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ [Subscription] Init error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load subscriptions. Please try again.";
        });
      }
    }
  }

  Future<void> _handlePurchase(ProductDetails product) async {
    if (_isPurchasing) {
      debugPrint("⚠️ [Subscription] Purchase already in progress");
      return;
    }

    setState(() {
      _isPurchasing = true;
      _currentPurchasingProductId = product.id;
      _errorMessage = null;
    });

    try {
      debugPrint("🛒 [Subscription] Initiating purchase: ${product.id}");

      final creditsBefore = context.read<CreditManager>().credits;
      final success = await _iapManager.purchaseProduct(product);

      if (!success && mounted) {
        setState(() {
          _isPurchasing = false;
          _currentPurchasingProductId = null;
        });
      } else {
        debugPrint("✅ [Subscription] Purchase initiated successfully");

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          final creditsAfter = context.read<CreditManager>().credits;
          final creditsAdded = creditsAfter - creditsBefore;

          setState(() {
            _isPurchasing = false;
            _currentPurchasingProductId = null;
          });

          if (creditsAdded > 0) {
            _showPurchaseSuccessDialog(creditsAdded);
          }
        }
      }
    } catch (e) {
      debugPrint("❌ [Subscription] Purchase error: ${e.toString()}");

      if (mounted) {
        setState(() {
          _isPurchasing = false;
          _currentPurchasingProductId = null;
        });
      }
    }
  }

  void _showPurchaseSuccessDialog(int creditsAdded) {
    final isTablet = AppTheme.isTablet(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppTheme.getResponsiveRadius(context, 20),
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(
              AppTheme.getResponsivePadding(context, 24),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                AppTheme.getResponsiveRadius(context, 20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isTablet ? 110 : 80,
                  height: isTablet ? 110 : 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryBlue,
                    size: AppTheme.getResponsiveIconSize(context, 50),
                  ),
                ),
                SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),
                Text(
                  'Purchase Successful!',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.getResponsiveSpacing(context, 12)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getResponsivePadding(context, 20),
                    vertical: AppTheme.getResponsivePadding(context, 12),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                      AppTheme.getResponsiveRadius(context, 12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle,
                        color: AppTheme.primaryBlue,
                        size: AppTheme.getResponsiveIconSize(context, 24),
                      ),
                      SizedBox(width: AppTheme.getResponsiveSpacing(context, 8)),
                      Text(
                        '$creditsAdded Credits',
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTheme.getResponsiveSpacing(context, 16)),
                Text(
                  'New Balance: ${context.read<CreditManager>().credits} Credits',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 16),
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.getResponsivePadding(context, 16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.getResponsiveRadius(context, 12),
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Got it!',
                      style: TextStyle(
                        fontSize: AppTheme.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRestore() async {
    if (_isLoading || _isPurchasing) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint("🔄 [Subscription] Restoring purchases...");

      final creditManager = context.read<CreditManager>();
      final result = await _iapManager.restorePurchases(creditManager);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result.success) {
        if (result.creditsRestored > 0) {
          _showRestoreSuccessDialog(result.creditsRestored);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No previous purchases found to restore.',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 14),
                ),
              ),
              backgroundColor: AppTheme.primaryBlue,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Some purchases could not be restored. Please try again.',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 14),
              ),
            ),
            backgroundColor: AppTheme.primaryBlue,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ [Subscription] Restore error: $e");

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to restore purchases: ${e.toString()}',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 14),
              ),
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showRestoreSuccessDialog(int creditsRestored) {
    final isTablet = AppTheme.isTablet(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppTheme.getResponsiveRadius(context, 20),
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(
              AppTheme.getResponsivePadding(context, 24),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                AppTheme.getResponsiveRadius(context, 20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isTablet ? 110 : 80,
                  height: isTablet ? 110 : 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.restore,
                    color: AppTheme.primaryBlue,
                    size: AppTheme.getResponsiveIconSize(context, 50),
                  ),
                ),
                SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),
                Text(
                  'Purchases Restored!',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.getResponsiveSpacing(context, 12)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getResponsivePadding(context, 20),
                    vertical: AppTheme.getResponsivePadding(context, 12),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                      AppTheme.getResponsiveRadius(context, 12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle,
                        color: AppTheme.primaryBlue,
                        size: AppTheme.getResponsiveIconSize(context, 24),
                      ),
                      SizedBox(width: AppTheme.getResponsiveSpacing(context, 8)),
                      Text(
                        '$creditsRestored Credits',
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTheme.getResponsiveSpacing(context, 16)),
                Text(
                  'Current Balance: ${context.read<CreditManager>().credits} Credits',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 16),
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.getResponsivePadding(context, 16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.getResponsiveRadius(context, 12),
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: AppTheme.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _watchAdForCredits() async {
    final adProvider = context.read<AdProvider>();

    if (!adProvider.isRewardedAdLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Loading ad... Please try again in a moment.',
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 14),
            ),
          ),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );

      await adProvider.loadRewardedAd();
      return;
    }

    final earned = await adProvider.showRewardedAdForCredits();

    if (earned && mounted) {
      _showAdRewardDialog();
    }
  }

  void _showAdRewardDialog() {
    final isTablet = AppTheme.isTablet(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppTheme.getResponsiveRadius(context, 20),
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(
              AppTheme.getResponsivePadding(context, 24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isTablet ? 100 : 80,
                  height: isTablet ? 100 : 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_circle_filled,
                    color: AppTheme.primaryBlue,
                    size: AppTheme.getResponsiveIconSize(context, 50),
                  ),
                ),
                SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),
                Text(
                  'Credits Earned!',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: AppTheme.getResponsiveSpacing(context, 12)),
                Text(
                  '+${CreditManager.rewardedAdCredits} Credits',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                SizedBox(height: AppTheme.getResponsiveSpacing(context, 16)),
                Text(
                  'Thanks for watching! Your credits have been added.',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 14),
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.getResponsivePadding(context, 16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.getResponsiveRadius(context, 12),
                        ),
                      ),
                    ),
                    child: Text(
                      'Awesome!',
                      style: TextStyle(
                        fontSize: AppTheme.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchExternalLink(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open link. Please try again later.'),
          ),
        );
      }
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final creditManager = context.watch<CreditManager>();
    final adProvider = context.watch<AdProvider>();
    final isTablet = AppTheme.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F4F8),
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
          'Go Premium',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: AppTheme.getResponsiveFontSize(context, 24),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: Colors.black,
              size: AppTheme.getResponsiveIconSize(context, 24),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryBlue),
            SizedBox(height: AppTheme.getResponsiveSpacing(context, 16)),
            Text(
              'Loading subscriptions...',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontSize: AppTheme.getResponsiveFontSize(context, 14),
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            // Premium Features Header
            Container(
              margin: EdgeInsets.all(
                AppTheme.getResponsivePadding(context, 16),
              ),
              padding: EdgeInsets.all(isTablet ? 48 : 40),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue,
                borderRadius: BorderRadius.circular(
                  AppTheme.getResponsiveRadius(context, 24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: isTablet ? 120 : 100,
                    height: isTablet ? 120 : 100,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.white,
                      size: AppTheme.getResponsiveIconSize(context, 50),
                    ),
                  ),
                  SizedBox(height: AppTheme.getResponsiveSpacing(context, 28)),
                  Text(
                    'Unlock Premium\nFeatures',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 32),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  SizedBox(height: AppTheme.getResponsiveSpacing(context, 20)),
                  Text(
                    'Get unlimited access to all\nRenovate AI features with no\nrestrictions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 16),
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Current Credits Display Card
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: AppTheme.getResponsivePadding(context, 16),
                vertical: AppTheme.getResponsivePadding(context, 8),
              ),
              padding: EdgeInsets.all(
                AppTheme.getResponsivePadding(context, 20),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  AppTheme.getResponsiveRadius(context, 16),
                ),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
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
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      AppTheme.getResponsivePadding(context, 12),
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue,
                      borderRadius: BorderRadius.circular(
                        AppTheme.getResponsiveRadius(context, 12),
                      ),
                    ),
                    child: Icon(
                      Icons.stars,
                      color: AppTheme.primaryBlue,
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
                          'Your Credits',
                          style: TextStyle(
                            color: AppTheme.primaryBlue.withOpacity(0.8),
                            fontSize: AppTheme.getResponsiveFontSize(context, 14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: AppTheme.getResponsiveSpacing(context, 4),
                        ),
                        if (creditManager.isLoading)
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue,
                            ),
                          )
                        else
                          Text(
                            '${creditManager.credits}',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontSize: AppTheme.getResponsiveFontSize(context, 32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Watch Ad Section
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: AppTheme.getResponsivePadding(context, 16),
                vertical: AppTheme.getResponsivePadding(context, 8),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  AppTheme.getResponsiveRadius(context, 16),
                ),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (adProvider.isRewardedAdLoaded &&
                      !adProvider.isLoadingRewardedAd)
                      ? _watchAdForCredits
                      : null,
                  borderRadius: BorderRadius.circular(
                    AppTheme.getResponsiveRadius(context, 16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      AppTheme.getResponsivePadding(context, 16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                            AppTheme.getResponsivePadding(context, 12),
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightBlue,
                            borderRadius: BorderRadius.circular(
                              AppTheme.getResponsiveRadius(context, 12),
                            ),
                          ),
                          child: Icon(
                            Icons.play_circle_filled,
                            color: AppTheme.primaryBlue,
                            size: AppTheme.getResponsiveIconSize(context, 32),
                          ),
                        ),
                        SizedBox(
                          width: AppTheme.getResponsiveSpacing(context, 16),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Watch a video to earn ',
                                    style: TextStyle(
                                      fontSize: AppTheme.getResponsiveFontSize(
                                        context,
                                        15,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppTheme.getResponsivePadding(
                                        context,
                                        8,
                                      ),
                                      vertical: AppTheme.getResponsivePadding(
                                        context,
                                        2,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.getResponsiveRadius(context, 8),
                                      ),
                                    ),
                                    child: Text(
                                      '+${CreditManager.rewardedAdCredits}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppTheme.getResponsiveFontSize(
                                          context,
                                          13,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: AppTheme.getResponsiveSpacing(context, 4),
                              ),
                              Text(
                                adProvider.isRewardedAdLoaded
                                    ? 'Tap to watch ad'
                                    : adProvider.isLoadingRewardedAd
                                    ? 'Loading ad...'
                                    : 'Ad not ready',
                                style: TextStyle(
                                  fontSize: AppTheme.getResponsiveFontSize(
                                    context,
                                    13,
                                  ),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          adProvider.isRewardedAdLoaded
                              ? Icons.chevron_right
                              : Icons.hourglass_empty,
                          color: Colors.grey[600],
                          size: AppTheme.getResponsiveIconSize(context, 24),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: AppTheme.getResponsiveSpacing(context, 32)),

            // Choose Your Plan
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getResponsivePadding(context, 16),
              ),
              child: Text(
                'Choose Your Plan',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 28),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),

            // Subscription Plans
            if (!_iapManager.isAvailable)
              Container(
                margin: EdgeInsets.all(
                  AppTheme.getResponsivePadding(context, 16),
                ),
                padding: EdgeInsets.all(
                  AppTheme.getResponsivePadding(context, 16),
                ),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(
                    AppTheme.getResponsiveRadius(context, 12),
                  ),
                  border: Border.all(color: AppTheme.primaryBlue),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.primaryBlue,
                      size: AppTheme.getResponsiveIconSize(context, 24),
                    ),
                    SizedBox(
                      width: AppTheme.getResponsiveSpacing(context, 12),
                    ),
                    Expanded(
                      child: Text(
                        'In-App Purchases are not available on this device.',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                          fontSize: AppTheme.getResponsiveFontSize(
                            context,
                            14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_iapManager.products.isEmpty)
              Container(
                margin: EdgeInsets.all(
                  AppTheme.getResponsivePadding(context, 16),
                ),
                padding: EdgeInsets.all(
                  AppTheme.getResponsivePadding(context, 32),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.primaryBlue,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading subscription plans...',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
            // Only show first 2 products (weekly and yearly)
              Column(
                children: [
                  for (int i = 0; i < (_iapManager.products.length > 2 ? 2 : _iapManager.products.length); i++)
                    _buildPlanCard(
                      context,
                      product: _iapManager.products[i],
                      isSelected: selectedPlan == i,
                      onTap: () => setState(() => selectedPlan = i),
                    ),
                ],
              ),

            SizedBox(height: AppTheme.getResponsiveSpacing(context, 32)),

            // Continue Button
            if (_iapManager.products.isNotEmpty && _iapManager.products.length >= 2)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getResponsivePadding(context, 16),
                ),
                child: Container(
                  width: double.infinity,
                  height: AppTheme.getResponsiveButtonHeight(context, 56),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(
                      AppTheme.getResponsiveRadius(context, 16),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        AppTheme.getResponsiveRadius(context, 16),
                      ),
                      onTap: _isPurchasing
                          ? null
                          : () => _handlePurchase(
                        _iapManager.products[selectedPlan],
                      ),
                      child: Center(
                        child: _isPurchasing &&
                            _currentPurchasingProductId ==
                                _iapManager.products[selectedPlan].id
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : Text(
                          'Continue to Purchase',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTheme.getResponsiveFontSize(
                              context,
                              18,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(height: AppTheme.getResponsiveSpacing(context, 20)),

            // Restore Purchases Button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getResponsivePadding(context, 16),
              ),
              child: Container(
                width: double.infinity,
                height: AppTheme.getResponsiveButtonHeight(context, 56),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryBlue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppTheme.getResponsiveRadius(context, 16),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      AppTheme.getResponsiveRadius(context, 16),
                    ),
                    onTap: _isLoading ? null : _handleRestore,
                    child: Center(
                      child: Text(
                        'Restore Purchases',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: AppTheme.getResponsiveFontSize(
                            context,
                            18,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),

            // Terms & Privacy
            Text(
              'Click here to see our Terms & Privacy Policy',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 12),
                color: Colors.grey[600],
              ),
            ),

            SizedBox(height: AppTheme.getResponsiveSpacing(context, 12)),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => _launchExternalLink(
                    'https://vectorlabzlimited.com/terms-of-use/',
                  ),
                  child: Text(
                    'Terms of Service',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(
                        context,
                        14,
                      ),
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.getResponsiveSpacing(context, 32)),
                TextButton(
                  onPressed: () => _launchExternalLink(
                    'https://vectorlabzlimited.com/privacy-policy/',
                  ),
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(
                        context,
                        14,
                      ),
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppTheme.getResponsiveSpacing(context, 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
      BuildContext context, {
        required ProductDetails product,
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    final isTablet = AppTheme.isTablet(context);
    final credits = IAPManager.productCredits[product.id] ?? 0;

    // Determine if it's weekly or yearly based on product ID or credits
    final isWeekly = credits <= 250;
    final period = isWeekly ? 'per week' : 'per year';
    final discount = isWeekly ? '40% off' : '33% off';

    // Features list
    final features = isWeekly
        ? [
      'All Renovate AI features',
      'Ad-free experience',
      'Priority support',
      'Weekly billing',
    ]
        : [
      'Ad-free experience',
      'Priority support',
      'Unlimited Renovate AI',
      'Exclusive features',
      'Best value',
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppTheme.getResponsivePadding(context, 16),
          vertical: AppTheme.getResponsivePadding(context, 8),
        ),
        padding: EdgeInsets.all(isTablet ? 28 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            AppTheme.getResponsiveRadius(context, 24),
          ),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.price,
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 40),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 16),
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.getResponsiveSpacing(context, 8)),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getResponsivePadding(context, 12),
                    vertical: AppTheme.getResponsivePadding(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.discountGreen,
                    borderRadius: BorderRadius.circular(
                      AppTheme.getResponsiveRadius(context, 12),
                    ),
                  ),
                  child: Text(
                    discount,
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 14),
                      color: Colors.green[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.getResponsiveSpacing(context, 8)),
                Text(
                  '$credits Credits',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 16),
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),
            ...features.map(
                  (feature) => Padding(
                padding: EdgeInsets.only(
                  bottom: AppTheme.getResponsiveSpacing(context, 16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryBlue,
                      size: AppTheme.getResponsiveIconSize(context, 24),
                    ),
                    SizedBox(width: AppTheme.getResponsiveSpacing(context, 16)),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(
                            context,
                            16,
                          ),
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppTheme.getResponsiveSpacing(context, 16)),
            Container(
              width: isTablet ? 56 : 48,
              height: isTablet ? 56 : 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryBlue : Colors.grey[400]!,
                  width: 3,
                ),
              ),
              child: isSelected
                  ? Icon(
                Icons.check,
                color: AppTheme.primaryBlue,
                size: isTablet ? 32 : 28,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}