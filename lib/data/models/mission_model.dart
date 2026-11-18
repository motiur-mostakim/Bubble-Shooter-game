enum MissionType {
  completeLevels,
  popBubbles,
  earnStars,
  usePowerUps,
  winWithoutFailing,
}

class MissionModel {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int targetCount;
  final int rewardCoins;
  final int rewardGems;

  const MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetCount,
    required this.rewardCoins,
    required this.rewardGems,
  });
}
