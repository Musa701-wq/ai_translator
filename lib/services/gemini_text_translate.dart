/*
// lib/services/gemini_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = 'AIzaSyAm3zoOQvyu_ok-yX1uYejU0vuYpTlmJsc'; // Apni API key yahan
  static const String url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static Future<String> translate(String text, String from, String to) async {
    try {
      final prompt = '''You are a professional translator. Translate the following text from $from to $to. 
Provide ONLY the translation, nothing else. No explanations, no notes.

Text to translate: "$text"

Translation:''';

      final response = await http.post(
        Uri.parse('$url?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String translation = data['candidates'][0]['content']['parts'][0]['text'].toString().trim();

        // Remove any extra text like "Translation:" or quotes
        translation = translation
            .replaceAll('Translation:', '')
            .replaceAll('translation:', '')
            .replaceAll('"', '')
            .trim();

        return translation;
      } else if (response.statusCode == 400) {
        throw Exception('Invalid request. Check your API key.');
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests. Try again later.');
      }
      throw Exception('Translation failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('$e');
    }
  }
}*/
// lib/services/google_translate_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleTranslateService {
  // ⚠️ IMPORTANT: Apni Google Translate API key yahan paste karein
  static const String apiKey = 'AIzaSyAm3zoOQvyu_ok-yX1uYejU0vuYpTlmJsc';

  // Google Translate API endpoint
  static const String url = 'https://translation.googleapis.com/language/translate/v2';

  /// Main translation function using Google Translate API
  /// [text] - Jo text translate karna hai
  /// [targetLanguage] - Target language code (e.g., 'es' for Spanish)
  /// [sourceLanguage] - Optional source language code (auto-detect if not provided)
  static Future<String> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    if (text.trim().isEmpty) {
      throw Exception('Text cannot be empty');
    }

    try {
      final Map<String, dynamic> requestBody = {
        'q': text,
        'target': targetLanguage,
      };

      // Add source language if provided (otherwise Google will auto-detect)
      if (sourceLanguage != null && sourceLanguage.isNotEmpty) {
        requestBody['source'] = sourceLanguage;
      }

      // Make API request
      final response = await http.post(
        Uri.parse('$url?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Check response status
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract translated text
        if (data['data'] != null &&
            data['data']['translations'] != null &&
            data['data']['translations'].isNotEmpty) {

          final translatedText = data['data']['translations'][0]['translatedText'];
          return translatedText;
        } else {
          throw Exception('Invalid response format from Google Translate API');
        }
      }
      // Handle different error codes
      else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception('Bad request: ${error['error']['message'] ?? 'Invalid parameters'}');
      } else if (response.statusCode == 403) {
        throw Exception('API key error. Please check your Google Translate API key and billing.');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Translation failed: ${error['error']['message'] ?? response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('Network error. Please check your internet connection.');
      }
      rethrow;
    }
  }

  /// Detect language of given text
  static Future<String> detectLanguage(String text) async {
    if (text.trim().isEmpty) {
      throw Exception('Text cannot be empty');
    }

    try {
      final response = await http.post(
        Uri.parse('https://translation.googleapis.com/language/translate/v2/detect?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null &&
            data['data']['detections'] != null &&
            data['data']['detections'].isNotEmpty) {
          return data['data']['detections'][0][0]['language'];
        }
      }
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  /// Get list of supported languages
  static Future<List<Map<String, String>>> getSupportedLanguages() async {
    try {
      final response = await http.get(
        Uri.parse('https://translation.googleapis.com/language/translate/v2/languages?key=$apiKey&target=en'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data']['languages'] != null) {
          return List<Map<String, String>>.from(
            data['data']['languages'].map((lang) => {
              'code': lang['language'].toString(),
              'name': lang['name'].toString(),
            }),
          );
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}