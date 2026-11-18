import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/glossy_button.dart';
import '../../data/models/achievement_model.dart';
import '../../data/models/player_data.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/static_data/achievements_data.dart';

class AchievementsScreen extends StatefulWidget {
  final PlayerRepository playerRepository;

  const AchievementsScreen({super.key, required this.playerRepository});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
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

  int _getAchievementProgress(AchievementModel ach) {
    switch (ach.id) {
      case 'ach_first_victory':
        return _player.levelStars.isNotEmpty ? 1 : 0;
      case 'ach_bubble_master':
        return (_player.levelStars.length * 30).clamp(0, ach.targetCount);
      case 'ach_level_explorer':
        return _player.levelStars.length;
      case 'ach_star_collector':
        int stars = 0;
        _player.levelStars.forEach((_, s) => stars += s);
        return stars;
      case 'ach_world_explorer':
        return _player.unlockedWorlds.length;
      default:
        return 0;
    }
  }

  Future<void> _claimAchievement(AchievementModel ach) async {
    final unlocked = List<String>.from(_player.unlockedAchievements)..add(ach.id);
    final updated = _player.copyWith(
      coins: _player.coins + ach.rewardCoins,
      gems: _player.gems + ach.rewardGems,
      unlockedAchievements: unlocked,
    );
    await widget.playerRepository.savePlayer(updated);
    _loadPlayer();
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
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text('ACHIEVEMENTS', style: AppTextStyles.title(fontSize: 24)),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: AchievementsData.achievements.length,
                  itemBuilder: (context, index) {
                    final ach = AchievementsData.achievements[index];
                    final progress = _getAchievementProgress(ach);
                    final isUnlocked = progress >= ach.targetCount;
                    final isClaimed = _player.unlockedAchievements.contains(ach.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CustomCard(
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isUnlocked
                                    ? Colors.amber.withValues(alpha: 0.2)
                                    : Colors.black38,
                                border: Border.all(
                                  color: isUnlocked ? Colors.amber : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                isUnlocked ? Icons.emoji_events : Icons.lock,
                                color: isUnlocked ? Colors.amber : Colors.grey,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ach.title,
                                    style: AppTextStyles.subtitle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    ach.description,
                                    style: AppTextStyles.body(fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: (progress / ach.targetCount)
                                          .clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: Colors.white24,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              AppColors.coinGold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (isClaimed)
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 24)
                            else if (isUnlocked)
                              GlossyButton(
                                label: 'CLAIM',
                                width: 80,
                                height: 36,
                                fontSize: 12,
                                onPressed: () => _claimAchievement(ach),
                              )
                            else
                              Text(
                                '$progress/${ach.targetCount}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
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
