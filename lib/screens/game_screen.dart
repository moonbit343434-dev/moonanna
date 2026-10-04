import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game_state.dart';
import '../models/level_config.dart';
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

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  late LevelManager _levelManager;
  late PlayerProgress _progress;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
    _levelManager = LevelManager();
    _progress = widget.progress;

    final config = levels.firstWhere((l) => l.id == widget.levelId);
    _levelManager.startLevel(_gameState, config, _progress);

    _gameState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _gameState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (!_resultShown &&
        (_gameState.status == GameStatus.won ||
            _gameState.status == GameStatus.lost)) {
      _resultShown = true;
      Future.delayed(const Duration(milliseconds: 600), _showResult);
    }
  }

  void _showResult() {
    if (!mounted) return;
    final won = _gameState.status == GameStatus.won;
    final stars = won ? _levelManager.calculateStars(_gameState) : 0;

    if (won) {
      final coinsEarned = [20, 50, 100][stars.clamp(1, 3) - 1];
      _progress.completeLevel(widget.levelId, stars, _gameState.score);
      _progress.coins += coinsEarned;
      _progress.powerUps['moonHammer'] =
          _gameState.powerUps[PowerUpType.moonHammer] ?? 0;
      _progress.powerUps['comet'] =
          _gameState.powerUps[PowerUpType.comet] ?? 0;
      _progress.powerUps['gravitySwitch'] =
          _gameState.powerUps[PowerUpType.gravitySwitch] ?? 0;
      _progress.powerUps['fullMoonBoost'] =
          _gameState.powerUps[PowerUpType.fullMoonBoost] ?? 0;
      _progress.powerUps['starRay'] =
          _gameState.powerUps[PowerUpType.starRay] ?? 0;
      SaveService().save(_progress);
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LevelCompleteScreen(
          won: won,
          stars: stars,
          score: _gameState.score,
          levelId: widget.levelId,
          progress: _progress,
        ),
      ),
    );
  }

  void _onPause() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => _PauseDialog(
        onResume: () => Navigator.pop(ctx),
        onQuit: () {
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
        onRestart: () {
          Navigator.pop(ctx);
          _resultShown = false;
          final config = levels.firstWhere((l) => l.id == widget.levelId);
          _levelManager.startLevel(_gameState, config, _progress);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameState>.value(
      value: _gameState,
      child: Scaffold(
        backgroundColor: GameColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              _buildStarfield(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    TopBarWidget(onPause: _onPause),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Center(
                        child: GameBoardWidget(levelManager: _levelManager),
                      ),
                    ),
                    const SizedBox(height: 8),
                    PowerUpBar(levelManager: _levelManager),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              // Gravity warning overlay
              Consumer<GameState>(
                builder: (_, state, __) {
                  if (!state.showGravityWarning) return const SizedBox();
                  return Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.5),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: const Text(
                          '🌀 GRAVITY SHIFT INCOMING!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .fadeIn(duration: 400.ms)
                          .then()
                          .fadeOut(duration: 400.ms),
                    ),
                  );
                },
              ),
              // Full Moon Boost overlay
              Consumer<GameState>(
                builder: (_, state, __) {
                  if (!state.fullMoonActive) return const SizedBox();
                  return Positioned(
                    bottom: 120,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: GameColors.fullMoon.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: GameColors.fullMoon.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          '🌕 FULL MOON × ${state.fullMoonMovesLeft}',
                          style: const TextStyle(
                            color: GameColors.fullMoon,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Boss label
              if (_gameState.currentLevel?.isBoss == true)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: GameColors.boss.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '👾 BOSS: ${_gameState.currentLevel?.bossName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarfield() {
    return CustomPaint(
      painter: _StarfieldPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _PauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onQuit;
  final VoidCallback onRestart;

  const _PauseDialog({
    required this.onResume,
    required this.onQuit,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: GameColors.boardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⏸ PAUSED',
              style: TextStyle(
                color: GameColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            _btn('▶ RESUME', GameColors.primary, onResume),
            const SizedBox(height: 10),
            _btn('🔄 RESTART', GameColors.accent, onRestart),
            const SizedBox(height: 10),
            _btn('🏠 QUIT', Colors.grey.shade700, onQuit),
          ],
        ),
      ),
    );
  }

  Widget _btn(String label, Color color, VoidCallback fn) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: fn,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.4);
    const stars = [
      [0.05, 0.1], [0.15, 0.25], [0.9, 0.05], [0.85, 0.3],
      [0.5, 0.08], [0.7, 0.15], [0.3, 0.02], [0.95, 0.5],
      [0.02, 0.6], [0.1, 0.85], [0.88, 0.75], [0.45, 0.95],
      [0.6, 0.55], [0.2, 0.45], [0.78, 0.9], [0.35, 0.7],
    ];
    for (final s in stars) {
      canvas.drawCircle(
        Offset(size.width * s[0], size.height * s[1]),
        1.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
