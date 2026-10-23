import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _settingsKey = 'game_settings';
  static const _highScoresKey = 'high_scores';
  static const _proCachedKey = 'pro_cached';
  static const _proTestOverrideKey = 'pro_test_override';

  GameSettings loadSettings() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null) return const GameSettings();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return GameSettings.fromJson(json);
    } catch (_) {
      return const GameSettings();
    }
  }

  Future<void> saveSettings(GameSettings settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  HighScores loadHighScores() {
    final raw = _prefs.getString(_highScoresKey);
    if (raw == null) return const HighScores();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return HighScores.fromJson(json);
    } catch (_) {
      return const HighScores();
    }
  }

  Future<void> saveHighScores(HighScores scores) async {
    await _prefs.setString(_highScoresKey, jsonEncode(scores.toJson()));
  }

  int loadClassicHighScore() => loadHighScores().classicBest;

  Future<void> saveClassicHighScore(int score) async {
    final current = loadHighScores();
    if (score <= current.classicBest) return;
    await saveHighScores(current.copyWith(classicBest: score));
  }

  bool loadCachedPro() => _prefs.getBool(_proCachedKey) ?? false;

  Future<void> saveCachedPro(bool isPro) async {
    await _prefs.setBool(_proCachedKey, isPro);
  }

  /// Tester override. Null follows the store. True forces Pro. False forces Free.
  bool? loadProTestOverride() {
    if (!_prefs.containsKey(_proTestOverrideKey)) return null;
    return _prefs.getBool(_proTestOverrideKey);
  }

  Future<void> saveProTestOverride(bool? enabled) async {
    if (enabled == null) {
      await _prefs.remove(_proTestOverrideKey);
      return;
    }
    await _prefs.setBool(_proTestOverrideKey, enabled);
  }
}
