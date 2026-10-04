const int kBoardSize = 8;
const int kMinMatch = 3;
const double kCellSize = 44.0;
const int kMoonPhaseInterval = 8; // каждые N ходов меняется фаза
const int kGravityShiftInterval = 10; // каждые N ходов меняется гравитация

// Очки
const int kBaseScore = 50;
const int kCascadeMultiplier = 2;
const int kFullMoonMultiplier = 3;

// Монеты за уровни
const List<int> kStarCoins = [20, 50, 100]; // 1, 2, 3 звезды

// Звёзды
const List<double> kStarThresholds = [0.4, 0.7, 1.0]; // % от цели
