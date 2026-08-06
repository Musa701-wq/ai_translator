// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTheme.getResponsiveFontSize(context, 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(
          AppTheme.getResponsivePadding(context, 16),
        ),
        child: Column(
          children: [
            // Add your settings options here
            Text(
              'Settings options will be added here',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}