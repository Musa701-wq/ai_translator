// lib/widgets/greeting_widget.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.getResponsivePadding(context, 16),
        AppTheme.getResponsivePadding(context, 32),
        AppTheme.getResponsivePadding(context, 16),
        AppTheme.getResponsivePadding(context, 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning, User!',
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 36),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: AppTheme.isTablet(context) ? 12 : 8),
          Text(
            'What would you like to translate today?',
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 18),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}