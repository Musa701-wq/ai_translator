// lib/screens/about_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@aitranslator.com', // Replace with your actual email
      queryParameters: {
        'subject': 'AI Translator Support',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    // Add your privacy policy URL here
    final Uri url = Uri.parse('https://your-privacy-policy-url.com');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _rateApp() async {
    // Add your app store URL here
    final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=com.aitranslator.app');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppTheme.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTheme.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16.0)),
          child: Column(
            children: [
              SizedBox(height: isTablet ? 40 : 32),

              // ========== OLD SECTION START (FROM FIRST SCREENSHOTS) ==========

              // App Icon
              Container(
                width: isTablet ? 180 : 150,
                height: isTablet ? 180 : 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/app_icon.png', // Add your app icon here
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1565C0),
                              Color(0xFF2196F3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.translate,
                            size: isTablet ? 80 : 60,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 32 : 24),

              // App Name
              Text(
                'AI Translator',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 32),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),

              // Subtitle
              Text(
                'AI-Powered Translation',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: isTablet ? 16 : 12),

              // Version
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 14),
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: isTablet ? 60 : 48),

              // About AI Translator Section
              Text(
                'About AI Translator',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 20 : 16),

              Text(
                'AI Translator revolutionizes language translation with cutting-edge AI technology. Our app provides seamless translation across text, voice, images, and real-time conversations, breaking down language barriers and connecting people worldwide.',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.grey[700],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 48 : 40),

              // Key Features Section
              Text(
                'Key Features',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 24 : 20),

              // Feature List
              _buildFeatureItem(
                context,
                icon: Icons.translate,
                iconColor: AppTheme.pinkIcon,
                iconBgColor: AppTheme.pinkIconBg.withOpacity(0.3),
                title: 'Text Translation',
                description: 'Translate between 100+ languages instantly',
              ),
              _buildFeatureItem(
                context,
                icon: Icons.camera_alt,
                iconColor: AppTheme.cyanIcon,
                iconBgColor: AppTheme.cyanIconBg.withOpacity(0.3),
                title: 'Scan & Translate',
                description: 'Real-time camera translation with AR overlay',
              ),
              _buildFeatureItem(
                context,
                icon: Icons.mic,
                iconColor: AppTheme.greenIcon,
                iconBgColor: AppTheme.greenIconBg.withOpacity(0.3),
                title: 'Voice Translation',
                description: 'Speech-to-text translation with voice output',
              ),
              _buildFeatureItem(
                context,
                icon: Icons.people,
                iconColor: AppTheme.orangeIcon,
                iconBgColor: AppTheme.orangeIconBg.withOpacity(0.3),
                title: 'Live Conversation',
                description: 'Real-time bilingual conversation support',
              ),
              _buildFeatureItem(
                context,
                icon: Icons.image,
                iconColor: AppTheme.primaryBlue,
                iconBgColor: AppTheme.lightBlue,
                title: 'Photo Translation',
                description: 'Extract and translate text from images',
              ),
              _buildFeatureItem(
                context,
                icon: Icons.menu_book,
                iconColor: AppTheme.purpleIcon,
                iconBgColor: AppTheme.purpleIconBg.withOpacity(0.3),
                title: 'Smart Dictionary',
                description: 'Detailed definitions and usage examples',
              ),

              // ========== OLD SECTION END ==========

              SizedBox(height: isTablet ? 48 : 40),

              // ========== NEW SECTION START (FROM SECOND SCREENSHOTS) ==========

              // Powered by Advanced AI Section
              Text(
                'Powered by Advanced AI',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 20 : 16),

              Text(
                'Our neural machine translation technology ensures accurate, context-aware translations that preserve meaning and nuance.',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 24 : 20),

              // Technology Tags
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildTechTag(context, 'Neural Machine Translation'),
                  _buildTechTag(context, 'OCR Technology'),
                  _buildTechTag(context, 'Speech Recognition'),
                  _buildTechTag(context, 'Context Awareness'),
                  _buildTechTag(context, 'Real-time Processing'),
                ],
              ),

              SizedBox(height: isTablet ? 48 : 40),

              // Our Mission Section
              Text(
                'Our Mission',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 20 : 16),

              Text(
                'We believe language should never be a barrier to communication. Our mission is to create technology that brings people together through seamless, accurate, and accessible translation.',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isTablet ? 48 : 40),

              // Connect With Us Section
              Text(
                'Connect With Us',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 24 : 20),

              // Support Button
              _buildActionButton(
                context,
                icon: Icons.email_outlined,
                label: 'Support',
                onTap: _launchEmail,
              ),
              SizedBox(height: isTablet ? 16 : 12),

              // Rate App Button
              _buildActionButton(
                context,
                icon: Icons.star_outline,
                label: 'Rate App',
                onTap: _rateApp,
              ),
              SizedBox(height: isTablet ? 16 : 12),

              // Share App Button
              _buildActionButton(
                context,
                icon: Icons.share_outlined,
                label: 'Share App',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality will be added'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              SizedBox(height: isTablet ? 16 : 12),

              // Privacy Policy Button
              _buildActionButton(
                context,
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: _launchPrivacyPolicy,
              ),

              // ========== NEW SECTION END ==========

              SizedBox(height: isTablet ? 48 : 40),

              // Copyright Footer
              Center(
                child: Text(
                  '© 2024 AI Translator. All rights reserved.',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 13),
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isTablet ? 32 : 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required Color iconBgColor,
        required String title,
        required String description,
      }) {
    final isTablet = AppTheme.isTablet(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 24 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? 60 : 50,
            height: isTablet ? 60 : 50,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: isTablet ? 28 : 24,
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: isTablet ? 8 : 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 14),
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechTag(BuildContext context, String label) {
    final isTablet = AppTheme.isTablet(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 20,
        vertical: isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppTheme.getResponsiveFontSize(context, 14),
          color: AppTheme.primaryBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    final isTablet = AppTheme.isTablet(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: screenWidth * 0.9, // 90% of screen width
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 28 : 24,
          vertical: isTablet ? 20 : 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lightBlue,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: isTablet ? 26 : 22,
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}