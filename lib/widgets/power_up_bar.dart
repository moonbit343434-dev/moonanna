import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.boardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GameColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: PowerUpType.values.map((type) {
          final count = state.powerUps[type] ?? 0;
          final active = state.activePowerUp == type;
          return _PowerUpBtn(
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

class _PowerUpBtn extends StatelessWidget {
  final PowerUpType type;
  final int count;
  final bool isActive;
  final VoidCallback? onTap;

  const _PowerUpBtn({
    required this.type,
    required this.count,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = count > 0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 56,
        height: 64,
        decoration: BoxDecoration(
          color: isActive
              ? GameColors.primary.withOpacity(0.25)
              : enabled
                  ? GameColors.cellBg
                  : GameColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? GameColors.primary
                : enabled
                    ? GameColors.primary.withOpacity(0.25)
                    : GameColors.textHint.withOpacity(0.15),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: GameColors.primary.withOpacity(0.4), blurRadius: 12)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              type.emoji,
              style: TextStyle(
                fontSize: 22,
                color: enabled ? null : Colors.white.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: enabled ? GameColors.primary : GameColors.textHint.withOpacity(0.2),
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
      )
          .animate(
            target: isActive ? 1 : 0,
          )
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 150.ms,
          ),
    );
  }
}
