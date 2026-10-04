import 'element_type.dart';

enum GoalType {
  score, // набрать очки
  clearCells, // очистить клетки
  collectElement, // собрать элемент
  combos, // сделать N комбо
  collectLunarPearl, // собрать lunar pearls
}

enum MoonPhaseType { newMoon, crescent, halfMoon, waxingMoon, fullMoon }

enum GravityDirection { down, up, left, right }

class ObstacleConfig {
  final int row, col;
  final String type; // 'blocked' | 'frozen' | 'dark'
  final int layers;
  ObstacleConfig({
    required this.row,
    required this.col,
    required this.type,
    this.layers = 1,
  });
}

class MoonPhaseConfig {
  final MoonPhaseType startPhase;
  final bool phaseChanges; // меняется ли фаза в течение уровня
  MoonPhaseConfig({
    this.startPhase = MoonPhaseType.crescent,
    this.phaseChanges = false,
  });
}

class GravityConfig {
  final GravityDirection startDirection;
  final bool gravityShifts; // меняется ли гравитация
  final int shiftInterval; // каждые N ходов
  GravityConfig({
    this.startDirection = GravityDirection.down,
    this.gravityShifts = false,
    this.shiftInterval = 10,
  });
}

class LevelConfig {
  final int id;
  final int boardSize;
  final GoalType goalType;
  final int goalValue;
  final int maxMoves;
  final List<ObstacleConfig> obstacles;
  final MoonPhaseConfig moonPhase;
  final GravityConfig gravity;
  final List<ElementType> availableElements;
  final String area;
  final bool isBoss;
  final String? bossName;

  const LevelConfig({
    required this.id,
    this.boardSize = 8,
    required this.goalType,
    required this.goalValue,
    required this.maxMoves,
    this.obstacles = const [],
    required this.moonPhase,
    required this.gravity,
    required this.availableElements,
    required this.area,
    this.isBoss = false,
    this.bossName,
  });

  String get areaDisplayName {
    switch (area) {
      case 'lunar_valley':
        return 'Lunar Valley';
      case 'crystal_desert':
        return 'Crystal Desert';
      case 'shadow_craters':
        return 'Shadow Craters';
      case 'frozen_moon':
        return 'Frozen Moon';
      case 'eclipse_zone':
        return 'Eclipse Zone';
      case 'dark_side':
        return 'Dark Side';
      case 'moon_core':
        return 'Moon Core';
      default:
        return area;
    }
  }

  String get goalDescription {
    switch (goalType) {
      case GoalType.score:
        return 'Score $goalValue pts';
      case GoalType.clearCells:
        return 'Clear $goalValue cells';
      case GoalType.collectElement:
        return 'Collect $goalValue elements';
      case GoalType.combos:
        return 'Make $goalValue combos';
      case GoalType.collectLunarPearl:
        return 'Collect $goalValue Lunar Pearls';
    }
  }
}
