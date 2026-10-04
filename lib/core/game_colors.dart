import 'package:flutter/material.dart';

class GameColors {
  // Backgrounds
  static const Color background    = Color(0xFF05050F);
  static const Color boardBg       = Color(0xFF0D0D20);
  static const Color cellBg        = Color(0xFF141430);
  static const Color cellBgDark    = Color(0xFF07070F);
  static const Color cardBg        = Color(0xFF111128);

  // Elements
  static const Color moonCrystal   = Color(0xFF29B6F6);
  static const Color shadowOrb     = Color(0xFFAB47BC);
  static const Color iceStar       = Color(0xFF26C6DA);
  static const Color emeraldMoon   = Color(0xFF66BB6A);
  static const Color solarStone    = Color(0xFFFFA726);
  static const Color lunarPearl    = Color(0xFFEEEEEE);

  // Specials
  static const Color moonBeam      = Color(0xFFFFEE58);
  static const Color lunarCore     = Color(0xFFFF7043);
  static const Color gravityBomb   = Color(0xFFEF5350);

  // UI
  static const Color primary       = Color(0xFF7C4DFF);
  static const Color primaryLight  = Color(0xFF9E6FFF);
  static const Color accent        = Color(0xFF40C4FF);
  static const Color gold          = Color(0xFFFFD700);
  static const Color silver        = Color(0xFFB0BEC5);
  static const Color success       = Color(0xFF69F0AE);
  static const Color danger        = Color(0xFFFF5252);

  // Text
  static const Color textPrimary   = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF7B7BA0);
  static const Color textHint      = Color(0xFF4A4A6A);

  // Moon phases
  static const Color newMoon       = Color(0xFF12122A);
  static const Color crescent      = Color(0xFF1E1E40);
  static const Color halfMoon      = Color(0xFF2C2C5E);
  static const Color waxingMoon    = Color(0xFF3D3D7A);
  static const Color fullMoon      = Color(0xFFBBBBFF);

  // Obstacles
  static const Color blocked       = Color(0xFF1A1A35);
  static const Color frozen        = Color(0xFF80D8FF);
  static const Color boss          = Color(0xFFFF1744);

  static Color elementColor(String name) {
    switch (name) {
      case 'moonCrystal':  return moonCrystal;
      case 'shadowOrb':    return shadowOrb;
      case 'iceStar':      return iceStar;
      case 'emeraldMoon':  return emeraldMoon;
      case 'solarStone':   return solarStone;
      case 'lunarPearl':   return lunarPearl;
      case 'moonBeam':     return moonBeam;
      case 'lunarCore':    return lunarCore;
      case 'gravityBomb':  return gravityBomb;
      default:             return primary;
    }
  }
}
