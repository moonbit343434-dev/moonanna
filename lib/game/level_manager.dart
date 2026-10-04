import '../models/game_state.dart';
import '../models/level_config.dart';
import '../models/player_progress.dart';
import '../core/constants.dart';
import 'board_engine.dart';

class LevelManager {
  final BoardEngine _engine = BoardEngine();

  // Инициализация уровня
  void startLevel(GameState state, LevelConfig config, PlayerProgress progress) {
    state.currentLevel = config;
    state.board = _engine.initBoard(config);
    state.boardSize = config.boardSize;
    state.score = 0;
    state.movesLeft = config.maxMoves;
    state.combosCount = 0;
    state.goalProgress = 0;
    state.selectedRow = null;
    state.selectedCol = null;
    state.currentMoonPhase = config.moonPhase.startPhase;
    state.movesSincePhaseChange = 0;
    state.currentGravity = config.gravity.startDirection;
    state.movesSinceGravityShift = 0;
    state.showGravityWarning = false;
    state.nextGravity = null;
    state.fullMoonActive = false;
    state.fullMoonMovesLeft = 0;
    state.activePowerUp = null;
    state.powerUpSelectMode = false;
    state.cascadeMultiplier = 1;
    state.status = GameStatus.playing;
    state.coins = progress.coins;
    state.crystals = progress.crystals;

    // Power-ups из прогресса
    state.powerUps = {
      PowerUpType.moonHammer: progress.powerUps['moonHammer'] ?? 3,
      PowerUpType.comet: progress.powerUps['comet'] ?? 2,
      PowerUpType.gravitySwitch: progress.powerUps['gravitySwitch'] ?? 2,
      PowerUpType.fullMoonBoost: progress.powerUps['fullMoonBoost'] ?? 1,
      PowerUpType.starRay: progress.powerUps['starRay'] ?? 2,
    };
    state.notify();
  }

  // Обработка хода
  bool makeMove(
    GameState state,
    int r1,
    int c1,
    int r2,
    int c2,
  ) {
    if (state.status != GameStatus.playing) return false;
    if (!_engine.isValidSwap(state.board, r1, c1, r2, c2)) return false;

    final result = _engine.processSwap(
      state.board,
      r1, c1, r2, c2,
      state.currentMoonPhase,
      state.currentLevel!,
    );

    state.score += result.score;
    state.combosCount += result.combos;
    state.movesLeft--;

    // Moon Phase: Half Moon — каждые 5 комбо даёт +1 ход
    if (state.currentMoonPhase == MoonPhaseType.halfMoon &&
        state.combosCount % 5 == 0 &&
        state.combosCount > 0) {
      state.movesLeft++;
    }

    // Обновляем прогресс цели
    _updateGoalProgress(state, result);

    // Full Moon Boost
    if (state.fullMoonActive) {
      state.fullMoonMovesLeft--;
      if (state.fullMoonMovesLeft <= 0) state.fullMoonActive = false;
    }

    // Moon Phase смена
    if (state.currentLevel!.moonPhase.phaseChanges) {
      state.movesSincePhaseChange++;
      if (state.movesSincePhaseChange >= kMoonPhaseInterval) {
        state.movesSincePhaseChange = 0;
        _advanceMoonPhase(state);
      }
    }

    // Gravity Shift
    if (state.currentLevel!.gravity.gravityShifts) {
      state.movesSinceGravityShift++;
      final interval = state.currentLevel!.gravity.shiftInterval;
      if (state.movesSinceGravityShift >= interval - 2 &&
          !state.showGravityWarning) {
        state.showGravityWarning = true;
        state.nextGravity = _nextGravityDirection(state.currentGravity);
      }
      if (state.movesSinceGravityShift >= interval) {
        state.currentGravity = _nextGravityDirection(state.currentGravity);
        state.movesSinceGravityShift = 0;
        state.showGravityWarning = false;
        state.nextGravity = null;
        _engine.applyGravity(state.board, state.currentGravity);
        _engine.fillBoard(state.board, state.currentLevel!.availableElements);
      }
    }

    // Проверяем конец
    _checkEndCondition(state);

    // Перемешать если нет ходов
    if (state.status == GameStatus.playing &&
        !_engine.hasAnyMoves(state.board)) {
      _engine.shuffleBoard(state.board);
    }

    state.notify();
    return true;
  }

  void _updateGoalProgress(GameState state, ProcessResult result) {
    switch (state.currentLevel!.goalType) {
      case GoalType.score:
        state.goalProgress = state.score;
        break;
      case GoalType.combos:
        state.goalProgress = state.combosCount;
        break;
      case GoalType.collectLunarPearl:
        state.goalProgress += result.collectedTypes
            .where((t) => t == 'lunarPearl')
            .length;
        break;
      case GoalType.collectElement:
        state.goalProgress += result.collectedTypes.length;
        break;
      case GoalType.clearCells:
        state.goalProgress += result.collectedTypes.length;
        break;
    }
  }

  void _checkEndCondition(GameState state) {
    final goal = state.currentLevel!.goalValue;
    if (state.goalProgress >= goal) {
      state.status = GameStatus.won;
      return;
    }
    if (state.movesLeft <= 0) {
      state.status = GameStatus.lost;
    }
  }

  void _advanceMoonPhase(GameState state) {
    switch (state.currentMoonPhase) {
      case MoonPhaseType.newMoon:
        state.currentMoonPhase = MoonPhaseType.crescent;
        _removeDarkCells(state);
        break;
      case MoonPhaseType.crescent:
        state.currentMoonPhase = MoonPhaseType.halfMoon;
        break;
      case MoonPhaseType.halfMoon:
        state.currentMoonPhase = MoonPhaseType.waxingMoon;
        break;
      case MoonPhaseType.waxingMoon:
        state.currentMoonPhase = MoonPhaseType.fullMoon;
        state.fullMoonActive = true;
        state.fullMoonMovesLeft = 5;
        break;
      case MoonPhaseType.fullMoon:
        state.currentMoonPhase = MoonPhaseType.newMoon;
        _applyDarkCells(state);
        break;
    }
  }

  void _applyDarkCells(GameState state) {
    // New Moon: затемняем несколько случайных клеток
    int count = 0;
    for (int r = 0; r < state.boardSize && count < 4; r++) {
      for (int c = 0; c < state.boardSize && count < 4; c++) {
        if (state.board[r][c].isPlayable && !state.board[r][c].isDark) {
          state.board[r][c] = state.board[r][c].copyWith(isDark: true);
          count++;
          if (r < state.boardSize - 1) { r++; c++; }
        }
      }
    }
  }

  void _removeDarkCells(GameState state) {
    for (int r = 0; r < state.boardSize; r++) {
      for (int c = 0; c < state.boardSize; c++) {
        if (state.board[r][c].isDark) {
          state.board[r][c] = state.board[r][c].copyWith(isDark: false);
        }
      }
    }
  }

  GravityDirection _nextGravityDirection(GravityDirection current) {
    switch (current) {
      case GravityDirection.down: return GravityDirection.right;
      case GravityDirection.right: return GravityDirection.up;
      case GravityDirection.up: return GravityDirection.left;
      case GravityDirection.left: return GravityDirection.down;
    }
  }

  // Вычислить звёзды
  int calculateStars(GameState state) {
    final goal = state.currentLevel!.goalValue.toDouble();
    final progress = state.goalProgress.toDouble();
    final ratio = progress / goal;
    if (ratio >= kStarThresholds[2]) return 3;
    if (ratio >= kStarThresholds[1]) return 2;
    if (ratio >= kStarThresholds[0]) return 1;
    return 0;
  }

  // Power-up: Moon Hammer — удалить одну клетку
  void useMoonHammer(GameState state, int row, int col) {
    if ((state.powerUps[PowerUpType.moonHammer] ?? 0) <= 0) return;
    if (!state.board[row][col].isPlayable) return;
    state.board[row][col].type = ElementType.empty;
    _engine.applyGravity(state.board, state.currentGravity);
    _engine.fillBoard(state.board, state.currentLevel!.availableElements);
    state.powerUps[PowerUpType.moonHammer] =
        (state.powerUps[PowerUpType.moonHammer] ?? 1) - 1;
    state.score += 200;
    state.movesLeft--;
    state.activePowerUp = null;
    state.powerUpSelectMode = false;
    _checkEndCondition(state);
    state.notify();
  }

  // Power-up: Comet — диагональная линия
  void useComet(GameState state, int row, int col) {
    if ((state.powerUps[PowerUpType.comet] ?? 0) <= 0) return;
    final size = state.boardSize;
    for (int i = 0; i < size; i++) {
      if (row + i < size && col + i < size && state.board[row + i][col + i].isPlayable) {
        state.board[row + i][col + i] = Cell(type: ElementType.empty);
        state.score += 100;
      }
      if (row - i >= 0 && col + i < size && state.board[row - i][col + i].isPlayable) {
        state.board[row - i][col + i] = Cell(type: ElementType.empty);
        state.score += 100;
      }
    }
    _engine.applyGravity(state.board, state.currentGravity);
    _engine.fillBoard(state.board, state.currentLevel!.availableElements);
    state.powerUps[PowerUpType.comet] =
        (state.powerUps[PowerUpType.comet] ?? 1) - 1;
    state.movesLeft--;
    state.activePowerUp = null;
    state.powerUpSelectMode = false;
    _checkEndCondition(state);
    state.notify();
  }

  // Power-up: Gravity Switch
  void useGravitySwitch(GameState state) {
    if ((state.powerUps[PowerUpType.gravitySwitch] ?? 0) <= 0) return;
    state.currentGravity = _nextGravityDirection(state.currentGravity);
    _engine.applyGravity(state.board, state.currentGravity);
    _engine.fillBoard(state.board, state.currentLevel!.availableElements);
    state.powerUps[PowerUpType.gravitySwitch] =
        (state.powerUps[PowerUpType.gravitySwitch] ?? 1) - 1;
    state.movesLeft--;
    _checkEndCondition(state);
    state.notify();
  }

  // Power-up: Full Moon Boost
  void useFullMoonBoost(GameState state) {
    if ((state.powerUps[PowerUpType.fullMoonBoost] ?? 0) <= 0) return;
    state.currentMoonPhase = MoonPhaseType.fullMoon;
    state.fullMoonActive = true;
    state.fullMoonMovesLeft = 5;
    state.powerUps[PowerUpType.fullMoonBoost] =
        (state.powerUps[PowerUpType.fullMoonBoost] ?? 1) - 1;
    state.notify();
  }

  // Power-up: Star Ray — уничтожить тип
  void useStarRay(GameState state, ElementType target) {
    if ((state.powerUps[PowerUpType.starRay] ?? 0) <= 0) return;
    for (int r = 0; r < state.boardSize; r++) {
      for (int c = 0; c < state.boardSize; c++) {
        if (state.board[r][c].type == target) {
          state.board[r][c] = Cell(type: ElementType.empty);
          state.score += 150;
        }
      }
    }
    _engine.applyGravity(state.board, state.currentGravity);
    _engine.fillBoard(state.board, state.currentLevel!.availableElements);
    state.powerUps[PowerUpType.starRay] =
        (state.powerUps[PowerUpType.starRay] ?? 1) - 1;
    state.movesLeft--;
    state.activePowerUp = null;
    state.powerUpSelectMode = false;
    _checkEndCondition(state);
    state.notify();
  }
}
