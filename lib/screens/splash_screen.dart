import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/game_colors.dart';
import '../models/player_progress.dart';
import '../services/save_service.dart';
import 'main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    final progress = await SaveService().load();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainMenuScreen(progress: progress)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Moon logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    GameColors.fullMoon,
                    GameColors.primary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.primary.withOpacity(0.6),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🌕', style: TextStyle(fontSize: 60)),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.3, 0.3),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 600.ms),
            const SizedBox(height: 28),
            const Text(
              'MOON MERGE',
              style: TextStyle(
                color: GameColors.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3),
            const SizedBox(height: 8),
            const Text(
              'Match the Moon. Change the Gravity.',
              style: TextStyle(
                color: GameColors.textSecondary,
                fontSize: 13,
                letterSpacing: 1,
              ),
            )
                .animate(delay: 700.ms)
                .fadeIn(duration: 600.ms),
            const SizedBox(height: 48),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: GameColors.primary.withOpacity(0.7),
                strokeWidth: 2,
              ),
            )
                .animate(delay: 900.ms)
                .fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
