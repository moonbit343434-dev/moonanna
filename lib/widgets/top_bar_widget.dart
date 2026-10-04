import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/level_config.dart';
import '../core/game_colors.dart';

class TopBarWidget extends StatelessWidget {
  final VoidCallback onPause;
  const TopBarWidget({super.key, required this.onPause});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final level = state.currentLevel;
    if (level == null) return const SizedBox();

    final goal = level.goalValue;
    final prog = state.goalProgress.clamp(0, goal);
    final pct = goal > 0 ? prog / goal : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: GameColors.boardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GameColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: GameColors.primary.withOpacity(0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Pause
              GestureDetector(
                onTap: onPause,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: GameColors.cellBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GameColors.primary.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.pause, color: GameColors.textSecondary, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              // Level info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LEVEL ${level.id}',
                    style: const TextStyle(
                      color: GameColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    level.areaDisplayName,
                    style: const TextStyle(
                      color: GameColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Moon phase
              _moonPhasePill(state.currentMoonPhase),
              const SizedBox(width: 8),
              // Moves
              _statPill('${state.movesLeft}', 'MOVES',
                  state.movesLeft <= 5 ? GameColors.danger : GameColors.accent),
            ],
          ),
          const SizedBox(height: 10),
          // Score + progress
          Row(
            children: [
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [GameColors.gold, GameColors.accent],
                ).createShader(b),
                child: Text(
                  _fmt(state.score),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                level.goalDescription,
                style: const TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 7,
                decoration: BoxDecoration(
                  color: GameColors.cellBg,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 7,
                width: MediaQuery.of(context).size.width * pct.clamp(0.0, 1.0) * 0.75,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: pct >= 1.0
                        ? [GameColors.success, GameColors.success]
                        : [GameColors.primary, GameColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: GameColors.primary.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Gravity warning
          if (state.showGravityWarning) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 13),
                  const SizedBox(width: 5),
                  Text(
                    'GRAVITY SHIFT → ${_gravEmoji(state.nextGravity ?? state.currentGravity)}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Gravity direction
          if (state.currentLevel?.gravity.gravityShifts == true) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Gravity  ${_gravEmoji(state.currentGravity)}',
                  style: const TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _moonPhasePill(MoonPhaseType phase) {
    final emoji = ['🌑', '🌒', '🌓', '🌔', '🌕'][phase.index];
    final names = ['New Moon', 'Crescent', 'Half Moon', 'Waxing', 'Full Moon'];
    final colors = [
      GameColors.newMoon,
      GameColors.crescent,
      GameColors.halfMoon,
      GameColors.waxingMoon,
      GameColors.fullMoon,
    ];
    final c = colors[phase.index];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          names[phase.index],
          style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }

  Widget _statPill(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(
          color: color, fontWeight: FontWeight.w800, fontSize: 18)),
        Text(label, style: const TextStyle(
          color: GameColors.textSecondary, fontSize: 8, letterSpacing: 0.5)),
      ]),
    );
  }

  String _gravEmoji(GravityDirection d) {
    switch (d) {
      case GravityDirection.down:  return '⬇️';
      case GravityDirection.up:    return '⬆️';
      case GravityDirection.left:  return '⬅️';
      case GravityDirection.right: return '➡️';
    }
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
