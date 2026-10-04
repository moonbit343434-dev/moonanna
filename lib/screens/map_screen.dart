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

  static const Map<String, Map<String, dynamic>> _areaInfo = {
    'lunar_valley': {'name': 'Lunar Valley', 'emoji': '🌙', 'color': 0xFF3D8EFF},
    'crystal_desert': {'name': 'Crystal Desert', 'emoji': '💎', 'color': 0xFF80DEEA},
    'shadow_craters': {'name': 'Shadow Craters', 'emoji': '🌑', 'color': 0xFF6C3DC8},
    'frozen_moon': {'name': 'Frozen Moon', 'emoji': '❄️', 'color': 0xFF4FC3F7},
    'eclipse_zone': {'name': 'Eclipse Zone', 'emoji': '🌗', 'color': 0xFFFFCC80},
    'dark_side': {'name': 'Dark Side', 'emoji': '🌌', 'color': 0xFFCE93D8},
    'moon_core': {'name': 'Moon Core', 'emoji': '🔮', 'color': 0xFFFF8A65},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildMap(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => MainMenuScreen(progress: progress)),
            ),
            child: const Icon(Icons.arrow_back_ios, color: GameColors.textSecondary),
          ),
          const Spacer(),
          const Text(
            '🌙 MOON WORLD',
            style: TextStyle(
              color: GameColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                '${progress.coins}',
                style: const TextStyle(
                  color: GameColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    String? currentArea;
    final widgets = <Widget>[];

    for (int i = 0; i < levels.length; i++) {
      final lvl = levels[i];
      if (lvl.area != currentArea) {
        currentArea = lvl.area;
        final info = _areaInfo[currentArea] ?? {'name': currentArea, 'emoji': '🌕', 'color': 0xFF6C3DC8};
        widgets.add(_buildAreaHeader(info));
      }
      widgets.add(_buildLevelNode(context, lvl.id));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: widgets,
    );
  }

  Widget _buildAreaHeader(Map<String, dynamic> info) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(info['color'] as int).withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Color(info['color'] as int).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(info['emoji'] as String, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            info['name'] as String,
            style: TextStyle(
              color: Color(info['color'] as int),
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelNode(BuildContext context, int id) {
    final config = levels.firstWhere((l) => l.id == id);
    final unlocked = progress.isLevelUnlocked(id);
    final stars = progress.starsForLevel(id);
    final isCurrent = id == progress.currentLevel;
    final isCompleted = stars > 0;

    Color nodeColor = unlocked
        ? (config.isBoss ? GameColors.boss : GameColors.primary)
        : Colors.grey.shade800;

    return GestureDetector(
      onTap: unlocked
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GameScreen(levelId: id, progress: progress),
                ),
              )
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrent
              ? nodeColor.withOpacity(0.25)
              : GameColors.boardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrent
                ? nodeColor
                : nodeColor.withOpacity(0.3),
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: isCurrent
              ? [BoxShadow(color: nodeColor.withOpacity(0.3), blurRadius: 10)]
              : [],
        ),
        child: Row(
          children: [
            // Level circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unlocked ? nodeColor.withOpacity(0.2) : Colors.grey.shade800,
                border: Border.all(
                  color: unlocked ? nodeColor : Colors.grey.shade600,
                  width: 2,
                ),
              ),
              child: Center(
                child: unlocked
                    ? Text(
                        config.isBoss ? '👾' : '$id',
                        style: TextStyle(
                          color: nodeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: config.isBoss ? 18 : 16,
                        ),
                      )
                    : const Icon(Icons.lock, color: Colors.grey, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        config.isBoss ? '👾 ${config.bossName}' : 'Level $id',
                        style: TextStyle(
                          color: unlocked ? GameColors.textPrimary : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: nodeColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'CURRENT',
                            style: TextStyle(
                              color: nodeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    config.goalDescription,
                    style: const TextStyle(
                      color: GameColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Stars
            if (isCompleted)
              Row(
                children: List.generate(3, (i) {
                  return Text(
                    i < stars ? '⭐' : '☆',
                    style: TextStyle(
                      fontSize: 14,
                      color: i < stars ? GameColors.gold : Colors.grey.shade600,
                    ),
                  );
                }),
              )
            else if (unlocked)
              const Icon(Icons.play_arrow, color: GameColors.primary, size: 24),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: id * 30))
          .fadeIn(duration: 300.ms)
          .slideX(begin: 0.1),
    );
  }
}
