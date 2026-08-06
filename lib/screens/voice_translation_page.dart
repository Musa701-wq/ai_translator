/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/gemini_text_translate.dart';
import '../services/speech_services.dart';
import '../services/ttc_services.dart';
import '../utils/app_theme.dart';
import 'history.dart';


class Language {
  final String name;
  final String code;
  final String speechCode; // For speech recognition (e.g., 'en-US')

  const Language(this.name, this.code, this.speechCode);
}

class VoiceTranslatePage extends StatefulWidget {
  const VoiceTranslatePage({super.key});

  @override
  State<VoiceTranslatePage> createState() => _VoiceTranslatePageState();
}

class _VoiceTranslatePageState extends State<VoiceTranslatePage> with SingleTickerProviderStateMixin {
  final List<Language> _languages = const [
    Language('English', 'en', 'en-US'),
    Language('Spanish', 'es', 'es-ES'),
    Language('French', 'fr', 'fr-FR'),
    Language('German', 'de', 'de-DE'),
    Language('Italian', 'it', 'it-IT'),
    Language('Portuguese', 'pt', 'pt-PT'),
    Language('Russian', 'ru', 'ru-RU'),
    Language('Chinese', 'zh', 'zh-CN'),
    Language('Japanese', 'ja', 'ja-JP'),
    Language('Korean', 'ko', 'ko-KR'),
    Language('Arabic', 'ar', 'ar-SA'),
    Language('Hindi', 'hi', 'hi-IN'),
    Language('Urdu', 'ur', 'ur-PK'),
    Language('Turkish', 'tr', 'tr-TR'),
    Language('Dutch', 'nl', 'nl-NL'),
    Language('Polish', 'pl', 'pl-PL'),
    Language('Swedish', 'sv', 'sv-SE'),
    Language('Greek', 'el', 'el-GR'),
    Language('Czech', 'cs', 'cs-CZ'),
    Language('Danish', 'da', 'da-DK'),
  ];

  Language _sourceLanguage = const Language('English', 'en', 'en-US');
  Language _targetLanguage = const Language('Spanish', 'es', 'es-ES');

  String _recognizedText = '';
  String _translatedText = '';

  bool _isListening = false;
  bool _isTranslating = false;
  bool _hasRecognizedText = false;
  bool _isSpeechInitialized = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _setupAnimation();
  }
  Future<bool> _checkSpeechPermissions() async {
    try {
      // Check microphone permission
      var micStatus = await Permission.microphone.status;
      if (micStatus.isPermanentlyDenied) {
        _showSnackBar('Please enable microphone in Settings', isError: true);
        return false;
      }
      if (!micStatus.isGranted) {
        micStatus = await Permission.microphone.request();
      }

      // Check speech recognition permission (iOS only)
      var speechStatus = await Permission.speech.status;
      if (speechStatus.isPermanentlyDenied) {
        _showSnackBar('Please enable speech recognition in Settings', isError: true);
        return false;
      }
      if (!speechStatus.isGranted) {
        speechStatus = await Permission.speech.request();
      }

      return micStatus.isGranted && speechStatus.isGranted;
    } catch (e) {
      _showSnackBar('Permission error: $e', isError: true);
      return false;
    }
  }

  // ✅ UPDATE _toggleListening FUNCTION
  Future<void> _toggleListening() async {
    if (_isListening) {
      // Stop listening
      await SpeechService.stopListening();
      setState(() {
        _isListening = false;
      });

      if (_recognizedText.trim().isEmpty) {
        _showSnackBar('No speech detected. Please try again.');
        return;
      }

      if (_recognizedText.trim().isNotEmpty) {
        await _translateText();
      }
    } else {
      // ✅ CHECK PERMISSIONS BEFORE STARTING
      final hasPermission = await _checkSpeechPermissions();
      if (!hasPermission) return;

      // Start listening
      setState(() {
        _recognizedText = '';
        _translatedText = '';
        _hasRecognizedText = false;
        _isListening = true;
      });

      await SpeechService.startListening(
        languageCode: _sourceLanguage.speechCode,
        onResult: (text) {
          setState(() {
            _recognizedText = text;
          });
        },
      );
    }
  }

  Future<void> _translateText() async {
    if (_recognizedText.trim().isEmpty) {
      _showSnackBar('No text to translate', isError: true);
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    try {
      final result = await GoogleTranslateService.translate(
        text: _recognizedText,
        sourceLanguage: _sourceLanguage.code,
        targetLanguage: _targetLanguage.code,
      );

      setState(() {
        _translatedText = result;
        _hasRecognizedText = true;
        _isTranslating = false;
      });

      // ✅ ADD THIS: Save to history database
      await TranslationHistoryService.addTranslation(
        originalText: _recognizedText,
        translatedText: result,
        sourceLanguage: _sourceLanguage.code,
        targetLanguage: _targetLanguage.code,
        translationType: 'voice', // This was missing
      );

      _showSnackBar('Translation complete!');
    } catch (e) {
      setState(() {
        _isTranslating = false;
      });
      _showSnackBar('Translation failed: $e', isError: true);
    }
  }

// ... rest of the code ...
  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeSpeech() async {
    final initialized = await SpeechService.initialize();
    setState(() {
      _isSpeechInitialized = initialized;
    });

    if (!initialized) {
      _showSnackBar('Speech recognition not available', isError: true);
    }
  }

*//*

*/
/*
  Future<void> _toggleListening() async {
    if (_isListening) {
      // Stop listening
      await SpeechService.stopListening();
      setState(() {
        _isListening = false;
      });

      // If no text recognized, don't proceed
      if (_recognizedText.trim().isEmpty) {
        _showSnackBar('No speech detected. Please try again.');
        return;
      }

      // Auto translate if text is recognized
      if (_recognizedText.trim().isNotEmpty) {
        await _translateText();
      }
    } else {
      // Start listening
      setState(() {
        _recognizedText = '';
        _translatedText = '';
        _hasRecognizedText = false;
        _isListening = true;
      });

      await SpeechService.startListening(
        languageCode: _sourceLanguage.speechCode,
        onResult: (text) {
          setState(() {
            _recognizedText = text;
          });
        },
      );
    }
  }
*//*
*/
/*


*//*

*/
/*
  Future<void> _translateText() async {
    if (_recognizedText.trim().isEmpty) {
      _showSnackBar('No text to translate', isError: true);
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    try {
      final result = await GoogleTranslateService.translate(
        text: _recognizedText,
        sourceLanguage: _sourceLanguage.code,
        targetLanguage: _targetLanguage.code,
      );

      setState(() {
        _translatedText = result;
        _hasRecognizedText = true;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _isTranslating = false;
      });
      _showSnackBar('Translation failed: $e', isError: true);
    }
  }
*//*
*/
/*


  Future<void> _speakTranslation() async {
    if (_translatedText.trim().isEmpty) {
      _showSnackBar('No translation to speak', isError: true);
      return;
    }

    try {
      await TTSService.speak(_translatedText, _targetLanguage.speechCode);
    } catch (e) {
      _showSnackBar('Text-to-speech failed: $e', isError: true);
    }
  }

  void _swap() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      if (_hasRecognizedText) {
        final tempText = _recognizedText;
        _recognizedText = _translatedText;
        _translatedText = tempText;
      }
    });
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : AppTheme.primaryBlue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _copyText(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copied!');
  }

  @override
  void dispose() {
    _animationController.dispose();
    SpeechService.dispose();
    TTSService.stop();
    super.dispose();
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
          'Voice Translate',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTheme.getResponsiveFontSize(context, 22),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16)),
        child: Column(
          children: [
            // Language Selection
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 16),
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
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<Language>(
                        value: _sourceLanguage,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.primaryBlue,
                          size: isTablet ? 28 : 24,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
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
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 12),
                    child: GestureDetector(
                      onTap: _swap,
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 10 : 10),
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
                        child: Icon(
                          Icons.swap_horiz,
                          color: Colors.white,
                          size: isTablet ? 28 : 24,
                        ),
                      ),
                    ),
                  ),

                  // Target Language Dropdown
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<Language>(
                        value: _targetLanguage,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.primaryBlue,
                          size: isTablet ? 28 : 24,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
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

            SizedBox(height: isTablet ? 60 : 50),

            // Microphone Button with Animation
            if (!_hasRecognizedText)
              Column(
                children: [
                  GestureDetector(
                    onTap: _isSpeechInitialized ? _toggleListening : null,
                    child: AnimatedBuilder(
                      animation: _isListening ? _scaleAnimation : AlwaysStoppedAnimation(1.0),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isListening ? _scaleAnimation.value : 1.0,
                          child: Container(
                            width: isTablet ? 220 : 200,
                            height: isTablet ? 220 : 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.primaryBlue.withOpacity(0.1),
                                  AppTheme.primaryBlue.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: isTablet ? 160 : 140,
                                height: isTablet ? 160 : 140,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryBlue.withOpacity(0.3),
                                      spreadRadius: 5,
                                      blurRadius: 20,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.mic,
                                  color: Colors.white,
                                  size: isTablet ? 72 : 64,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: isTablet ? 32 : 24),
                  Text(
                    _isListening ? 'Listening...' : 'Tap to start speaking',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 20),
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (_isListening) ...[
                    SizedBox(height: isTablet ? 16 : 12),
                    Text(
                      'Speak clearly into the microphone',
                      style: TextStyle(
                        fontSize: AppTheme.getResponsiveFontSize(context, 16),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (_isListening && _recognizedText.isNotEmpty) ...[
                    SizedBox(height: isTablet ? 24 : 20),
                    Container(
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.mic, color: AppTheme.primaryBlue, size: isTablet ? 24 : 20),
                          SizedBox(width: isTablet ? 12 : 8),
                          Expanded(
                            child: Text(
                              _recognizedText,
                              style: TextStyle(
                                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

            // Show recognized text and translation
            if (_hasRecognizedText) ...[
              // Recognized Text Container
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
                      padding: EdgeInsets.all(isTablet ? 16 : 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.mic, size: isTablet ? 24 : 20, color: AppTheme.primaryBlue),
                              SizedBox(width: isTablet ? 8 : 8),
                              Text(
                                'Recognized Text',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, size: isTablet ? 24 : 20),
                            onPressed: () => _copyText(_recognizedText),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 16 : 16,
                        0,
                        isTablet ? 16 : 16,
                        isTablet ? 16 : 16,
                      ),
                      child: Text(
                        _recognizedText,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 24 : 20),

              // Translated Text Container
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
                      padding: EdgeInsets.all(isTablet ? 16 : 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.translate,
                                size: isTablet ? 24 : 20,
                                color: AppTheme.primaryBlue,
                              ),
                              SizedBox(width: isTablet ? 8 : 8),
                              Text(
                                'Translated Text',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.volume_up,
                                  size: isTablet ? 24 : 20,
                                  color: AppTheme.primaryBlue,
                                ),
                                onPressed: _speakTranslation,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.copy,
                                  size: isTablet ? 24 : 20,
                                  color: AppTheme.primaryBlue,
                                ),
                                onPressed: () => _copyText(_translatedText),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 16 : 16,
                        0,
                        isTablet ? 16 : 16,
                        isTablet ? 16 : 16,
                      ),
                      child: _isTranslating
                          ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 24 : 20),
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryBlue,
                            strokeWidth: isTablet ? 3 : 2.5,
                          ),
                        ),
                      )
                          : Text(
                        _translatedText.isEmpty
                            ? 'Translation will appear here...'
                            : _translatedText,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
                          color: _translatedText.isEmpty
                              ? AppTheme.primaryBlue.withOpacity(0.4)
                              : AppTheme.primaryBlue,
                          fontWeight: _translatedText.isEmpty
                              ? FontWeight.normal
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 24 : 20),

              // Try Again Button
              SizedBox(
                width: double.infinity,
                height: isTablet ? 60 : 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _recognizedText = '';
                      _translatedText = '';
                      _hasRecognizedText = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mic, size: isTablet ? 28 : 24),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}*//*

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../services/gemini_text_translate.dart';
import '../services/speech_services.dart';
import '../services/ttc_services.dart';
import '../utils/app_theme.dart';
import '../in_app_purchase/credit_manager.dart';
import 'history.dart';

class Language {
  final String name;
  final String code;
  final String speechCode;

  const Language(this.name, this.code, this.speechCode);
}

class VoiceTranslatePage extends StatefulWidget {
  const VoiceTranslatePage({super.key});

  @override
  State<VoiceTranslatePage> createState() => _VoiceTranslatePageState();
}

class _VoiceTranslatePageState extends State<VoiceTranslatePage> with SingleTickerProviderStateMixin {
  final List<Language> _languages = const [
    Language('English', 'en', 'en-US'),
    Language('Spanish', 'es', 'es-ES'),
    Language('French', 'fr', 'fr-FR'),
    Language('German', 'de', 'de-DE'),
    Language('Italian', 'it', 'it-IT'),
    Language('Portuguese', 'pt', 'pt-PT'),
    Language('Russian', 'ru', 'ru-RU'),
    Language('Chinese', 'zh', 'zh-CN'),
    Language('Japanese', 'ja', 'ja-JP'),
    Language('Korean', 'ko', 'ko-KR'),
    Language('Arabic', 'ar', 'ar-SA'),
    Language('Hindi', 'hi', 'hi-IN'),
    Language('Urdu', 'ur', 'ur-PK'),
    Language('Turkish', 'tr', 'tr-TR'),
    Language('Dutch', 'nl', 'nl-NL'),
    Language('Polish', 'pl', 'pl-PL'),
    Language('Swedish', 'sv', 'sv-SE'),
    Language('Greek', 'el', 'el-GR'),
    Language('Czech', 'cs', 'cs-CZ'),
    Language('Danish', 'da', 'da-DK'),
  ];

  Language _sourceLanguage = const Language('English', 'en', 'en-US');
  Language _targetLanguage = const Language('Spanish', 'es', 'es-ES');

  String _recognizedText = '';
  String _translatedText = '';

  bool _isListening = false;
  bool _isTranslating = false;
  bool _hasRecognizedText = false;
  bool _isSpeechInitialized = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _setupAnimation();
  }

  /// ✅ FIXED: Proper iOS permission check
  Future<bool> _checkSpeechPermissions() async {
    try {
      debugPrint("🔐 [Permissions] Checking speech permissions...");

      // Check microphone permission
      var micStatus = await Permission.microphone.status;
      debugPrint("🎤 [Permissions] Microphone status: $micStatus");

      if (micStatus.isPermanentlyDenied) {
        debugPrint("❌ [Permissions] Microphone permanently denied");
        _showPermissionDialog('Microphone');
        return false;
      }

      if (!micStatus.isGranted) {
        debugPrint("⏳ [Permissions] Requesting microphone...");
        micStatus = await Permission.microphone.request();
        debugPrint("🎤 [Permissions] Microphone after request: $micStatus");
      }

      // Check speech recognition permission (iOS specific)
      var speechStatus = await Permission.speech.status;
      debugPrint("🗣️ [Permissions] Speech status: $speechStatus");

      if (speechStatus.isPermanentlyDenied) {
        debugPrint("❌ [Permissions] Speech permanently denied");
        _showPermissionDialog('Speech Recognition');
        return false;
      }

      if (!speechStatus.isGranted) {
        debugPrint("⏳ [Permissions] Requesting speech...");
        speechStatus = await Permission.speech.request();
        debugPrint("🗣️ [Permissions] Speech after request: $speechStatus");
      }

      final granted = micStatus.isGranted && speechStatus.isGranted;
      debugPrint(granted
          ? "✅ [Permissions] All permissions granted"
          : "❌ [Permissions] Some permissions denied");

      return granted;

    } catch (e) {
      debugPrint("❌ [Permissions] Error: $e");
      _showSnackBar('Permission error: $e', isError: true);
      return false;
    }
  }

  /// Show dialog to open settings if permission permanently denied
  void _showPermissionDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(
          'Please enable $permissionName permission in Settings to use voice translation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// ✅ FIXED: Toggle listening with better error handling
  Future<void> _toggleListening() async {
    debugPrint("🎙️ [Voice] Toggle listening. Current state: $_isListening");

    if (_isListening) {
      // Stop listening
      debugPrint("⏹️ [Voice] Stopping listening...");
      await SpeechService.stopListening();
      setState(() {
        _isListening = false;
      });

      if (_recognizedText.trim().isEmpty) {
        debugPrint("⚠️ [Voice] No speech detected");
        _showSnackBar('No speech detected. Please try again.');
        return;
      }

      debugPrint("✅ [Voice] Speech recognized: $_recognizedText");
      if (_recognizedText.trim().isNotEmpty) {
        await _translateText();
      }
    } else {
      // Start listening
      debugPrint("▶️ [Voice] Starting listening...");

      // ✅ CHECK PERMISSIONS FIRST
      final hasPermission = await _checkSpeechPermissions();
      if (!hasPermission) {
        debugPrint("❌ [Voice] Permissions not granted");
        return;
      }

      // ✅ CHECK SPEECH INITIALIZATION
      if (!_isSpeechInitialized) {
        debugPrint("⚠️ [Voice] Speech not initialized, reinitializing...");
        await _initializeSpeech();
        if (!_isSpeechInitialized) {
          _showSnackBar('Speech recognition not available', isError: true);
          return;
        }
      }

      setState(() {
        _recognizedText = '';
        _translatedText = '';
        _hasRecognizedText = false;
        _isListening = true;
      });

      debugPrint("🎤 [Voice] Starting speech recognition...");
      try {
        await SpeechService.startListening(
          languageCode: _sourceLanguage.speechCode,
          onResult: (text) {
            debugPrint("📝 [Voice] Recognized: $text");
            setState(() {
              _recognizedText = text;
            });
          },
        );
        debugPrint("✅ [Voice] Speech recognition started");
      } catch (e) {
        debugPrint("❌ [Voice] Error starting speech: $e");
        setState(() {
          _isListening = false;
        });
        _showSnackBar('Failed to start listening: $e', isError: true);
      }
    }
  }

  Future<void> _translateText() async {
    if (_recognizedText.trim().isEmpty) {
      _showSnackBar('No text to translate', isError: true);
      return;
    }

    // ✅ Check credits before translation
    final creditManager = context.read<CreditManager>();
    const requiredCredits = 5;
    if (!creditManager.hasEnoughCredits(requiredCredits)) {
      _showSnackBar('Insufficient credits. You need $requiredCredits credits to translate.', isError: true);
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    try {
      debugPrint("🔄 [Translate] Translating: $_recognizedText");

      final result = await GoogleTranslateService.translate(
        text: _recognizedText,
        sourceLanguage: _sourceLanguage.code,
        targetLanguage: _targetLanguage.code,
      );

      debugPrint("✅ [Translate] Result: $result");

      // ✅ Deduct credits after successful translation
      final deducted = await creditManager.deductCredits(requiredCredits, reason: 'voice_translation');
      if (!deducted) {
        _showSnackBar('Failed to deduct credits', isError: true);
      }

      setState(() {
        _translatedText = result;
        _hasRecognizedText = true;
        _isTranslating = false;
      });

      // Save to history database
      await TranslationHistoryService.addTranslation(
        originalText: _recognizedText,
        translatedText: result,
        sourceLanguage: _sourceLanguage.code,
        targetLanguage: _targetLanguage.code,
        translationType: 'voice',
      );

      _showSnackBar('Translation complete!');
    } catch (e) {
      debugPrint("❌ [Translate] Error: $e");
      setState(() {
        _isTranslating = false;
      });
      _showSnackBar('Translation failed: $e', isError: true);
    }
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeSpeech() async {
    debugPrint("🎤 [Speech] Initializing...");
    final initialized = await SpeechService.initialize();
    setState(() {
      _isSpeechInitialized = initialized;
    });

    debugPrint(initialized
        ? "✅ [Speech] Initialized successfully"
        : "❌ [Speech] Initialization failed");

    if (!initialized) {
      _showSnackBar('Speech recognition not available', isError: true);
    }
  }

  Future<void> _speakTranslation() async {
    if (_translatedText.trim().isEmpty) {
      _showSnackBar('No translation to speak', isError: true);
      return;
    }

    try {
      await TTSService.speak(_translatedText, _targetLanguage.speechCode);
    } catch (e) {
      _showSnackBar('Text-to-speech failed: $e', isError: true);
    }
  }

  void _swap() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      if (_hasRecognizedText) {
        final tempText = _recognizedText;
        _recognizedText = _translatedText;
        _translatedText = tempText;
      }
    });
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : AppTheme.primaryBlue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _copyText(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copied!');
  }

  @override
  void dispose() {
    _animationController.dispose();
    SpeechService.dispose();
    TTSService.stop();
    super.dispose();
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
          'Voice Translate',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTheme.getResponsiveFontSize(context, 22),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16)),
        child: Column(
          children: [
            // Language Selection
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 16),
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
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<Language>(
                        value: _sourceLanguage,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.primaryBlue,
                          size: isTablet ? 28 : 24,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
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
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 12),
                    child: GestureDetector(
                      onTap: _swap,
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 10 : 10),
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
                        child: Icon(
                          Icons.swap_horiz,
                          color: Colors.white,
                          size: isTablet ? 28 : 24,
                        ),
                      ),
                    ),
                  ),

                  // Target Language Dropdown
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<Language>(
                        value: _targetLanguage,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.primaryBlue,
                          size: isTablet ? 28 : 24,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
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

            SizedBox(height: isTablet ? 60 : 50),

            // Microphone Button with Animation
            if (!_hasRecognizedText)
              Column(
                children: [
                  GestureDetector(
                    onTap: _isSpeechInitialized ? _toggleListening : null,
                    child: AnimatedBuilder(
                      animation: _isListening ? _scaleAnimation : AlwaysStoppedAnimation(1.0),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isListening ? _scaleAnimation.value : 1.0,
                          child: Container(
                            width: isTablet ? 220 : 200,
                            height: isTablet ? 220 : 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.primaryBlue.withOpacity(0.1),
                                  AppTheme.primaryBlue.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: isTablet ? 160 : 140,
                                height: isTablet ? 160 : 140,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryBlue.withOpacity(0.3),
                                      spreadRadius: 5,
                                      blurRadius: 20,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.mic,
                                  color: Colors.white,
                                  size: isTablet ? 72 : 64,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: isTablet ? 32 : 24),
                  Text(
                    _isListening ? 'Listening...' : 'Tap to start speaking',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 20),
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (_isListening) ...[
                    SizedBox(height: isTablet ? 16 : 12),
                    Text(
                      'Speak clearly into the microphone',
                      style: TextStyle(
                        fontSize: AppTheme.getResponsiveFontSize(context, 16),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (_isListening && _recognizedText.isNotEmpty) ...[
                    SizedBox(height: isTablet ? 24 : 20),
                    Container(
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.mic, color: AppTheme.primaryBlue, size: isTablet ? 24 : 20),
                          SizedBox(width: isTablet ? 12 : 8),
                          Expanded(
                            child: Text(
                              _recognizedText,
                              style: TextStyle(
                                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

            // Show recognized text and translation
            if (_hasRecognizedText) ...[
              // Recognized Text Container
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
                      padding: EdgeInsets.all(isTablet ? 16 : 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.mic, size: isTablet ? 24 : 20, color: AppTheme.primaryBlue),
                              SizedBox(width: isTablet ? 8 : 8),
                              Text(
                                'Recognized Text',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, size: isTablet ? 24 : 20),
                            onPressed: () => _copyText(_recognizedText),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 16 : 16,
                        0,
                        isTablet ? 16 : 16,
                        isTablet ? 16 : 16,
                      ),
                      child: Text(
                        _recognizedText,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 24 : 20),

              // Translated Text Container
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
                      padding: EdgeInsets.all(isTablet ? 16 : 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.translate,
                                size: isTablet ? 24 : 20,
                                color: AppTheme.primaryBlue,
                              ),
                              SizedBox(width: isTablet ? 8 : 8),
                              Text(
                                'Translated Text',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.volume_up,
                                  size: isTablet ? 24 : 20,
                                  color: AppTheme.primaryBlue,
                                ),
                                onPressed: _speakTranslation,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.copy,
                                  size: isTablet ? 24 : 20,
                                  color: AppTheme.primaryBlue,
                                ),
                                onPressed: () => _copyText(_translatedText),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 16 : 16,
                        0,
                        isTablet ? 16 : 16,
                        isTablet ? 16 : 16,
                      ),
                      child: _isTranslating
                          ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 24 : 20),
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryBlue,
                            strokeWidth: isTablet ? 3 : 2.5,
                          ),
                        ),
                      )
                          : Text(
                        _translatedText.isEmpty
                            ? 'Translation will appear here...'
                            : _translatedText,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
                          color: _translatedText.isEmpty
                              ? AppTheme.primaryBlue.withOpacity(0.4)
                              : AppTheme.primaryBlue,
                          fontWeight: _translatedText.isEmpty
                              ? FontWeight.normal
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 24 : 20),

              // Try Again Button
              SizedBox(
                width: double.infinity,
                height: isTablet ? 60 : 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _recognizedText = '';
                      _translatedText = '';
                      _hasRecognizedText = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mic, size: isTablet ? 28 : 24),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}*/
// lib/screens/voice_translation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../services/gemini_text_translate.dart';
import '../services/speech_services.dart';
import '../services/ttc_services.dart';
import '../utils/app_theme.dart';
import '../in_app_purchase/credit_manager.dart';
import 'history.dart';

class Language {
  final String name;
  final String code;
  final String speechCode;

  const Language(this.name, this.code, this.speechCode);
}

class VoiceTranslatePage extends StatefulWidget {
  const VoiceTranslatePage({super.key});

  @override
  State<VoiceTranslatePage> createState() => _VoiceTranslatePageState();
}

class _VoiceTranslatePageState extends State<VoiceTranslatePage> with SingleTickerProviderStateMixin {
  final List<Language> _languages = const [
    Language('English', 'en', 'en-US'),
    Language('Spanish', 'es', 'es-ES'),
    Language('French', 'fr', 'fr-FR'),
    Language('German', 'de', 'de-DE'),
    Language('Italian', 'it', 'it-IT'),
    Language('Portuguese', 'pt', 'pt-PT'),
    Language('Russian', 'ru', 'ru-RU'),
    Language('Chinese', 'zh', 'zh-CN'),
    Language('Japanese', 'ja', 'ja-JP'),
    Language('Korean', 'ko', 'ko-KR'),
    Language('Arabic', 'ar', 'ar-SA'),
    Language('Hindi', 'hi', 'hi-IN'),
    Language('Urdu', 'ur', 'ur-PK'),
    Language('Turkish', 'tr', 'tr-TR'),
    Language('Dutch', 'nl', 'nl-NL'),
    Language('Polish', 'pl', 'pl-PL'),
    Language('Swedish', 'sv', 'sv-SE'),
    Language('Greek', 'el', 'el-GR'),
    Language('Czech', 'cs', 'cs-CZ'),
    Language('Danish', 'da', 'da-DK'),
  ];

  Language _sourceLanguage = const Language('English', 'en', 'en-US');
  Language _targetLanguage = const Language('Spanish', 'es', 'es-ES');

  String _recognizedText = '';
  String _translatedText = '';

  bool _isListening = false;
  bool _isTranslating = false;
  bool _hasRecognizedText = false;
  bool _isSpeechInitialized = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _setupAnimation();
  }
  Future<bool> _checkSpeechPermissions() async {
    try {
      debugPrint("🔐 [Permissions] Checking speech permissions...");

      // ✅ Check microphone permission
      var micStatus = await Permission.microphone.status;
      debugPrint("🎤 [Permissions] Microphone status: $micStatus");

      if (!micStatus.isGranted) {
        if (micStatus.isPermanentlyDenied) {
          // Show dialog to open settings
          await _showPermissionSettingsDialog(
            'Microphone Permission Required',
            'Voice translation requires microphone access. Please enable it in Settings.',
          );
          return false;
        }

        // Request permission
        micStatus = await Permission.microphone.request();

        if (!micStatus.isGranted) {
          if (micStatus.isPermanentlyDenied) {
            await _showPermissionSettingsDialog(
              'Microphone Permission Denied',
              'Please enable microphone access in Settings.',
            );
          } else {
            _showSnackBar('Microphone permission is required', isError: true);
          }
          return false;
        }
      }

      // ✅ Check speech permission (iOS only)
      var speechStatus = await Permission.speech.status;
      debugPrint("🗣️ [Permissions] Speech status: $speechStatus");

      if (!speechStatus.isGranted) {
        if (speechStatus.isPermanentlyDenied) {
          await _showPermissionSettingsDialog(
            'Speech Recognition Required',
            'Voice translation requires speech recognition. Please enable it in Settings.',
          );
          return false;
        }

        // Request permission
        speechStatus = await Permission.speech.request();

        if (!speechStatus.isGranted) {
          if (speechStatus.isPermanentlyDenied) {
            await _showPermissionSettingsDialog(
              'Speech Recognition Denied',
              'Please enable speech recognition in Settings.',
            );
          } else {
            _showSnackBar('Speech recognition permission is required', isError: true);
          }
          return false;
        }
      }

      final granted = micStatus.isGranted && speechStatus.isGranted;
      debugPrint(granted
          ? "✅ [Permissions] All permissions granted"
          : "❌ [Permissions] Some permissions denied");

      return granted;

    } catch (e) {
      debugPrint("❌ [Permissions] Error: $e");
      _showSnackBar('Permission error: $e', isError: true);
      return false;
    }
  }
  /// ✅ FIXED: Comprehensive iOS permission check with proper dialogs
/*
  Future<bool> _checkSpeechPermissions() async {
    try {
      debugPrint("🔐 [Permissions] Checking speech permissions...");

      // Check microphone permission
      var micStatus = await Permission.microphone.status;
      debugPrint("🎤 [Permissions] Microphone status: $micStatus");

      if (micStatus.isPermanentlyDenied) {
        debugPrint("❌ [Permissions] Microphone permanently denied");
        await _showPermissionSettingsDialog(
          'Microphone Permission Required',
          'Voice translation requires microphone access. Please enable it in Settings.',
        );
        return false;
      }

      if (micStatus.isDenied) {
        debugPrint("⏳ [Permissions] Requesting microphone...");
        micStatus = await Permission.microphone.request();
        debugPrint("🎤 [Permissions] Microphone after request: $micStatus");

        if (micStatus.isPermanentlyDenied) {
          await _showPermissionSettingsDialog(
            'Microphone Permission Denied',
            'Please enable microphone access in Settings to use voice translation.',
          );
          return false;
        }

        if (!micStatus.isGranted) {
          debugPrint("❌ [Permissions] Microphone request denied");
          _showSnackBar('Microphone permission is required', isError: true);
          return false;
        }
      }

      // Check speech recognition permission (iOS specific)
      var speechStatus = await Permission.speech.status;
      debugPrint("🗣️ [Permissions] Speech status: $speechStatus");

      if (speechStatus.isPermanentlyDenied) {
        debugPrint("❌ [Permissions] Speech permanently denied");
        await _showPermissionSettingsDialog(
          'Speech Recognition Required',
          'Voice translation requires speech recognition. Please enable it in Settings.',
        );
        return false;
      }

      if (speechStatus.isDenied) {
        debugPrint("⏳ [Permissions] Requesting speech...");
        speechStatus = await Permission.speech.request();
        debugPrint("🗣️ [Permissions] Speech after request: $speechStatus");

        if (speechStatus.isPermanentlyDenied) {
          await _showPermissionSettingsDialog(
            'Speech Recognition Denied',
            'Please enable speech recognition in Settings to use voice translation.',
          );
          return false;
        }

        if (!speechStatus.isGranted) {
          debugPrint("❌ [Permissions] Speech request denied");
          _showSnackBar('Speech recognition permission is required', isError: true);
          return false;
        }
      }

      final granted = micStatus.isGranted && speechStatus.isGranted;
      debugPrint(granted
          ? "✅ [Permissions] All permissions granted"
          : "❌ [Permissions] Some permissions denied");

      return granted;

    } catch (e) {
      debugPrint("❌ [Permissions] Error: $e");
      _showSnackBar('Permission error: $e', isError: true);
      return false;
    }
  }
*/

  /// Show dialog to open app settings
  Future<void> _showPermissionSettingsDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getResponsiveRadius(context, 16),
          ),
        ),
        title: Row(
          children: [
            Icon(
              Icons.settings,
              color: AppTheme.primaryBlue,
              size: AppTheme.getResponsiveIconSize(context, 28),
            ),
            SizedBox(width: AppTheme.getResponsiveSpacing(context, 12)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 16),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.getResponsiveRadius(context, 8),
                ),
              ),
            ),
            child: Text(
              'Open Settings',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await openAppSettings();
    }
  }

  /// ✅ FIXED: Toggle listening with better error handling
  Future<void> _toggleListening() async {
    debugPrint("🎙️ [Voice] Toggle listening. Current state: $_isListening");

    if (_isListening) {
      // Stop listening
      debugPrint("⏹️ [Voice] Stopping listening...");
      await SpeechService.stopListening();
      setState(() {
        _isListening = false;
      });

      if (_recognizedText.trim().isEmpty) {
        debugPrint("⚠️ [Voice] No speech detected");
        _showSnackBar('No speech detected. Please try again.');
        return;
      }

      debugPrint("✅ [Voice] Speech recognized: $_recognizedText");
      if (_recognizedText.trim().isNotEmpty) {
        await _translateText();
      }
    } else {
      // Start listening
      debugPrint("▶️ [Voice] Starting listening...");

      // ✅ CHECK PERMISSIONS FIRST
      final hasPermission = await _checkSpeechPermissions();
      if (!hasPermission) {
        debugPrint("❌ [Voice] Permissions not granted");
        return;
      }

      // ✅ CHECK SPEECH INITIALIZATION
      if (!_isSpeechInitialized) {
        debugPrint("⚠️ [Voice] Speech not initialized, reinitializing...");
        await _initializeSpeech();
        if (!_isSpeechInitialized) {
          _showSnackBar('Speech recognition not available', isError: true);
          return;
        }
      }

      setState(() {
        _recognizedText = '';
        _translatedText = '';
        _hasRecognizedText = false;
        _isListening = true;
      });

      debugPrint("🎤 [Voice] Starting speech recognition...");
      try {
        await SpeechService.startListening(
          languageCode: _sourceLanguage.speechCode,
          onResult: (text) {
            debugPrint("📝 [Voice] Recognized: $text");
            setState(() {
              _recognizedText = text;
            });
          },
        );
        debugPrint("✅ [Voice] Speech recognition started");
      } catch (e) {
        debugPrint("❌ [Voice] Error starting speech: $e");
        setState(() {
          _isListening = false;
        });
        _showSnackBar('Failed to start listening: $e', isError: true);
      }
    }
  }

  Future<void> _translateText() async {
    if (_recognizedText.trim().isEmpty) {
      _showSnackBar('No text to translate', isError: true);
      return;
    }

    // ✅ Check credits before translation
    final creditManager = context.read<CreditManager>();
    const requiredCredits = 5;
    if (!creditManager.hasEnoughCredits(requiredCredits)) {
      _showSnackBar('Insufficient credits. You need $requiredCredits credits to translate.', isError: true);
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    try {
      debugPrint("🔄 [Translate] Translating: $_recognizedText");

      final result = await GoogleTranslateService.translate(
        text: _recognizedText,
        sourceLanguage: _sourceLanguage.code,
        targetLanguage: _targetLanguage.code,
      );

      debugPrint("✅ [Translate] Result: $result");

      // ✅ Deduct credits after successful translation
      final deducted = await creditManager.deductCredits(requiredCredits, reason: 'voice_translation');
      if (!deducted) {
        _showSnackBar('Failed to deduct credits', isError: true);
      }

      setState(() {
        _translatedText = result;
        _hasRecognizedText = true;
        _isTranslating = false;
      });

      // Save to history database
      await TranslationHistoryService.addTranslation(
        originalText: _recognizedText,
        translatedText: result,
        sourceLanguage: _sourceLanguage.code,
        targetLanguage: _targetLanguage.code,
        translationType: 'voice',
      );

      _showSnackBar('Translation complete!');
    } catch (e) {
      debugPrint("❌ [Translate] Error: $e");
      setState(() {
        _isTranslating = false;
      });
      _showSnackBar('Translation failed: $e', isError: true);
    }
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeSpeech() async {
    debugPrint("🎤 [Speech] Initializing...");
    final initialized = await SpeechService.initialize();
    setState(() {
      _isSpeechInitialized = initialized;
    });

    debugPrint(initialized
        ? "✅ [Speech] Initialized successfully"
        : "❌ [Speech] Initialization failed");

    if (!initialized) {
      _showSnackBar('Speech recognition not available', isError: true);
    }
  }

  Future<void> _speakTranslation() async {
    if (_translatedText.trim().isEmpty) {
      _showSnackBar('No translation to speak', isError: true);
      return;
    }

    try {
      await TTSService.speak(_translatedText, _targetLanguage.speechCode);
    } catch (e) {
      _showSnackBar('Text-to-speech failed: $e', isError: true);
    }
  }

  void _swap() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      if (_hasRecognizedText) {
        final tempText = _recognizedText;
        _recognizedText = _translatedText;
        _translatedText = tempText;
      }
    });
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 14),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : AppTheme.primaryBlue,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getResponsiveRadius(context, 12),
          ),
        ),
      ),
    );
  }

  void _copyText(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copied!');
  }

  @override
  void dispose() {
    _animationController.dispose();
    SpeechService.dispose();
    TTSService.stop();
    super.dispose();
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
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: AppTheme.getResponsiveIconSize(context, 24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Voice Translate',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTheme.getResponsiveFontSize(context, 22),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16)),
        child: Column(
          children: [
            // Language Selection
            Container(
              padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  AppTheme.getResponsiveRadius(context, 16),
                ),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  width: 1,
                ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getResponsivePadding(context, 16),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: BorderRadius.circular(
                          AppTheme.getResponsiveRadius(context, 12),
                        ),
                      ),
                      child: DropdownButton<Language>(
                        value: _sourceLanguage,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.primaryBlue,
                          size: AppTheme.getResponsiveIconSize(context, 24),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getResponsivePadding(context, 12),
                    ),
                    child: GestureDetector(
                      onTap: _swap,
                      child: Container(
                        padding: EdgeInsets.all(
                          AppTheme.getResponsivePadding(context, 10),
                        ),
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
                        child: Icon(
                          Icons.swap_horiz,
                          color: Colors.white,
                          size: AppTheme.getResponsiveIconSize(context, 24),
                        ),
                      ),
                    ),
                  ),

                  // Target Language Dropdown
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getResponsivePadding(context, 16),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: BorderRadius.circular(
                          AppTheme.getResponsiveRadius(context, 12),
                        ),
                      ),
                      child: DropdownButton<Language>(
                        value: _targetLanguage,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.primaryBlue,
                          size: AppTheme.getResponsiveIconSize(context, 24),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
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

            SizedBox(height: AppTheme.getResponsiveSpacing(context, 60)),

            // Microphone Button with Animation
            if (!_hasRecognizedText)
              Column(
                children: [
                  GestureDetector(
                    onTap: _isSpeechInitialized ? _toggleListening : null,
                    child: AnimatedBuilder(
                      animation: _isListening ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isListening ? _scaleAnimation.value : 1.0,
                          child: Container(
                            width: isTablet ? 220 : 200,
                            height: isTablet ? 220 : 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.primaryBlue.withOpacity(0.1),
                                  AppTheme.primaryBlue.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: isTablet ? 160 : 140,
                                height: isTablet ? 160 : 140,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryBlue.withOpacity(0.3),
                                      spreadRadius: 5,
                                      blurRadius: 20,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.mic,
                                  color: Colors.white,
                                  size: AppTheme.getResponsiveIconSize(context, 64),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: AppTheme.getResponsiveSpacing(context, 32)),
                  Text(
                    _isListening ? 'Listening...' : 'Tap to start speaking',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 20),
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (_isListening) ...[
                    SizedBox(height: AppTheme.getResponsiveSpacing(context, 16)),
                    Text(
                      'Speak clearly into the microphone',
                      style: TextStyle(
                        fontSize: AppTheme.getResponsiveFontSize(context, 16),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (_isListening && _recognizedText.isNotEmpty) ...[
                    SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),
                    Container(
                      padding: EdgeInsets.all(
                        AppTheme.getResponsivePadding(context, 20),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(
                          AppTheme.getResponsiveRadius(context, 16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.mic,
                            color: AppTheme.primaryBlue,
                            size: AppTheme.getResponsiveIconSize(context, 24),
                          ),
                          SizedBox(width: AppTheme.getResponsiveSpacing(context, 12)),
                          Expanded(
                            child: Text(
                              _recognizedText,
                              style: TextStyle(
                                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

            // Show recognized text and translation
            if (_hasRecognizedText) ...[
              // Recognized Text Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppTheme.getResponsiveRadius(context, 20),
                  ),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    width: 1,
                  ),
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
                      padding: EdgeInsets.all(
                        AppTheme.getResponsivePadding(context, 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.mic,
                                size: AppTheme.getResponsiveIconSize(context, 24),
                                color: AppTheme.primaryBlue,
                              ),
                              SizedBox(
                                width: AppTheme.getResponsiveSpacing(context, 8),
                              ),
                              Text(
                                'Recognized Text',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.copy,
                              size: AppTheme.getResponsiveIconSize(context, 24),
                            ),
                            onPressed: () => _copyText(_recognizedText),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppTheme.getResponsivePadding(context, 16),
                        0,
                        AppTheme.getResponsivePadding(context, 16),
                        AppTheme.getResponsivePadding(context, 16),
                      ),
                      child: Text(
                        _recognizedText,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),

              // Translated Text Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppTheme.getResponsiveRadius(context, 20),
                  ),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.5),
                    width: 1,
                  ),
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
                      padding: EdgeInsets.all(
                        AppTheme.getResponsivePadding(context, 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.translate,
                                size: AppTheme.getResponsiveIconSize(context, 24),
                                color: AppTheme.primaryBlue,
                              ),
                              SizedBox(
                                width: AppTheme.getResponsiveSpacing(context, 8),
                              ),
                              Text(
                                'Translated Text',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.volume_up,
                                  size: AppTheme.getResponsiveIconSize(context, 24),
                                  color: AppTheme.primaryBlue,
                                ),
                                onPressed: _speakTranslation,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.copy,
                                  size: AppTheme.getResponsiveIconSize(context, 24),
                                  color: AppTheme.primaryBlue,
                                ),
                                onPressed: () => _copyText(_translatedText),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppTheme.getResponsivePadding(context, 16),
                        0,
                        AppTheme.getResponsivePadding(context, 16),
                        AppTheme.getResponsivePadding(context, 16),
                      ),
                      child: _isTranslating
                          ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(
                            AppTheme.getResponsivePadding(context, 24),
                          ),
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryBlue,
                            strokeWidth: 2.5,
                          ),
                        ),
                      )
                          : Text(
                        _translatedText.isEmpty
                            ? 'Translation will appear here...'
                            : _translatedText,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
                          color: _translatedText.isEmpty
                              ? AppTheme.primaryBlue.withOpacity(0.4)
                              : AppTheme.primaryBlue,
                          fontWeight: _translatedText.isEmpty
                              ? FontWeight.normal
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.getResponsiveSpacing(context, 24)),

              // Try Again Button
              SizedBox(
                width: double.infinity,
                height: AppTheme.getResponsiveButtonHeight(context, 56),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _recognizedText = '';
                      _translatedText = '';
                      _hasRecognizedText = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.getResponsiveRadius(context, 16),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic,
                        size: AppTheme.getResponsiveIconSize(context, 24),
                      ),
                      SizedBox(width: AppTheme.getResponsiveSpacing(context, 12)),
                      Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
