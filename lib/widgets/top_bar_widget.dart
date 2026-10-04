import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/level_config.dart';
import '../core/game_colors.dart';
import 'moon_phase_widget.dart';

class TopBarWidget extends StatelessWidget {
  final VoidCallback onPause;
  const TopBarWidget({super.key, required this.onPause});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final level = state.currentLevel;
    if (level == null) return const SizedBox();

    final goal = level.goalValue;
    final progress = state.goalProgress.clamp(0, goal);
    final pct = goal > 0 ? progress / goal : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.boardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GameColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Кнопка назад
              GestureDetector(
                onTap: onPause,
                child: const Icon(Icons.pause_circle_outline,
                    color: GameColors.textSecondary, size: 26),
              ),
              const SizedBox(width: 8),
              // Уровень
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${level.id}',
                    style: const TextStyle(
                      color: GameColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    level.areaDisplayName,
                    style: const TextStyle(
                      color: GameColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Фаза луны
              MoonPhaseWidget(phase: state.currentMoonPhase, compact: true),
              const SizedBox(width: 8),
              // Ходы
              _statBox('MOVES', '${state.movesLeft}', Icons.swap_horiz),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Очки
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Score: ${_fmt(state.score)}',
                          style: const TextStyle(
                            color: GameColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          level.goalDescription,
                          style: const TextStyle(
                            color: GameColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct.toDouble(),
                        minHeight: 6,
                        backgroundColor: GameColors.cellBg,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          pct >= 1.0 ? Colors.greenAccent : GameColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Gravity direction indicator
          if (state.currentLevel?.gravity.gravityShifts == true) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Gravity: ${_gravityEmoji(state.currentGravity)}',
                  style: const TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                if (state.showGravityWarning) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          'GRAVITY SHIFT → ${_gravityEmoji(state.nextGravity ?? state.currentGravity)}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: GameColors.cellBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GameColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: GameColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: GameColors.textSecondary,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _gravityEmoji(GravityDirection d) {
    switch (d) {
      case GravityDirection.down: return '⬇️';
      case GravityDirection.up: return '⬆️';
      case GravityDirection.left: return '⬅️';
      case GravityDirection.right: return '➡️';
    }
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
