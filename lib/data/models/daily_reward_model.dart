enum RewardType { coins, gems, rainbowBooster, bombBooster, lightningBooster }

class DailyRewardModel {
  final int day;
  final String title;
  final RewardType rewardType;
  final int amount;

  const DailyRewardModel({
    required this.day,
    required this.title,
    required this.rewardType,
    required this.amount,
  });
}
