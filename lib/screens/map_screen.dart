import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/player_progress.dart';
import '../data/levels_data.dart';
import '../core/game_colors.dart';
import 'game_screen.dart';
import 'main_menu_screen.dart';

class MapScreen extends StatelessWidget {
  final PlayerProgress progress;
  const MapScreen({super.key, required this.progress});

  static const _areas = {
    'lunar_valley':   {'name': 'Lunar Valley',    'emoji': '🌙', 'color': 0xFF3D8EFF},
    'crystal_desert': {'name': 'Crystal Desert',  'emoji': '💎', 'color': 0xFF26C6DA},
    'shadow_craters': {'name': 'Shadow Craters',  'emoji': '🌑', 'color': 0xFFAB47BC},
    'frozen_moon':    {'name': 'Frozen Moon',     'emoji': '❄️', 'color': 0xFF29B6F6},
    'eclipse_zone':   {'name': 'Eclipse Zone',    'emoji': '🌗', 'color': 0xFFFFA726},
    'dark_side':      {'name': 'Dark Side',       'emoji': '🌌', 'color': 0xFFCE93D8},
    'moon_core':      {'name': 'Moon Core',       'emoji': '🔮', 'color': 0xFFFF7043},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(child: _buildList(context)),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => MainMenuScreen(progress: progress)),
            ),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: GameColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GameColors.primary.withOpacity(0.3)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: GameColors.textSecondary, size: 16),
            ),
          ),
          const Spacer(),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [GameColors.accent, GameColors.primaryLight],
            ).createShader(b),
            child: const Text(
              '🌙  MOON WORLD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          const Spacer(),
          _coinBadge(),
        ],
      ),
    );
  }

  Widget _coinBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: GameColors.gold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameColors.gold.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('🪙', style: TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text('${progress.coins}', style: const TextStyle(
          color: GameColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    );
  }

  Widget _buildList(BuildContext context) {
    String? lastArea;
    final items = <Widget>[];

    for (int i = 0; i < levels.length; i++) {
      final lvl = levels[i];
      if (lvl.area != lastArea) {
        lastArea = lvl.area;
        final info = _areas[lvl.area] ?? {'name': lvl.area, 'emoji': '🌕', 'color': 0xFF7C4DFF};
        items.add(_areaHeader(info));
      }
      items.add(_levelTile(context, lvl.id, i));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      children: items,
    );
  }

  Widget _areaHeader(Map info) {
    final c = Color(info['color'] as int);
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(info['emoji'] as String, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(info['name'] as String, style: TextStyle(
          color: c, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
      ]),
    );
  }

  Widget _levelTile(BuildContext context, int id, int animIndex) {
    final cfg = levels.firstWhere((l) => l.id == id);
    final unlocked = progress.isLevelUnlocked(id);
    final stars = progress.starsForLevel(id);
    final isCurrent = id == progress.currentLevel;
    final isBoss = cfg.isBoss;

    final color = unlocked
        ? (isBoss ? GameColors.boss : GameColors.primary)
        : GameColors.textHint;

    return GestureDetector(
      onTap: unlocked ? () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, a, __) => GameScreen(levelId: id, progress: progress),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrent ? color.withOpacity(0.12) : GameColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent ? color : color.withOpacity(0.2),
            width: isCurrent ? 1.5 : 1,
          ),
          boxShadow: isCurrent
              ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12)]
              : [],
        ),
        child: Row(
          children: [
            // Number circle
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unlocked ? color.withOpacity(0.15) : GameColors.cellBg,
                border: Border.all(color: color.withOpacity(0.4), width: 1.5),
              ),
              child: Center(
                child: unlocked
                    ? Text(
                        isBoss ? '👾' : '$id',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: isBoss ? 20 : 16,
                        ),
                      )
                    : Icon(Icons.lock_outline, color: GameColors.textHint, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(
                      isBoss ? '👾  ${cfg.bossName}' : 'Level $id',
                      style: TextStyle(
                        color: unlocked ? GameColors.textPrimary : GameColors.textHint,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('NOW', style: TextStyle(
                          color: color, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ]),
                  Text(
                    cfg.goalDescription,
                    style: const TextStyle(color: GameColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            // Stars
            if (stars > 0)
              Row(
                children: List.generate(3, (i) => Text(
                  i < stars ? '⭐' : '☆',
                  style: TextStyle(
                    fontSize: 15,
                    color: i < stars ? GameColors.gold : GameColors.textHint,
                  ),
                )),
              )
            else if (unlocked)
              Icon(Icons.play_arrow_rounded, color: color, size: 26),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: animIndex * 25))
          .fadeIn(duration: 250.ms)
          .slideX(begin: 0.08),
    );
  }
}
