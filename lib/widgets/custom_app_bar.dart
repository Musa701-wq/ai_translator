/*

import 'package:flutter/material.dart';
import '../screens/about_page.dart';
import '../screens/subscription.dart';
import '../screens/history_page.dart';
import '../screens/favorites_page.dart';
import '../utils/app_theme.dart';

class AppBarWidget extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onDiamondTap;

  const AppBarWidget({
    super.key,
    this.onMenuTap,
    this.onDiamondTap,
  });

  void _showMenuDropdown(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final isTablet = AppTheme.isTablet(context);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + renderBox.size.width - (isTablet ? 220 : 200),
        offset.dy + renderBox.size.height + 8,
        offset.dx + renderBox.size.width,
        0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      items: [
        PopupMenuItem(
          value: 'history',
          child: Row(
            children: [
              Icon(
                Icons.history,
                size: isTablet ? 22 : 20,
                color: Colors.grey[700],
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'History',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'favorites',
          child: Row(
            children: [
              Icon(
                Icons.favorite_border,
                size: isTablet ? 22 : 20,
                color: Colors.grey[700],
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'Favorites',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'subscription',
          child: Row(
            children: [
              Icon(
                Icons.diamond_outlined,
                size: isTablet ? 22 : 20,
                color: Colors.grey[700],
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'Subscription',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'about',
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: isTablet ? 22 : 20,
                color: Colors.grey[700],
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'About',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 'history':
            // Navigate to History page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HistoryPage(),
              ),
            );
            break;
          case 'favorites':
            // Navigate to Favorites page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FavoritesPage(),
              ),
            );
            break;
          case 'subscription':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubscriptionPage(),
              ),
            );
            break;
          case 'about':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AboutPage(),
              ),
            );
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppTheme.isTablet(context);

    return Padding(
      padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'AI Translator',
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 28),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onDiamondTap ??
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubscriptionPage(),
                        ),
                      );
                    },
                child: Icon(
                  Icons.diamond_outlined,
                  size: isTablet ? 28 : 24,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: isTablet ? 24 : 16),
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => _showMenuDropdown(context),
                  child: Icon(
                    Icons.menu,
                    size: isTablet ? 32 : 28,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}*/
// lib/widgets/app_bar_widget.dart

import 'package:flutter/material.dart';
import '../screens/about_page.dart';
import '../screens/subscription.dart';
import '../screens/history_page.dart';
import '../screens/favorites_page.dart';
import '../screens/profile_screen.dart';
import '../utils/app_theme.dart';

class AppBarWidget extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onDiamondTap;

  const AppBarWidget({
    super.key,
    this.onMenuTap,
    this.onDiamondTap,
  });

  void _showMenuDropdown(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final isTablet = AppTheme.isTablet(context);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + renderBox.size.width - (isTablet ? 220 : 200),
        offset.dy + renderBox.size.height + 8,
        offset.dx + renderBox.size.width,
        0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      items: [
        PopupMenuItem(
          value: 'history',
          child: Row(
            children: [
              Icon(
                Icons.history,
                size: isTablet ? 22 : 20,
                color: Colors.grey[700],
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'History',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'favorites',
          child: Row(
            children: [
              Icon(
                Icons.favorite_border,
                size: isTablet ? 22 : 20,
                color: Colors.grey[700],
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'Favorites',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'subscription',
          child: Row(
            children: [
              Icon(
                Icons.diamond_outlined,
                size: isTablet ? 22 : 20,
                color: Colors.grey[700],
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'Subscription',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                size: isTablet ? 22 : 20,
                color: Colors.grey[700],
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'about',
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: isTablet ? 22 : 20,
                color: Colors.grey[700],
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'About',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 'history':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HistoryPage(),
              ),
            );
            break;
          case 'favorites':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FavoritesPage(),
              ),
            );
            break;
          case 'subscription':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubscriptionPage(),
              ),
            );
            break;
          case 'profile':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
            break;
          case 'about':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AboutPage(),
              ),
            );
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppTheme.isTablet(context);

    return Padding(
      padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'AI Translator',
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 28),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onDiamondTap ??
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubscriptionPage(),
                        ),
                      );
                    },
                child: Icon(
                  Icons.diamond_outlined,
                  size: isTablet ? 28 : 24,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: isTablet ? 24 : 16),
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => _showMenuDropdown(context),
                  child: Icon(
                    Icons.menu,
                    size: isTablet ? 32 : 28,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}