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
          // Glow background
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: won
                      ? [GameColors.primary.withOpacity(0.3), Colors.transparent]
                      : [GameColors.danger.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          // Stars floating
          if (won) ...List.generate(8, (i) => _FloatingStar(index: i)),
          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Big emoji
                    Text(
                      won ? '🏆' : '💀',
                      style: const TextStyle(fontSize: 72),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0, 0),
                          duration: 700.ms,
                          curve: Curves.elasticOut,
                        ),
                    const SizedBox(height: 16),
                    // Title
                    ShaderMask(
                      shaderCallback: (b) => LinearGradient(
                        colors: won
                            ? [GameColors.gold, GameColors.accent]
                            : [GameColors.danger, Colors.orange],
                      ).createShader(b),
                      child: Text(
                        won ? 'LEVEL COMPLETE!' : 'LEVEL FAILED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.3),
                    const SizedBox(height: 20),
                    // Stars row
                    if (won)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          final filled = i < stars;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              filled ? '⭐' : '☆',
                              style: TextStyle(
                                fontSize: 44,
                                color: filled ? GameColors.gold : GameColors.textHint,
                              ),
                            )
                                .animate(
                                  delay: Duration(milliseconds: 400 + i * 200),
                                )
                                .scale(
                                  begin: const Offset(0, 0),
                                  curve: Curves.elasticOut,
                                  duration: 600.ms,
                                ),
                          );
                        }),
                      ),
                    const SizedBox(height: 24),
                    // Score card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: GameColors.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GameColors.primary.withOpacity(0.25)),
                        boxShadow: [
                          BoxShadow(
                            color: GameColors.primary.withOpacity(0.1),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(children: [
                        _scoreRow('Score', _fmt(score), GameColors.textPrimary),
                        if (won) ...[
                          const Divider(color: GameColors.cellBg, height: 20),
                          _scoreRow('Coins earned', '+${_coins()}', GameColors.gold),
                          _scoreRow('Total coins', _fmt(progress.coins), GameColors.gold),
                        ],
                      ]),
                    )
                        .animate(delay: 500.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.3),
                    const SizedBox(height: 32),
                    // Buttons
                    if (won && levelId < 30)
                      _actionBtn(
                        context,
                        '▶  NEXT LEVEL',
                        const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF40C4FF)]),
                        () => _go(context, GameScreen(levelId: levelId + 1, progress: progress)),
                        delay: 0,
                      ),
                    const SizedBox(height: 10),
                    _actionBtn(
                      context,
                      '🔄  RETRY',
                      const LinearGradient(colors: [Color(0xFF0077B6), Color(0xFF00B4D8)]),
                      () => _go(context, GameScreen(levelId: levelId, progress: progress)),
                      delay: 80,
                    ),
                    const SizedBox(height: 10),
                    _actionBtn(
                      context,
                      '🗺  MAP',
                      LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade700]),
                      () => _go(context, MapScreen(progress: progress)),
                      delay: 140,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _coins() => [20, 50, 100][(stars.clamp(1, 3) - 1)];

  Widget _scoreRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: GameColors.textSecondary, fontSize: 14)),
          Text(value, style: TextStyle(
            color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _actionBtn(
    BuildContext ctx,
    String label,
    Gradient gradient,
    VoidCallback fn,
    {required int delay}
  ) {
    return GestureDetector(
      onTap: fn,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (gradient as LinearGradient).colors.first.withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 700 + delay))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.3);
  }

  void _go(BuildContext ctx, Widget screen) {
    Navigator.of(ctx).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => screen,
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _FloatingStar extends StatelessWidget {
  final int index;
  const _FloatingStar({required this.index});

  @override
  Widget build(BuildContext context) {
    final positions = [
      [0.1, 0.1], [0.85, 0.12], [0.05, 0.5], [0.9, 0.45],
      [0.2, 0.85], [0.75, 0.8], [0.5, 0.05], [0.5, 0.95],
    ];
    final p = positions[index % positions.length];
    final sz = MediaQuery.of(context).size;
    return Positioned(
      left: sz.width * p[0],
      top: sz.height * p[1],
      child: Text('✨', style: TextStyle(fontSize: 14 + (index % 3) * 6.0))
          .animate(
            delay: Duration(milliseconds: index * 150),
            onPlay: (c) => c.repeat(reverse: true),
          )
          .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2), duration: 1000.ms)
          .fadeIn(duration: 500.ms),
    );
  }
}
