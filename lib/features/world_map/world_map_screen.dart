import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/custom_card.dart';
import '../../data/models/player_data.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/static_data/worlds_data.dart';
import '../level_selection/level_selection_screen.dart';

class WorldMapScreen extends StatefulWidget {
  final PlayerRepository playerRepository;

  const WorldMapScreen({super.key, required this.playerRepository});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
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

  int _calculateTotalStars() {
    int total = 0;
    _player.levelStars.forEach((_, stars) {
      total += stars;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalStars = _calculateTotalStars();

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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text('WORLD MAP', style: AppTextStyles.title(fontSize: 24)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amberAccent),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amberAccent, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$totalStars Stars',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: WorldsData.worlds.length,
                  itemBuilder: (context, index) {
                    final world = WorldsData.worlds[index];
                    final isUnlocked = _player.unlockedWorlds.contains(world.id) ||
                        totalStars >= world.requiredStarsToUnlock;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onTap: isUnlocked
                            ? () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (_) => LevelSelectionScreen(
                                          world: world,
                                          playerRepository: widget.playerRepository,
                                        ),
                                      ),
                                    )
                                    .then((_) => _loadPlayer());
                              }
                            : null,
                        child: CustomCard(
                          borderColor: isUnlocked
                              ? world.accentColor
                              : Colors.grey.shade700,
                          backgroundColor: isUnlocked
                              ? AppColors.cardBg
                              : Colors.black.withValues(alpha: 0.6),
                          child: Row(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: isUnlocked
                                        ? world.backgroundGradient
                                        : [Colors.grey.shade800, Colors.grey.shade900],
                                  ),
                                  border: Border.all(
                                    color: isUnlocked ? world.accentColor : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  isUnlocked ? Icons.landscape : Icons.lock,
                                  color: isUnlocked ? world.accentColor : Colors.grey,
                                  size: 34,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'World ${world.id}: ${world.name}',
                                      style: AppTextStyles.subtitle(
                                        color: isUnlocked
                                            ? Colors.white
                                            : Colors.grey,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      world.description,
                                      style: AppTextStyles.body(
                                        color: isUnlocked
                                            ? Colors.white70
                                            : Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Levels ${world.startLevel} - ${world.endLevel}',
                                      style: TextStyle(
                                        color: world.accentColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isUnlocked)
                                Column(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    Text(
                                      '${world.requiredStarsToUnlock} Stars',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
