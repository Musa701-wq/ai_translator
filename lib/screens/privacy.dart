// lib/screens/privacy_policy_page.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          'Privacy Policy',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTheme.getResponsiveFontSize(context, 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          AppTheme.getResponsivePadding(context, 16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 24),
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: AppTheme.getResponsiveSpacing(context, 16)),
            Text(
              'Your privacy policy content will be added here.',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}