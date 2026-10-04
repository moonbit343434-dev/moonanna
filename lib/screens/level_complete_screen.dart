import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/player_progress.dart';
import '../core/game_colors.dart';
import 'game_screen.dart';
import 'map_screen.dart';

class LevelCompleteScreen extends StatelessWidget {
  final bool won;
  final int stars;
  final int score;
  final int levelId;
  final PlayerProgress progress;

  const LevelCompleteScreen({
    super.key,
    required this.won,
    required this.stars,
    required this.score,
    required this.levelId,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Stack(
        children: [
          // Background
          CustomPaint(painter: _BgPainter(won: won), child: const SizedBox.expand()),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  won ? '🌕 LEVEL COMPLETE!' : '🌑 LEVEL FAILED',
                  style: TextStyle(
                    color: won ? GameColors.gold : Colors.redAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.5, 0.5)),
                const SizedBox(height: 20),
                // Stars
                if (won) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return Text(
                        i < stars ? '⭐' : '☆',
                        style: TextStyle(
                          fontSize: 40,
                          color: i < stars ? GameColors.gold : Colors.grey,
                        ),
                      )
                          .animate(delay: Duration(milliseconds: 300 + i * 200))
                          .scale(begin: const Offset(0, 0), curve: Curves.elasticOut);
                    }),
                  ),
                  const SizedBox(height: 20),
                ],
                // Score card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: GameColors.boardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GameColors.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      _row('Score', _fmt(score), GameColors.textPrimary),
                      if (won) ...[
                        const Divider(color: GameColors.cellBg, height: 16),
                        _row(
                          'Coins earned',
                          '+${_coinsEarned()}',
                          GameColors.gold,
                        ),
                        _row('Total coins', _fmt(progress.coins), GameColors.gold),
                      ],
                    ],
                  ),
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3),
                const SizedBox(height: 32),
                // Buttons
                if (won && levelId < 30)
                  _bigBtn(
                    context,
                    '▶ NEXT LEVEL',
                    GameColors.primary,
                    () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => GameScreen(
                          levelId: levelId + 1,
                          progress: progress,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                _bigBtn(
                  context,
                  '🔄 RETRY',
                  GameColors.accent,
                  () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => GameScreen(
                        levelId: levelId,
                        progress: progress,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _bigBtn(
                  context,
                  '🗺 MAP',
                  Colors.grey.shade700,
                  () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => MapScreen(progress: progress),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _coinsEarned() => [20, 50, 100][(stars.clamp(1, 3) - 1)];

  Widget _row(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: GameColors.textSecondary, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigBtn(
    BuildContext ctx,
    String label,
    Color color,
    VoidCallback fn,
  ) {
    return SizedBox(
      width: 220,
      child: ElevatedButton(
        onPressed: fn,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 4,
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    )
        .animate(delay: 600.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2);
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _BgPainter extends CustomPainter {
  final bool won;
  _BgPainter({required this.won});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.3);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: won
            ? [
                GameColors.primary.withOpacity(0.3),
                GameColors.background,
              ]
            : [
                Colors.red.withOpacity(0.2),
                GameColors.background,
              ],
      ).createShader(Rect.fromCenter(
        center: center,
        width: size.width * 1.5,
        height: size.width * 1.5,
      ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
