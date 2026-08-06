/*


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'credit_manager.dart';
import 'credit_purchase_screen.dart' show CreditsPurchaseScreen;
import '../utils/theme.dart'; // ADD THIS IMPORT

class CreditsCard extends StatelessWidget {
  final VoidCallback? onGetPressed;

  const CreditsCard({
    Key? key,
    this.onGetPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final creditManager = context.watch<CreditManager>();

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreditsPurchaseScreen(),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(AppTheme.responsiveSize(context, phone: 20, tablet: 26)),
        decoration: BoxDecoration(
          // CHANGED: Your theme colors
          gradient: LinearGradient(
            colors: [
              AppTheme.secondaryColor,
              AppTheme.secondaryColor1,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 16, tablet: 20)),
          // ADDED: Border like your other containers
          border: Border.all(
            color: AppTheme.primaryColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.responsiveSize(context, phone: 8, tablet: 10)),
                  decoration: BoxDecoration(
                    // CHANGED: Your theme color
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 8, tablet: 10)),
                  ),
                  child: Icon(
                    Icons.stars,
                    // CHANGED: Your theme color
                    color: AppTheme.primaryColor,
                    size: AppTheme.responsiveSize(context, phone: 20, tablet: 26),
                  ),
                ),
                SizedBox(width: AppTheme.responsiveSize(context, phone: 12, tablet: 16)),
                Text(
                  'Available Credits',
                  // CHANGED: Your theme color
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 20),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.responsiveSize(context, phone: 16, tablet: 22)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (creditManager.isLoading)
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        )
                      else
                        Text(
                          '${creditManager.credits}',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: AppTheme.responsiveFont(context, phone: 44, tablet: 56),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      SizedBox(height: AppTheme.responsiveSize(context, phone: 4, tablet: 8)),
                      Text(
                        'Use credits for AI styling features',
                        style: TextStyle(
                          color: AppTheme.primaryColor.withOpacity(0.8),
                          fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CreditsPurchaseScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppTheme.primaryColor,
                      width: AppTheme.responsiveSize(context, phone: 1.5, tablet: 2),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.responsiveSize(context, phone: 14, tablet: 20),
                      vertical: AppTheme.responsiveSize(context, phone: 10, tablet: 14),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 8, tablet: 12)),
                    ),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Get More',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/subscription.dart';
import '../utils/app_theme.dart' show AppTheme;
import 'credit_manager.dart';

class CreditsCard extends StatelessWidget {
  final VoidCallback? onGetPressed;

  const CreditsCard({
    Key? key,
    this.onGetPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final creditManager = context.watch<CreditManager>();

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SubscriptionPage(),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(
          AppTheme.getResponsivePadding(context, 20),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppTheme.primaryBlue,
              AppTheme.lightBlue,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(
            AppTheme.getResponsiveRadius(context, 16),
          ),
          border: Border.all(
            color: AppTheme.primaryBlue,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    AppTheme.getResponsivePadding(context, 8),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      AppTheme.getResponsiveRadius(context, 8),
                    ),
                  ),
                  child: Icon(
                    Icons.stars,
                    color: Colors.white,
                    size: AppTheme.getResponsiveIconSize(context, 20),
                  ),
                ),
                SizedBox(
                  width: AppTheme.getResponsiveSpacing(context, 12),
                ),
                Text(
                  'Available Credits',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: AppTheme.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: AppTheme.getResponsiveSpacing(context, 16),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (creditManager.isLoading)
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      else
                        Text(
                          '${creditManager.credits}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTheme.getResponsiveFontSize(
                              context,
                              44,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      SizedBox(
                        height: AppTheme.getResponsiveSpacing(
                          context,
                          4,
                        ),
                      ),
                      Text(
                        'Use credits for Renovate AI features',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: AppTheme.getResponsiveFontSize(
                            context,
                            12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppTheme.getResponsiveRadius(context, 8),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionPage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(
                        AppTheme.getResponsiveRadius(context, 8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.getResponsivePadding(
                            context,
                            14,
                          ),
                          vertical: AppTheme.getResponsivePadding(
                            context,
                            10,
                          ),
                        ),
                        child: Text(
                          'Get More',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: AppTheme.getResponsiveFontSize(
                              context,
                              14,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}