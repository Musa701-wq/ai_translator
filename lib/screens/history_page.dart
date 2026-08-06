// lib/pages/history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'history.dart' show TranslationHistory, TranslationHistoryService;

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<TranslationHistory> _translations = [];
  List<TranslationHistory> _filteredTranslations = [];
  bool _isLoading = true;
  bool _showFavoritesOnly = false;
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTranslations();
    _searchController.addListener(_filterTranslations);
  }

  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      List<TranslationHistory> translations;

      if (_showFavoritesOnly) {
        translations = await TranslationHistoryService.getFavoriteTranslations();
      } else if (_selectedFilter == 'all') {
        translations = await TranslationHistoryService.getAllTranslations();
      } else {
        translations = await TranslationHistoryService.getTranslationsByType(
            _selectedFilter);
      }

      setState(() {
        _translations = translations;
        _filteredTranslations = translations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to load history: $e', isError: true);
    }
  }

  void _filterTranslations() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredTranslations = _translations;
      });
    } else {
      setState(() {
        _filteredTranslations = _translations.where((translation) {
          return translation.originalText.toLowerCase().contains(query) ||
              translation.translatedText.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  Future<void> _toggleFavorite(TranslationHistory translation) async {
    try {
      await TranslationHistoryService.toggleFavorite(
          translation.id!, !translation.isFavorite);
      await _loadTranslations();
    } catch (e) {
      _showSnackBar('Failed to update favorite: $e', isError: true);
    }
  }

  Future<void> _deleteTranslation(int id) async {
    try {
      await TranslationHistoryService.deleteTranslation(id);
      await _loadTranslations();
      _showSnackBar('Translation deleted');
    } catch (e) {
      _showSnackBar('Failed to delete: $e', isError: true);
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
            'Are you sure you want to delete all translation history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await TranslationHistoryService.clearHistory();
        await _loadTranslations();
        _showSnackBar('History cleared');
      } catch (e) {
        _showSnackBar('Failed to clear history: $e', isError: true);
      }
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Translation History',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: AppTheme.getResponsiveFontSize(context, 20),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? Colors.red : Colors.black,
              size: AppTheme.getResponsiveIconSize(context, 24),
            ),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
              _loadTranslations();
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
              size: AppTheme.getResponsiveIconSize(context, 24),
            ),
            onSelected: (value) {
              if (value == 'clear') {
                _clearHistory();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear History'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16)),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
              ),
              decoration: InputDecoration(
                hintText: 'Search translations...',
                hintStyle: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.primaryBlue,
                  size: AppTheme.getResponsiveIconSize(context, 24),
                ),
                filled: true,
                fillColor: AppTheme.lightBlue.withOpacity(0.3),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getResponsivePadding(context, 16),
                  vertical: AppTheme.getResponsivePadding(context, 16),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.getResponsiveRadius(context, 12),
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getResponsivePadding(context, 16),
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedFilter == 'all',
                  onTap: () {
                    setState(() => _selectedFilter = 'all');
                    _loadTranslations();
                  },
                ),
                SizedBox(width: AppTheme.getResponsiveSpacing(context, 8)),
                _FilterChip(
                  label: 'Text',
                  selected: _selectedFilter == 'text',
                  onTap: () {
                    setState(() => _selectedFilter = 'text');
                    _loadTranslations();
                  },
                ),
                SizedBox(width: AppTheme.getResponsiveSpacing(context, 8)),
                _FilterChip(
                  label: 'Voice',
                  selected: _selectedFilter == 'voice',
                  onTap: () {
                    setState(() => _selectedFilter = 'voice');
                    _loadTranslations();
                  },
                ),
                SizedBox(width: AppTheme.getResponsiveSpacing(context, 8)),
                _FilterChip(
                  label: 'Scan',
                  selected: _selectedFilter == 'scan',
                  onTap: () {
                    setState(() => _selectedFilter = 'scan');
                    _loadTranslations();
                  },
                ),
                SizedBox(width: AppTheme.getResponsiveSpacing(context, 8)),
                _FilterChip(
                  label: 'Conversation',
                  selected: _selectedFilter == 'conversation',
                  onTap: () {
                    setState(() => _selectedFilter = 'conversation');
                    _loadTranslations();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Translations List
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
              ),
            )
                : _filteredTranslations.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: AppTheme.getResponsiveIconSize(context, 80),
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: AppTheme.getResponsiveSpacing(context, 16)),
                  Text(
                    _showFavoritesOnly
                        ? 'No favorites yet'
                        : 'No translations yet',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 18),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16)),
              itemCount: _filteredTranslations.length,
              itemBuilder: (context, index) {
                final translation = _filteredTranslations[index];
                return GestureDetector(
                  onTap: () {
                    // Show bottom sheet with full details
                    showTranslationBottomSheet(
                      context,
                      translation,
                      () => _toggleFavorite(translation),
                      _copyText,
                    );
                  },
                  child: _TranslationCard(
                    translation: translation,
                    onToggleFavorite: () =>
                        _toggleFavorite(translation),
                    onDelete: () =>
                        _deleteTranslation(translation.id!),
                    onCopyOriginal: () =>
                        _copyText(translation.originalText),
                    onCopyTranslated: () =>
                        _copyText(translation.translatedText),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom sheet function for showing translation details
void showTranslationBottomSheet(
  BuildContext context,
  TranslationHistory translation,
  VoidCallback onToggleFavorite,
  Function(String) onCopyText,
) {
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

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getResponsivePadding(context, 20),
                vertical: AppTheme.getResponsivePadding(context, 16),
              ),
              child: Row(
                children: [
                  Text(
                    _getTypeIcon(translation.translationType),
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 24),
                    ),
                  ),
                  SizedBox(width: AppTheme.getResponsiveSpacing(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${translation.sourceLanguage} → ${translation.targetLanguage}',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context, 16),
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppTheme.getResponsiveSpacing(context, 4)),
                        Text(
                          _formatTimestamp(translation.timestamp),
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context, 12),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      translation.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: translation.isFavorite ? Colors.red : Colors.grey,
                      size: AppTheme.getResponsiveIconSize(context, 24),
                    ),
                    onPressed: () {
                      onToggleFavorite();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Original Text Section
                    Row(
                      children: [
                        Text(
                          'Original Text',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context, 14),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.copy,
                            size: AppTheme.getResponsiveIconSize(context, 18),
                          ),
                          onPressed: () {
                            onCopyText(translation.originalText);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Copied to clipboard',
                                  style: TextStyle(
                                    fontSize: AppTheme.getResponsiveFontSize(context, 14),
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.getResponsiveSpacing(context, 8)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16)),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(
                          AppTheme.getResponsiveRadius(context, 12),
                        ),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        translation.originalText,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),
                    // Translated Text Section
                    Row(
                      children: [
                        Text(
                          'Translation',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context, 14),
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.copy,
                            size: AppTheme.getResponsiveIconSize(context, 18),
                            color: AppTheme.primaryBlue,
                          ),
                          onPressed: () {
                            onCopyText(translation.translatedText);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Copied to clipboard',
                                  style: TextStyle(
                                    fontSize: AppTheme.getResponsiveFontSize(context, 14),
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.getResponsiveSpacing(context, 8)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16)),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppTheme.getResponsiveRadius(context, 12),
                        ),
                        border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.3)),
                      ),
                      child: Text(
                        translation.translatedText,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),
                    // Translation Type
                    Row(
                      children: [
                        Text(
                          'Type: ',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context, 14),
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.getResponsivePadding(context, 12),
                            vertical: AppTheme.getResponsivePadding(context, 6),
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(
                              AppTheme.getResponsiveRadius(context, 20),
                            ),
                          ),
                          child: Text(
                            translation.translationType.toUpperCase(),
                            style: TextStyle(
                              fontSize: AppTheme.getResponsiveFontSize(context, 12),
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.getResponsivePadding(context, 16),
          vertical: AppTheme.getResponsivePadding(context, 8),
        ),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(
            AppTheme.getResponsiveRadius(context, 20),
          ),
          border: Border.all(
            color: selected ? AppTheme.primaryBlue : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: AppTheme.getResponsiveFontSize(context, 14),
          ),
        ),
      ),
    );
  }
}

class _TranslationCard extends StatelessWidget {
  final TranslationHistory translation;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;
  final VoidCallback onCopyOriginal;
  final VoidCallback onCopyTranslated;

  const _TranslationCard({
    required this.translation,
    required this.onToggleFavorite,
    required this.onDelete,
    required this.onCopyOriginal,
    required this.onCopyTranslated,
  });

  String _getTypeIcon() {
    switch (translation.translationType) {
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

  String _formatTimestamp() {
    final now = DateTime.now();
    final difference = now.difference(translation.timestamp);

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
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.getResponsiveSpacing(context, 12)),
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
            padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 12)),
            child: Row(
              children: [
                Text(
                  _getTypeIcon(),
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 20),
                  ),
                ),
                SizedBox(width: AppTheme.getResponsiveSpacing(context, 8)),
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
                  _formatTimestamp(),
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
            padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 12)),
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
                      onPressed: onCopyOriginal,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.getResponsiveSpacing(context, 8)),
                Row(
                  children: [
                    Icon(
                      Icons.translate,
                      size: AppTheme.getResponsiveIconSize(context, 16),
                      color: AppTheme.primaryBlue,
                    ),
                    SizedBox(width: AppTheme.getResponsiveSpacing(context, 4)),
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
                      onPressed: onCopyTranslated,
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
                    translation.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: translation.isFavorite ? Colors.red : Colors.grey,
                    size: AppTheme.getResponsiveIconSize(context, 20),
                  ),
                  onPressed: onToggleFavorite,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.grey,
                    size: AppTheme.getResponsiveIconSize(context, 20),
                  ),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Translation'),
                        content: const Text(
                            'Are you sure you want to delete this translation?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}