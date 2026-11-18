import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/glossy_button.dart';

class LoseDialog extends StatelessWidget {
  final int score;
  final bool canBuyMoves;
  final VoidCallback onBuyExtraMoves;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  const LoseDialog({
    super.key,
    required this.score,
    required this.canBuyMoves,
    required this.onBuyExtraMoves,
    required this.onRetry,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: CustomCard(
        borderColor: Colors.redAccent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('OUT OF MOVES!', style: AppTextStyles.title(fontSize: 26, color: Colors.redAccent)),
            const SizedBox(height: 12),

            Text('Score: $score', style: AppTextStyles.subtitle(fontSize: 18)),
            const SizedBox(height: 20),

            if (canBuyMoves) ...[
              GlossyButton(
                label: '+5 MOVES (100 Coins)',
                icon: Icons.add_circle_outline,
                width: 220,
                height: 48,
                gradientColors: const [Color(0xFFFFA726), Color(0xFFE65100)],
                onPressed: onBuyExtraMoves,
              ),
              const SizedBox(height: 12),
            ],

            GlossyButton(
              label: 'RETRY',
              icon: Icons.refresh,
              width: 220,
              height: 48,
              onPressed: onRetry,
            ),
            const SizedBox(height: 12),

            IconButton(
              icon: const Icon(Icons.home, color: Colors.white, size: 32),
              onPressed: onHome,
            ),
          ],
        ),
      ),
    );
  }
}
