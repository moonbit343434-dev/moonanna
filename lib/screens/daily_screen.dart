import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/player_progress.dart';
import '../services/save_service.dart';
import '../core/game_colors.dart';

class DailyScreen extends StatefulWidget {
  final PlayerProgress progress;
  const DailyScreen({super.key, required this.progress});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  static const List<Map<String, dynamic>> _rewards = [
    {'day': 1, 'coins': 50, 'crystals': 0, 'label': '50 🪙'},
    {'day': 2, 'coins': 100, 'crystals': 0, 'label': '100 🪙'},
    {'day': 3, 'coins': 0, 'crystals': 3, 'label': '3 💎'},
    {'day': 4, 'coins': 150, 'crystals': 0, 'label': '150 🪙'},
    {'day': 5, 'coins': 0, 'crystals': 5, 'label': '5 💎'},
    {'day': 6, 'coins': 200, 'crystals': 0, 'label': '200 🪙'},
    {'day': 7, 'coins': 500, 'crystals': 20, 'label': '500 🪙 + 20 💎'},
  ];

  bool _canClaim = false;

  @override
  void initState() {
    super.initState();
    _checkCanClaim();
  }

  void _checkCanClaim() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    _canClaim = widget.progress.lastDailyRewardDate != today;
  }

  void _claim() {
    if (!_canClaim) return;
    final day = (widget.progress.dailyRewardDay % 7) + 1;
    final reward = _rewards[day - 1];
    setState(() {
      widget.progress.coins += reward['coins'] as int;
      widget.progress.crystals += reward['crystals'] as int;
      widget.progress.dailyRewardDay = day;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      widget.progress.lastDailyRewardDate = today;
      _canClaim = false;
    });
    SaveService().save(widget.progress);
    _showClaimedDialog(reward);
  }

  void _showClaimedDialog(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: GameColors.boardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎁', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'Daily Reward!',
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reward['label'] as String,
                style: const TextStyle(
                  color: GameColors.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Awesome!',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDay = (widget.progress.dailyRewardDay % 7);

    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        color: GameColors.textSecondary),
                  ),
                  const Spacer(),
                  const Text(
                    '📅 DAILY REWARDS',
                    style: TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Days grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: 7,
                itemBuilder: (_, i) {
                  final dayData = _rewards[i];
                  final dayNum = dayData['day'] as int;
                  final isClaimed = dayNum <= currentDay;
                  final isToday = dayNum == currentDay + 1 && _canClaim;
                  final isFuture = dayNum > currentDay + 1 ||
                      (dayNum == currentDay + 1 && !_canClaim && !isClaimed);

                  return _DayCard(
                    dayNum: dayNum,
                    label: dayData['label'] as String,
                    isClaimed: isClaimed,
                    isToday: isToday,
                    isFuture: isFuture,
                    isLast: dayNum == 7,
                  )
                      .animate(delay: Duration(milliseconds: i * 80))
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.7, 0.7));
                },
              ),
            ),
            const Spacer(),
            if (_canClaim)
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: _claim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GameColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                  ),
                  child: const Text(
                    '🎁 CLAIM DAILY REWARD',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GameColors.boardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '✅ Already claimed today!\nCome back tomorrow.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: GameColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final int dayNum;
  final String label;
  final bool isClaimed;
  final bool isToday;
  final bool isFuture;
  final bool isLast;

  const _DayCard({
    required this.dayNum,
    required this.label,
    required this.isClaimed,
    required this.isToday,
    required this.isFuture,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    if (isClaimed) {
      borderColor = Colors.green.shade400;
      bgColor = Colors.green.withOpacity(0.15);
    } else if (isToday) {
      borderColor = GameColors.gold;
      bgColor = GameColors.gold.withOpacity(0.15);
    } else {
      borderColor = GameColors.primary.withOpacity(0.3);
      bgColor = GameColors.boardBg;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isToday ? 2 : 1),
        boxShadow: isToday
            ? [BoxShadow(color: GameColors.gold.withOpacity(0.3), blurRadius: 8)]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isClaimed ? '✅' : isLast ? '🎁' : '📦',
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 4),
          Text(
            'Day $dayNum',
            style: TextStyle(
              color: isFuture ? Colors.grey : GameColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isFuture ? Colors.grey.shade600 : GameColors.gold,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
