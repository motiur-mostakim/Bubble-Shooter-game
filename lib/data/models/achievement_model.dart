class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int targetCount;
  final int rewardCoins;
  final int rewardGems;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.targetCount,
    required this.rewardCoins,
    required this.rewardGems,
  });
}
