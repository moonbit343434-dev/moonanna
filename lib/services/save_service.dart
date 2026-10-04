import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_progress.dart';

class SaveService {
  static const String _keyCurrentLevel = 'current_level';
  static const String _keyCoins = 'coins';
  static const String _keyCrystals = 'crystals';
  static const String _keyLevelResults = 'level_results';
  static const String _keyPowerUps = 'power_ups';
  static const String _keyDailyDay = 'daily_day';
  static const String _keyDailyDate = 'daily_date';
  static const String _keySound = 'sound';
  static const String _keyMusic = 'music';

  Future<PlayerProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getString(_keyLevelResults);
    Map<int, LevelResult> results = {};
    if (resultsJson != null) {
      final Map<String, dynamic> raw = jsonDecode(resultsJson);
      raw.forEach((key, val) {
        results[int.parse(key)] = LevelResult(
          levelId: int.parse(key),
          stars: val['stars'],
          bestScore: val['score'],
        );
      });
    }
    final powerUpsJson = prefs.getString(_keyPowerUps);
    Map<String, int> powerUps = {
      'moonHammer': 3,
      'comet': 2,
      'gravitySwitch': 2,
      'fullMoonBoost': 1,
      'starRay': 2,
    };
    if (powerUpsJson != null) {
      final Map<String, dynamic> raw = jsonDecode(powerUpsJson);
      raw.forEach((k, v) => powerUps[k] = v as int);
    }
    return PlayerProgress(
      currentLevel: prefs.getInt(_keyCurrentLevel) ?? 1,
      levelResults: results,
      coins: prefs.getInt(_keyCoins) ?? 200,
      crystals: prefs.getInt(_keyCrystals) ?? 10,
      powerUps: powerUps,
      dailyRewardDay: prefs.getInt(_keyDailyDay) ?? 0,
      lastDailyRewardDate: prefs.getString(_keyDailyDate),
      soundEnabled: prefs.getBool(_keySound) ?? true,
      musicEnabled: prefs.getBool(_keyMusic) ?? true,
    );
  }

  Future<void> save(PlayerProgress p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentLevel, p.currentLevel);
    await prefs.setInt(_keyCoins, p.coins);
    await prefs.setInt(_keyCrystals, p.crystals);
    // Level results
    final resultsMap = <String, dynamic>{};
    p.levelResults.forEach((id, r) {
      resultsMap[id.toString()] = {'stars': r.stars, 'score': r.bestScore};
    });
    await prefs.setString(_keyLevelResults, jsonEncode(resultsMap));
    // Power-ups
    await prefs.setString(_keyPowerUps, jsonEncode(p.powerUps));
    await prefs.setInt(_keyDailyDay, p.dailyRewardDay);
    if (p.lastDailyRewardDate != null) {
      await prefs.setString(_keyDailyDate, p.lastDailyRewardDate!);
    }
    await prefs.setBool(_keySound, p.soundEnabled);
    await prefs.setBool(_keyMusic, p.musicEnabled);
  }
}
