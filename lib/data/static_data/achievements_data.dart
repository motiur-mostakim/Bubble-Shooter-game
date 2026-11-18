import '../models/achievement_model.dart';

class AchievementsData {
  static const List<AchievementModel> achievements = [
    AchievementModel(
      id: 'ach_first_victory',
      title: 'First Victory',
      description: 'Clear your first level',
      iconName: 'trophy',
      targetCount: 1,
      rewardCoins: 200,
      rewardGems: 5,
    ),
    AchievementModel(
      id: 'ach_bubble_master',
      title: 'Bubble Master',
      description: 'Pop 200 total bubbles',
      iconName: 'burst',
      targetCount: 200,
      rewardCoins: 500,
      rewardGems: 10,
    ),
    AchievementModel(
      id: 'ach_level_explorer',
      title: 'Level Explorer',
      description: 'Complete 10 levels',
      iconName: 'map',
      targetCount: 10,
      rewardCoins: 600,
      rewardGems: 15,
    ),
    AchievementModel(
      id: 'ach_star_collector',
      title: 'Star Collector',
      description: 'Collect 25 stars overall',
      iconName: 'star',
      targetCount: 25,
      rewardCoins: 800,
      rewardGems: 20,
    ),
    AchievementModel(
      id: 'ach_world_explorer',
      title: 'World Explorer',
      description: 'Unlock 3 worlds',
      iconName: 'globe',
      targetCount: 3,
      rewardCoins: 1000,
      rewardGems: 25,
    ),
  ];
}
