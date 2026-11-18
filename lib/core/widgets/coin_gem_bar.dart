import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class CoinGemBar extends StatelessWidget {
  final int coins;
  final int gems;
  final VoidCallback? onAddCoins;
  final VoidCallback? onAddGems;

  const CoinGemBar({
    super.key,
    required this.coins,
    required this.gems,
    this.onAddCoins,
    this.onAddGems,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPill(
          icon: Icons.monetization_on,
          iconColor: AppColors.coinGold,
          value: '$coins',
          onAdd: onAddCoins,
        ),
        const SizedBox(width: 12),
        _buildPill(
          icon: Icons.diamond,
          iconColor: AppColors.gemCyan,
          value: '$gems',
          onAdd: onAddGems,
        ),
      ],
    );
  }

  Widget _buildPill({
    required IconData icon,
    required Color iconColor,
    required String value,
    VoidCallback? onAdd,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (onAdd != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
