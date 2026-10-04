import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game_state.dart';
import '../models/player_progress.dart';
import '../game/level_manager.dart';
import '../data/levels_data.dart';
import '../services/save_service.dart';
import '../core/game_colors.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/top_bar_widget.dart';
import '../widgets/power_up_bar.dart';
import 'level_complete_screen.dart';

class GameScreen extends StatefulWidget {
  final int levelId;
  final PlayerProgress progress;
  const GameScreen({super.key, required this.levelId, required this.progress});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameState _state;
  late LevelManager _manager;
  late PlayerProgress _progress;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    _state = GameState();
    _manager = LevelManager();
    _progress = widget.progress;

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut),
    );

    final cfg = levels.firstWhere((l) => l.id == widget.levelId);
    _manager.startLevel(_state, cfg, _progress);
    _state.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChange);
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (!_resultShown &&
        (_state.status == GameStatus.won || _state.status == GameStatus.lost)) {
      _resultShown = true;
      if (_state.status == GameStatus.won) {
        HapticFeedback.heavyImpact();
        _shakeCtrl.forward();
      } else {
        HapticFeedback.mediumImpact();
      }
      Future.delayed(const Duration(milliseconds: 700), _showResult);
    }
  }

  void _showResult() {
    if (!mounted) return;
    final won = _state.status == GameStatus.won;
    final stars = won ? _manager.calculateStars(_state) : 0;
    if (won) {
      final coins = [20, 50, 100][(stars.clamp(1, 3) - 1)];
      _progress.completeLevel(widget.levelId, stars, _state.score);
      _progress.coins += coins;
      _progress.powerUps['moonHammer']    = _state.powerUps[PowerUpType.moonHammer] ?? 0;
      _progress.powerUps['comet']         = _state.powerUps[PowerUpType.comet] ?? 0;
      _progress.powerUps['gravitySwitch'] = _state.powerUps[PowerUpType.gravitySwitch] ?? 0;
      _progress.powerUps['fullMoonBoost'] = _state.powerUps[PowerUpType.fullMoonBoost] ?? 0;
      _progress.powerUps['starRay']       = _state.powerUps[PowerUpType.starRay] ?? 0;
      SaveService().save(_progress);
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => LevelCompleteScreen(
          won: won, stars: stars, score: _state.score,
          levelId: widget.levelId, progress: _progress,
        ),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _onPause() {
    showModalBottomSheet(
      context: context,
      backgroundColor: GameColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PauseSheet(
        onResume: () => Navigator.pop(context),
        onRestart: () {
          Navigator.pop(context);
          _resultShown = false;
          final cfg = levels.firstWhere((l) => l.id == widget.levelId);
          _manager.startLevel(_state, cfg, _progress);
        },
        onQuit: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameState>.value(
      value: _state,
      child: Scaffold(
        backgroundColor: GameColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              // Starfield bg
              const _Starfield(),
              // Main content
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(
                    _shakeCtrl.isAnimating
                        ? ((_shakeAnim.value * 8) * ((_shakeAnim.value * 10).toInt().isEven ? 1 : -1))
                        : 0,
                    0,
                  ),
                  child: child,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TopBarWidget(onPause: _onPause),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Center(
                          child: GameBoardWidget(levelManager: _manager),
                        ),
                      ),
                      const SizedBox(height: 8),
                      PowerUpBar(levelManager: _manager),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
              // Boss banner
              Consumer<GameState>(
                builder: (_, s, __) {
                  if (s.currentLevel?.isBoss != true) return const SizedBox();
                  return Positioned(
                    top: 0, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [GameColors.boss, Color(0xFFFF6D00)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: GameColors.boss.withOpacity(0.5), blurRadius: 12),
                          ],
                        ),
                        child: Text(
                          '👾  BOSS: ${s.currentLevel?.bossName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .shimmer(duration: 2000.ms, color: Colors.white30),
                    ),
                  );
                },
              ),
              // Full moon boost badge
              Consumer<GameState>(
                builder: (_, s, __) {
                  if (!s.fullMoonActive) return const SizedBox();
                  return Positioned(
                    bottom: 110, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: GameColors.fullMoon.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: GameColors.fullMoon.withOpacity(0.5)),
                        ),
                        child: Text(
                          '🌕  FULL MOON BOOST  ×${s.fullMoonMovesLeft}',
                          style: const TextStyle(
                            color: GameColors.fullMoon,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(begin: const Offset(0.97, 0.97), end: const Offset(1.03, 1.03), duration: 800.ms),
                    ),
                  );
                },
              ),
              // Power-up select hint
              Consumer<GameState>(
                builder: (_, s, __) {
                  if (!s.powerUpSelectMode) return const SizedBox();
                  return Positioned(
                    bottom: 100, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: GameColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: GameColors.accent.withOpacity(0.5)),
                        ),
                        child: Text(
                          '${s.activePowerUp?.emoji ?? ''}  Tap a cell to use',
                          style: const TextStyle(
                            color: GameColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.3),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PauseSheet extends StatelessWidget {
  final VoidCallback onResume, onRestart, onQuit;
  const _PauseSheet({
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: GameColors.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '⏸  PAUSED',
            style: TextStyle(
              color: GameColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 24),
          _sheetBtn('▶  RESUME', const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF40C4FF)]), onResume),
          const SizedBox(height: 10),
          _sheetBtn('🔄  RESTART', const LinearGradient(colors: [Color(0xFF0077B6), Color(0xFF00B4D8)]), onRestart),
          const SizedBox(height: 10),
          _sheetBtn('🏠  QUIT', LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade700]), onQuit),
        ],
      ),
    );
  }

  Widget _sheetBtn(String label, Gradient gradient, VoidCallback fn) {
    return GestureDetector(
      onTap: fn,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (gradient as LinearGradient).colors.first.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
    );
  }
}

class _Starfield extends StatelessWidget {
  const _Starfield();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.3);
    const stars = [
      [0.05, 0.1], [0.15, 0.25], [0.9, 0.05], [0.85, 0.3],
      [0.5, 0.08], [0.7, 0.15],  [0.3, 0.02], [0.95, 0.5],
      [0.02, 0.6], [0.1, 0.85],  [0.88, 0.75],[0.45, 0.95],
      [0.6, 0.55], [0.2, 0.45],  [0.78, 0.9], [0.35, 0.7],
    ];
    for (final s in stars) {
      canvas.drawCircle(
        Offset(size.width * s[0], size.height * s[1]), 1.5, paint,
      );
    }
  }
  @override bool shouldRepaint(_) => false;
}
