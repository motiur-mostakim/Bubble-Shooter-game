import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/coin_gem_bar.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/glossy_button.dart';
import '../../data/models/player_data.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/static_data/worlds_data.dart';
import '../achievements/achievements_screen.dart';
import '../daily_rewards/daily_rewards_dialog.dart';
import '../gameplay/screens/game_screen.dart';
import '../missions/missions_screen.dart';
import '../settings/settings_screen.dart';
import '../shop/shop_screen.dart';
import '../themes/theme_selection_screen.dart';
import '../world_map/world_map_screen.dart';

class HomeScreen extends StatefulWidget {
  final PlayerRepository playerRepository;

  const HomeScreen({super.key, required this.playerRepository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  void _onPlayNow() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          levelId: _player.currentLevel,
          playerRepository: widget.playerRepository,
        ),
      ),
    )
        .then((_) => _loadPlayer());
  }

  void _onOpenWorldMap() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => WorldMapScreen(
          playerRepository: widget.playerRepository,
        ),
      ),
    )
        .then((_) => _loadPlayer());
  }

  void _openDailyRewards() {
    showDialog(
      context: context,
      builder: (_) => DailyRewardsDialog(
        playerRepository: widget.playerRepository,
        onClaimed: _loadPlayer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWorldId = ((_player.currentLevel - 1) ~/ 5) + 1;
    final world = WorldsData.worlds.firstWhere(
      (w) => w.id == currentWorldId,
      orElse: () => WorldsData.worlds.first,
    );

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
              // Top HUD
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CoinGemBar(
                      coins: _player.coins,
                      gems: _player.gems,
                      onAddCoins: () => _openShop(),
                      onAddGems: () => _openShop(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => SettingsScreen(
                                  playerRepository: widget.playerRepository,
                                ),
                              ),
                            )
                            .then((_) => _loadPlayer());
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Game Logo Header
              Text(
                'BUBBLE QUEST',
                style: AppTextStyles.title(fontSize: 34),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: world.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: world.accentColor),
                ),
                child: Text(
                  'World $currentWorldId: ${world.name}',
                  style: TextStyle(
                    color: world.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              // World Preview Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: CustomCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: world.backgroundGradient,
                              ),
                              border: Border.all(
                                  color: AppColors.cardBorder, width: 2),
                            ),
                            child: const Icon(Icons.stars,
                                color: Colors.amberAccent, size: 36),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CURRENT LEVEL ${_player.currentLevel}',
                                  style: AppTextStyles.subtitle(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  world.description,
                                  style: AppTextStyles.body(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GlossyButton(
                        label: 'PLAY NOW',
                        icon: Icons.play_arrow,
                        width: double.infinity,
                        height: 56,
                        gradientColors: const [
                          Color(0xFF66BB6A),
                          Color(0xFF2E7D32)
                        ],
                        onPressed: _onPlayNow,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // World Map Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GlossyButton(
                  label: 'WORLD MAP',
                  icon: Icons.map,
                  width: double.infinity,
                  height: 48,
                  gradientColors: const [
                    Color(0xFF29B6F6),
                    Color(0xFF0277BD)
                  ],
                  onPressed: _onOpenWorldMap,
                ),
              ),

              const Spacer(),

              // Bottom Grid Shortcuts
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavButton(
                      icon: Icons.card_giftcard,
                      label: 'Rewards',
                      color: Colors.amber,
                      onTap: _openDailyRewards,
                    ),
                    _buildNavButton(
                      icon: Icons.palette,
                      label: 'Themes',
                      color: Colors.purpleAccent,
                      onTap: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => ThemeSelectionScreen(
                                  playerRepository: widget.playerRepository,
                                ),
                              ),
                            )
                            .then((_) => _loadPlayer());
                      },
                    ),
                    _buildNavButton(
                      icon: Icons.assignment_turned_in,
                      label: 'Missions',
                      color: Colors.greenAccent,
                      onTap: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => MissionsScreen(
                                  playerRepository: widget.playerRepository,
                                ),
                              ),
                            )
                            .then((_) => _loadPlayer());
                      },
                    ),
                    _buildNavButton(
                      icon: Icons.emoji_events,
                      label: 'Badges',
                      color: Colors.orangeAccent,
                      onTap: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => AchievementsScreen(
                                  playerRepository: widget.playerRepository,
                                ),
                              ),
                            )
                            .then((_) => _loadPlayer());
                      },
                    ),
                    _buildNavButton(
                      icon: Icons.store,
                      label: 'Shop',
                      color: Colors.cyanAccent,
                      onTap: _openShop,
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

  void _openShop() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => ShopScreen(
              playerRepository: widget.playerRepository,
            ),
          ),
        )
        .then((_) => _loadPlayer());
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
