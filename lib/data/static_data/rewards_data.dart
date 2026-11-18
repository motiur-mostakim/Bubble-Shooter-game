import '../models/daily_reward_model.dart';

class RewardsData {
  static const List<DailyRewardModel> dailyRewards = [
    DailyRewardModel(day: 1, title: 'Day 1', rewardType: RewardType.coins, amount: 100),
    DailyRewardModel(day: 2, title: 'Day 2', rewardType: RewardType.coins, amount: 150),
    DailyRewardModel(day: 3, title: 'Day 3', rewardType: RewardType.gems, amount: 5),
    DailyRewardModel(day: 4, title: 'Day 4', rewardType: RewardType.rainbowBooster, amount: 2),
    DailyRewardModel(day: 5, title: 'Day 5', rewardType: RewardType.coins, amount: 250),
    DailyRewardModel(day: 6, title: 'Day 6', rewardType: RewardType.bombBooster, amount: 2),
    DailyRewardModel(day: 7, title: 'Day 7 Jackpot', rewardType: RewardType.gems, amount: 25),
  ];
}
