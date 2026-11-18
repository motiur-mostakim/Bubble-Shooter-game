import 'bubble_type.dart';

class LevelConfig {
  final int id;
  final int worldId;
  final String title;
  final String difficulty;
  final int maxMoves;
  final int targetScore;
  final List<BubbleColor> availableColors;
  final Map<String, BubbleColor> initialBubbles; // key: "row_col"
  final List<int> starThresholds;

  const LevelConfig({
    required this.id,
    required this.worldId,
    required this.title,
    required this.difficulty,
    required this.maxMoves,
    required this.targetScore,
    required this.availableColors,
    required this.initialBubbles,
    required this.starThresholds,
  });

  int calculateStars(int score) {
    if (score >= starThresholds[2]) return 3;
    if (score >= starThresholds[1]) return 2;
    if (score >= starThresholds[0]) return 1;
    return 0;
  }
}
