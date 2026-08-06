// lib/services/ocr_service.dart
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  static final _textRecognizer = TextRecognizer();

  /// Extract text from image using ML Kit
  static Future<String> extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        throw Exception('No text found in image');
      }

      return recognizedText.text;
    } catch (e) {
      throw Exception('Failed to extract text: $e');
    }
  }

  /// Dispose the text recognizer when done
  static void dispose() {
    _textRecognizer.close();
  }
}