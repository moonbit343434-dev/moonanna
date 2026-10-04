import 'package:flutter/material.dart';
import '../core/game_colors.dart';

enum ElementType {
  moonCrystal,
  shadowOrb,
  iceStar,
  emeraldMoon,
  solarStone,
  lunarPearl,
  // Специальные
  moonBeam,
  lunarCore,
  gravityBomb,
  // Служебные
  empty,
  blocked,
}

extension ElementTypeExt on ElementType {
  bool get isSpecial =>
      this == ElementType.moonBeam ||
      this == ElementType.lunarCore ||
      this == ElementType.gravityBomb;

  bool get isNormal =>
      this == ElementType.moonCrystal ||
      this == ElementType.shadowOrb ||
      this == ElementType.iceStar ||
      this == ElementType.emeraldMoon ||
      this == ElementType.solarStone ||
      this == ElementType.lunarPearl;

  bool get isPlayable => isNormal || isSpecial;

  Color get color {
    switch (this) {
      case ElementType.moonCrystal:
        return GameColors.moonCrystal;
      case ElementType.shadowOrb:
        return GameColors.shadowOrb;
      case ElementType.iceStar:
        return GameColors.iceStar;
      case ElementType.emeraldMoon:
        return GameColors.emeraldMoon;
      case ElementType.solarStone:
        return GameColors.solarStone;
      case ElementType.lunarPearl:
        return GameColors.lunarPearl;
      case ElementType.moonBeam:
        return GameColors.moonBeam;
      case ElementType.lunarCore:
        return GameColors.lunarCore;
      case ElementType.gravityBomb:
        return GameColors.gravityBomb;
      default:
        return Colors.transparent;
    }
  }

  String get emoji {
    switch (this) {
      case ElementType.moonCrystal:
        return '🔵';
      case ElementType.shadowOrb:
        return '🟣';
      case ElementType.iceStar:
        return '🔷';
      case ElementType.emeraldMoon:
        return '🟢';
      case ElementType.solarStone:
        return '🟠';
      case ElementType.lunarPearl:
        return '⚪';
      case ElementType.moonBeam:
        return '✨';
      case ElementType.lunarCore:
        return '💥';
      case ElementType.gravityBomb:
        return '💣';
      default:
        return '';
    }
  }

  String get label {
    switch (this) {
      case ElementType.moonCrystal:
        return 'Moon Crystal';
      case ElementType.shadowOrb:
        return 'Shadow Orb';
      case ElementType.iceStar:
        return 'Ice Star';
      case ElementType.emeraldMoon:
        return 'Emerald Moon';
      case ElementType.solarStone:
        return 'Solar Stone';
      case ElementType.lunarPearl:
        return 'Lunar Pearl';
      case ElementType.moonBeam:
        return 'Moon Beam';
      case ElementType.lunarCore:
        return 'Lunar Core';
      case ElementType.gravityBomb:
        return 'Gravity Bomb';
      default:
        return '';
    }
  }

  // Символ для отрисовки
  IconData get icon {
    switch (this) {
      case ElementType.moonCrystal:
        return Icons.diamond_outlined;
      case ElementType.shadowOrb:
        return Icons.circle;
      case ElementType.iceStar:
        return Icons.star_outline;
      case ElementType.emeraldMoon:
        return Icons.brightness_3;
      case ElementType.solarStone:
        return Icons.hexagon_outlined;
      case ElementType.lunarPearl:
        return Icons.circle_outlined;
      case ElementType.moonBeam:
        return Icons.flash_on;
      case ElementType.lunarCore:
        return Icons.blur_on;
      case ElementType.gravityBomb:
        return Icons.radio_button_checked;
      default:
        return Icons.block;
    }
  }
}

// Нормальные типы (для рандома)
const List<ElementType> kNormalElements = [
  ElementType.moonCrystal,
  ElementType.shadowOrb,
  ElementType.iceStar,
  ElementType.emeraldMoon,
  ElementType.solarStone,
  ElementType.lunarPearl,
];
