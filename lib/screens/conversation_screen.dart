/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import '../services/gemini_text_translate.dart';
import '../services/speech_services.dart';
import '../services/ttc_services.dart';
import '../services/ocr_services.dart';
import '../utils/app_theme.dart';
import 'history.dart';

class Language {
  final String name;
  final String code;
  final String speechCode;

  const Language(this.name, this.code, this.speechCode);
}

class ConversationMessage {
  final String text;
  final String translatedText;
  final bool isUserMessage;
  final String language;

  ConversationMessage({
    required this.text,
    required this.translatedText,
    required this.isUserMessage,
    required this.language,
  });
}

class LiveConversationPage extends StatefulWidget {
  const LiveConversationPage({super.key});

  @override
  State<LiveConversationPage> createState() => _LiveConversationPageState();
}

class _LiveConversationPageState extends State<LiveConversationPage> {
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

  Language _userLanguage = const Language('English', 'en', 'en-US');
  Language _otherLanguage = const Language('Spanish', 'es', 'es-ES');

  final List<ConversationMessage> _messages = [];
  String _currentListeningText = '';
  String _lastDetectedText = '';
  DateTime _lastDetectionTime = DateTime.now();

  bool _isListening = false;
  bool _isTranslating = false;
  bool _isSpeechInitialized = false;
  bool _isCameraMode = false;
  bool _isCameraInitialized = false;
  bool _isProcessingFrame = false;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  Timer? _ocrTimer;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeCamera();
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

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      _showSnackBar('Camera not available: $e', isError: true);
    }
  }

  Future<void> _startCamera() async {
    if (!_isCameraInitialized || _cameras == null || _cameras!.isEmpty) {
      _showSnackBar('Camera not available', isError: true);
      return;
    }

    try {
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      setState(() {
        _isCameraMode = true;
      });

      // Start processing frames every 2 seconds
      _ocrTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (_cameraController != null && _cameraController!.value.isInitialized) {
          _processCameraFrame();
        }
      });
    } catch (e) {
      _showSnackBar('Failed to start camera: $e', isError: true);
    }
  }

  Future<void> _stopCamera() async {
    _ocrTimer?.cancel();
    _ocrTimer = null;

    await _cameraController?.dispose();
    _cameraController = null;

    setState(() {
      _isCameraMode = false;
      _lastDetectedText = '';
    });
  }

  Future<void> _processCameraFrame() async {
    if (_isProcessingFrame || _cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      _isProcessingFrame = true;
      final image = await _cameraController!.takePicture();
      
      // Process image for OCR
      final extractedText = await OCRService.extractTextFromImage(image.path);
      
      // Delete temporary image file
      final file = File(image.path);
      if (await file.exists()) {
        await file.delete();
      }

      if (extractedText.isNotEmpty && extractedText != _lastDetectedText) {
        _lastDetectedText = extractedText;
        _lastDetectionTime = DateTime.now();
        
        // Translate and add to conversation
        await _translateAndAddMessage(extractedText);
      }
    } catch (e) {
      // Silent fail for OCR processing
    } finally {
      _isProcessingFrame = false;
    }
  }

  void _toggleMode() {
    if (_isCameraMode) {
      // Switch to voice mode
      _stopCamera();
      setState(() {
        _isCameraMode = false;
      });
    } else {
      // Switch to camera mode
      _stopListening();
      setState(() {
        _isCameraMode = true;
      });
      _startCamera();
    }
  }
// lib/screens/conversation_screen.dart
// ... existing code ...

  Future<void> _translateAndAddMessage(String text) async {
    setState(() {
      _isTranslating = true;
    });

    try {
      // Add user message (right side - blue bubble)
      final userMessage = ConversationMessage(
        text: text,
        translatedText: '',
        isUserMessage: true,
        language: _userLanguage.name,
      );

      setState(() {
        _messages.add(userMessage);
      });

      _scrollToBottom();

      // Translate to target language
      final translatedText = await GoogleTranslateService.translate(
        text: text,
        sourceLanguage: _userLanguage.code,
        targetLanguage: _otherLanguage.code,
      );

      // Add translated message (left side - white bubble with translate icon)
      final translatedMessage = ConversationMessage(
        text: translatedText,
        translatedText: text,
        isUserMessage: false,
        language: _otherLanguage.name,
      );

      setState(() {
        _messages.add(translatedMessage);
        _isTranslating = false;
      });

      // ✅ ADD THIS: Save to history (CONVERSATION TYPE)
      await TranslationHistoryService.addTranslation(
        originalText: text,
        translatedText: translatedText,
        sourceLanguage: _userLanguage.code,
        targetLanguage: _otherLanguage.code,
        translationType: 'conversation', // Important: use 'conversation'
      );

      _scrollToBottom();

      // Speak the translation
      await TTSService.speak(translatedText, _otherLanguage.speechCode);

    } catch (e) {
      setState(() {
        _isTranslating = false;
      });

      // Show error message as a message bubble
      final errorMessage = ConversationMessage(
        text: '❌ Exception: ${e.toString().replaceAll('Exception: ', '')}',
        translatedText: '',
        isUserMessage: false,
        language: _userLanguage.name,
      );

      setState(() {
        _messages.add(errorMessage);
      });

      _scrollToBottom();
    }
  }

// ... rest of the code ...
  Future<void> _startListening() async {
    if (!_isSpeechInitialized) {
      _showSnackBar('Speech recognition not initialized', isError: true);
      return;
    }

    setState(() {
      _isListening = true;
      _currentListeningText = '';
    });

    await SpeechService.startListening(
      languageCode: _userLanguage.speechCode,
      onResult: (text) {
        setState(() {
          _currentListeningText = text;
        });
      },
    );
  }

  Future<void> _stopListening() async {
    await SpeechService.stopListening();

    setState(() {
      _isListening = false;
    });

    if (_currentListeningText.trim().isEmpty) {
      _showSnackBar('No speech detected');
      return;
    }

    // Translate and add to conversation
    await _translateAndAddMessage(_currentListeningText);

    setState(() {
      _currentListeningText = '';
    });
  }

*/
/*
  Future<void> _translateAndAddMessage(String text) async {
    setState(() {
      _isTranslating = true;
    });

    try {
      // Add user message (right side - blue bubble)
      final userMessage = ConversationMessage(
        text: text,
        translatedText: '',
        isUserMessage: true,
        language: _userLanguage.name,
      );

      setState(() {
        _messages.add(userMessage);
      });

      _scrollToBottom();

      // Translate to target language
      final translatedText = await GoogleTranslateService.translate(
        text: text,
        sourceLanguage: _userLanguage.code,
        targetLanguage: _otherLanguage.code,
      );

      // Add translated message (left side - white bubble with translate icon)
      final translatedMessage = ConversationMessage(
        text: translatedText,
        translatedText: text,
        isUserMessage: false,
        language: _otherLanguage.name,
      );

      setState(() {
        _messages.add(translatedMessage);
        _isTranslating = false;
      });

      // Save to history
      await TranslationHistoryService.addTranslation(
        originalText: text,
        translatedText: translatedText,
        sourceLanguage: _userLanguage.code,
        targetLanguage: _otherLanguage.code,
        translationType: 'conversation',
      );

      _scrollToBottom();

      // Speak the translation
      await TTSService.speak(translatedText, _otherLanguage.speechCode);

    } catch (e) {
      setState(() {
        _isTranslating = false;
      });

      // Show error message as a message bubble
      final errorMessage = ConversationMessage(
        text: '❌ Exception: ${e.toString().replaceAll('Exception: ', '')}',
        translatedText: '',
        isUserMessage: false,
        language: _userLanguage.name,
      );

      setState(() {
        _messages.add(errorMessage);
      });

      _scrollToBottom();
    }
  }
*//*


  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _swap() {
    setState(() {
      final temp = _userLanguage;
      _userLanguage = _otherLanguage;
      _otherLanguage = temp;
    });
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : AppTheme.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _ocrTimer?.cancel();
    _cameraController?.dispose();
    _scrollController.dispose();
    SpeechService.dispose();
    TTSService.stop();
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
          'Live Conversation',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTheme.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Language Selection Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getResponsivePadding(context, 16),
              vertical: AppTheme.getResponsivePadding(context, 16),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                // You speak
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You speak',
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 12),
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: AppTheme.getResponsiveSpacing(context, 4)),
                      Text(
                        _userLanguage.name,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Swap icon in middle
                GestureDetector(
                  onTap: _swap,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    child: CustomPaint(
                      size: const Size(40, 20),
                      painter: SwapArrowPainter(),
                    ),
                  ),
                ),

                // They hear
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'They hear',
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 12),
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: AppTheme.getResponsiveSpacing(context, 4)),
                      Text(
                        _otherLanguage.name,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Listening/Camera indicator
          if (_isListening || _isCameraMode)
            Container(
              padding: EdgeInsets.symmetric(
                vertical: AppTheme.getResponsivePadding(context, 10),
                horizontal: AppTheme.getResponsivePadding(context, 16),
              ),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isCameraMode ? Icons.camera_alt : Icons.edit,
                    size: AppTheme.getResponsiveIconSize(context, 16),
                    color: Colors.grey,
                  ),
                  SizedBox(width: AppTheme.getResponsiveSpacing(context, 8)),
                  Text(
                    _isCameraMode
                        ? 'Scanning text in ${_userLanguage.name}'
                        : 'Listening in ${_userLanguage.name}',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 14),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

          // Camera Preview
          if (_isCameraMode && _cameraController != null && _cameraController!.value.isInitialized)
            Container(
              height: AppTheme.isTablet(context) ? 300 : 200,
              margin: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AppTheme.getResponsiveRadius(context, 16),
                ),
                border: Border.all(color: AppTheme.primaryBlue, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CameraPreview(_cameraController!),
              ),
            ),

          // Messages area
          Expanded(
            child: _messages.isEmpty
                ? Center(
              child: Text(
                'Speak in ${_userLanguage.name}',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.grey[400],
                ),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16)),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Language selector and button at bottom
          Container(
            padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16)),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Language dropdowns
                  Row(
                    children: [
                      // Source language
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.getResponsivePadding(context, 16),
                            vertical: AppTheme.getResponsivePadding(context, 12),
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(
                              AppTheme.getResponsiveRadius(context, 12),
                            ),
                          ),
                          child: DropdownButton<Language>(
                            value: _userLanguage,
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.primaryBlue,
                              size: AppTheme.getResponsiveIconSize(context, 24),
                            ),
                            style: TextStyle(
                              fontSize: AppTheme.getResponsiveFontSize(context, 16),
                              fontWeight: FontWeight.w600,
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
                                  _userLanguage = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),

                      // Swap button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GestureDetector(
                          onTap: _swap,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.swap_horiz,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // Target language
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.lightBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<Language>(
                            value: _otherLanguage,
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
                                  _otherLanguage = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Mode Toggle Button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: !_isCameraMode ? null : _toggleMode,
                          icon: const Icon(Icons.mic, size: 20),
                          label: const Text('Voice'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !_isCameraMode ? AppTheme.primaryBlue : Colors.grey[300],
                            foregroundColor: !_isCameraMode ? Colors.white : Colors.grey[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isCameraMode ? null : _toggleMode,
                          icon: const Icon(Icons.camera_alt, size: 20),
                          label: const Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isCameraMode ? AppTheme.primaryBlue : Colors.grey[300],
                            foregroundColor: _isCameraMode ? Colors.white : Colors.grey[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Start/Stop button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isListening || _isCameraMode)
                          ? (_isCameraMode ? _stopCamera : _stopListening)
                          : (_isCameraMode ? _startCamera : _startListening),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_isListening || _isCameraMode) ? Colors.green : AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            (_isListening || _isCameraMode)
                                ? Icons.stop
                                : (_isCameraMode ? Icons.camera_alt : Icons.mic),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (_isListening || _isCameraMode)
                                ? 'Stop ${_isCameraMode ? "Scanning" : "Listening"}'
                                : 'Start ${_isCameraMode ? "Scanning" : "Conversation"}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ConversationMessage message) {
    // Check if this is an error message
    final isError = message.text.startsWith('❌');

    if (message.isUserMessage) {
      // User message - right side, blue bubble
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message.text,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.language,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // User icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
          ],
        ),
      );
    } else {
      // Translated message - left side, white bubble with icon
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Translate icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError ? Icons.error_outline : Icons.translate,
                color: isError ? Colors.red : AppTheme.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.all(
                    color: isError
                        ? Colors.red.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 15,
                        color: isError ? Colors.red : Colors.black87,
                      ),
                    ),
                    if (!isError) ...[
                      const SizedBox(height: 4),
                      Text(
                        message.language,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

// Custom painter for swap arrow
class SwapArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Draw curved arrow
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.1,
      size.width, size.height * 0.3,
    );

    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.9,
      size.width, size.height * 0.7,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}*/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as Math;
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

class ConversationMessage {
  final String text;
  final String translatedText;
  final bool isUserMessage;
  final String language;

  ConversationMessage({
    required this.text,
    required this.translatedText,
    required this.isUserMessage,
    required this.language,
  });
}

class LiveConversationPage extends StatefulWidget {
  const LiveConversationPage({super.key});

  @override
  State<LiveConversationPage> createState() => _LiveConversationPageState();
}

class _LiveConversationPageState extends State<LiveConversationPage> with SingleTickerProviderStateMixin {
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

  Language _userLanguage = const Language('English', 'en', 'en-US');
  Language _otherLanguage = const Language('Spanish', 'es', 'es-ES');

  final List<ConversationMessage> _messages = [];
  String _currentListeningText = '';

  bool _isListening = false;
  bool _isTranslating = false;
  bool _isSpeechInitialized = false;

  late AnimationController _waveController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
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
  Future<bool> _checkSpeechPermissions() async {
    try {
      var micStatus = await Permission.microphone.status;
      if (micStatus.isPermanentlyDenied) {
        _showSnackBar('Please enable microphone in Settings', isError: true);
        return false;
      }
      if (!micStatus.isGranted) {
        micStatus = await Permission.microphone.request();
      }

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

  // ✅ UPDATE _startListening FUNCTION
  Future<void> _startListening() async {
    if (!_isSpeechInitialized) {
      _showSnackBar('Speech recognition not initialized', isError: true);
      return;
    }

    // ✅ CHECK PERMISSIONS
    final hasPermission = await _checkSpeechPermissions();
    if (!hasPermission) return;

    setState(() {
      _isListening = true;
      _currentListeningText = '';
    });

    await SpeechService.startListening(
      languageCode: _userLanguage.speechCode,
      onResult: (text) {
        setState(() {
          _currentListeningText = text;
        });
      },
    );
  }

  Future<void> _translateAndAddMessage(String text) async {
    // ✅ Check credits before translation (2 credits per message)
    final creditManager = context.read<CreditManager>();
    const requiredCredits = 2;
    if (!creditManager.hasEnoughCredits(requiredCredits)) {
      final errorMessage = ConversationMessage(
        text: '❌ Insufficient credits. You need $requiredCredits credits to translate.',
        translatedText: '',
        isUserMessage: false,
        language: _userLanguage.name,
      );
      setState(() {
        _messages.add(errorMessage);
      });
      _scrollToBottom();
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    try {
      // Add user message (right side - blue bubble)
      final userMessage = ConversationMessage(
        text: text,
        translatedText: '',
        isUserMessage: true,
        language: _userLanguage.name,
      );

      setState(() {
        _messages.add(userMessage);
      });

      _scrollToBottom();

      // Translate to target language
      final translatedText = await GoogleTranslateService.translate(
        text: text,
        sourceLanguage: _userLanguage.code,
        targetLanguage: _otherLanguage.code,
      );

      // ✅ Deduct credits after successful translation (2 credits per message)
      final deducted = await creditManager.deductCredits(requiredCredits, reason: 'conversation_translation');
      if (!deducted) {
        final errorMessage = ConversationMessage(
          text: '❌ Failed to deduct credits',
          translatedText: '',
          isUserMessage: false,
          language: _userLanguage.name,
        );
        setState(() {
          _messages.add(errorMessage);
        });
        _scrollToBottom();
        return;
      }

      // Add translated message (left side - white bubble with translate icon)
      final translatedMessage = ConversationMessage(
        text: translatedText,
        translatedText: text,
        isUserMessage: false,
        language: _otherLanguage.name,
      );

      setState(() {
        _messages.add(translatedMessage);
        _isTranslating = false;
      });

      // Save to history (CONVERSATION TYPE)
      await TranslationHistoryService.addTranslation(
        originalText: text,
        translatedText: translatedText,
        sourceLanguage: _userLanguage.code,
        targetLanguage: _otherLanguage.code,
        translationType: 'conversation',
      );

      _scrollToBottom();

      // Speak the translation
      await TTSService.speak(translatedText, _otherLanguage.speechCode);

    } catch (e) {
      setState(() {
        _isTranslating = false;
      });

      // Show error message as a message bubble
      final errorMessage = ConversationMessage(
        text: '❌ Exception: ${e.toString().replaceAll('Exception: ', '')}',
        translatedText: '',
        isUserMessage: false,
        language: _userLanguage.name,
      );

      setState(() {
        _messages.add(errorMessage);
      });

      _scrollToBottom();
    }
  }

/*
  Future<void> _startListening() async {
    if (!_isSpeechInitialized) {
      _showSnackBar('Speech recognition not initialized', isError: true);
      return;
    }

    setState(() {
      _isListening = true;
      _currentListeningText = '';
    });

    await SpeechService.startListening(
      languageCode: _userLanguage.speechCode,
      onResult: (text) {
        setState(() {
          _currentListeningText = text;
        });
      },
    );
  }
*/

  Future<void> _stopListening() async {
    await SpeechService.stopListening();

    setState(() {
      _isListening = false;
    });

    if (_currentListeningText.trim().isEmpty) {
      _showSnackBar('No speech detected');
      return;
    }

    // Translate and add to conversation
    await _translateAndAddMessage(_currentListeningText);

    setState(() {
      _currentListeningText = '';
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _swap() {
    setState(() {
      final temp = _userLanguage;
      _userLanguage = _otherLanguage;
      _otherLanguage = temp;
    });
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : AppTheme.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _scrollController.dispose();
    SpeechService.dispose();
    TTSService.stop();
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
          'Live Conversation',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTheme.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Language Selection Header with Wave Animation
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getResponsivePadding(context, 16),
              vertical: AppTheme.getResponsivePadding(context, 16),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                // You speak
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You speak',
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 12),
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: AppTheme.getResponsiveSpacing(context, 4)),
                      Text(
                        _userLanguage.name,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Wave Animation in middle
                SizedBox(
                  width: 60,
                  height: 40,
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: WaveAnimationPainter(
                          animationValue: _waveController.value,
                          isActive: _isListening,
                        ),
                      );
                    },
                  ),
                ),

                // They hear
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'They hear',
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 12),
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: AppTheme.getResponsiveSpacing(context, 4)),
                      Text(
                        _otherLanguage.name,
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Listening indicator
          if (_isListening)
            Container(
              padding: EdgeInsets.symmetric(
                vertical: AppTheme.getResponsivePadding(context, 10),
                horizontal: AppTheme.getResponsivePadding(context, 16),
              ),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mic,
                    size: AppTheme.getResponsiveIconSize(context, 16),
                    color: Colors.grey,
                  ),
                  SizedBox(width: AppTheme.getResponsiveSpacing(context, 8)),
                  Text(
                    'Listening in ${_userLanguage.name}',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 14),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

          // Messages area
          Expanded(
            child: _messages.isEmpty
                ? Center(
              child: Text(
                'Speak in ${_userLanguage.name}',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  color: Colors.grey[400],
                ),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16)),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Language selector and button at bottom
          Container(
            padding: EdgeInsets.all(AppTheme.getResponsivePadding(context, 16)),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Language dropdowns
                  Row(
                    children: [
                      // Source language
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.getResponsivePadding(context, 16),
                            vertical: AppTheme.getResponsivePadding(context, 12),
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(
                              AppTheme.getResponsiveRadius(context, 12),
                            ),
                          ),
                          child: DropdownButton<Language>(
                            value: _userLanguage,
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.primaryBlue,
                              size: AppTheme.getResponsiveIconSize(context, 24),
                            ),
                            style: TextStyle(
                              fontSize: AppTheme.getResponsiveFontSize(context, 16),
                              fontWeight: FontWeight.w600,
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
                                  _userLanguage = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),

                      // Swap button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GestureDetector(
                          onTap: _swap,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.swap_horiz,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // Target language
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.lightBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<Language>(
                            value: _otherLanguage,
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
                                  _otherLanguage = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Start/Stop button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isListening ? _stopListening : _startListening,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isListening ? Colors.red : AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isListening ? Icons.stop : Icons.mic,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isListening ? 'Stop Conversation' : 'Start Conversation',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ConversationMessage message) {
    // Check if this is an error message
    final isError = message.text.startsWith('❌');

    if (message.isUserMessage) {
      // User message - right side, blue bubble
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message.text,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.language,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // User icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
          ],
        ),
      );
    } else {
      // Translated message - left side, white bubble with icon
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Translate icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError ? Icons.error_outline : Icons.translate,
                color: isError ? Colors.red : AppTheme.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.all(
                    color: isError
                        ? Colors.red.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 15,
                        color: isError ? Colors.red : Colors.black87,
                      ),
                    ),
                    if (!isError) ...[
                      const SizedBox(height: 4),
                      Text(
                        message.language,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

// Wave Animation Painter
class WaveAnimationPainter extends CustomPainter {
  final double animationValue;
  final bool isActive;

  WaveAnimationPainter({
    required this.animationValue,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? AppTheme.primaryBlue : Colors.grey.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final waveHeight = isActive ? 15.0 : 5.0;
    final frequency = 2.0;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          waveHeight *
              Math.sin((x / size.width * frequency * 2 * Math.pi) +
                  (animationValue * 2 * Math.pi));
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveAnimationPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isActive != isActive;
  }
}