import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/glossy_button.dart';
import '../../../core/widgets/star_rating_bar.dart';

class WinDialog extends StatelessWidget {
  final int score;
  final int stars;
  final int coinsEarned;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const WinDialog({
    super.key,
    required this.score,
    required this.stars,
    required this.coinsEarned,
    required this.onNextLevel,
    required this.onReplay,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: CustomCard(
        borderColor: AppColors.coinGold,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('LEVEL CLEARED!', style: AppTextStyles.title(fontSize: 26, color: AppColors.coinGold)),
            const SizedBox(height: 16),

            StarRatingBar(stars: stars, starSize: 36),
            const SizedBox(height: 16),

            Text('Final Score: $score', style: AppTextStyles.subtitle(fontSize: 20)),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: AppColors.coinGold, size: 24),
                const SizedBox(width: 6),
                Text('+$coinsEarned Coins', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 24),

            GlossyButton(
              label: 'NEXT LEVEL',
              icon: Icons.navigate_next,
              width: 200,
              height: 52,
              onPressed: onNextLevel,
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 32),
                  onPressed: onReplay,
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white, size: 32),
                  onPressed: onHome,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
