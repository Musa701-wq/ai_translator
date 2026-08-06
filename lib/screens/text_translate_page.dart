/*
// lib/pages/text_translation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/gemini_text_translate.dart';
import '../utils/app_theme.dart';

class Language {
  final String name;
  final String code;
  const Language(this.name, this.code);
}

class TextTranslationPage extends StatefulWidget {
  const TextTranslationPage({super.key});

  @override
  State<TextTranslationPage> createState() => _TextTranslationPageState();
}

class _TextTranslationPageState extends State<TextTranslationPage> {
  final _sourceController = TextEditingController();
  final _translatedController = TextEditingController();

  final List<Language> _languages = const [
    Language('English', 'en'),
    Language('Spanish', 'es'),
    Language('French', 'fr'),
    Language('German', 'de'),
    Language('Italian', 'it'),
    Language('Portuguese', 'pt'),
    Language('Russian', 'ru'),
    Language('Chinese', 'zh'),
    Language('Japanese', 'ja'),
    Language('Korean', 'ko'),
    Language('Arabic', 'ar'),
    Language('Hindi', 'hi'),
    Language('Urdu', 'ur'),
    Language('Punjabi', 'pa'),
    Language('Turkish', 'tr'),
    Language('Dutch', 'nl'),
    Language('Polish', 'pl'),
    Language('Swedish', 'sv'),
    Language('Greek', 'el'),
    Language('Czech', 'cs'),
    Language('Danish', 'da'),
    Language('Finnish', 'fi'),
    Language('Hungarian', 'hu'),
    Language('Norwegian', 'no'),
    Language('Romanian', 'ro'),
    Language('Slovak', 'sk'),
    Language('Ukrainian', 'uk'),
    Language('Vietnamese', 'vi'),
    Language('Thai', 'th'),
    Language('Indonesian', 'id'),
  ];

  Language _sourceLanguage = const Language('English', 'en');
  Language _targetLanguage = const Language('Spanish', 'es');

  bool _isTranslating = false;
  bool _hasTranslated = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _sourceController.addListener(() {
      setState(() {
        _hasText = _sourceController.text.trim().isNotEmpty;
      });
    });
  }

  Future<void> _translate() async {
    final text = _sourceController.text.trim();

    if (text.isEmpty) {
      _showSnackBar('Please enter text to translate');
      return;
    }

    if (_sourceLanguage.code == _targetLanguage.code) {
      _showSnackBar('Please select different languages');
      return;
    }

    setState(() {
      _isTranslating = true;
      _translatedController.clear();
    });

    try {
      print('Translating: $text');
      print('From: ${_sourceLanguage.name} To: ${_targetLanguage.name}');

      final result = await GeminiService.translate(
        text,
        _sourceLanguage.name,
        _targetLanguage.name,
      );

      print('Translation result: $result');

      if (result.isNotEmpty) {
        setState(() {
          _translatedController.text = result;
          _isTranslating = false;
          _hasTranslated = true;
        });
        _showSnackBar('Translation complete!');
      } else {
        throw Exception('Empty translation received');
      }
    } catch (e) {
      setState(() => _isTranslating = false);
      print('Translation error: $e');
      _showSnackBar('Translation failed: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  void _swap() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      final tempText = _sourceController.text;
      _sourceController.text = _translatedController.text;
      _translatedController.text = tempText;
    });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: msg.contains('failed') || msg.contains('Error')
            ? Colors.red
            : AppTheme.primaryBlue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _copy() {
    if (_translatedController.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedController.text));
    _showSnackBar('Copied!');
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
        title: const Text(
          'Text Translation',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Language Selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Source Language Dropdown
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<Language>(
                        value: _sourceLanguage,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        dropdownColor: Colors.white,
                        items: _languages.map((Language lang) {
                          return DropdownMenuItem<Language>(
                            value: lang,
                            child: Text(lang.name),
                          );
                        }).toList(),
                        onChanged: (Language? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _sourceLanguage = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  // Swap Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GestureDetector(
                      onTap: _swap,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.swap_horiz, color: Colors.white, size: 24),
                      ),
                    ),
                  ),

                  // Target Language Dropdown
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<Language>(
                        value: _targetLanguage,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        dropdownColor: Colors.white,
                        items: _languages.map((Language lang) {
                          return DropdownMenuItem<Language>(
                            value: lang,
                            child: Text(lang.name),
                          );
                        }).toList(),
                        onChanged: (Language? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _targetLanguage = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Original Text
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        const Text('Original Text', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextField(
                      controller: _sourceController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Enter text...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Translate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_isTranslating || !_hasText) ? null : _translate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isTranslating
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.translate, size: 24),
                    SizedBox(width: 8),
                    Text('Translate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Translated Text - Only show after translation
            if (_hasTranslated)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.translate, size: 20, color: AppTheme.primaryBlue),
                          const SizedBox(width: 8),
                          const Text(
                            'Translated Text',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextField(
                        controller: _translatedController,
                        maxLines: 6,
                        readOnly: true,
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Translation will appear here...',
                          hintStyle: TextStyle(color: AppTheme.primaryBlue.withOpacity(0.4)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_hasTranslated) const SizedBox(height: 20),

            // Action Buttons - Only show after translation
            if (_hasTranslated)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.favorite_border,
                    label: 'Favorite',
                    onTap: () => _showSnackBar('Added to favorites'),
                  ),
                  _ActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () => _showSnackBar('Share feature'),
                  ),
                  _ActionButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    onTap: _copy,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }
}*/
// lib/pages/text_translation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/gemini_text_translate.dart';
import '../utils/app_theme.dart';
import '../in_app_purchase/credit_manager.dart';
import 'history.dart';

class Language {
  final String name;
  final String code;
  const Language(this.name, this.code);
}

class TextTranslationPage extends StatefulWidget {
  const TextTranslationPage({super.key});

  @override
  State<TextTranslationPage> createState() => _TextTranslationPageState();
}

class _TextTranslationPageState extends State<TextTranslationPage> {
  final _sourceController = TextEditingController();
  final _translatedController = TextEditingController();

  final List<Language> _languages = const [
    Language('English', 'en'),
    Language('Spanish', 'es'),
    Language('French', 'fr'),
    Language('German', 'de'),
    Language('Italian', 'it'),
    Language('Portuguese', 'pt'),
    Language('Russian', 'ru'),
    Language('Chinese', 'zh'),
    Language('Japanese', 'ja'),
    Language('Korean', 'ko'),
    Language('Arabic', 'ar'),
    Language('Hindi', 'hi'),
    Language('Urdu', 'ur'),
    Language('Punjabi', 'pa'),
    Language('Turkish', 'tr'),
    Language('Dutch', 'nl'),
    Language('Polish', 'pl'),
    Language('Swedish', 'sv'),
    Language('Greek', 'el'),
    Language('Czech', 'cs'),
    Language('Danish', 'da'),
    Language('Finnish', 'fi'),
    Language('Hungarian', 'hu'),
    Language('Norwegian', 'no'),
    Language('Romanian', 'ro'),
    Language('Slovak', 'sk'),
    Language('Ukrainian', 'uk'),
    Language('Vietnamese', 'vi'),
    Language('Thai', 'th'),
    Language('Indonesian', 'id'),
  ];

  Language _sourceLanguage = const Language('English', 'en');
  Language _targetLanguage = const Language('Spanish', 'es');

  bool _isTranslating = false;
  bool _hasTranslated = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _sourceController.addListener(() {
      setState(() {
        _hasText = _sourceController.text.trim().isNotEmpty;
      });
    });
  }
  // lib/screens/text_translate_page.dart
// ... existing code ...

  Future<void> _translate() async {
    final text = _sourceController.text.trim();

    if (text.isEmpty) {
      _showSnackBar('Please enter text to translate');
      return;
    }

    if (_sourceLanguage.code == _targetLanguage.code) {
      _showSnackBar('Please select different languages');
      return;
    }

    // ✅ Check credits before translation
    final creditManager = context.read<CreditManager>();
    const requiredCredits = 5;
    if (!creditManager.hasEnoughCredits(requiredCredits)) {
      _showSnackBar('Insufficient credits. You need $requiredCredits credits to translate.');
      return;
    }

    setState(() {
      _isTranslating = true;
      _translatedController.clear();
    });

    try {
      print('Translating: $text');
      print('From: ${_sourceLanguage.code} To: ${_targetLanguage.code}');

      final result = await GoogleTranslateService.translate(
        text: text,
        sourceLanguage: _sourceLanguage.code,
        targetLanguage: _targetLanguage.code,
      );

      print('Translation result: $result');

      if (result.isNotEmpty) {
        // ✅ Deduct credits after successful translation
        final deducted = await creditManager.deductCredits(requiredCredits, reason: 'text_translation');
        if (!deducted) {
          _showSnackBar('Failed to deduct credits');
        }

        setState(() {
          _translatedController.text = result;
          _isTranslating = false;
          _hasTranslated = true;
        });

        // ✅ ADD THIS: Save to history database
        await TranslationHistoryService.addTranslation(
          originalText: text,
          translatedText: result,
          sourceLanguage: _sourceLanguage.code,
          targetLanguage: _targetLanguage.code,
          translationType: 'text', // Text translation type
        );

        _showSnackBar('Translation complete!');
      } else {
        throw Exception('Empty translation received');
      }
    } catch (e) {
      setState(() => _isTranslating = false);
      print('Translation error: $e');
      _showSnackBar('Translation failed: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

// ... rest of the code ...
/*
  Future<void> _translate() async {
    final text = _sourceController.text.trim();

    if (text.isEmpty) {
      _showSnackBar('Please enter text to translate');
      return;
    }

    if (_sourceLanguage.code == _targetLanguage.code) {
      _showSnackBar('Please select different languages');
      return;
    }

    setState(() {
      _isTranslating = true;
      _translatedController.clear();
    });

    try {
      print('Translating: $text');
      print('From: ${_sourceLanguage.code} To: ${_targetLanguage.code}');

      final result = await GoogleTranslateService.translate(
        text: text,
        sourceLanguage: _sourceLanguage.code,
        targetLanguage: _targetLanguage.code,
      );

      print('Translation result: $result');

      if (result.isNotEmpty) {
        setState(() {
          _translatedController.text = result;
          _isTranslating = false;
          _hasTranslated = true;
        });
        _showSnackBar('Translation complete!');
      } else {
        throw Exception('Empty translation received');
      }
    } catch (e) {
      setState(() => _isTranslating = false);
      print('Translation error: $e');
      _showSnackBar('Translation failed: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
*/

  void _swap() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      final tempText = _sourceController.text;
      _sourceController.text = _translatedController.text;
      _translatedController.text = tempText;
    });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: msg.contains('failed') || msg.contains('Error')
            ? Colors.red
            : AppTheme.primaryBlue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _copy() {
    if (_translatedController.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedController.text));
    _showSnackBar('Copied!');
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
        title: const Text(
          'Text Translation',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Language Selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Source Language Dropdown
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<Language>(
                        value: _sourceLanguage,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        dropdownColor: Colors.white,
                        items: _languages.map((Language lang) {
                          return DropdownMenuItem<Language>(
                            value: lang,
                            child: Text(lang.name),
                          );
                        }).toList(),
                        onChanged: (Language? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _sourceLanguage = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  // Swap Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GestureDetector(
                      onTap: _swap,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.swap_horiz, color: Colors.white, size: 24),
                      ),
                    ),
                  ),

                  // Target Language Dropdown
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<Language>(
                        value: _targetLanguage,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        dropdownColor: Colors.white,
                        items: _languages.map((Language lang) {
                          return DropdownMenuItem<Language>(
                            value: lang,
                            child: Text(lang.name),
                          );
                        }).toList(),
                        onChanged: (Language? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _targetLanguage = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Original Text
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        const Text('Original Text', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextField(
                      controller: _sourceController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Enter text...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Translate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_isTranslating || !_hasText) ? null : _translate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isTranslating
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.translate, size: 24),
                    SizedBox(width: 8),
                    Text('Translate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Translated Text - Only show after translation
            if (_hasTranslated)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.translate, size: 20, color: AppTheme.primaryBlue),
                          const SizedBox(width: 8),
                          const Text(
                            'Translated Text',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextField(
                        controller: _translatedController,
                        maxLines: 6,
                        readOnly: true,
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Translation will appear here...',
                          hintStyle: TextStyle(color: AppTheme.primaryBlue.withOpacity(0.4)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_hasTranslated) const SizedBox(height: 20),

            // Action Buttons - Only show after translation
            if (_hasTranslated)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.favorite_border,
                    label: 'Favorite',
                    onTap: () => _showSnackBar('Added to favorites'),
                  ),
                  _ActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () => _showSnackBar('Share feature'),
                  ),
                  _ActionButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    onTap: _copy,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }
}