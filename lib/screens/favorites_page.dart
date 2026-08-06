// lib/screens/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'history.dart' show TranslationHistory, TranslationHistoryService;
import 'history_page.dart' show showTranslationBottomSheet;

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<TranslationHistory> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      final favorites = await TranslationHistoryService.getFavoriteTranslations();

      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to load favorites: $e', isError: true);
    }
  }

  Future<void> _toggleFavorite(TranslationHistory translation) async {
    try {
      await TranslationHistoryService.toggleFavorite(
          translation.id!, !translation.isFavorite);
      await _loadFavorites();
      _showSnackBar(
          translation.isFavorite ? 'Removed from favorites' : 'Added to favorites');
    } catch (e) {
      _showSnackBar('Failed to update favorite: $e', isError: true);
    }
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copied to clipboard');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : AppTheme.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

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
          'Favorites',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: AppTheme.getResponsiveFontSize(context, 20),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
              ),
            )
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: AppTheme.getResponsiveIconSize(context, 80),
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: AppTheme.getResponsiveSpacing(context, 16)),
                      Text(
                        'No favorites yet',
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 18),
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: AppTheme.getResponsiveSpacing(context, 8)),
                      Text(
                        'Tap the heart icon to add translations to favorites',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 14),
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16)),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final translation = _favorites[index];
                    return GestureDetector(
                      onTap: () {
                        // Show bottom sheet with details
                        showTranslationBottomSheet(
                          context,
                          translation,
                          () => _toggleFavorite(translation),
                          _copyText,
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: AppTheme.getResponsiveSpacing(context, 12),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppTheme.getResponsiveRadius(context, 16),
                          ),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.25),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Padding(
                              padding: EdgeInsets.all(
                                AppTheme.getResponsivePadding(context, 12),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _getTypeIcon(translation.translationType),
                                    style: TextStyle(
                                      fontSize: AppTheme.getResponsiveFontSize(context, 20),
                                    ),
                                  ),
                                  SizedBox(
                                    width: AppTheme.getResponsiveSpacing(context, 8),
                                  ),
                                  Text(
                                    '${translation.sourceLanguage} → ${translation.targetLanguage}',
                                    style: TextStyle(
                                      fontSize: AppTheme.getResponsiveFontSize(context, 12),
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatTimestamp(translation.timestamp),
                                    style: TextStyle(
                                      fontSize: AppTheme.getResponsiveFontSize(context, 11),
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            // Original Text
                            Padding(
                              padding: EdgeInsets.all(
                                AppTheme.getResponsivePadding(context, 12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          translation.originalText,
                                          style: TextStyle(
                                            fontSize: AppTheme.getResponsiveFontSize(context, 15),
                                            color: Colors.black87,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.copy,
                                          size: AppTheme.getResponsiveIconSize(context, 18),
                                        ),
                                        onPressed: () =>
                                            _copyText(translation.originalText),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: AppTheme.getResponsiveSpacing(context, 8),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.translate,
                                        size: AppTheme.getResponsiveIconSize(context, 16),
                                        color: AppTheme.primaryBlue,
                                      ),
                                      SizedBox(
                                        width: AppTheme.getResponsiveSpacing(context, 4),
                                      ),
                                      Expanded(
                                        child: Text(
                                          translation.translatedText,
                                          style: TextStyle(
                                            fontSize: AppTheme.getResponsiveFontSize(context, 15),
                                            color: AppTheme.primaryBlue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.copy,
                                          size: AppTheme.getResponsiveIconSize(context, 18),
                                          color: AppTheme.primaryBlue,
                                        ),
                                        onPressed: () =>
                                            _copyText(translation.translatedText),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Actions
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.getResponsivePadding(context, 8),
                                vertical: AppTheme.getResponsivePadding(context, 4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: AppTheme.getResponsiveIconSize(context, 20),
                                    ),
                                    onPressed: () => _toggleFavorite(translation),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

