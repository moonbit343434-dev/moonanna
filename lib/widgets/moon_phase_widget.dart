import 'package:flutter/material.dart';
import '../models/level_config.dart';
import '../core/game_colors.dart';

class MoonPhaseWidget extends StatelessWidget {
  final MoonPhaseType phase;
  final bool compact;

  const MoonPhaseWidget({
    super.key,
    required this.phase,
    this.compact = false,
  });

  String get _emoji {
    switch (phase) {
      case MoonPhaseType.newMoon:    return '🌑';
      case MoonPhaseType.crescent:   return '🌒';
      case MoonPhaseType.halfMoon:   return '🌓';
      case MoonPhaseType.waxingMoon: return '🌔';
      case MoonPhaseType.fullMoon:   return '🌕';
    }
  }

  String get _label {
    switch (phase) {
      case MoonPhaseType.newMoon:    return 'New Moon';
      case MoonPhaseType.crescent:   return 'Crescent';
      case MoonPhaseType.halfMoon:   return 'Half Moon';
      case MoonPhaseType.waxingMoon: return 'Waxing';
      case MoonPhaseType.fullMoon:   return 'Full Moon';
    }
  }

  Color get _color {
    switch (phase) {
      case MoonPhaseType.newMoon:    return GameColors.newMoon;
      case MoonPhaseType.crescent:   return GameColors.crescent;
      case MoonPhaseType.halfMoon:   return GameColors.halfMoon;
      case MoonPhaseType.waxingMoon: return GameColors.waxingMoon;
      case MoonPhaseType.fullMoon:   return GameColors.fullMoon;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          Text(
            _label,
            style: const TextStyle(
              color: GameColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 5),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
