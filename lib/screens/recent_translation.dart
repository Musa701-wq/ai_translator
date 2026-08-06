/*
// lib/widgets/recent_translations.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'history.dart';

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
      print("🔄 Loading recent translations..."); // Debug print
      final translations = await TranslationHistoryService.getRecentTranslations(3); // Changed to 3
      print("✅ Loaded ${translations.length} translations"); // Debug print

      setState(() {
        _recentTranslations = translations;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading translations: $e"); // Debug print
      setState(() {
        _isLoading = false;
      });
    }
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

  void _showDetail(TranslationHistory translation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _getTypeIcon(translation.translationType),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${translation.sourceLanguage} → ${translation.targetLanguage}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    Text(
                      _formatTime(translation.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Original Text',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translation.originalText,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            const Text(
              'Translation',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translation.translatedText,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
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
                  fontSize: AppTheme.getResponsiveFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Add navigation to full history page here if you have one
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
          // Show empty state
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
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No translations yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your translations will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _recentTranslations.map((translation) {
                return GestureDetector(
                  onTap: () => _showDetail(translation),
                  child: Container(
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
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}*/
/*
// lib/widgets/recent_translations.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'history.dart'; // ✅ Add this import

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
      print("🔄 Loading recent translations...");
      final translations = await TranslationHistoryService.getRecentTranslations(3);
      print("✅ Loaded ${translations.length} translations");

      // Debug: Print all translations
      for (var t in translations) {
        print("📝 ${t.originalText} → ${t.translatedText}");
      }

      setState(() {
        _recentTranslations = translations;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading translations: $e");
      setState(() {
        _isLoading = false;
      });
    }
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
    return Container(
      child: _isLoading
          ? Container(
        height: 100,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: AppTheme.primaryBlue),
      )
          : _recentTranslations.isEmpty
          ? Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No translations yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your translations will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      )
          : Column(
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
    );
  }
}*/
// lib/widgets/recent_translations.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'history.dart';

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
      print("🔄 Loading recent translations...");
      final translations = await TranslationHistoryService.getRecentTranslations(3);
      print("✅ Loaded ${translations.length} translations");

      // Debug: Print all translations
      for (var t in translations) {
        print("📝 ${t.originalText} → ${t.translatedText}");
      }

      setState(() {
        _recentTranslations = translations;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading translations: $e");
      setState(() {
        _isLoading = false;
      });
    }
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
    return Container(
      child: _isLoading
          ? Container(
        height: 100,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: AppTheme.primaryBlue),
      )
          : _recentTranslations.isEmpty
          ? Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No translations yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your translations will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      )
          : Column(
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
    );
  }
}
