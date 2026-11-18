import 'package:flutter/material.dart';
import '../../../data/models/bubble_type.dart';
import '../../../data/models/player_data.dart';

class PowerUpsBar extends StatelessWidget {
  final PlayerData playerData;
  final Function(BubbleColor) onUsePowerUp;
  final VoidCallback onSwapBubbles;

  const PowerUpsBar({
    super.key,
    required this.playerData,
    required this.onUsePowerUp,
    required this.onSwapBubbles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPowerUpItem(
            icon: Icons.swap_horizontal_circle,
            color: Colors.purpleAccent,
            label: 'Swap',
            count: 99, // unlimited swap
            onTap: onSwapBubbles,
          ),
          _buildPowerUpItem(
            icon: Icons.color_lens,
            color: Colors.redAccent,
            label: 'Rainbow',
            count: playerData.rainbowBoosters,
            onTap: () => onUsePowerUp(BubbleColor.rainbow),
          ),
          _buildPowerUpItem(
            icon: Icons.local_fire_department,
            color: Colors.orangeAccent,
            label: 'Bomb',
            count: playerData.bombBoosters,
            onTap: () => onUsePowerUp(BubbleColor.bomb),
          ),
          _buildPowerUpItem(
            icon: Icons.bolt,
            color: Colors.amber,
            label: 'Zap',
            count: playerData.lightningBoosters,
            onTap: () => onUsePowerUp(BubbleColor.lightning),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpItem({
    required IconData icon,
    required Color color,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: count > 0 ? onTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: count > 0
                  ? color.withValues(alpha: 0.25)
                  : Colors.grey.withValues(alpha: 0.2),
              border: Border.all(
                color: count > 0 ? color : Colors.grey,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: count > 0 ? color : Colors.grey,
              size: 28,
            ),
          ),
          if (count < 99)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
