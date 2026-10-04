import 'element_type.dart';

class Cell {
  ElementType type;
  bool isBlocked; // статически заблокирована
  bool isFrozen; // ледяная клетка (нужен 1 матч рядом)
  bool isDark; // тёмная (New Moon)
  bool isSelected;
  bool isMatched; // помечена для удаления
  int frozenLayers; // количество слоёв льда
  // Для специальных — направление MoonBeam
  String? specialDirection; // 'horizontal' | 'vertical'

  Cell({
    required this.type,
    this.isBlocked = false,
    this.isFrozen = false,
    this.isDark = false,
    this.isSelected = false,
    this.isMatched = false,
    this.frozenLayers = 0,
    this.specialDirection,
  });

  Cell copyWith({
    ElementType? type,
    bool? isBlocked,
    bool? isFrozen,
    bool? isDark,
    bool? isSelected,
    bool? isMatched,
    int? frozenLayers,
    String? specialDirection,
  }) {
    return Cell(
      type: type ?? this.type,
      isBlocked: isBlocked ?? this.isBlocked,
      isFrozen: isFrozen ?? this.isFrozen,
      isDark: isDark ?? this.isDark,
      isSelected: isSelected ?? this.isSelected,
      isMatched: isMatched ?? this.isMatched,
      frozenLayers: frozenLayers ?? this.frozenLayers,
      specialDirection: specialDirection ?? this.specialDirection,
    );
  }

  bool get isPlayable => !isBlocked && type != ElementType.blocked;

  bool get canMatch => isPlayable && !isFrozen && type.isNormal;
}
