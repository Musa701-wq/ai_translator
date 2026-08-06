// lib/services/translation_history_service.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TranslationHistory {
  final int? id;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final String translationType; // 'text', 'voice', 'scan', 'conversation'
  final DateTime timestamp;
  final bool isFavorite;

  TranslationHistory({
    this.id,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.translationType,
    required this.timestamp,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'translationType': translationType,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory TranslationHistory.fromMap(Map<String, dynamic> map) {
    return TranslationHistory(
      id: map['id'],
      originalText: map['originalText'],
      translatedText: map['translatedText'],
      sourceLanguage: map['sourceLanguage'],
      targetLanguage: map['targetLanguage'],
      translationType: map['translationType'],
      timestamp: DateTime.parse(map['timestamp']),
      isFavorite: map['isFavorite'] == 1,
    );
  }
}

class TranslationHistoryService {
  static Database? _database;

  /// Get or initialize the database
  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'translation_history.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE translations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            originalText TEXT NOT NULL,
            translatedText TEXT NOT NULL,
            sourceLanguage TEXT NOT NULL,
            targetLanguage TEXT NOT NULL,
            translationType TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            isFavorite INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  /// Add a new translation to history
  static Future<int> addTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required String translationType,
  }) async {
    final db = await database;

    final translation = TranslationHistory(
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      translationType: translationType,
      timestamp: DateTime.now(),
    );

    return await db.insert('translations', translation.toMap());
  }

  /// Get all translations (most recent first)
  static Future<List<TranslationHistory>> getAllTranslations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'translations',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return TranslationHistory.fromMap(maps[i]);
    });
  }

  /// Get translations by type
  static Future<List<TranslationHistory>> getTranslationsByType(
      String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'translations',
      where: 'translationType = ?',
      whereArgs: [type],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return TranslationHistory.fromMap(maps[i]);
    });
  }

  /// Get favorite translations
  static Future<List<TranslationHistory>> getFavoriteTranslations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'translations',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return TranslationHistory.fromMap(maps[i]);
    });
  }

  /// Search translations
  static Future<List<TranslationHistory>> searchTranslations(
      String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'translations',
      where: 'originalText LIKE ? OR translatedText LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return TranslationHistory.fromMap(maps[i]);
    });
  }

  /// Toggle favorite status
  static Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'translations',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a translation
  static Future<void> deleteTranslation(int id) async {
    final db = await database;
    await db.delete(
      'translations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all translations
  static Future<void> clearHistory() async {
    final db = await database;
    await db.delete('translations');
  }

  /// Get translation count
  static Future<int> getTranslationCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM translations');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get recent translations (limit to n items)
  static Future<List<TranslationHistory>> getRecentTranslations(
      int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'translations',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return TranslationHistory.fromMap(maps[i]);
    });
  }

  /// Close the database
  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}