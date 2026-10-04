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
    with TickerProviderStateMixin {
  late AnimationController _moonCtrl;
  late AnimationController _glowCtrl;
  late Animation<double> _moonFloat;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();
    _moonCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _moonFloat = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _moonCtrl, curve: Curves.easeInOut),
    );
    _glowPulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _moonCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Stack(
        children: [
          // Stars
          ...List.generate(18, (i) => _buildStar(context, i)),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Top currency bar
                    _buildCurrencyBar(),
                    const SizedBox(height: 30),
                    // Floating moon
                    AnimatedBuilder(
                      animation: _moonCtrl,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, _moonFloat.value),
                        child: AnimatedBuilder(
                          animation: _glowCtrl,
                          builder: (_, __) => Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [
                                  GameColors.fullMoon,
                                  GameColors.primary,
                                  Color(0xFF2A0080),
                                ],
                                stops: [0.0, 0.55, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: GameColors.primary.withOpacity(_glowPulse.value),
                                  blurRadius: 60,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: GameColors.accent.withOpacity(_glowPulse.value * 0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🌕', style: TextStyle(fontSize: 60)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          GameColors.accent,
                          GameColors.primaryLight,
                          GameColors.fullMoon,
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'MOON MERGE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 5,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 700.ms)
                        .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                    const SizedBox(height: 6),
                    const Text(
                      'Match the Moon. Change the Gravity.',
                      style: TextStyle(
                        color: GameColors.textSecondary,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: GameColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GameColors.primary.withOpacity(0.4)),
                      ),
                      child: Text(
                        'Level ${widget.progress.currentLevel}',
                        style: const TextStyle(
                          color: GameColors.primaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 500.ms),
                    const SizedBox(height: 40),
                    // Buttons
                    _menuBtn(
                      icon: '▶',
                      label: 'PLAY',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C4DFF), Color(0xFF40C4FF)],
                      ),
                      large: true,
                      delay: 0,
                      onTap: () => _navigate(
                        context,
                        GameScreen(
                          levelId: widget.progress.currentLevel.clamp(1, 30),
                          progress: widget.progress,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _menuBtn(
                            icon: '🗺',
                            label: 'MAP',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
                            ),
                            delay: 80,
                            onTap: () => _navigate(
                              context,
                              MapScreen(progress: widget.progress),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _menuBtn(
                            icon: '📅',
                            label: 'DAILY',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                            ),
                            delay: 120,
                            onTap: () => _navigate(
                              context,
                              DailyScreen(progress: widget.progress),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _menuBtn(
                            icon: '🛒',
                            label: 'SHOP',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4E342E), Color(0xFF8D6E63)],
                            ),
                            delay: 160,
                            onTap: () => _navigate(
                              context,
                              ShopScreen(progress: widget.progress),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _menuBtn(
                            icon: '⚙️',
                            label: 'SETTINGS',
                            gradient: LinearGradient(
                              colors: [Colors.grey.shade800, Colors.grey.shade700],
                            ),
                            delay: 200,
                            onTap: () => _showSettings(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => screen,
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ).then((_) => setState(() {}));
  }

  Widget _buildCurrencyBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _badge('🪙', '${widget.progress.coins}', GameColors.gold),
        const SizedBox(width: 8),
        _badge('💎', '${widget.progress.crystals}', GameColors.accent),
      ],
    );
  }

  Widget _badge(String icon, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 5),
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ]),
    );
  }

  Widget _menuBtn({
    required String icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
    required int delay,
    bool large = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: large ? 62 : 52,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (gradient as LinearGradient).colors.first.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: TextStyle(fontSize: large ? 22 : 18)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: large ? 18 : 15,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 500 + delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.3, curve: Curves.easeOutCubic);
  }

  Widget _buildStar(BuildContext context, int i) {
    final positions = [
      [0.05, 0.08], [0.15, 0.22], [0.88, 0.06], [0.82, 0.28],
      [0.5, 0.04],  [0.68, 0.14], [0.3, 0.02],  [0.95, 0.45],
      [0.02, 0.6],  [0.12, 0.82], [0.87, 0.72], [0.44, 0.92],
      [0.6, 0.52],  [0.22, 0.42], [0.76, 0.88], [0.37, 0.65],
      [0.55, 0.78], [0.08, 0.35],
    ];
    final p = positions[i % positions.length];
    final sz = MediaQuery.of(context).size;
    return Positioned(
      left: sz.width * p[0],
      top: sz.height * p[1],
      child: Container(
        width: 2, height: 2,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white54,
        ),
      )
          .animate(
            delay: Duration(milliseconds: i * 180),
            onPlay: (c) => c.repeat(reverse: true),
          )
          .fadeIn(duration: 700.ms)
          .then()
          .fadeOut(duration: 700.ms),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: GameColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: GameColors.textHint,
              borderRadius: BorderRadius.circular(2),
            )),
            const SizedBox(height: 20),
            const Text('⚙️  SETTINGS', style: TextStyle(
              color: GameColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            )),
            const SizedBox(height: 24),
            _settingRow('🔊  Sound Effects', widget.progress.soundEnabled,
                (v) => setState(() => widget.progress.soundEnabled = v)),
            const SizedBox(height: 12),
            _settingRow('🎵  Music', widget.progress.musicEnabled,
                (v) => setState(() => widget.progress.musicEnabled = v)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _settingRow(String label, bool val, ValueChanged<bool> onChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: GameColors.textPrimary, fontSize: 15)),
        Switch(value: val, onChanged: onChange, activeColor: GameColors.primary),
      ],
    );
  }
}
