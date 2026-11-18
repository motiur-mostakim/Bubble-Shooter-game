import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/coin_gem_bar.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/glossy_button.dart';
import '../../data/models/player_data.dart';
import '../../data/repositories/player_repository.dart';

class ShopScreen extends StatefulWidget {
  final PlayerRepository playerRepository;

  const ShopScreen({super.key, required this.playerRepository});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  PlayerData _player = const PlayerData();

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  Future<void> _loadPlayer() async {
    final player = await widget.playerRepository.loadPlayer();
    setState(() => _player = player);
  }

  Future<void> _buyBooster(String type, int costGems, int amount) async {
    if (_player.gems >= costGems) {
      int rB = _player.rainbowBoosters;
      int bB = _player.bombBoosters;
      int lB = _player.lightningBoosters;

      if (type == 'rainbow') rB += amount;
      if (type == 'bomb') bB += amount;
      if (type == 'lightning') lB += amount;

      final updated = _player.copyWith(
        gems: _player.gems - costGems,
        rainbowBoosters: rB,
        bombBoosters: bB,
        lightningBoosters: lB,
      );

      await widget.playerRepository.savePlayer(updated);
      _loadPlayer();
    }
  }

  Future<void> _exchangeCoinsForGems(int coinsCost, int gemsGained) async {
    if (_player.coins >= coinsCost) {
      final updated = _player.copyWith(
        coins: _player.coins - coinsCost,
        gems: _player.gems + gemsGained,
      );
      await widget.playerRepository.savePlayer(updated);
      _loadPlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.mainBackgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text('ITEM SHOP', style: AppTextStyles.title(fontSize: 24)),
                    CoinGemBar(coins: _player.coins, gems: _player.gems),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    Text('Booster Packs', style: AppTextStyles.subtitle(fontSize: 20)),
                    const SizedBox(height: 12),
                    _buildShopTile(
                      icon: Icons.color_lens,
                      iconColor: Colors.redAccent,
                      title: 'x3 Rainbow Boosters',
                      subtitle: 'Matches any bubble color',
                      costText: '10 Gems',
                      onBuy: () => _buyBooster('rainbow', 10, 3),
                    ),
                    const SizedBox(height: 12),
                    _buildShopTile(
                      icon: Icons.local_fire_department,
                      iconColor: Colors.orangeAccent,
                      title: 'x3 Bomb Boosters',
                      subtitle: 'Explodes all surrounding bubbles',
                      costText: '10 Gems',
                      onBuy: () => _buyBooster('bomb', 10, 3),
                    ),
                    const SizedBox(height: 12),
                    _buildShopTile(
                      icon: Icons.bolt,
                      iconColor: Colors.amber,
                      title: 'x3 Lightning Boosters',
                      subtitle: 'Clears an entire horizontal row',
                      costText: '10 Gems',
                      onBuy: () => _buyBooster('lightning', 10, 3),
                    ),
                    const SizedBox(height: 24),

                    Text('Currency Exchange', style: AppTextStyles.subtitle(fontSize: 20)),
                    const SizedBox(height: 12),
                    _buildShopTile(
                      icon: Icons.diamond,
                      iconColor: AppColors.gemCyan,
                      title: '5 Gems',
                      subtitle: 'Exchange 300 Coins for 5 Gems',
                      costText: '300 Coins',
                      onBuy: () => _exchangeCoinsForGems(300, 5),
                    ),
                    const SizedBox(height: 12),
                    _buildShopTile(
                      icon: Icons.diamond,
                      iconColor: AppColors.gemCyan,
                      title: '20 Gems (Best Value!)',
                      subtitle: 'Exchange 1000 Coins for 20 Gems',
                      costText: '1000 Coins',
                      onBuy: () => _exchangeCoinsForGems(1000, 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String costText,
    required VoidCallback onBuy,
  }) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor, width: 2),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle(fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.body(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GlossyButton(
            label: costText,
            width: 110,
            height: 40,
            fontSize: 12,
            gradientColors: const [Color(0xFFFFA726), Color(0xFFE65100)],
            onPressed: onBuy,
          ),
        ],
      ),
    );
  }
}
