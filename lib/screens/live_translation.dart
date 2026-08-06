import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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

class DetectedTextElement {
  final String text;
  final Rect boundingBox;
  String? translation;
  bool isTranslating;

  DetectedTextElement({
    required this.text,
    required this.boundingBox,
    this.translation,
    this.isTranslating = false,
  });
}

class PhotoTranslatePage extends StatefulWidget {
  const PhotoTranslatePage({super.key});

  @override
  State<PhotoTranslatePage> createState() => _PhotoTranslatePageState();
}

class _PhotoTranslatePageState extends State<PhotoTranslatePage> {
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
    Language('Turkish', 'tr'),
    Language('Dutch', 'nl'),
    Language('Polish', 'pl'),
    Language('Swedish', 'sv'),
    Language('Greek', 'el'),
    Language('Czech', 'cs'),
    Language('Danish', 'da'),
  ];

  Language _sourceLanguage = const Language('Detecting...', 'auto');
  Language _targetLanguage = const Language('Spanish', 'es');

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isDetecting = false;

  final TextRecognizer _textRecognizer = TextRecognizer();
  List<DetectedTextElement> _detectedTexts = [];
  Timer? _detectionTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });

          // Start continuous text detection
          _startContinuousDetection();
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  void _startContinuousDetection() {
    _detectionTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isCameraInitialized && !_isProcessing) {
        _detectAndTranslateText();
      }
    });
  }

  Future<void> _detectAndTranslateText() async {
    if (_isProcessing || _cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _isDetecting = true;
    });

    try {
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Delete temporary image
      final file = File(image.path);
      if (await file.exists()) {
        await file.delete();
      }

      if (recognizedText.blocks.isNotEmpty) {
        List<DetectedTextElement> newDetectedTexts = [];

        for (final block in recognizedText.blocks) {
          for (final line in block.lines) {
            if (line.text.trim().isNotEmpty) {
              newDetectedTexts.add(
                DetectedTextElement(
                  text: line.text,
                  boundingBox: line.boundingBox,
                  isTranslating: true,
                ),
              );
            }
          }
        }

        setState(() {
          _detectedTexts = newDetectedTexts;
        });

        // Translate each detected text
        for (var element in _detectedTexts) {
          _translateElement(element);
        }
      } else {
        setState(() {
          _detectedTexts = [];
        });
      }
    } catch (e) {
      debugPrint('Text detection error: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _translateElement(DetectedTextElement element) async {
    // ✅ Check credits before translation (1 credit per element)
    final creditManager = context.read<CreditManager>();
    const requiredCredits = 1;
    if (!creditManager.hasEnoughCredits(requiredCredits)) {
      setState(() {
        element.translation = null;
        element.isTranslating = false;
      });
      return;
    }

    try {
      final translatedText = await GoogleTranslateService.translate(
        text: element.text,
        sourceLanguage: 'auto',
        targetLanguage: _targetLanguage.code,
      );

      // ✅ Deduct credits after successful translation
      final deducted = await creditManager.deductCredits(requiredCredits, reason: 'live_translation');
      if (!deducted) {
        setState(() {
          element.translation = null;
          element.isTranslating = false;
        });
        return;
      }

      setState(() {
        element.translation = translatedText;
        element.isTranslating = false;
      });
    } catch (e) {
      setState(() {
        element.translation = null;
        element.isTranslating = false;
      });
    }
  }

  Future<void> _captureAndSaveTranslation() async {
    if (_detectedTexts.isEmpty) {
      _showSnackBar('No text detected to translate');
      return;
    }

    // Combine all detected texts
    final originalText = _detectedTexts.map((e) => e.text).join('\n');
    final translatedText = _detectedTexts
        .where((e) => e.translation != null)
        .map((e) => e.translation!)
        .join('\n');

    if (translatedText.isEmpty) {
      _showSnackBar('Translation in progress, please wait...');
      return;
    }

    // Save to history
    await TranslationHistoryService.addTranslation(
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: 'auto',
      targetLanguage: _targetLanguage.code,
      translationType: 'photo',
    );

    _showSnackBar('Translation saved to history!');
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
    _detectionTimer?.cancel();
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Photo Translate',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Language Selection Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Detect (Source Language)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detect',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _sourceLanguage.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (_isDetecting)
                                const Icon(Icons.lock, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Swap Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  // Translate to (Target Language)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Translate to',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.lightBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<Language>(
                            value: _targetLanguage,
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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
                                  // Retrigger translation with new language
                                  for (var element in _detectedTexts) {
                                    element.isTranslating = true;
                                    element.translation = null;
                                    _translateElement(element);
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Camera View with Overlays
            Expanded(
              child: _isCameraInitialized && _cameraController != null
                  ? Stack(
                children: [
                  // Camera Preview
                  SizedBox.expand(
                    child: CameraPreview(_cameraController!),
                  ),

                  // Text Overlays
                  ..._detectedTexts.map((element) {
                    return _buildTextOverlay(element);
                  }).toList(),
                ],
              )
                  : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

            // Bottom Translate Button
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _captureAndSaveTranslation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.translate, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Translate',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextOverlay(DetectedTextElement element) {
    final screenSize = MediaQuery.of(context).size;
    final cameraSize = _cameraController!.value.previewSize!;

    // Calculate scale factors
    final scaleX = screenSize.width / cameraSize.height;
    final scaleY = (screenSize.height - 200) / cameraSize.width; // Adjust for top/bottom bars

    // Transform bounding box coordinates
    final left = element.boundingBox.left * scaleX;
    final top = element.boundingBox.top * scaleY;
    final width = element.boundingBox.width * scaleX;
    final height = element.boundingBox.height * scaleY;

    return Positioned(
      left: left,
      top: top + 100, // Offset for top bar
      child: GestureDetector(
        onTap: () {
          // Show original text dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Original Text'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    element.text,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (element.translation != null) ...[
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Translation:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(element.translation!),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.85),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show translation or loading
              if (element.isTranslating)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Error',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              else if (element.translation != null)
                Text(
                  element.translation!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Error',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}