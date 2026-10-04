import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/player_progress.dart';
import '../core/game_colors.dart';
import 'game_screen.dart';
import 'map_screen.dart';
import 'daily_screen.dart';
import 'shop_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final PlayerProgress progress;
  const MainMenuScreen({super.key, required this.progress});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _moonController;
  late Animation<double> _moonFloat;

  @override
  void initState() {
    super.initState();
    _moonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _moonFloat = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _moonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _moonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress;
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Stack(
        children: [
          // Starfield
          CustomPaint(painter: _MenuStarPainter(), child: const SizedBox.expand()),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Currency bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _badge('🪙', '${progress.coins}', GameColors.gold),
                        const SizedBox(width: 8),
                        _badge('💎', '${progress.crystals}', GameColors.accent),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Floating moon
                    AnimatedBuilder(
                      animation: _moonFloat,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, _moonFloat.value),
                        child: Container(
                          width: 110,
                          height: 110,
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
                                color: GameColors.primary.withOpacity(0.5),
                                blurRadius: 40,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🌕', style: TextStyle(fontSize: 56)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Title
                    const Text(
                      'MOON MERGE',
                      style: TextStyle(
                        color: GameColors.textPrimary,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .shimmer(
                          delay: 800.ms,
                          duration: 2000.ms,
                          color: GameColors.fullMoon.withOpacity(0.6),
                        ),
                    const SizedBox(height: 6),
                    const Text(
                      'Match the Moon. Change the Gravity.',
                      style: TextStyle(
                        color: GameColors.textSecondary,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 500.ms),
                    const SizedBox(height: 10),
                    Text(
                      'Level ${progress.currentLevel}',
                      style: const TextStyle(
                        color: GameColors.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate(delay: 500.ms).fadeIn(duration: 500.ms),
                    const SizedBox(height: 36),
                    // PLAY button
                    _menuButton(
                      context,
                      '▶  PLAY',
                      GameColors.primary,
                      large: true,
                      delay: 0,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            levelId: progress.currentLevel.clamp(1, 30),
                            progress: progress,
                          ),
                        ),
                      ).then((_) => setState(() {})),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _menuButton(
                            context,
                            '🗺  MAP',
                            GameColors.accent,
                            delay: 100,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MapScreen(progress: progress),
                              ),
                            ).then((_) => setState(() {})),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _menuButton(
                            context,
                            '📅  DAILY',
                            const Color(0xFF4CAF50),
                            delay: 150,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DailyScreen(progress: progress),
                              ),
                            ).then((_) => setState(() {})),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _menuButton(
                      context,
                      '🛒  SHOP',
                      const Color(0xFF795548),
                      delay: 200,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShopScreen(progress: progress),
                        ),
                      ).then((_) => setState(() {})),
                    ),
                    const SizedBox(height: 10),
                    _menuButton(
                      context,
                      '⚙️  SETTINGS',
                      Colors.grey.shade700,
                      delay: 250,
                      onTap: () => _showSettings(context),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(
    BuildContext ctx,
    String label,
    Color color, {
    bool large = false,
    required int delay,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, large ? 58 : 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(large ? 18 : 14),
        ),
        elevation: large ? 8 : 4,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: large ? 18 : 15,
          letterSpacing: 1,
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 600 + delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.3);
  }

  void _showSettings(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dctx) => Dialog(
        backgroundColor: GameColors.boardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '⚙️ SETTINGS',
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              _settingRow('🔊 Sound', widget.progress.soundEnabled, (v) {
                setState(() => widget.progress.soundEnabled = v);
              }),
              const SizedBox(height: 10),
              _settingRow('🎵 Music', widget.progress.musicEnabled, (v) {
                setState(() => widget.progress.musicEnabled = v);
              }),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(dctx),
                child: const Text(
                  'Close',
                  style: TextStyle(color: GameColors.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: GameColors.textPrimary, fontSize: 15)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: GameColors.primary,
        ),
      ],
    );
  }
}

class _MenuStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.35);
    const stars = [
      [0.05, 0.07], [0.18, 0.15], [0.9, 0.04], [0.83, 0.22],
      [0.5, 0.03], [0.68, 0.12], [0.32, 0.01], [0.95, 0.45],
      [0.02, 0.55], [0.12, 0.82], [0.87, 0.72], [0.44, 0.92],
      [0.6, 0.5], [0.22, 0.4], [0.76, 0.88], [0.37, 0.65],
      [0.55, 0.78], [0.08, 0.35], [0.92, 0.6], [0.48, 0.18],
    ];
    for (final s in stars) {
      canvas.drawCircle(
        Offset(size.width * s[0], size.height * s[1]),
        1.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
