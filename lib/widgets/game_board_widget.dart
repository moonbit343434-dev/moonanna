import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/element_type.dart';
import '../game/level_manager.dart';
import '../core/constants.dart';
import '../core/game_colors.dart';
import 'game_cell_widget.dart';

class GameBoardWidget extends StatefulWidget {
  final LevelManager levelManager;
  const GameBoardWidget({super.key, required this.levelManager});

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  int? _dragStartRow;
  int? _dragStartCol;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final size = state.boardSize;

    final double maxW = MediaQuery.of(context).size.width - 16;
    final double cellSz = (maxW / size).clamp(36.0, 56.0);

    return Container(
      decoration: BoxDecoration(
        color: GameColors.boardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GameColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GameColors.primary.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(size, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(size, (col) {
              final cell = state.board[row][col];
              final selected =
                  state.selectedRow == row && state.selectedCol == col;
              return SizedBox(
                width: cellSz,
                height: cellSz,
                child: GestureDetector(
                  onTap: () => _onCellTap(state, row, col),
                  onPanStart: (d) {
                    _dragStartRow = row;
                    _dragStartCol = col;
                  },
                  onPanEnd: (d) => _onDragEnd(state, d, cellSz),
                  child: GameCellWidget(
                    cell: cell,
                    isSelected: selected,
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  void _onCellTap(GameState state, int row, int col) {
    if (state.status != GameStatus.playing) return;

    // Power-up режим
    if (state.powerUpSelectMode && state.activePowerUp != null) {
      _handlePowerUpTap(state, row, col);
      return;
    }

    if (state.selectedRow == null) {
      // Первый выбор
      if (!state.board[row][col].isPlayable) return;
      if (state.board[row][col].isFrozen) return;
      state.selectedRow = row;
      state.selectedCol = col;
      state.notify();
    } else {
      final r1 = state.selectedRow!;
      final c1 = state.selectedCol!;
      if (r1 == row && c1 == col) {
        // Снять выбор
        state.selectedRow = null;
        state.selectedCol = null;
        state.notify();
        return;
      }
      // Попытка хода
      final moved = widget.levelManager.makeMove(state, r1, c1, row, col);
      if (!moved) {
        // Выбрать другую клетку
        state.selectedRow = row;
        state.selectedCol = col;
        state.notify();
      } else {
        state.selectedRow = null;
        state.selectedCol = null;
      }
    }
  }

  void _onDragEnd(GameState state, DragEndDetails d, double cellSz) {
    if (_dragStartRow == null || _dragStartCol == null) return;
    if (state.status != GameStatus.playing) return;

    final v = d.velocity.pixelsPerSecond;
    int dr = 0, dc = 0;
    if (v.dx.abs() > v.dy.abs()) {
      dc = v.dx > 0 ? 1 : -1;
    } else {
      dr = v.dy > 0 ? 1 : -1;
    }

    final r2 = _dragStartRow! + dr;
    final c2 = _dragStartCol! + dc;
    final size = state.boardSize;
    if (r2 >= 0 && r2 < size && c2 >= 0 && c2 < size) {
      widget.levelManager.makeMove(state, _dragStartRow!, _dragStartCol!, r2, c2);
    }
    _dragStartRow = null;
    _dragStartCol = null;
    state.selectedRow = null;
    state.selectedCol = null;
  }

  void _handlePowerUpTap(GameState state, int row, int col) {
    switch (state.activePowerUp) {
      case PowerUpType.moonHammer:
        widget.levelManager.useMoonHammer(state, row, col);
        break;
      case PowerUpType.comet:
        widget.levelManager.useComet(state, row, col);
        break;
      case PowerUpType.starRay:
        final t = state.board[row][col].type;
        if (t.isNormal) widget.levelManager.useStarRay(state, t);
        break;
      default:
        state.activePowerUp = null;
        state.powerUpSelectMode = false;
        state.notify();
    }
  }
}
