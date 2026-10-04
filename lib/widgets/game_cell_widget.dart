import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/cell.dart';
import '../models/element_type.dart';
import '../core/game_colors.dart';

class GameCellWidget extends StatelessWidget {
  final Cell cell;
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;

  const GameCellWidget({
    super.key,
    required this.cell,
    this.isSelected = false,
    this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    if (cell.isBlocked || cell.type == ElementType.blocked) {
      return _buildBlocked();
    }
    return GestureDetector(
      onTap: onTap,
      child: _buildCell(),
    );
  }

  Widget _buildBlocked() {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: GameColors.blocked,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Center(
        child: Icon(
          Icons.lock_outline,
          color: Colors.white.withOpacity(0.15),
          size: size * 0.35,
        ),
      ),
    );
  }

  Widget _buildCell() {
    final color = cell.type.color;
    final selected = isSelected;

    Widget gem = _buildGem(color);

    // Pulsate specials
    if (cell.type.isSpecial) {
      gem = gem
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(0.92, 0.92),
            end: const Offset(1.08, 1.08),
            duration: 900.ms,
            curve: Curves.easeInOut,
          )
          .shimmer(
            duration: 1200.ms,
            color: color.withOpacity(0.6),
          );
    }

    // Glow when selected
    if (selected) {
      gem = gem
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
            duration: 600.ms,
            color: Colors.white.withOpacity(0.5),
          );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: selected
            ? color.withOpacity(0.18)
            : GameColors.cellBg,
        border: Border.all(
          color: selected ? color : color.withOpacity(0.25),
          width: selected ? 2 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.55),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: color.withOpacity(0.12),
                  blurRadius: 6,
                ),
              ],
      ),
      child: Stack(
        children: [
          Center(child: gem),
          if (cell.isFrozen) _buildFrozenOverlay(),
          if (cell.isDark)   _buildDarkOverlay(),
        ],
      ),
    );
  }

  Widget _buildGem(Color color) {
    if (cell.type == ElementType.empty) return const SizedBox();

    final iconSize = size * 0.48;

    // Special elements get a bigger glowing shape
    if (cell.type.isSpecial) {
      return Container(
        width: size * 0.72,
        height: size * 0.72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withOpacity(0.9),
              color,
              color.withOpacity(0.3),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.7),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Icon(cell.type.icon, color: Colors.white, size: iconSize),
        ),
      );
    }

    // Normal elements — gem shape
    return Container(
      width: size * 0.65,
      height: size * 0.65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.3),
            color,
            color.withOpacity(0.6),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(cell.type.icon, color: Colors.white, size: iconSize),
      ),
    );
  }

  Widget _buildFrozenOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GameColors.frozen.withOpacity(0.35),
            Colors.transparent,
          ],
        ),
        border: Border.all(color: GameColors.frozen.withOpacity(0.6), width: 1.5),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Text(
            cell.frozenLayers > 1 ? '${cell.frozenLayers}❄' : '❄',
            style: const TextStyle(fontSize: 10, color: GameColors.frozen),
          ),
        ),
      ),
    );
  }

  Widget _buildDarkOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(0.6),
      ),
      child: const Center(
        child: Text('🌑', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
