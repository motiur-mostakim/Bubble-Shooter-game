import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/glossy_button.dart';
import '../../data/models/daily_reward_model.dart';
import '../../data/models/player_data.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/static_data/rewards_data.dart';

class DailyRewardsDialog extends StatefulWidget {
  final PlayerRepository playerRepository;
  final VoidCallback onClaimed;

  const DailyRewardsDialog({
    super.key,
    required this.playerRepository,
    required this.onClaimed,
  });

  @override
  State<DailyRewardsDialog> createState() => _DailyRewardsDialogState();
}

class _DailyRewardsDialogState extends State<DailyRewardsDialog> {
  PlayerData _player = const PlayerData();
  bool _canClaimToday = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final player = await widget.playerRepository.loadPlayer();
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final canClaim = player.lastDailyRewardClaimDate != todayStr;

    setState(() {
      _player = player;
      _canClaimToday = canClaim;
    });
  }

  Future<void> _claimReward() async {
    if (!_canClaimToday) return;

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final currentStreak = (_player.dailyRewardStreak % 7) + 1;
    final reward = RewardsData.dailyRewards[currentStreak - 1];

    int coins = _player.coins;
    int gems = _player.gems;
    int rB = _player.rainbowBoosters;
    int bB = _player.bombBoosters;

    switch (reward.rewardType) {
      case RewardType.coins:
        coins += reward.amount;
        break;
      case RewardType.gems:
        gems += reward.amount;
        break;
      case RewardType.rainbowBooster:
        rB += reward.amount;
        break;
      case RewardType.bombBooster:
        bB += reward.amount;
        break;
      default:
        coins += 100;
        break;
    }

    final updated = _player.copyWith(
      coins: coins,
      gems: gems,
      rainbowBoosters: rB,
      bombBoosters: bB,
      lastDailyRewardClaimDate: todayStr,
      dailyRewardStreak: currentStreak,
    );

    await widget.playerRepository.savePlayer(updated);
    widget.onClaimed();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeDayIndex = (_player.dailyRewardStreak % 7);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: CustomCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('DAILY REWARDS', style: AppTextStyles.title(fontSize: 24)),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.9,
              ),
              itemCount: RewardsData.dailyRewards.length,
              itemBuilder: (context, index) {
                final r = RewardsData.dailyRewards[index];
                final isCurrent = index == activeDayIndex && _canClaimToday;
                final isClaimed = index < activeDayIndex ||
                    (index == activeDayIndex && !_canClaimToday);

                return Container(
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.coinGold.withValues(alpha: 0.2)
                        : Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent ? AppColors.coinGold : Colors.white24,
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        r.title,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        r.rewardType == RewardType.gems
                            ? Icons.diamond
                            : Icons.monetization_on,
                        color: r.rewardType == RewardType.gems
                            ? AppColors.gemCyan
                            : AppColors.coinGold,
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${r.amount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isClaimed)
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 16),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            GlossyButton(
              label: _canClaimToday ? 'CLAIM REWARD' : 'ALREADY CLAIMED',
              width: 200,
              height: 48,
              gradientColors: _canClaimToday
                  ? const [Color(0xFF66BB6A), Color(0xFF2E7D32)]
                  : const [Colors.grey, Colors.blueGrey],
              onPressed: _canClaimToday ? _claimReward : () {},
            ),
          ],
        ),
      ),
    );
  }
}
