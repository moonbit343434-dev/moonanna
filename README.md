# 🌕 MOON MERGE

> **Match the Moon. Change the Gravity.**

Полноценная мобильная match-3 игра с уникальными механиками Moon Phase и Gravity Shift.

---

## 🎮 Механики

| Механика | Описание |
|----------|----------|
| **Match-3** | Меняй местами соседние элементы, собирай 3+ в ряд |
| **Moon Phase** | Фаза луны меняется каждые 8 ходов и влияет на правила поля |
| **Gravity Shift** | Направление падения элементов меняется: ↓ → → ↑ → ← |
| **Special Elements** | Moon Beam, Lunar Core, Gravity Bomb |
| **Power-Ups** | 5 уникальных усилителей |

## 🌙 Элементы

| Элемент | Цвет | Как создать |
|---------|------|-------------|
| Moon Beam ✨ | Жёлтый | 4 в ряд → уничтожает линию |
| Lunar Core 💥 | Оранжевый | 5 в ряд → уничтожает все элементы типа |
| Gravity Bomb 💣 | Красный | L-образная → взрыв 5×5 |

## 🗺 Уровни (30 штук)

| Уровни | Локация | Механика |
|--------|---------|----------|
| 1–5 | Lunar Valley | Базовый match-3 |
| 6–10 | Crystal Desert | Заблокированные клетки |
| 11–15 | Shadow Craters | Moon Phase |
| 16–20 | Frozen Moon | Gravity Shift + Лёд |
| 21–25 | Eclipse Zone | Все механики |
| 26–30 | Dark Side | Максимальная сложность |

Боссы на уровнях: **5, 10, 15, 20, 25, 30**

---

## 🚀 Сборка

### Через GitHub Actions (рекомендуется)

1. Создай репозиторий на GitHub
2. Залей папку `moon_merge`:
```bash
cd moon_merge
git init
git add .
git commit -m "Moon Merge v1.0"
git branch -M main
git remote add origin https://github.com/ТВО_ИМЯ/moon-merge.git
git push -u origin main
```
3. Открой вкладку **Actions** → дождись сборки (~5 мин)
4. Скачай **moon-merge-release-apk** из Artifacts

### Локально (нужен Flutter 3.24+)

```bash
flutter pub get
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Структура

```
moon_merge/
├── lib/
│   ├── main.dart                  # Точка входа
│   ├── core/
│   │   ├── constants.dart         # Константы
│   │   └── game_colors.dart       # Цвета
│   ├── models/
│   │   ├── element_type.dart      # Типы элементов
│   │   ├── cell.dart              # Клетка поля
│   │   ├── level_config.dart      # Конфигурация уровня
│   │   ├── game_state.dart        # Состояние игры
│   │   └── player_progress.dart   # Прогресс игрока
│   ├── game/
│   │   ├── board_engine.dart      # Движок поля (swap, match, gravity)
│   │   └── level_manager.dart     # Менеджер уровней + power-ups
│   ├── data/
│   │   └── levels_data.dart       # Все 30 уровней
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── main_menu_screen.dart
│   │   ├── map_screen.dart
│   │   ├── game_screen.dart
│   │   ├── level_complete_screen.dart
│   │   ├── daily_screen.dart
│   │   └── shop_screen.dart
│   ├── widgets/
│   │   ├── game_board_widget.dart
│   │   ├── game_cell_widget.dart
│   │   ├── moon_phase_widget.dart
│   │   ├── top_bar_widget.dart
│   │   └── power_up_bar.dart
│   └── services/
│       └── save_service.dart
├── android/                       # Android конфигурация
├── .github/workflows/build.yml    # GitHub Actions
└── pubspec.yaml
```
