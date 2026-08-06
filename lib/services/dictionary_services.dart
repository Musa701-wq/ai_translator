// lib/services/dictionary_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class DictionaryService {
  // Free Dictionary API - No API key required
  static const String baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries';

  /// Get word definition, pronunciation, and examples
  static Future<Map<String, dynamic>> getWordDetails(
      String word,
      String language,
      ) async {
    try {
      // Map language to API language code
      final langCode = _getLanguageCode(language);

      final response = await http.get(
        Uri.parse('$baseUrl/$langCode/$word'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isEmpty) {
          throw Exception('No definition found');
        }

        final wordData = data[0];

        // Extract definitions
        final List<Map<String, String>> definitions = [];
        if (wordData['meanings'] != null) {
          for (var meaning in wordData['meanings']) {
            final partOfSpeech = meaning['partOfSpeech'] ?? 'N/A';
            if (meaning['definitions'] != null && meaning['definitions'].isNotEmpty) {
              final definition = meaning['definitions'][0]['definition'] ?? '';
              definitions.add({
                'type': partOfSpeech.toUpperCase(),
                'meaning': definition,
              });
            }
          }
        }

        // Extract pronunciation
        String? pronunciation;
        if (wordData['phonetics'] != null && wordData['phonetics'].isNotEmpty) {
          for (var phonetic in wordData['phonetics']) {
            if (phonetic['text'] != null && phonetic['text'].isNotEmpty) {
              pronunciation = phonetic['text'];
              break;
            }
          }
        }

        // Extract examples
        final List<String> examples = [];
        if (wordData['meanings'] != null) {
          for (var meaning in wordData['meanings']) {
            if (meaning['definitions'] != null) {
              for (var def in meaning['definitions']) {
                if (def['example'] != null && def['example'].isNotEmpty) {
                  examples.add(def['example']);
                  if (examples.length >= 3) break;
                }
              }
              if (examples.length >= 3) break;
            }
          }
        }

        // Extract audio URL
        String? audioUrl;
        if (wordData['phonetics'] != null) {
          for (var phonetic in wordData['phonetics']) {
            if (phonetic['audio'] != null && phonetic['audio'].isNotEmpty) {
              audioUrl = phonetic['audio'];
              break;
            }
          }
        }

        return {
          'word': word,
          'definitions': definitions,
          'pronunciation': pronunciation,
          'examples': examples,
          'audioUrl': audioUrl,
        };
      } else if (response.statusCode == 404) {
        throw Exception('Word not found');
      } else {
        throw Exception('Failed to fetch word details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Translate word to different languages using Google Translate API
  static Future<Map<String, String>> getTranslations(
      String word,
      String sourceLanguage,
      ) async {
    // This would use Google Translate API
    // For now, returning mock data
    final translations = <String, String>{};

    // You can integrate with your existing GoogleTranslateService here
    final targetLanguages = ['es', 'fr', 'de', 'it', 'pt'];
    final languageNames = ['Spanish', 'French', 'German', 'Italian', 'Portuguese'];

    for (int i = 0; i < targetLanguages.length; i++) {
      try {
        // Use your existing translation service
        // final translated = await GoogleTranslateService.translate(
        //   text: word,
        //   sourceLanguage: 'en',
        //   targetLanguage: targetLanguages[i],
        // );
        // translations[languageNames[i]] = translated;

        // Mock translation for now
        translations[languageNames[i]] = '$word (${targetLanguages[i]})';
      } catch (e) {
        translations[languageNames[i]] = 'N/A';
      }
    }

    return translations;
  }

  /// Map language names to API codes
  static String _getLanguageCode(String language) {
    final Map<String, String> languageCodes = {
      'English': 'en',
      'Spanish': 'es',
      'French': 'fr',
      'German': 'de',
      'Italian': 'it',
      'Portuguese': 'pt',
      'Chinese': 'zh',
      'Japanese': 'ja',
      'Korean': 'ko',
      'Arabic': 'ar',
      'Hindi': 'hi',
      'Urdu': 'ur',
    };

    return languageCodes[language] ?? 'en';
  }

  /// Get popular words suggestions
  static List<String> getPopularWords() {
    return [
      'Goods',
      'Hello',
      'Thank you',
      'Welcome',
      'Beautiful',
      'Friend',
      'Love',
      'Peace',
      'Happy',
      'Success',
    ];
  }

  /// Search word suggestions
  static Future<List<String>> searchSuggestions(String query) async {
    // This would typically call an autocomplete API
    // For now, returning filtered popular words
    final popular = getPopularWords();
    return popular
        .where((word) => word.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}