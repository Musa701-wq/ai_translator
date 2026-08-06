import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../services/ttc_services.dart';
import '../in_app_purchase/credit_manager.dart';
import 'history.dart';

class SmartDictionaryPage extends StatefulWidget {
  const SmartDictionaryPage({super.key});

  @override
  State<SmartDictionaryPage> createState() => _SmartDictionaryPageState();
}

class _SmartDictionaryPageState extends State<SmartDictionaryPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Chinese',
    'Japanese',
    'Korean',
    'Arabic',
    'Hindi',
    'Urdu',
  ];

  String _selectedLanguage = 'English';
  String? _searchedWord;
  bool _isLoading = false;

  final List<String> _popularWords = [
    'Goods',
    'Hello',
    'Thank you',
    'Welcome',
    'Beautiful',
    'Friend',
  ];
  // lib/screens/dictionary_page.dart
// ... existing code ...

  void _searchWord(String word) async {
    if (word.trim().isEmpty) return;

    // ✅ Check credits before dictionary search (3 credits per word)
    final creditManager = context.read<CreditManager>();
    const requiredCredits = 3;
    if (!creditManager.hasEnoughCredits(requiredCredits)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient credits. You need $requiredCredits credits to search dictionary.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _searchedWord = word.trim();
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // ✅ Deduct credits after successful search
    final deducted = await creditManager.deductCredits(requiredCredits, reason: 'dictionary_search');
    if (!deducted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to deduct credits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = false;
    });

    // ✅ ADD THIS: Save dictionary search to history
    await TranslationHistoryService.addTranslation(
      originalText: word,
      translatedText: 'Dictionary search for "$word"',
      sourceLanguage: _selectedLanguage,
      targetLanguage: _selectedLanguage,
      translationType: 'dictionary', // Add new type for dictionary
    );

    // Navigate to word detail page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordDetailPage(
          word: _searchedWord!,
          language: _selectedLanguage,
        ),
      ),
    );
  }

// ... rest of the code ...

/*
  void _searchWord(String word) async {
    if (word.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchedWord = word.trim();
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    // Navigate to word detail page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordDetailPage(
          word: _searchedWord!,
          language: _selectedLanguage,
        ),
      ),
    );
  }
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Smart Dictionary',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Row(
              children: [
                // Language Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    items: _languages.map((String lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(lang),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedLanguage = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Search Field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for words...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: _searchWord,
                  ),
                ),
                const SizedBox(width: 12),
                // Search Button
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white, size: 28),
                    onPressed: () => _searchWord(_searchController.text),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Discover Words Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: AppTheme.primaryBlue,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Discover Words',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Search your word to see its meaning,\ntranslations, and usage examples.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Feature Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FeatureIcon(
                  icon: Icons.translate,
                  label: 'Translations',
                  color: AppTheme.lightBlue,
                ),
                _FeatureIcon(
                  icon: Icons.record_voice_over,
                  label: 'Pronunciation',
                  color: Colors.green[50]!,
                ),
                _FeatureIcon(
                  icon: Icons.format_quote,
                  label: 'Examples',
                  color: Colors.orange[50]!,
                ),
              ],
            ),

            const SizedBox(height: 50),

            // Popular Words
            const Text(
              'Popular Words',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _popularWords.map((word) {
                return GestureDetector(
                  onTap: () => _searchWord(word),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      word,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureIcon({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: icon == Icons.translate
                ? AppTheme.primaryBlue
                : icon == Icons.record_voice_over
                ? Colors.green
                : Colors.orange,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

// Word Detail Page
class WordDetailPage extends StatefulWidget {
  final String word;
  final String language;

  const WordDetailPage({
    super.key,
    required this.word,
    required this.language,
  });

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _wordData;

  @override
  void initState() {
    super.initState();
    _loadWordData();
  }

  Future<void> _loadWordData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _wordData = {
        'word': widget.word.toLowerCase(),
        'definitions': [
          {
            'type': 'N/A',
            'meaning': 'Bienes',
          }
        ],
        'translations': {
          'Spanish': 'Bienes',
          'French': 'Biens',
          'German': 'Waren',
        },
        'pronunciation': 'ɡʊdz',
        'examples': [
          'These goods are imported from China.',
          'The store sells various goods.',
        ],
      };
      _isLoading = false;
    });
  }

  Future<void> _speak(String text) async {
    try {
      await TTSService.speak(text, 'en-US');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to play audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.word.toLowerCase(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word with pronunciation
            Row(
              children: [
                Text(
                  _wordData!['word'],
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    color: AppTheme.primaryBlue,
                    size: 32,
                  ),
                  onPressed: () => _speak(_wordData!['word']),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Definitions
            const Text(
              'Definitions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            ...(_wordData!['definitions'] as List).map((def) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        def['type'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      def['meaning'],
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Translations
            const Text(
              'Translations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            ...(_wordData!['translations'] as Map<String, dynamic>)
                .entries
                .map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Pronunciation (if API available)
            const Text(
              'Pronunciation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.record_voice_over, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  Text(
                    _wordData!['pronunciation'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Examples
            const Text(
              'Examples',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            ...(_wordData!['examples'] as List).map((example) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        example,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.orange[900],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}