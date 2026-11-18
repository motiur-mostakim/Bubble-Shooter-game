import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/glossy_button.dart';

class GamePauseDialog extends StatefulWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const GamePauseDialog({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  State<GamePauseDialog> createState() => _GamePauseDialogState();
}

class _GamePauseDialogState extends State<GamePauseDialog> {
  bool soundOn = AudioService.instance.soundEnabled;
  bool musicOn = AudioService.instance.musicEnabled;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: CustomCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('GAME PAUSED', style: AppTextStyles.title(fontSize: 26)),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToggle(
                  icon: soundOn ? Icons.volume_up : Icons.volume_off,
                  label: 'Sound',
                  value: soundOn,
                  onChanged: (val) {
                    setState(() => soundOn = val);
                    AudioService.instance.updateSettings(sound: val);
                  },
                ),
                _buildToggle(
                  icon: musicOn ? Icons.music_note : Icons.music_off,
                  label: 'Music',
                  value: musicOn,
                  onChanged: (val) {
                    setState(() => musicOn = val);
                    AudioService.instance.updateSettings(music: val);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            GlossyButton(
              label: 'RESUME',
              icon: Icons.play_arrow,
              width: 180,
              height: 48,
              onPressed: widget.onResume,
            ),
            const SizedBox(height: 12),

            GlossyButton(
              label: 'RESTART',
              icon: Icons.refresh,
              width: 180,
              height: 44,
              gradientColors: const [Color(0xFFFFA726), Color(0xFFE65100)],
              onPressed: widget.onRestart,
            ),
            const SizedBox(height: 12),

            GlossyButton(
              label: 'QUIT',
              icon: Icons.home,
              width: 180,
              height: 44,
              gradientColors: const [Color(0xFFEF5350), Color(0xFFC62828)],
              onPressed: widget.onQuit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: value ? Colors.amberAccent : Colors.grey, size: 36),
          onPressed: () => onChanged(!value),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
