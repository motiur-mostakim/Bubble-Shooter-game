import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class GameHud extends StatelessWidget {
  final int levelId;
  final int score;
  final int remainingMoves;
  final int targetScore;
  final VoidCallback onPausePressed;

  const GameHud({
    super.key,
    required this.levelId,
    required this.score,
    required this.remainingMoves,
    required this.targetScore,
    required this.onPausePressed,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (score / targetScore).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.pause_circle_filled,
                    color: Colors.white, size: 36),
                onPressed: onPausePressed,
              ),

              Column(
                children: [
                  Text('LEVEL $levelId', style: AppTextStyles.subtitle(fontSize: 18)),
                  Text(
                    'Score: $score',
                    style: const TextStyle(
                      color: AppColors.coinGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amberAccent, width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'MOVES',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$remainingMoves',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Target Score Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.coinGold),
            ),
          ),
        ],
      ),
    );
  }
}
