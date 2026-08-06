// lib/services/speech_service.dart
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static bool _isInitialized = false;

  /// Initialize speech recognition
  static Future<bool> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (error) => print('Speech error: $error'),
        onStatus: (status) => print('Speech status: $status'),
      );
    }
    return _isInitialized;
  }

  /// Start listening to user's voice
  /// [languageCode] - Language code (e.g., 'en-US', 'es-ES')
  /// [onResult] - Callback when text is recognized
  static Future<void> startListening({
    required String languageCode,
    required Function(String) onResult,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_speech.isAvailable) {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        localeId: languageCode,
        cancelOnError: true,
        partialResults: true,
        listenMode: stt.ListenMode.confirmation,
      );
    }
  }

  /// Stop listening
  static Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  /// Check if currently listening
  static bool isListening() {
    return _speech.isListening;
  }

  /// Check if speech recognition is available
  static bool isAvailable() {
    return _speech.isAvailable;
  }

  /// Get available locales/languages
  static Future<List<stt.LocaleName>> getLocales() async {
    return await _speech.locales();
  }

  /// Dispose/cleanup
  static void dispose() {
    _speech.cancel();
  }
}