import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../services/gemini_text_translate.dart';
import '../services/ocr_services.dart';
import '../utils/app_theme.dart';
import '../in_app_purchase/credit_manager.dart';
import 'history.dart';

class Language {
  final String name;
  final String code;
  const Language(this.name, this.code);
}

class ScanTranslatePage extends StatefulWidget {
  const ScanTranslatePage({super.key});

  @override
  State<ScanTranslatePage> createState() => _ScanTranslatePageState();
}

class _ScanTranslatePageState extends State<ScanTranslatePage> {
  final ImagePicker _picker = ImagePicker();
  final _extractedTextController = TextEditingController();
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

  File? _selectedImage;
  bool _isProcessing = false;
  bool _hasScanned = false;
  bool _hasTranslated = false;
  Future<bool> _checkCameraPermission() async {
    try {
      var status = await Permission.camera.status;

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        _showSnackBar('Please enable camera access in Settings', isError: true);
        return false;
      }

      status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      _showSnackBar('Permission error: $e', isError: true);
      return false;
    }
  }
  // ✅ ADD GALLERY PERMISSION CHECK
  Future<bool> _checkGalleryPermission() async {
    try {
      var status = await Permission.photos.status;

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        _showSnackBar('Please enable photo library access in Settings', isError: true);
        return false;
      }

      status = await Permission.photos.request();
      return status.isGranted;
    } catch (e) {
      _showSnackBar('Permission error: $e', isError: true);
      return false;
    }
  }
  Future<void> _pickImageFromCamera() async {
    try {
      // Check permission first
      final hasPermission = await _checkCameraPermission();
      if (!hasPermission) return;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImage(image.path);
      }
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') {
        _showSnackBar('Camera access denied', isError: true);
      } else if (e.code == 'camera_access_restricted') {
        _showSnackBar('Camera access restricted', isError: true);
      } else {
        _showSnackBar('Camera error: ${e.message}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to open camera: $e', isError: true);
    }
  }
  Future<void> _pickImageFromGallery() async {
    try {
      // Check permission first
      final hasPermission = await _checkGalleryPermission();
      if (!hasPermission) return;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImage(image.path);
      }
    } on PlatformException catch (e) {
      if (e.code == 'photo_access_denied') {
        _showSnackBar('Photo library access denied', isError: true);
      } else {
        _showSnackBar('Gallery error: ${e.message}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to open gallery: $e', isError: true);
    }
  }

/*  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImage(image.path);
      }
    } catch (e) {
      _showSnackBar('Camera error: $e', isError: true);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImage(image.path);
      }
    } catch (e) {
      _showSnackBar('Gallery error: $e', isError: true);
    }
  }*/
  // lib/screens/scan_translate_page.dart
// ... existing code ...

  Future<void> _translateExtractedText() async {
    if (_extractedTextController.text.trim().isEmpty) {
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

    setState(() => _isProcessing = true);

    try {
      final result = await GoogleTranslateService.translate(
        text: _extractedTextController.text,
        sourceLanguage: _sourceLanguage.code,
        targetLanguage: _targetLanguage.code,
      );

      // ✅ Deduct credits after successful translation
      final deducted = await creditManager.deductCredits(requiredCredits, reason: 'photo_translation');
      if (!deducted) {
        _showSnackBar('Failed to deduct credits', isError: true);
      }

      setState(() {
        _translatedController.text = result;
        _hasTranslated = true;
        _isProcessing = false;
      });

      // ✅ THIS IS ALREADY THERE - Make sure it's not commented
      await TranslationHistoryService.addTranslation(
        originalText: _extractedTextController.text,
        translatedText: result,
        sourceLanguage: _sourceLanguage.code,
        targetLanguage: _targetLanguage.code,
        translationType: 'scan',
      );

      _showSnackBar('Translation complete!');
    } catch (e) {
      setState(() => _isProcessing = false);
      _showSnackBar('Translation failed: $e', isError: true);
    }
  }

// ... rest of the code ...

  Future<void> _processImage(String imagePath) async {
    setState(() {
      _isProcessing = true;
      _selectedImage = File(imagePath);
      _extractedTextController.clear();
      _translatedController.clear();
      _hasScanned = false;
      _hasTranslated = false;
    });

    try {
      final extractedText = await OCRService.extractTextFromImage(imagePath);

      setState(() {
        _extractedTextController.text = extractedText;
        _hasScanned = true;
        _isProcessing = false;
      });

      _showSnackBar('Text extracted successfully!');
    } catch (e) {
      setState(() => _isProcessing = false);
      _showSnackBar('Failed to extract text: $e', isError: true);
    }
  }

/*
  Future<void> _translateExtractedText() async {
    if (_extractedTextController.text.trim().isEmpty) {
      _showSnackBar('No text to translate', isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final result = await GoogleTranslateService.translate(
        text: _extractedTextController.text,
        sourceLanguage: _sourceLanguage.code,
        targetLanguage: _targetLanguage.code,
      );

      setState(() {
        _translatedController.text = result;
        _hasTranslated = true;
        _isProcessing = false;
      });

      // Save to history
      await TranslationHistoryService.addTranslation(
        originalText: _extractedTextController.text,
        translatedText: result,
        sourceLanguage: _sourceLanguage.code,
        targetLanguage: _targetLanguage.code,
        translationType: 'scan',
      );

      _showSnackBar('Translation complete!');
    } catch (e) {
      setState(() => _isProcessing = false);
      _showSnackBar('Translation failed: $e', isError: true);
    }
  }
*/

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Options
            Row(
              children: [
                // Camera Option
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromCamera();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Camera',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Gallery Option
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Gallery',
                            style: TextStyle(
                              fontSize: 14,
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _swap() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      if (_hasTranslated) {
        final tempText = _extractedTextController.text;
        _extractedTextController.text = _translatedController.text;
        _translatedController.text = tempText;
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

  void _copy(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copied!');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - appBarHeight - 32; // 32 for top/bottom padding

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
          'Scan & Translate',
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
                    color: Colors.grey.withOpacity(0.25),
                    spreadRadius: 1,
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
                        color: AppTheme.lightBlue.withOpacity(0.3),
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
                        color: AppTheme.lightBlue.withOpacity(0.3),
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

            const SizedBox(height: 24),

            // Scan Document Container with dynamic height
            GestureDetector(
              onTap: _isProcessing ? null : _showImageSourceDialog,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: _hasScanned ? 120 : availableHeight * 0.4,
                ),
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Camera Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isProcessing ? Icons.hourglass_empty : Icons.camera_alt,
                        color: AppTheme.primaryBlue,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tap to Scan Text
                    Text(
                      _isProcessing ? 'Processing...' : 'Tap to Scan Document',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Use Camera or Gallery Text
                    Text(
                      'Use Camera or Select from Gallery',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Show extracted text if available
            if (_hasScanned) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      spreadRadius: 1,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.document_scanner, size: 20, color: AppTheme.primaryBlue),
                              SizedBox(width: 8),
                              Text('Extracted Text', style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () => _copy(_extractedTextController.text),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextField(
                        controller: _extractedTextController,
                        maxLines: 6,
                        readOnly: true,
                        style: const TextStyle(fontSize: 15),
                        decoration: const InputDecoration(
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
                  onPressed: _isProcessing ? null : _translateExtractedText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isProcessing
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
            ],

            // Show translated text if available
            if (_hasTranslated) ...[
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                      spreadRadius: 1,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.translate, size: 20, color: AppTheme.primaryBlue),
                              SizedBox(width: 8),
                              Text(
                                'Translated Text',
                                style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20, color: AppTheme.primaryBlue),
                            onPressed: () => _copy(_translatedController.text),
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
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}