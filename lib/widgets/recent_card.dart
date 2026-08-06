// lib/widgets/recent_translations.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../screens/history.dart';
import '../screens/history_page.dart';

class RecentTranslations extends StatefulWidget {
  const RecentTranslations({super.key});

  @override
  State<RecentTranslations> createState() => _RecentTranslationsState();
}

class _RecentTranslationsState extends State<RecentTranslations> {
  List<TranslationHistory> _recentTranslations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentTranslations();
  }

  Future<void> _loadRecentTranslations() async {
    try {
      // Load 2 recent translations (including conversation now)
      final translations = await TranslationHistoryService.getRecentTranslations(2);
      
      setState(() {
        _recentTranslations = translations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Refresh when returning to home screen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when screen becomes visible again
    _loadRecentTranslations();
  }

  String _getTypeIcon(String type) {
    switch (type) {
      case 'text':
        return '📝';
      case 'voice':
        return '🎤';
      case 'scan':
        return '📷';
      case 'conversation':
        return '💬';
      case 'dictionary':
        return '📖';
      default:
        return '🌐';
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppTheme.isTablet(context);

    return Padding(
      padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Translations',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 22),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to history page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryPage(),
                    ),
                  ).then((_) {
                    // Reload when returning from history page
                    _loadRecentTranslations();
                  });
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          
          if (_isLoading)
            Container(
              height: 120,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: AppTheme.primaryBlue),
            )
          else if (_recentTranslations.isEmpty)
            // Empty state
            Container(
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: isTablet ? 48 : 40,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  Text(
                    'No recent translations yet',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 16),
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your translations will appear here',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 14),
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          else
            // Show 2 recent translations
            Column(
              children: _recentTranslations.map((translation) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _getTypeIcon(translation.translationType),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${translation.sourceLanguage} → ${translation.targetLanguage}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatTime(translation.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        translation.originalText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.translate,
                            size: 14,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              translation.translatedText,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}