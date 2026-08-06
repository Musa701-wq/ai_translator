/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/theme.dart';
import '../provider/Ad_provider.dart';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'credit_manager.dart';
import 'i_ap_manager.dart';

class CreditsPurchaseScreen extends StatefulWidget {
  const CreditsPurchaseScreen({Key? key}) : super(key: key);

  @override
  State<CreditsPurchaseScreen> createState() => _CreditsPurchaseScreenState();
}

class _CreditsPurchaseScreenState extends State<CreditsPurchaseScreen> {
  final IAPManager _iapManager = IAPManager();
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;
  String? _currentPurchasingProductId;

// CreditsPurchaseScreen ke initState mein ye add karo:
  @override
  void initState() {
    super.initState();
    _initIAP();

    // Rewarded ad preload karo
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
      debugPrint("❌ [Purchase Screen] Init error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load purchases. Please try again.";
        });
      }
    }
  }

  Future<void> _handlePurchase(ProductDetails product) async {
    if (_isPurchasing) {
      debugPrint("⚠️ [Purchase Screen] Purchase already in progress");
      return;
    }

    setState(() {
      _isPurchasing = true;
      _currentPurchasingProductId = product.id;
      _errorMessage = null;
    });

    try {
      debugPrint("🛒 [Purchase Screen] Initiating purchase: ${product.id}");

      final creditsBefore = context.read<CreditManager>().credits;
      final success = await _iapManager.purchaseProduct(product);

      if (!success && mounted) {
        setState(() {
          _isPurchasing = false;
          _currentPurchasingProductId = null;
        });

        // _showErrorSnackBar('Purchase could not be initiated. Please try again.');
      } else {
        debugPrint("✅ [Purchase Screen] Purchase initiated successfully");

        // Wait for purchase to complete and credits to update
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
      debugPrint("❌ [Purchase Screen] Purchase error: ${e.toString()}");

      if (mounted) {
        setState(() {
          _isPurchasing = false;
          _currentPurchasingProductId = null;
        });

        //_showErrorSnackBar('Error: ${e.toString()}');
      }
    }
  }

  void _showPurchaseSuccessDialog(int creditsAdded) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(
              AppTheme.responsiveSize(context, phone: 24, tablet: 32),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon with Animation
                Container(
                  width: AppTheme.responsiveSize(
                    context,
                    phone: 80,
                    tablet: 110,
                  ),
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 80,
                    tablet: 110,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryColor,
                    size: AppTheme.responsiveSize(
                      context,
                      phone: 50,
                      tablet: 64,
                    ),
                  ),
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 24,
                    tablet: 32,
                  ),
                ),

                // Success Title
                Text(
                  'Purchase Successful!',
                  style: TextStyle(
                    fontSize: AppTheme.responsiveFont(
                      context,
                      phone: 24,
                      tablet: 28,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 12,
                    tablet: 16,
                  ),
                ),

                // Credits Added Info
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.responsiveSize(
                      context,
                      phone: 20,
                      tablet: 28,
                    ),
                    vertical: AppTheme.responsiveSize(
                      context,
                      phone: 12,
                      tablet: 16,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                      AppTheme.responsiveSize(context, phone: 12, tablet: 16),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle,
                        color: AppTheme.primaryColor,
                        size: AppTheme.responsiveSize(
                          context,
                          phone: 24,
                          tablet: 30,
                        ),
                      ),
                      SizedBox(
                        width: AppTheme.responsiveSize(
                          context,
                          phone: 8,
                          tablet: 12,
                        ),
                      ),
                      Text(
                        '$creditsAdded Credits',
                        style: TextStyle(
                          fontSize: AppTheme.responsiveFont(
                            context,
                            phone: 20,
                            tablet: 26,
                          ),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 16,
                    tablet: 22,
                  ),
                ),

                // Current Balance
                Text(
                  'New Balance: ${context.read<CreditManager>().credits} Credits',
                  style: TextStyle(
                    fontSize: AppTheme.responsiveFont(
                      context,
                      phone: 16,
                      tablet: 18,
                    ),
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 24,
                    tablet: 32,
                  ),
                ),

                // Confirmation Message
                Text(
                  'Your credits have been added to your account successfully. You can now use them for plant scans and AI features.',
                  style: TextStyle(
                    fontSize: AppTheme.responsiveFont(
                      context,
                      phone: 14,
                      tablet: 16,
                    ),
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 24,
                    tablet: 32,
                  ),
                ),

                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.responsiveSize(
                          context,
                          phone: 16,
                          tablet: 20,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.responsiveSize(
                            context,
                            phone: 12,
                            tablet: 16,
                          ),
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Got it!',
                      style: TextStyle(
                        fontSize: AppTheme.responsiveFont(
                          context,
                          phone: 16,
                          tablet: 18,
                        ),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
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
      debugPrint("🔄 [Purchase Screen] Restoring purchases...");

      final creditManager = context.read<CreditManager>();

      // Call restore with proper result handling
      final result = await _iapManager.restorePurchases(creditManager);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result.success) {
        if (result.creditsRestored > 0) {
          // Show success dialog with credits restored
          _showRestoreSuccessDialog(result.creditsRestored);
        } else {
          // No purchases to restore
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  SizedBox(
                    width: AppTheme.responsiveSize(
                      context,
                      phone: 12,
                      tablet: 16,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'No previous purchases found to restore.',
                      style: TextStyle(
                        fontSize: AppTheme.responsiveFont(
                          context,
                          phone: 14,
                          tablet: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.primaryColor,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.responsiveSize(context, phone: 10, tablet: 12),
                ),
              ),
            ),
          );
        }
      } else {
        // Restore had some issues
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_outlined, color: Colors.white),
                SizedBox(
                  width: AppTheme.responsiveSize(
                    context,
                    phone: 12,
                    tablet: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Some purchases could not be restored. Please try again.',
                    style: TextStyle(
                      fontSize: AppTheme.responsiveFont(
                        context,
                        phone: 14,
                        tablet: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.primaryColor,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppTheme.responsiveSize(context, phone: 10, tablet: 12),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ [Purchase Screen] Restore error: $e");

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                SizedBox(
                  width: AppTheme.responsiveSize(
                    context,
                    phone: 12,
                    tablet: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Failed to restore purchases: ${e.toString()}',
                    style: TextStyle(
                      fontSize: AppTheme.responsiveFont(
                        context,
                        phone: 14,
                        tablet: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppTheme.responsiveSize(context, phone: 10, tablet: 12),
              ),
            ),
          ),
        );
      }
    }
  }

  void _showRestoreSuccessDialog(int creditsRestored) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(
              AppTheme.responsiveSize(context, phone: 24, tablet: 32),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: AppTheme.responsiveSize(
                    context,
                    phone: 80,
                    tablet: 110,
                  ),
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 80,
                    tablet: 110,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.restore,
                    color: AppTheme.primaryColor,
                    size: AppTheme.responsiveSize(
                      context,
                      phone: 50,
                      tablet: 64,
                    ),
                  ),
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 24,
                    tablet: 32,
                  ),
                ),

                // Title
                Text(
                  'Purchases Restored!',
                  style: TextStyle(
                    fontSize: AppTheme.responsiveFont(
                      context,
                      phone: 24,
                      tablet: 28,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 12,
                    tablet: 16,
                  ),
                ),

                // Credits Restored
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.responsiveSize(
                      context,
                      phone: 20,
                      tablet: 28,
                    ),
                    vertical: AppTheme.responsiveSize(
                      context,
                      phone: 12,
                      tablet: 16,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                      AppTheme.responsiveSize(context, phone: 12, tablet: 16),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle,
                        color: AppTheme.primaryColor,
                        size: AppTheme.responsiveSize(
                          context,
                          phone: 24,
                          tablet: 30,
                        ),
                      ),
                      SizedBox(
                        width: AppTheme.responsiveSize(
                          context,
                          phone: 8,
                          tablet: 12,
                        ),
                      ),
                      Text(
                        '$creditsRestored Credits',
                        style: TextStyle(
                          fontSize: AppTheme.responsiveFont(
                            context,
                            phone: 20,
                            tablet: 26,
                          ),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 16,
                    tablet: 22,
                  ),
                ),

                // Current Balance
                Text(
                  'Current Balance: ${context.read<CreditManager>().credits} Credits',
                  style: TextStyle(
                    fontSize: AppTheme.responsiveFont(
                      context,
                      phone: 16,
                      tablet: 18,
                    ),
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 24,
                    tablet: 32,
                  ),
                ),

                // Message
                Text(
                  'Your previous purchases have been successfully restored to your account.',
                  style: TextStyle(
                    fontSize: AppTheme.responsiveFont(
                      context,
                      phone: 14,
                      tablet: 16,
                    ),
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 24,
                    tablet: 32,
                  ),
                ),

                // Done Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.responsiveSize(
                          context,
                          phone: 16,
                          tablet: 20,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.responsiveSize(
                            context,
                            phone: 12,
                            tablet: 16,
                          ),
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: AppTheme.responsiveFont(
                          context,
                          phone: 16,
                          tablet: 18,
                        ),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
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
              fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 16),
            ),
          ),
          backgroundColor: AppTheme.primaryColor,
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppTheme.responsiveSize(
                    context,
                    phone: 80,
                    tablet: 100,
                  ),
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 80,
                    tablet: 100,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_circle_filled,
                    color: AppTheme.primaryColor,
                    size: AppTheme.responsiveSize(
                      context,
                      phone: 50,
                      tablet: 60,
                    ),
                  ),
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 24,
                    tablet: 30,
                  ),
                ),
                Text(
                  'Credits Earned!',
                  style: TextStyle(
                    fontSize: AppTheme.responsiveFont(
                      context,
                      phone: 24,
                      tablet: 28,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 12,
                    tablet: 16,
                  ),
                ),
                Text(
                  '+${CreditManager.rewardedAdCredits} Credits',
                  style: TextStyle(
                    fontSize: AppTheme.responsiveFont(
                      context,
                      phone: 20,
                      tablet: 24,
                    ),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 16,
                    tablet: 20,
                  ),
                ),
                Text(
                  'Thanks for watching! Your credits have been added.',
                  style: TextStyle(
                    fontSize: AppTheme.responsiveFont(
                      context,
                      phone: 14,
                      tablet: 16,
                    ),
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 24,
                    tablet: 28,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.responsiveSize(
                          context,
                          phone: 16,
                          tablet: 20,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.responsiveSize(
                            context,
                            phone: 12,
                            tablet: 16,
                          ),
                        ),
                      ),
                    ),
                    child: Text(
                      'Awesome!',
                      style: TextStyle(
                        fontSize: AppTheme.responsiveFont(
                          context,
                          phone: 16,
                          tablet: 18,
                        ),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
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
          const SnackBar(content: Text('Unable to open link. Please try again later.')),
        );
      }
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final creditManager = context.watch<CreditManager>();
    final adProvider = context.watch<AdProvider>();

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        toolbarHeight: AppTheme.appBarHeight(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.primaryColor,
            size: AppTheme.responsiveSize(context, phone: 24, tablet: 28),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Get Credits',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: AppTheme.responsiveFont(context, phone: 20, tablet: 24),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppTheme.primaryColor,
              size: AppTheme.responsiveSize(context, phone: 22, tablet: 26),
            ),
            onPressed: _isLoading ? null : _handleRestore,
            tooltip: 'Restore Purchases',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Loading products...',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Credits Display
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.responsiveSize(
                        context,
                        phone: 40,
                        tablet: 56,
                      ),
                      horizontal: AppTheme.responsiveSize(
                        context,
                        phone: 24,
                        tablet: 32,
                      ),
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor1,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Your Credits',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: AppTheme.responsiveFont(
                              context,
                              phone: 16,
                              tablet: 20,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: AppTheme.responsiveSize(
                            context,
                            phone: 12,
                            tablet: 18,
                          ),
                        ),
                        Text(
                          '${creditManager.credits}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTheme.responsiveFont(
                              context,
                              phone: 64,
                              tablet: 80,
                            ),
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(
                          height: AppTheme.responsiveSize(
                            context,
                            phone: 8,
                            tablet: 12,
                          ),
                        ),
                        Text(
                          'Use credits for AI features',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: AppTheme.responsiveFont(
                              context,
                              phone: 14,
                              tablet: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Error Message (if any)
                  if (_errorMessage != null)
                    Container(
                      margin: EdgeInsets.all(
                        AppTheme.responsiveSize(context, phone: 16, tablet: 22),
                      ),
                      padding: EdgeInsets.all(
                        AppTheme.responsiveSize(context, phone: 16, tablet: 20),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor1.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(
                          AppTheme.responsiveSize(
                            context,
                            phone: 12,
                            tablet: 16,
                          ),
                        ),
                        border: Border.all(color: AppTheme.primaryColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppTheme.primaryColor,
                            size: AppTheme.responsiveSize(
                              context,
                              phone: 22,
                              tablet: 26,
                            ),
                          ),
                          SizedBox(
                            width: AppTheme.responsiveSize(
                              context,
                              phone: 12,
                              tablet: 16,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: AppTheme.responsiveFont(
                                  context,
                                  phone: 14,
                                  tablet: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Watch Ad Section
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: AppTheme.responsiveSize(
                        context,
                        phone: 16,
                        tablet: 22,
                      ),
                      vertical: AppTheme.responsiveSize(
                        context,
                        phone: 8,
                        tablet: 12,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppTheme.responsiveSize(context, phone: 16, tablet: 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: AppTheme.responsiveSize(
                            context,
                            phone: 10,
                            tablet: 14,
                          ),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: (adProvider.isRewardedAdLoaded && !adProvider.isLoadingRewardedAd)
                            ? _watchAdForCredits
                            : null,
                        borderRadius: BorderRadius.circular(
                          AppTheme.responsiveSize(
                            context,
                            phone: 16,
                            tablet: 20,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(
                            AppTheme.responsiveSize(
                              context,
                              phone: 16,
                              tablet: 20,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(
                                  AppTheme.responsiveSize(
                                    context,
                                    phone: 12,
                                    tablet: 16,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryColor1.withOpacity(
                                    0.8,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.responsiveSize(
                                      context,
                                      phone: 12,
                                      tablet: 16,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  Icons.play_circle_filled,
                                  color: AppTheme.primaryColor,
                                  size: AppTheme.responsiveSize(
                                    context,
                                    phone: 32,
                                    tablet: 40,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: AppTheme.responsiveSize(
                                  context,
                                  phone: 16,
                                  tablet: 20,
                                ),
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
                                            fontSize: AppTheme.responsiveFont(
                                              context,
                                              phone: 15,
                                              tablet: 18,
                                            ),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: AppTheme.responsiveSize(
                                              context,
                                              phone: 8,
                                              tablet: 10,
                                            ),
                                            vertical: AppTheme.responsiveSize(
                                              context,
                                              phone: 2,
                                              tablet: 4,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.responsiveSize(
                                                context,
                                                phone: 8,
                                                tablet: 10,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            '+${CreditManager.rewardedAdCredits}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: AppTheme.responsiveFont(
                                                context,
                                                phone: 13,
                                                tablet: 16,
                                              ),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: AppTheme.responsiveSize(
                                        context,
                                        phone: 4,
                                        tablet: 6,
                                      ),
                                    ),
                                    Text(
                                      adProvider.isRewardedAdLoaded
                                          ? 'Tap to watch ad'
                                          : adProvider.isLoadingRewardedAd
                                          ? 'Loading ad...'
                                          : 'Ad not ready',
                                      style: TextStyle(
                                        fontSize: AppTheme.responsiveFont(
                                          context,
                                          phone: 13,
                                          tablet: 16,
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Buy Credits Section Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppTheme.responsiveSize(context, phone: 16, tablet: 22),
                      AppTheme.responsiveSize(context, phone: 24, tablet: 32),
                      AppTheme.responsiveSize(context, phone: 16, tablet: 22),
                      AppTheme.responsiveSize(context, phone: 8, tablet: 12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buy Credits',
                          style: TextStyle(
                            fontSize: AppTheme.responsiveFont(
                              context,
                              phone: 22,
                              tablet: 26,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(
                          height: AppTheme.responsiveSize(
                            context,
                            phone: 4,
                            tablet: 6,
                          ),
                        ),
                        Text(
                          'Credits power Renovate AI makeovers for walls, floors, exteriors, and object removal canvases.',
                          style: TextStyle(
                            fontSize: AppTheme.responsiveFont(
                              context,
                              phone: 14,
                              tablet: 18,
                            ),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Credit Packages Grid
                  if (!_iapManager.isAvailable)
                    Container(
                      margin: EdgeInsets.all(
                        AppTheme.responsiveSize(context, phone: 16, tablet: 22),
                      ),
                      padding: EdgeInsets.all(
                        AppTheme.responsiveSize(context, phone: 16, tablet: 20),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor1.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(
                          AppTheme.responsiveSize(
                            context,
                            phone: 12,
                            tablet: 16,
                          ),
                        ),
                        border: Border.all(color: AppTheme.primaryColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(
                            width: AppTheme.responsiveSize(
                              context,
                              phone: 12,
                              tablet: 16,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'In-App Purchases are not available on this device. Please check your device settings.',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: AppTheme.responsiveFont(
                                  context,
                                  phone: 14,
                                  tablet: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_iapManager.products.isEmpty)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(32),
                      child: const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading credit packages...',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.responsiveSize(
                          context,
                          phone: 16,
                          tablet: 22,
                        ),
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppTheme.responsiveSize(
                            context,
                            phone: 12,
                            tablet: 16,
                          ),
                          mainAxisSpacing: AppTheme.responsiveSize(
                            context,
                            phone: 12,
                            tablet: 16,
                          ),
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _iapManager.products.length,
                        itemBuilder: (context, index) {
                          final product = _iapManager.products[index];
                          final credits =
                              IAPManager.productCredits[product.id] ?? 0;
                          final isThisProductPurchasing =
                              _isPurchasing &&
                              _currentPurchasingProductId == product.id;

                          return NatureCreditCard(
                            price: product.price,
                            credits: credits,
                            isPurchasing: isThisProductPurchasing,
                            onTap: () => _handlePurchase(product),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Restore Purchases Button
                  Center(
                    child: TextButton.icon(
                      onPressed: _isLoading ? null : _handleRestore,
                      icon: const Icon(
                        Icons.restore,
                        color: AppTheme.primaryColor,
                      ),
                      label: const Text(
                        'Restore Purchases',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),



                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => _launchExternalLink(
                            'https://vectorlabzlimited.com/privacy-policy/',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                          ),
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: AppTheme.responsiveFont(
                                context,
                                phone: 14,
                                tablet: 16,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          ' | ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: AppTheme.responsiveFont(
                              context,
                              phone: 14,
                              tablet: 16,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _launchExternalLink(
                            'https://vectorlabzlimited.com/terms-of-use/',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                          ),
                          child: Text(
                            'Terms of Use',
                            style: TextStyle(
                              fontSize: AppTheme.responsiveFont(
                                context,
                                phone: 14,
                                tablet: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.responsiveSize(context, phone: 24, tablet: 32),
                    ).copyWith(bottom: AppTheme.responsiveSize(context, phone: 8, tablet: 10)),
                    child: Container(
                      padding: EdgeInsets.all(
                        AppTheme.responsiveSize(context, phone: 12, tablet: 16),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor,
                        borderRadius: BorderRadius.circular(
                          AppTheme.responsiveSize(context, phone: 12, tablet: 16),
                        ),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: AppTheme.responsiveSize(context, phone: 6, tablet: 10),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Purchase Information',
                            style: TextStyle(
                              fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 14),
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: AppTheme.responsiveSize(context, phone: 4, tablet: 6),
                          ),
                          Text(
                            'Credits are granted for a lifetime until they are consumed and cannot be changed, transferred.',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 14),
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // FAQs Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                      AppTheme.responsiveSize(context, phone: 24, tablet: 32),
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(
                        AppTheme.responsiveSize(context, phone: 18, tablet: 22),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FAQs',
                          style: TextStyle(
                            fontSize: AppTheme.responsiveFont(
                              context,
                              phone: 20,
                              tablet: 24,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: AppTheme.responsiveSize(
                            context,
                            phone: 16,
                            tablet: 20,
                          ),
                        ),
                        _buildFAQItem(
                          'How can I spend Renovate AI credits?',
                          'Use them to generate new wall, floor, exterior, and object removal previews with Renovate AI.',
                        ),
                        _buildFAQItem(
                          'Do credits expire?',
                          'Credits never expire — they stay in your account until you use them.',
                        ),
                        _buildFAQItem(
                          'How many credits do I start with?',
                          'Fresh installs get 30 complimentary Renovate AI credits to explore makeovers.',
                        ),
                        _buildFAQItem(
                          'How do I add more credits?',
                          'You can watch rewarded ads to earn bonus credits or buy a Renovate AI pack below.',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildFAQItem(String question, String answer, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppTheme.responsiveFont(context, phone: 15, tablet: 18),
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: AppTheme.responsiveSize(context, phone: 4, tablet: 6),
          ),
          Text(
            answer,
            style: TextStyle(
              color: Colors.white70,
              fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class NatureCreditCard extends StatelessWidget {
  final String price;
  final int credits;
  final bool isPurchasing;
  final VoidCallback onTap;

  const NatureCreditCard({
    Key? key,
    required this.price,
    required this.credits,
    required this.isPurchasing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isPurchasing ? null : onTap,
        borderRadius: BorderRadius.circular(
          AppTheme.responsiveSize(context, phone: 16, tablet: 20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor1,
            borderRadius: BorderRadius.circular(
              AppTheme.responsiveSize(context, phone: 16, tablet: 20),
            ),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: AppTheme.responsiveSize(context, phone: 2, tablet: 3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.1),
                blurRadius: AppTheme.responsiveSize(
                  context,
                  phone: 8,
                  tablet: 12,
                ),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(
              AppTheme.responsiveSize(context, phone: 12, tablet: 16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    AppTheme.responsiveSize(context, phone: 12, tablet: 16),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppTheme.responsiveSize(context, phone: 12, tablet: 16),
                    ),
                  ),
                  child: Icon(
                    Icons.credit_card_rounded,
                    color: AppTheme.primaryColor,
                    size: AppTheme.responsiveSize(
                      context,
                      phone: 28,
                      tablet: 34,
                    ),
                  ),
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 8,
                    tablet: 12,
                  ),
                ),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$credits Credits',
                        style: TextStyle(
                          fontSize: AppTheme.responsiveFont(
                            context,
                            phone: 16,
                            tablet: 20,
                          ),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        height: AppTheme.responsiveSize(
                          context,
                          phone: 4,
                          tablet: 6,
                        ),
                      ),
                      Text(
                        '$credits Credits for Renovate AI makeovers',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppTheme.responsiveFont(
                            context,
                            phone: 11,
                            tablet: 14,
                          ),
                          color: Colors.grey[700],
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 8,
                    tablet: 12,
                  ),
                ),
                if (isPurchasing)
                  SizedBox(
                    width: AppTheme.responsiveSize(
                      context,
                      phone: 24,
                      tablet: 28,
                    ),
                    height: AppTheme.responsiveSize(
                      context,
                      phone: 24,
                      tablet: 28,
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: AppTheme.responsiveSize(
                        context,
                        phone: 2,
                        tablet: 2.5,
                      ),
                      color: AppTheme.primaryColor,
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.responsiveSize(
                        context,
                        phone: 8,
                        tablet: 12,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(
                        AppTheme.responsiveSize(context, phone: 12, tablet: 16),
                      ),
                    ),
                    child: Text(
                      price,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.responsiveFont(
                          context,
                          phone: 14,
                          tablet: 18,
                        ),
                      ),
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
*/
