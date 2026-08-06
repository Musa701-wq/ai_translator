// lib/services/tts_service.dart
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  /// Initialize TTS
  static Future<void> initialize() async {
    if (!_isInitialized) {
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    }
  }

  /// Speak the given text in specified language
  /// [text] - Text to speak
  /// [languageCode] - Language code (e.g., 'en-US', 'es-ES')
  static Future<void> speak(String text, String languageCode) async {
    if (!_isInitialized) {
      await initialize();
    }

    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.speak(text);
  }

  /// Stop speaking
  static Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Check if currently speaking
  static Future<bool> isSpeaking() async {
    return await _flutterTts.awaitSpeakCompletion(true);
  }

  /// Get available languages
  static Future<List<dynamic>> getLanguages() async {
    return await _flutterTts.getLanguages;
  }
}