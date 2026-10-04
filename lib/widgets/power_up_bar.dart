import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../game/level_manager.dart';
import '../core/game_colors.dart';

class PowerUpBar extends StatelessWidget {
  final LevelManager levelManager;
  const PowerUpBar({super.key, required this.levelManager});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: GameColors.boardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GameColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: PowerUpType.values.map((type) {
          final count = state.powerUps[type] ?? 0;
          final active = state.activePowerUp == type;
          return _PowerUpButton(
            type: type,
            count: count,
            isActive: active,
            onTap: count > 0 ? () => _activate(state, type) : null,
          );
        }).toList(),
      ),
    );
  }

  void _activate(GameState state, PowerUpType type) {
    if (type == PowerUpType.gravitySwitch) {
      levelManager.useGravitySwitch(state);
      return;
    }
    if (type == PowerUpType.fullMoonBoost) {
      levelManager.useFullMoonBoost(state);
      return;
    }
    // Требуют выбора клетки
    if (state.activePowerUp == type) {
      state.activePowerUp = null;
      state.powerUpSelectMode = false;
    } else {
      state.activePowerUp = type;
      state.powerUpSelectMode = true;
    }
    state.notify();
  }
}

class _PowerUpButton extends StatelessWidget {
  final PowerUpType type;
  final int count;
  final bool isActive;
  final VoidCallback? onTap;

  const _PowerUpButton({
    required this.type,
    required this.count,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive
              ? GameColors.primary.withOpacity(0.3)
              : GameColors.cellBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? GameColors.primary : GameColors.primary.withOpacity(0.2),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: GameColors.primary.withOpacity(0.4), blurRadius: 8)]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(type.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: count > 0 ? GameColors.primary : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
