import 'dart:math';
import '../models/cell.dart';
import '../models/element_type.dart';
import '../models/level_config.dart';
import '../models/game_state.dart';
import '../core/constants.dart';

class MatchResult {
  final List<List<bool>> matched; // positions to remove
  final List<SpecialCreation> specials; // specials to create
  final int score;
  MatchResult({
    required this.matched,
    required this.specials,
    required this.score,
  });
}

class SpecialCreation {
  final int row, col;
  final ElementType type;
  final String? direction;
  SpecialCreation({
    required this.row,
    required this.col,
    required this.type,
    this.direction,
  });
}

class BoardEngine {
  final Random _rng = Random();

  // ─── Инициализация поля ────────────────────────────────────────────────────
  List<List<Cell>> initBoard(LevelConfig config) {
    final size = config.boardSize;
    final board = List.generate(
      size,
      (r) => List.generate(
        size,
        (c) => Cell(type: _randomElement(config.availableElements)),
      ),
    );

    // Применяем препятствия
    for (final obs in config.obstacles) {
      if (obs.row < size && obs.col < size) {
        switch (obs.type) {
          case 'blocked':
            board[obs.row][obs.col] = Cell(
              type: ElementType.blocked,
              isBlocked: true,
            );
            break;
          case 'frozen':
            board[obs.row][obs.col] = Cell(
              type: _randomElement(config.availableElements),
              isFrozen: true,
              frozenLayers: obs.layers,
            );
            break;
          case 'dark':
            board[obs.row][obs.col] = Cell(
              type: _randomElement(config.availableElements),
              isDark: true,
            );
            break;
        }
      }
    }

    // Устраняем стартовые совпадения
    _eliminateStartMatches(board, config.availableElements);
    return board;
  }

  ElementType _randomElement(List<ElementType> available) {
    final normals = available.where((e) => e.isNormal).toList();
    return normals[_rng.nextInt(normals.length)];
  }

  void _eliminateStartMatches(
    List<List<Cell>> board,
    List<ElementType> available,
  ) {
    final size = board.length;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (!board[r][c].isPlayable) continue;
        int attempts = 0;
        while (_hasMatchAt(board, r, c) && attempts < 20) {
          board[r][c] = Cell(type: _randomElement(available));
          attempts++;
        }
      }
    }
  }

  bool _hasMatchAt(List<List<Cell>> board, int r, int c) {
    final t = board[r][c].type;
    if (!t.isNormal) return false;
    final size = board.length;
    // горизонталь
    if (c >= 2 &&
        board[r][c - 1].type == t &&
        board[r][c - 2].type == t)
      return true;
    // вертикаль
    if (r >= 2 &&
        board[r - 1][c].type == t &&
        board[r - 2][c].type == t)
      return true;
    return false;
  }

  // ─── Проверка допустимости хода ───────────────────────────────────────────
  bool isValidSwap(
    List<List<Cell>> board,
    int r1,
    int c1,
    int r2,
    int c2,
  ) {
    if (!board[r1][c1].isPlayable || !board[r2][c2].isPlayable) return false;
    if (board[r1][c1].isFrozen || board[r2][c2].isFrozen) return false;
    // Соседние клетки
    final dr = (r1 - r2).abs();
    final dc = (c1 - c2).abs();
    if (!((dr == 1 && dc == 0) || (dr == 0 && dc == 1))) return false;
    // Проверяем даёт ли матч
    _doSwap(board, r1, c1, r2, c2);
    final hasMatch = _findAllMatches(board).isNotEmpty;
    // Специальный элемент — всегда допустим
    final hasSpecial =
        board[r1][c1].type.isSpecial || board[r2][c2].type.isSpecial;
    _doSwap(board, r1, c1, r2, c2); // откат
    return hasMatch || hasSpecial;
  }

  void _doSwap(List<List<Cell>> board, int r1, int c1, int r2, int c2) {
    final tmp = board[r1][c1];
    board[r1][c1] = board[r2][c2];
    board[r2][c2] = tmp;
  }

  // ─── Поиск совпадений ─────────────────────────────────────────────────────
  List<List<int>> _findAllMatches(List<List<Cell>> board) {
    final size = board.length;
    final Set<String> found = {};

    // Горизонталь
    for (int r = 0; r < size; r++) {
      int c = 0;
      while (c < size) {
        if (!board[r][c].canMatch) { c++; continue; }
        int len = 1;
        while (c + len < size && board[r][c + len].canMatch &&
            board[r][c + len].type == board[r][c].type) len++;
        if (len >= kMinMatch) {
          for (int k = 0; k < len; k++) found.add('$r,${c + k}');
        }
        c += len;
      }
    }
    // Вертикаль
    for (int c = 0; c < size; c++) {
      int r = 0;
      while (r < size) {
        if (!board[r][c].canMatch) { r++; continue; }
        int len = 1;
        while (r + len < size && board[r + len][c].canMatch &&
            board[r + len][c].type == board[r][c].type) len++;
        if (len >= kMinMatch) {
          for (int k = 0; k < len; k++) found.add('${r + k},$c');
        }
        r += len;
      }
    }

    return found.map((s) {
      final p = s.split(',');
      return [int.parse(p[0]), int.parse(p[1])];
    }).toList();
  }

  // ─── Полный шаг обработки ─────────────────────────────────────────────────
  /// Выполняет обмен, возвращает набранные очки. Изменяет board на месте.
  ProcessResult processSwap(
    List<List<Cell>> board,
    int r1,
    int c1,
    int r2,
    int c2,
    MoonPhaseType phase,
    LevelConfig config,
  ) {
    _doSwap(board, r1, c1, r2, c2);

    // Активация специальных элементов при обмене
    final activations = <SpecialActivation>[];
    if (board[r1][c1].type.isSpecial) {
      activations.add(SpecialActivation(row: r1, col: c1));
    }
    if (board[r2][c2].type.isSpecial) {
      activations.add(SpecialActivation(row: r2, col: c2));
    }

    int totalScore = 0;
    int totalCombos = 0;
    List<String> collectedTypes = [];
    List<List<bool>> allCleared = List.generate(
      board.length,
      (_) => List.filled(board.length, false),
    );

    // Активируем специальные
    for (final act in activations) {
      final result = _activateSpecial(board, act.row, act.col, config);
      totalScore += result.score;
      for (int r = 0; r < board.length; r++) {
        for (int c = 0; c < board.length; c++) {
          if (result.cleared[r][c]) allCleared[r][c] = true;
        }
      }
    }

    // Убираем активированные специальные
    _applyClearMap(board, allCleared, config.availableElements);
    allCleared = List.generate(board.length, (_) => List.filled(board.length, false));

    // Каскад
    int cascade = 0;
    while (true) {
      final matches = _findAllMatches(board);
      if (matches.isEmpty) break;

      // Определяем специальные для создания
      final specials = _detectSpecialCreations(board, matches, r2, c2);
      final scoreForStep = _calcScore(matches.length, cascade, phase);
      totalScore += scoreForStep;
      totalCombos++;
      cascade++;

      // Отмечаем к удалению
      for (final pos in matches) {
        final cell = board[pos[0]][pos[1]];
        if (cell.isFrozen) {
          // Уменьшаем слои льда
          if (cell.frozenLayers > 1) {
            board[pos[0]][pos[1]] = cell.copyWith(frozenLayers: cell.frozenLayers - 1);
          } else {
            board[pos[0]][pos[1]] = cell.copyWith(isFrozen: false, frozenLayers: 0);
          }
        } else {
          collectedTypes.add(cell.type.name);
          board[pos[0]][pos[1]] = Cell(type: ElementType.empty);
        }
      }

      // Создаём специальные элементы
      for (final s in specials) {
        board[s.row][s.col] = Cell(
          type: s.type,
          specialDirection: s.direction,
        );
      }

      // Гравитация
      _applyGravity(board, GravityDirection.down); // TODO: передавать
      _fillBoard(board, config.availableElements);
    }

    return ProcessResult(
      score: totalScore,
      combos: totalCombos,
      collectedTypes: collectedTypes,
    );
  }

  List<SpecialCreation> _detectSpecialCreations(
    List<List<Cell>> board,
    List<List<int>> matches,
    int swapRow,
    int swapCol,
  ) {
    final specials = <SpecialCreation>[];
    final size = board.length;

    // Группируем по строкам и столбцам
    final Map<int, List<int>> byRow = {};
    final Map<int, List<int>> byCol = {};
    for (final m in matches) {
      byRow.putIfAbsent(m[0], () => []).add(m[1]);
      byCol.putIfAbsent(m[1], () => []).add(m[0]);
    }

    final Set<String> usedPos = {};

    // 5 в ряд → Lunar Core
    byRow.forEach((r, cols) {
      if (cols.length >= 5) {
        final c = cols.contains(swapCol) ? swapCol : cols[cols.length ~/ 2];
        specials.add(SpecialCreation(row: r, col: c, type: ElementType.lunarCore));
        usedPos.add('$r,$c');
      }
    });
    byCol.forEach((c, rows) {
      if (rows.length >= 5) {
        final r = rows.contains(swapRow) ? swapRow : rows[rows.length ~/ 2];
        if (!usedPos.contains('$r,$c')) {
          specials.add(SpecialCreation(row: r, col: c, type: ElementType.lunarCore));
          usedPos.add('$r,$c');
        }
      }
    });

    // 4 в ряд → Moon Beam
    byRow.forEach((r, cols) {
      if (cols.length == 4) {
        final c = cols.contains(swapCol) ? swapCol : cols[1];
        if (!usedPos.contains('$r,$c')) {
          specials.add(SpecialCreation(row: r, col: c, type: ElementType.moonBeam, direction: 'horizontal'));
          usedPos.add('$r,$c');
        }
      }
    });
    byCol.forEach((c, rows) {
      if (rows.length == 4) {
        final r = rows.contains(swapRow) ? swapRow : rows[1];
        if (!usedPos.contains('$r,$c')) {
          specials.add(SpecialCreation(row: r, col: c, type: ElementType.moonBeam, direction: 'vertical'));
          usedPos.add('$r,$c');
        }
      }
    });

    // L-образная → Gravity Bomb
    for (final pos in matches) {
      final r = pos[0], c = pos[1];
      if (usedPos.contains('$r,$c')) continue;
      final inRow = byRow[r]?.length ?? 0;
      final inCol = byCol[c]?.length ?? 0;
      if (inRow >= 3 && inCol >= 3) {
        specials.add(SpecialCreation(row: r, col: c, type: ElementType.gravityBomb));
        usedPos.add('$r,$c');
        break;
      }
    }

    return specials;
  }

  // ─── Активация специальных ─────────────────────────────────────────────────
  SpecialActivationResult _activateSpecial(
    List<List<Cell>> board,
    int row,
    int col,
    LevelConfig config,
  ) {
    final size = board.length;
    final cleared = List.generate(size, (_) => List.filled(size, false));
    int score = 0;
    final cell = board[row][col];

    switch (cell.type) {
      case ElementType.moonBeam:
        // Уничтожает строку или столбец
        if (cell.specialDirection == 'vertical') {
          for (int r = 0; r < size; r++) {
            if (board[r][col].isPlayable) { cleared[r][col] = true; score += 100; }
          }
        } else {
          for (int c = 0; c < size; c++) {
            if (board[row][c].isPlayable) { cleared[row][c] = true; score += 100; }
          }
        }
        break;

      case ElementType.lunarCore:
        // Уничтожает все элементы того же типа что и сосед
        ElementType? target;
        if (row > 0 && board[row - 1][col].type.isNormal) target = board[row - 1][col].type;
        else if (row < size - 1 && board[row + 1][col].type.isNormal) target = board[row + 1][col].type;
        else if (col > 0 && board[row][col - 1].type.isNormal) target = board[row][col - 1].type;
        else if (col < size - 1 && board[row][col + 1].type.isNormal) target = board[row][col + 1].type;
        if (target != null) {
          for (int r = 0; r < size; r++) {
            for (int c = 0; c < size; c++) {
              if (board[r][c].type == target) { cleared[r][c] = true; score += 150; }
            }
          }
        }
        break;

      case ElementType.gravityBomb:
        // Уничтожает 3x3 область
        for (int dr = -2; dr <= 2; dr++) {
          for (int dc = -2; dc <= 2; dc++) {
            final r = row + dr, c = col + dc;
            if (r >= 0 && r < size && c >= 0 && c < size && board[r][c].isPlayable) {
              cleared[r][c] = true; score += 120;
            }
          }
        }
        break;

      default:
        break;
    }

    cleared[row][col] = true;
    return SpecialActivationResult(cleared: cleared, score: score);
  }

  void _applyClearMap(
    List<List<Cell>> board,
    List<List<bool>> cleared,
    List<ElementType> available,
  ) {
    for (int r = 0; r < board.length; r++) {
      for (int c = 0; c < board.length; c++) {
        if (cleared[r][c]) board[r][c] = Cell(type: ElementType.empty);
      }
    }
  }

  // ─── Гравитация ────────────────────────────────────────────────────────────
  void applyGravity(List<List<Cell>> board, GravityDirection direction) {
    _applyGravity(board, direction);
  }

  void _applyGravity(List<List<Cell>> board, GravityDirection direction) {
    final size = board.length;
    switch (direction) {
      case GravityDirection.down:
        for (int c = 0; c < size; c++) {
          final col = [for (int r = 0; r < size; r++) board[r][c]];
          final filled = col.where((cell) => cell.type != ElementType.empty && !cell.isBlocked).toList();
          final blocked = <int>[];
          for (int r = 0; r < size; r++) if (col[r].isBlocked) blocked.add(r);
          int fi = filled.length - 1;
          for (int r = size - 1; r >= 0; r--) {
            if (blocked.contains(r)) continue;
            board[r][c] = fi >= 0 ? filled[fi--] : Cell(type: ElementType.empty);
          }
        }
        break;
      case GravityDirection.up:
        for (int c = 0; c < size; c++) {
          final col = [for (int r = 0; r < size; r++) board[r][c]];
          final filled = col.where((cell) => cell.type != ElementType.empty && !cell.isBlocked).toList();
          final blocked = <int>[];
          for (int r = 0; r < size; r++) if (col[r].isBlocked) blocked.add(r);
          int fi = 0;
          for (int r = 0; r < size; r++) {
            if (blocked.contains(r)) continue;
            board[r][c] = fi < filled.length ? filled[fi++] : Cell(type: ElementType.empty);
          }
        }
        break;
      case GravityDirection.right:
        for (int r = 0; r < size; r++) {
          final row = [for (int c = 0; c < size; c++) board[r][c]];
          final filled = row.where((cell) => cell.type != ElementType.empty && !cell.isBlocked).toList();
          final blocked = <int>[];
          for (int c = 0; c < size; c++) if (row[c].isBlocked) blocked.add(c);
          int fi = filled.length - 1;
          for (int c = size - 1; c >= 0; c--) {
            if (blocked.contains(c)) continue;
            board[r][c] = fi >= 0 ? filled[fi--] : Cell(type: ElementType.empty);
          }
        }
        break;
      case GravityDirection.left:
        for (int r = 0; r < size; r++) {
          final row = [for (int c = 0; c < size; c++) board[r][c]];
          final filled = row.where((cell) => cell.type != ElementType.empty && !cell.isBlocked).toList();
          final blocked = <int>[];
          for (int c = 0; c < size; c++) if (row[c].isBlocked) blocked.add(c);
          int fi = 0;
          for (int c = 0; c < size; c++) {
            if (blocked.contains(c)) continue;
            board[r][c] = fi < filled.length ? filled[fi++] : Cell(type: ElementType.empty);
          }
        }
        break;
    }
  }

  // ─── Заполнение ───────────────────────────────────────────────────────────
  void fillBoard(List<List<Cell>> board, List<ElementType> available) {
    _fillBoard(board, available);
  }

  void _fillBoard(List<List<Cell>> board, List<ElementType> available) {
    for (int r = 0; r < board.length; r++) {
      for (int c = 0; c < board.length; c++) {
        if (board[r][c].type == ElementType.empty) {
          board[r][c] = Cell(type: _randomElement(available));
        }
      }
    }
  }

  // ─── Подсчёт очков ────────────────────────────────────────────────────────
  int _calcScore(int matchCount, int cascade, MoonPhaseType phase) {
    int base = matchCount * kBaseScore;
    if (cascade > 0) base = (base * kCascadeMultiplier * cascade).toInt();
    if (phase == MoonPhaseType.fullMoon) base = (base * kFullMoonMultiplier).toInt();
    if (phase == MoonPhaseType.waxingMoon) base = (base * 1.5).toInt();
    return base;
  }

  // ─── Есть ли возможные ходы ───────────────────────────────────────────────
  bool hasAnyMoves(List<List<Cell>> board) {
    final size = board.length;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (c < size - 1 && isValidSwap(board, r, c, r, c + 1)) return true;
        if (r < size - 1 && isValidSwap(board, r, c, r + 1, c)) return true;
      }
    }
    return false;
  }

  // ─── Перемешать если нет ходов ────────────────────────────────────────────
  void shuffleBoard(List<List<Cell>> board) {
    final size = board.length;
    final playable = <Cell>[];
    final positions = <List<int>>[];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (board[r][c].isPlayable && !board[r][c].isBlocked) {
          playable.add(board[r][c]);
          positions.add([r, c]);
        }
      }
    }
    playable.shuffle(_rng);
    for (int i = 0; i < positions.length; i++) {
      board[positions[i][0]][positions[i][1]] = playable[i];
    }
  }
}

class ProcessResult {
  final int score;
  final int combos;
  final List<String> collectedTypes;
  ProcessResult({
    required this.score,
    required this.combos,
    required this.collectedTypes,
  });
}

class SpecialActivation {
  final int row, col;
  SpecialActivation({required this.row, required this.col});
}

class SpecialActivationResult {
  final List<List<bool>> cleared;
  final int score;
  SpecialActivationResult({required this.cleared, required this.score});
}
