import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/game_colors.dart';
import '../services/save_service.dart';
import 'main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    final progress = await SaveService().load();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, __) => MainMenuScreen(progress: progress),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Stack(
        children: [
          // Animated stars
          ...List.generate(20, (i) => _Star(index: i)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rotating moon ring
                AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => Transform.rotate(
                    angle: _ctrl.value * 6.28,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: GameColors.primary.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: const SizedBox(),
                    ),
                  ),
                ),
                // Moon icon on top
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            GameColors.fullMoon,
                            GameColors.primary,
                            Color(0xFF3D00B0),
                          ],
                          stops: [0.0, 0.6, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: GameColors.primary.withOpacity(0.7),
                            blurRadius: 50,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🌕', style: TextStyle(fontSize: 52)),
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.2, 0.2),
                        duration: 900.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 600.ms),
                ),
                const SizedBox(height: 40),
                // Title
                const Text(
                  'MOON MERGE',
                  style: TextStyle(
                    color: GameColors.textPrimary,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                  ),
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 700.ms)
                    .slideY(begin: 0.4, curve: Curves.easeOutCubic),
                const SizedBox(height: 8),
                const Text(
                  'Match the Moon. Change the Gravity.',
                  style: TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                )
                    .animate(delay: 700.ms)
                    .fadeIn(duration: 600.ms),
                const SizedBox(height: 60),
                // Loading dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: GameColors.primary,
                      ),
                    )
                        .animate(
                          delay: Duration(milliseconds: 900 + i * 150),
                          onPlay: (c) => c.repeat(reverse: true),
                        )
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.3, 1.3),
                          duration: 500.ms,
                        )
                        .fadeIn(duration: 300.ms);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Star extends StatelessWidget {
  final int index;
  const _Star({required this.index});

  @override
  Widget build(BuildContext context) {
    final positions = [
      [0.05, 0.08], [0.15, 0.22], [0.88, 0.06], [0.82, 0.28],
      [0.5, 0.04],  [0.68, 0.14], [0.3, 0.02],  [0.95, 0.45],
      [0.02, 0.6],  [0.12, 0.82], [0.87, 0.72], [0.44, 0.92],
      [0.6, 0.52],  [0.22, 0.42], [0.76, 0.88], [0.37, 0.65],
      [0.55, 0.78], [0.08, 0.35], [0.92, 0.6],  [0.48, 0.18],
    ];
    final p = positions[index % positions.length];
    final sz = MediaQuery.of(context).size;

    return Positioned(
      left: sz.width * p[0],
      top: sz.height * p[1],
      child: Container(
        width: 2.5,
        height: 2.5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.6),
        ),
      )
          .animate(
            delay: Duration(milliseconds: index * 200),
            onPlay: (c) => c.repeat(reverse: true),
          )
          .fadeIn(duration: 800.ms)
          .then()
          .fadeOut(duration: 800.ms),
    );
  }
}
