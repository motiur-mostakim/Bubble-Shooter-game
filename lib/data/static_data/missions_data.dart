import '../models/mission_model.dart';

class MissionsData {
  static const List<MissionModel> dailyMissions = [
    MissionModel(
      id: 'mission_complete_levels',
      title: 'Level Master',
      description: 'Complete 3 levels',
      type: MissionType.completeLevels,
      targetCount: 3,
      rewardCoins: 150,
      rewardGems: 2,
    ),
    MissionModel(
      id: 'mission_pop_bubbles',
      title: 'Bubble Popper',
      description: 'Pop 50 bubbles',
      type: MissionType.popBubbles,
      targetCount: 50,
      rewardCoins: 100,
      rewardGems: 1,
    ),
    MissionModel(
      id: 'mission_earn_stars',
      title: 'Star Collector',
      description: 'Earn 6 stars in gameplay',
      type: MissionType.earnStars,
      targetCount: 6,
      rewardCoins: 200,
      rewardGems: 3,
    ),
    MissionModel(
      id: 'mission_use_powerups',
      title: 'Power-up Fanatic',
      description: 'Use 2 power-ups in any level',
      type: MissionType.usePowerUps,
      targetCount: 2,
      rewardCoins: 120,
      rewardGems: 2,
    ),
  ];
}
