import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/game_colors.dart';

/// Виджет частиц для эффекта комбо
class ComboParticles extends StatelessWidget {
  final int comboCount;
  const ComboParticles({super.key, required this.comboCount});

  @override
  Widget build(BuildContext context) {
    if (comboCount < 2) return const SizedBox();
    return Center(
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          shadows: [
            Shadow(color: _color.withOpacity(0.8), blurRadius: 12),
          ],
        ),
      )
          .animate()
          .scale(begin: const Offset(0.5, 0.5), duration: 300.ms, curve: Curves.elasticOut)
          .fadeIn(duration: 200.ms)
          .then(delay: 500.ms)
          .fadeOut(duration: 300.ms),
    );
  }

  String get _label {
    if (comboCount >= 5) return '🌕 SUPER COMBO!';
    if (comboCount >= 4) return '💥 MEGA COMBO!';
    if (comboCount >= 3) return '✨ GREAT COMBO!';
    return '🔥 COMBO x$comboCount';
  }

  Color get _color {
    if (comboCount >= 5) return GameColors.fullMoon;
    if (comboCount >= 4) return GameColors.lunarCore;
    if (comboCount >= 3) return GameColors.moonBeam;
    return Colors.white;
  }
}

/// Маленькая вспышка при матче
class MatchFlash extends StatelessWidget {
  final Color color;
  const MatchFlash({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.6),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.8), blurRadius: 20, spreadRadius: 5),
        ],
      ),
    )
        .animate()
        .scale(begin: const Offset(0.1, 0.1), end: const Offset(2, 2), duration: 400.ms)
        .fadeOut(duration: 400.ms);
  }
}
