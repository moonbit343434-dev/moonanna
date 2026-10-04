import 'package:flutter/material.dart';
import '../models/player_progress.dart';
import '../models/game_state.dart';
import '../services/save_service.dart';
import '../core/game_colors.dart';

class ShopScreen extends StatefulWidget {
  final PlayerProgress progress;
  const ShopScreen({super.key, required this.progress});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  static const List<Map<String, dynamic>> _coinPacks = [
    {'amount': 200, 'price': 'Free (Ad)', 'free': true, 'icon': '📦'},
    {'amount': 500, 'crystals': 10, 'icon': '💎'},
    {'amount': 1000, 'crystals': 18, 'icon': '💎💎'},
    {'amount': 3000, 'crystals': 50, 'icon': '💎💎💎'},
  ];

  static const List<Map<String, dynamic>> _powerUpShop = [
    {
      'key': 'moonHammer',
      'type': PowerUpType.moonHammer,
      'coins': 100,
      'amount': 1,
    },
    {'key': 'comet', 'type': PowerUpType.comet, 'coins': 150, 'amount': 1},
    {
      'key': 'gravitySwitch',
      'type': PowerUpType.gravitySwitch,
      'coins': 200,
      'amount': 1,
    },
    {
      'key': 'fullMoonBoost',
      'type': PowerUpType.fullMoonBoost,
      'crystals': 5,
      'amount': 1,
    },
    {
      'key': 'starRay',
      'type': PowerUpType.starRay,
      'coins': 180,
      'amount': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('💰 COINS'),
                    const SizedBox(height: 10),
                    ..._coinPacks.map(_buildCoinPack),
                    const SizedBox(height: 20),
                    _sectionTitle('⚡ POWER-UPS'),
                    const SizedBox(height: 10),
                    ..._powerUpShop.map(_buildPowerUpItem),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios,
                color: GameColors.textSecondary),
          ),
          const Spacer(),
          const Text(
            '🛒 SHOP',
            style: TextStyle(
              color: GameColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          _currencyBadge('🪙', '${widget.progress.coins}', GameColors.gold),
          const SizedBox(width: 8),
          _currencyBadge('💎', '${widget.progress.crystals}', GameColors.accent),
        ],
      ),
    );
  }

  Widget _currencyBadge(String icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: GameColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildCoinPack(Map<String, dynamic> pack) {
    final isFree = pack['free'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: GameColors.boardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GameColors.primary.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Text(pack['icon'] as String,
            style: const TextStyle(fontSize: 28)),
        title: Text(
          '+${pack['amount']} Coins',
          style: const TextStyle(
            color: GameColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          isFree ? 'Watch an ad' : 'Pay with crystals',
          style: const TextStyle(color: GameColors.textSecondary, fontSize: 12),
        ),
        trailing: ElevatedButton(
          onPressed: () => _buyCoinPack(pack),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFree ? Colors.green.shade700 : GameColors.accent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Text(
            isFree ? 'FREE' : '${pack['crystals']} 💎',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPowerUpItem(Map<String, dynamic> item) {
    final type = item['type'] as PowerUpType;
    final hasCoinPrice = item.containsKey('coins');
    final price = hasCoinPrice ? '${item['coins']} 🪙' : '${item['crystals']} 💎';
    final current = widget.progress.powerUps[item['key'] as String] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: GameColors.boardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GameColors.primary.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GameColors.primary.withOpacity(0.2),
          ),
          child: Center(
            child: Text(type.emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Text(
          type.label.replaceAll('\n', ' '),
          style: const TextStyle(
            color: GameColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          'Owned: $current',
          style: const TextStyle(color: GameColors.textSecondary, fontSize: 11),
        ),
        trailing: ElevatedButton(
          onPressed: () => _buyPowerUp(item),
          style: ElevatedButton.styleFrom(
            backgroundColor: GameColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _buyCoinPack(Map<String, dynamic> pack) {
    final isFree = pack['free'] == true;
    if (isFree) {
      // Симуляция рекламы
      setState(() {
        widget.progress.coins += pack['amount'] as int;
      });
      SaveService().save(widget.progress);
      _showSuccess('+${pack['amount']} coins!');
    } else {
      final cost = pack['crystals'] as int;
      if (widget.progress.crystals >= cost) {
        setState(() {
          widget.progress.crystals -= cost;
          widget.progress.coins += pack['amount'] as int;
        });
        SaveService().save(widget.progress);
        _showSuccess('+${pack['amount']} coins!');
      } else {
        _showError('Not enough crystals!');
      }
    }
  }

  void _buyPowerUp(Map<String, dynamic> item) {
    final hasCoinPrice = item.containsKey('coins');
    if (hasCoinPrice) {
      final cost = item['coins'] as int;
      if (widget.progress.coins >= cost) {
        setState(() {
          widget.progress.coins -= cost;
          widget.progress.powerUps[item['key'] as String] =
              (widget.progress.powerUps[item['key'] as String] ?? 0) + 1;
        });
        SaveService().save(widget.progress);
        final type = item['type'] as PowerUpType;
        _showSuccess('${type.emoji} +1 ${type.label.replaceAll('\n', ' ')}!');
      } else {
        _showError('Not enough coins!');
      }
    } else {
      final cost = item['crystals'] as int;
      if (widget.progress.crystals >= cost) {
        setState(() {
          widget.progress.crystals -= cost;
          widget.progress.powerUps[item['key'] as String] =
              (widget.progress.powerUps[item['key'] as String] ?? 0) + 1;
        });
        SaveService().save(widget.progress);
        final type = item['type'] as PowerUpType;
        _showSuccess('${type.emoji} +1 ${type.label.replaceAll('\n', ' ')}!');
      } else {
        _showError('Not enough crystals!');
      }
    }
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.green.shade700,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade700,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }
}
