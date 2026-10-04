import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/cell.dart';
import '../models/element_type.dart';
import '../core/game_colors.dart';
import '../core/constants.dart';

class GameCellWidget extends StatelessWidget {
  final Cell cell;
  final bool isSelected;
  final VoidCallback? onTap;

  const GameCellWidget({
    super.key,
    required this.cell,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (cell.isBlocked || cell.type == ElementType.blocked) {
      return _buildBlocked();
    }

    Widget content = _buildCell();

    if (isSelected) {
      content = content
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 800.ms, color: Colors.white.withOpacity(0.4));
    }

    return GestureDetector(onTap: onTap, child: content);
  }

  Widget _buildBlocked() {
    return Container(
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: GameColors.blocked,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26, width: 1),
      ),
      child: const Center(
        child: Icon(Icons.lock, color: Colors.black38, size: 18),
      ),
    );
  }

  Widget _buildCell() {
    Color bgColor = GameColors.cellBg;
    Color borderColor = cell.type.color.withOpacity(0.4);

    if (cell.isDark) bgColor = GameColors.cellBgDark;
    if (cell.isFrozen) borderColor = GameColors.frozen;
    if (isSelected) borderColor = Colors.white;

    return Container(
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor.withOpacity(0.8),
            bgColor,
          ],
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: cell.type.color.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: cell.type.color.withOpacity(0.15),
                  blurRadius: 4,
                ),
              ],
      ),
      child: Stack(
        children: [
          Center(child: _buildElementIcon()),
          if (cell.isFrozen) _buildFrozenOverlay(),
          if (cell.isDark) _buildDarkOverlay(),
        ],
      ),
    );
  }

  Widget _buildElementIcon() {
    if (cell.type == ElementType.empty) return const SizedBox();

    final svgPath = _getSvgPath(cell.type);
    if (svgPath != null) {
      return Padding(
        padding: const EdgeInsets.all(4),
        child: SvgPicture.asset(
          svgPath,
          width: kCellSize * 0.7,
          height: kCellSize * 0.7,
        ),
      );
    }

    // Fallback для элементов без SVG
    return Container(
      width: kCellSize * 0.62,
      height: kCellSize * 0.62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            cell.type.color.withOpacity(0.9),
            cell.type.color.withOpacity(0.4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: cell.type.color.withOpacity(0.5),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          cell.type.icon,
          color: Colors.white.withOpacity(0.9),
          size: kCellSize * 0.32,
        ),
      ),
    );
  }

  String? _getSvgPath(ElementType type) {
    switch (type) {
      case ElementType.moonCrystal:
        return 'assets/images/moon_crystal.svg';
      case ElementType.shadowOrb:
        return 'assets/images/shadow_orb.svg';
      case ElementType.iceStar:
        return 'assets/images/ice_star.svg';
      case ElementType.emeraldMoon:
        return 'assets/images/emerald_moon.svg';
      case ElementType.solarStone:
        return 'assets/images/solar_stone.svg';
      case ElementType.lunarPearl:
        return 'assets/images/lunar_pearl.svg';
      case ElementType.moonBeam:
        return 'assets/images/moon_beam.svg';
      case ElementType.lunarCore:
        return 'assets/images/lunar_core.svg';
      case ElementType.gravityBomb:
        return 'assets/images/gravity_bomb.svg';
      default:
        return null;
    }
  }

  Widget _buildFrozenOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GameColors.frozen, width: 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GameColors.frozen.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Text(
            cell.frozenLayers > 1 ? '${cell.frozenLayers}' : '❄',
            style: TextStyle(
              fontSize: cell.frozenLayers > 1 ? 10 : 14,
              color: GameColors.frozen,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDarkOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withOpacity(0.55),
      ),
      child: const Center(
        child: Text('🌑', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
