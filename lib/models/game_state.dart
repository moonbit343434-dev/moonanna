import 'package:flutter/foundation.dart';
import '../models/cell.dart';
import '../models/element_type.dart';
import '../models/level_config.dart';

enum GameStatus { idle, playing, animating, paused, won, lost }

enum PowerUpType { moonHammer, comet, gravitySwitch, fullMoonBoost, starRay }

extension PowerUpExt on PowerUpType {
  String get label {
    switch (this) {
      case PowerUpType.moonHammer:
        return 'Moon\nHammer';
      case PowerUpType.comet:
        return 'Comet';
      case PowerUpType.gravitySwitch:
        return 'Gravity\nSwitch';
      case PowerUpType.fullMoonBoost:
        return 'Full Moon\nBoost';
      case PowerUpType.starRay:
        return 'Star Ray';
    }
  }

  String get emoji {
    switch (this) {
      case PowerUpType.moonHammer:
        return '🌙';
      case PowerUpType.comet:
        return '☄️';
      case PowerUpType.gravitySwitch:
        return '🌀';
      case PowerUpType.fullMoonBoost:
        return '🌕';
      case PowerUpType.starRay:
        return '⚡';
    }
  }
}

class GameState extends ChangeNotifier {
  // Поле
  List<List<Cell>> board = [];
  int boardSize = 8;

  // Статус
  GameStatus status = GameStatus.idle;

  // Уровень
  LevelConfig? currentLevel;
  int score = 0;
  int movesLeft = 0;
  int combosCount = 0;
  int goalProgress = 0;

  // Выбор
  int? selectedRow;
  int? selectedCol;

  // Фаза луны
  MoonPhaseType currentMoonPhase = MoonPhaseType.crescent;
  int movesSincePhaseChange = 0;

  // Гравитация
  GravityDirection currentGravity = GravityDirection.down;
  int movesSinceGravityShift = 0;
  bool showGravityWarning = false;
  GravityDirection? nextGravity;

  // Бустер Full Moon
  bool fullMoonActive = false;
  int fullMoonMovesLeft = 0;

  // Power-up выбран
  PowerUpType? activePowerUp;
  bool powerUpSelectMode = false;
  ElementType? starRayTarget; // для Star Ray

  // Ресурсы
  int coins = 0;
  int crystals = 0;
  Map<PowerUpType, int> powerUps = {
    PowerUpType.moonHammer: 3,
    PowerUpType.comet: 2,
    PowerUpType.gravitySwitch: 2,
    PowerUpType.fullMoonBoost: 1,
    PowerUpType.starRay: 2,
  };

  // Cascade multiple
  int cascadeMultiplier = 1;

  void notify() => notifyListeners();
}
