// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Google Analytics Service for tracking feature clicks
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Track Text Translation feature click
  static Future<void> trackTextTranslationClicked() async {
    try {
      await _analytics.logEvent(
        name: 'text_translation_clicked',
        parameters: {
          'feature_name': 'Text Translation',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 [Analytics] Text Translation clicked tracked');
    } catch (e) {
      debugPrint('❌ [Analytics] Error tracking text translation: $e');
    }
  }

  /// Track Scan & Translate feature click
  static Future<void> trackScanTranslateClicked() async {
    try {
      await _analytics.logEvent(
        name: 'scan_translate_clicked',
        parameters: {
          'feature_name': 'Scan & Translate',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 [Analytics] Scan & Translate clicked tracked');
    } catch (e) {
      debugPrint('❌ [Analytics] Error tracking scan translate: $e');
    }
  }

  /// Track Voice Translate feature click
  static Future<void> trackVoiceTranslateClicked() async {
    try {
      await _analytics.logEvent(
        name: 'voice_translate_clicked',
        parameters: {
          'feature_name': 'Voice Translate',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 [Analytics] Voice Translate clicked tracked');
    } catch (e) {
      debugPrint('❌ [Analytics] Error tracking voice translate: $e');
    }
  }

  /// Track Live Conversation feature click
  static Future<void> trackLiveConversationClicked() async {
    try {
      await _analytics.logEvent(
        name: 'live_conversation_clicked',
        parameters: {
          'feature_name': 'Live Conversation',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 [Analytics] Live Conversation clicked tracked');
    } catch (e) {
      debugPrint('❌ [Analytics] Error tracking live conversation: $e');
    }
  }

  /// Track Smart Dictionary feature click
  static Future<void> trackSmartDictionaryClicked() async {
    try {
      await _analytics.logEvent(
        name: 'smart_dictionary_clicked',
        parameters: {
          'feature_name': 'Smart Dictionary',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 [Analytics] Smart Dictionary clicked tracked');
    } catch (e) {
      debugPrint('❌ [Analytics] Error tracking smart dictionary: $e');
    }
  }

  /// Track Live Translation feature click
  static Future<void> trackLiveTranslationClicked() async {
    try {
      await _analytics.logEvent(
        name: 'live_translation_clicked',
        parameters: {
          'feature_name': 'Live Translation',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 [Analytics] Live Translation clicked tracked');
    } catch (e) {
      debugPrint('❌ [Analytics] Error tracking live translation: $e');
    }
  }
}

