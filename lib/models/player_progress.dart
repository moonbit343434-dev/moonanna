class LevelResult {
  final int levelId;
  final int stars; // 1-3
  final int bestScore;
  LevelResult({
    required this.levelId,
    required this.stars,
    required this.bestScore,
  });
}

class PlayerProgress {
  int currentLevel;
  Map<int, LevelResult> levelResults;
  int coins;
  int crystals;
  Map<String, int> powerUps; // PowerUpType.name -> count
  int dailyRewardDay;
  String? lastDailyRewardDate;
  bool soundEnabled;
  bool musicEnabled;

  PlayerProgress({
    this.currentLevel = 1,
    Map<int, LevelResult>? levelResults,
    this.coins = 200,
    this.crystals = 10,
    Map<String, int>? powerUps,
    this.dailyRewardDay = 0,
    this.lastDailyRewardDate,
    this.soundEnabled = true,
    this.musicEnabled = true,
  })  : levelResults = levelResults ?? {},
        powerUps = powerUps ??
            {
              'moonHammer': 3,
              'comet': 2,
              'gravitySwitch': 2,
              'fullMoonBoost': 1,
              'starRay': 2,
            };

  int starsForLevel(int id) => levelResults[id]?.stars ?? 0;
  int bestScoreForLevel(int id) => levelResults[id]?.bestScore ?? 0;
  bool isLevelUnlocked(int id) => id <= currentLevel;

  void completeLevel(int id, int stars, int score) {
    final prev = levelResults[id];
    if (prev == null || stars > prev.stars) {
      levelResults[id] = LevelResult(
        levelId: id,
        stars: stars,
        bestScore: score,
      );
    } else if (score > prev.bestScore) {
      levelResults[id] = LevelResult(
        levelId: id,
        stars: prev.stars,
        bestScore: score,
      );
    }
    if (id >= currentLevel) currentLevel = id + 1;
  }
}
