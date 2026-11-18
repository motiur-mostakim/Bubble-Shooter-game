import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/glossy_button.dart';
import '../../data/models/mission_model.dart';
import '../../data/models/player_data.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/static_data/missions_data.dart';

class MissionsScreen extends StatefulWidget {
  final PlayerRepository playerRepository;

  const MissionsScreen({super.key, required this.playerRepository});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
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

  int _getMissionProgress(MissionModel mission) {
    switch (mission.type) {
      case MissionType.completeLevels:
        return _player.levelStars.length;
      case MissionType.popBubbles:
        return (_player.levelStars.length * 25).clamp(0, mission.targetCount);
      case MissionType.earnStars:
        int stars = 0;
        _player.levelStars.forEach((_, s) => stars += s);
        return stars;
      case MissionType.usePowerUps:
        return 2;
      case MissionType.winWithoutFailing:
        return 1;
    }
  }

  Future<void> _claimMissionReward(MissionModel mission) async {
    final completed = List<String>.from(_player.completedMissions)..add(mission.id);
    final updated = _player.copyWith(
      coins: _player.coins + mission.rewardCoins,
      gems: _player.gems + mission.rewardGems,
      completedMissions: completed,
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
                    Text('DAILY MISSIONS', style: AppTextStyles.title(fontSize: 24)),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: MissionsData.dailyMissions.length,
                  itemBuilder: (context, index) {
                    final mission = MissionsData.dailyMissions[index];
                    final progress = _getMissionProgress(mission);
                    final isCompleted = progress >= mission.targetCount;
                    final isClaimed = _player.completedMissions.contains(mission.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  mission.title,
                                  style: AppTextStyles.subtitle(fontSize: 18),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.monetization_on,
                                        color: AppColors.coinGold, size: 18),
                                    Text('+${mission.rewardCoins}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.diamond,
                                        color: AppColors.gemCyan, size: 18),
                                    Text('+${mission.rewardGems}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(mission.description, style: AppTextStyles.body()),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: (progress / mission.targetCount)
                                          .clamp(0.0, 1.0),
                                      minHeight: 12,
                                      backgroundColor: Colors.white24,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              AppColors.buttonGreenStart),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('$progress/${mission.targetCount}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (isClaimed)
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Text('CLAIMED',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold)),
                              )
                            else if (isCompleted)
                              Align(
                                alignment: Alignment.centerRight,
                                child: GlossyButton(
                                  label: 'CLAIM',
                                  width: 100,
                                  height: 36,
                                  fontSize: 13,
                                  onPressed: () => _claimMissionReward(mission),
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
