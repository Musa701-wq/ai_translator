// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFE3F2FD);

  // Feature Card Colors
  static const Color pinkBg = Color(0xFFFCE4EC);
  static const Color pinkIconBg = Color(0xFFF8BBD0);
  static const Color pinkIcon = Color(0xFFE91E63);

  static const Color cyanBg = Color(0xFFE0F7FA);
  static const Color cyanIconBg = Color(0xFFB2EBF2);
  static const Color cyanIcon = Color(0xFF00BCD4);

  static const Color greenBg = Color(0xFFE8F5E9);
  static const Color greenIconBg = Color(0xFFC8E6C9);
  static const Color greenIcon = Color(0xFF4CAF50);

  static const Color orangeBg = Color(0xFFFFF3E0);
  static const Color orangeIconBg = Color(0xFFFFE0B2);
  static const Color orangeIcon = Color(0xFFFF9800);

  static const Color purpleBg = Color(0xFFF3E5F5);
  static const Color purpleIconBg = Color(0xFFE1BEE7);
  static const Color purpleIcon = Color(0xFF9C27B0);

  // Subscription Page Colors
  static const Color discountGreen = Color(0xFFB2DFDB);

  // Responsive Dimensions
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // iPad: typically 768px or more, iPhone: typically less than 600px
    return width >= 600;
  }

  static bool isIPad(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768;
  }

  static bool isIPhone(BuildContext context) {
    return !isTablet(context);
  }

  // Responsive Font Size
  static double getResponsiveFontSize(BuildContext context, double size) {
    if (isIPad(context)) {
      return size * 1.3; // iPad: 30% larger
    } else if (isTablet(context)) {
      return size * 1.2; // Small tablets: 20% larger
    }
    return size; // iPhone: original size
  }

  // Responsive Padding
  static double getResponsivePadding(BuildContext context, double padding) {
    if (isIPad(context)) {
      return padding * 1.8; // iPad: 80% more padding
    } else if (isTablet(context)) {
      return padding * 1.5; // Small tablets: 50% more padding
    }
    return padding; // iPhone: original padding
  }

  // Responsive Icon Size
  static double getResponsiveIconSize(BuildContext context, double size) {
    if (isIPad(context)) {
      return size * 1.4; // iPad: 40% larger icons
    } else if (isTablet(context)) {
      return size * 1.25; // Small tablets: 25% larger icons
    }
    return size; // iPhone: original size
  }

  // Responsive Spacing
  static double getResponsiveSpacing(BuildContext context, double spacing) {
    if (isIPad(context)) {
      return spacing * 1.5; // iPad: 50% more spacing
    } else if (isTablet(context)) {
      return spacing * 1.3; // Small tablets: 30% more spacing
    }
    return spacing; // iPhone: original spacing
  }

  // Responsive Border Radius
  static double getResponsiveRadius(BuildContext context, double radius) {
    if (isIPad(context)) {
      return radius * 1.2; // iPad: 20% larger radius
    } else if (isTablet(context)) {
      return radius * 1.1; // Small tablets: 10% larger radius
    }
    return radius; // iPhone: original radius
  }

  // Responsive Button Height
  static double getResponsiveButtonHeight(BuildContext context, double height) {
    if (isIPad(context)) {
      return height * 1.3; // iPad: 30% taller buttons
    } else if (isTablet(context)) {
      return height * 1.2; // Small tablets: 20% taller buttons
    }
    return height; // iPhone: original height
  }

  // Get responsive max width for content (useful for centering content on tablets)
  static double getMaxContentWidth(BuildContext context) {
    if (isIPad(context)) {
      return 900; // iPad: max width 900px
    } else if (isTablet(context)) {
      return 700; // Small tablets: max width 700px
    }
    return double.infinity; // iPhone: full width
  }
}