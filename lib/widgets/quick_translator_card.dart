/*
// lib/widgets/quick_translate_card.dart
import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class QuickTranslateCard extends StatelessWidget {
  final VoidCallback? onTap;

  const QuickTranslateCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isTablet = AppTheme.isTablet(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getResponsivePadding(context, 16.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightBlue,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: isTablet ? 56 : 48,
                        height: isTablet ? 56 : 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.translate,
                          color: AppTheme.primaryBlue,
                          size: isTablet ? 28 : 24,
                        ),
                      ),
                      SizedBox(width: isTablet ? 20 : 16),
                      Text(
                        'Quick Translate',
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 20),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: isTablet ? 28 : 24,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}*/
// lib/widgets/quick_translator_card.dart

import 'package:flutter/material.dart';
import '../screens/text_translate_page.dart';
import '../utils/app_theme.dart';

class QuickTranslateCard extends StatelessWidget {
  const QuickTranslateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = AppTheme.isTablet(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getResponsivePadding(context, 16.0),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TextTranslationPage(),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 20.0)),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: isTablet ? 56 : 48,
                height: isTablet ? 56 : 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.translate,
                  color: AppTheme.primaryBlue,
                  size: isTablet ? 28 : 24,
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Translate',
                      style: TextStyle(
                        fontSize: AppTheme.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap to start translating',
                      style: TextStyle(
                        fontSize: AppTheme.getResponsiveFontSize(context, 14),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.primaryBlue,
                size: isTablet ? 22 : 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}