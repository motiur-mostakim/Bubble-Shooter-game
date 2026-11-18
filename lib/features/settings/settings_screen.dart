import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/glossy_button.dart';
import '../../data/models/player_data.dart';
import '../../data/repositories/player_repository.dart';

class SettingsScreen extends StatefulWidget {
  final PlayerRepository playerRepository;

  const SettingsScreen({super.key, required this.playerRepository});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  Future<void> _toggleSound(bool val) async {
    final updated = _player.copyWith(soundEnabled: val);
    await widget.playerRepository.savePlayer(updated);
    AudioService.instance.updateSettings(sound: val);
    _loadPlayer();
  }

  Future<void> _toggleMusic(bool val) async {
    final updated = _player.copyWith(musicEnabled: val);
    await widget.playerRepository.savePlayer(updated);
    AudioService.instance.updateSettings(music: val);
    _loadPlayer();
  }

  Future<void> _toggleHaptics(bool val) async {
    final updated = _player.copyWith(hapticsEnabled: val);
    await widget.playerRepository.savePlayer(updated);
    AudioService.instance.updateSettings(haptics: val);
    _loadPlayer();
  }

  Future<void> _confirmResetProgress() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: CustomCard(
          borderColor: Colors.redAccent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('RESET PROGRESS?',
                  style: AppTextStyles.title(fontSize: 22, color: Colors.redAccent)),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to reset all coins, stars, unlocked themes, and level progress? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GlossyButton(
                    label: 'CANCEL',
                    width: 100,
                    height: 40,
                    fontSize: 13,
                    gradientColors: const [Colors.grey, Colors.blueGrey],
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                  GlossyButton(
                    label: 'RESET',
                    width: 100,
                    height: 40,
                    fontSize: 13,
                    gradientColors: const [Color(0xFFEF5350), Color(0xFFC62828)],
                    onPressed: () => Navigator.of(ctx).pop(true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      await widget.playerRepository.resetProgress();
      await _loadPlayer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game progress reset successfully.')),
        );
      }
    }
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
                    Text('SETTINGS', style: AppTextStyles.title(fontSize: 24)),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    CustomCard(
                      child: Column(
                        children: [
                          SwitchListTile(
                            activeTrackColor: AppColors.coinGold,
                            title: Text('Sound Effects', style: AppTextStyles.subtitle(fontSize: 16)),
                            subtitle: Text('In-game popping and pop effects', style: AppTextStyles.body(fontSize: 12)),
                            value: _player.soundEnabled,
                            onChanged: _toggleSound,
                          ),
                          const Divider(color: Colors.white24),
                          SwitchListTile(
                            activeTrackColor: AppColors.coinGold,
                            title: Text('Background Music', style: AppTextStyles.subtitle(fontSize: 16)),
                            subtitle: Text('Atmospheric background music', style: AppTextStyles.body(fontSize: 12)),
                            value: _player.musicEnabled,
                            onChanged: _toggleMusic,
                          ),
                          const Divider(color: Colors.white24),
                          SwitchListTile(
                            activeTrackColor: AppColors.coinGold,
                            title: Text('Haptic Feedback', style: AppTextStyles.subtitle(fontSize: 16)),
                            subtitle: Text('Device vibration feedback on shoot/pop', style: AppTextStyles.body(fontSize: 12)),
                            value: _player.hapticsEnabled,
                            onChanged: _toggleHaptics,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    CustomCard(
                      borderColor: Colors.redAccent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Danger Zone', style: AppTextStyles.subtitle(fontSize: 18, color: Colors.redAccent)),
                          const SizedBox(height: 6),
                          Text(
                            'Wipe all local save data and restore game to default state.',
                            style: AppTextStyles.body(fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          GlossyButton(
                            label: 'RESET GAME PROGRESS',
                            icon: Icons.delete_forever,
                            width: double.infinity,
                            height: 48,
                            gradientColors: const [Color(0xFFEF5350), Color(0xFFC62828)],
                            onPressed: _confirmResetProgress,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    Center(
                      child: Column(
                        children: [
                          Text('Bubble Quest v1.0.0', style: AppTextStyles.body(color: Colors.white38)),
                          const SizedBox(height: 4),
                          Text('Offline Casual Mobile Game', style: AppTextStyles.body(color: Colors.white24, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
