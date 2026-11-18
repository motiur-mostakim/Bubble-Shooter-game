import '../models/bubble_type.dart';
import '../models/level_config.dart';

class LevelsData {
  static List<LevelConfig> getAllLevels() {
    return List.generate(30, (index) {
      final levelId = index + 1;
      return _generateLevel(levelId);
    });
  }

  static LevelConfig getLevel(int levelId) {
    if (levelId < 1) levelId = 1;
    if (levelId > 30) levelId = 30;
    return _generateLevel(levelId);
  }

  static LevelConfig _generateLevel(int levelId) {
    int worldId = ((levelId - 1) ~/ 5) + 1;
    if (worldId > 6) worldId = 6;

    String difficulty = 'Easy';
    if (levelId > 10 && levelId <= 20) difficulty = 'Normal';
    if (levelId > 20) difficulty = 'Medium';

    int maxMoves = 30 - (levelId ~/ 3);
    if (maxMoves < 15) maxMoves = 15;

    final palette = [
      BubbleColor.red,
      BubbleColor.blue,
      BubbleColor.green,
      BubbleColor.purple,
      BubbleColor.yellow,
      BubbleColor.orange,
    ];

    // Generate dense initial grid: 6 to 9 staggered hexagonal rows
    final numRows = 7 + (levelId % 3);
    final initialBubbles = <String, BubbleColor>{};

    for (int r = 0; r < numRows; r++) {
      final numCols = (r % 2 == 0) ? 8 : 7;
      for (int c = 0; c < numCols; c++) {
        int colorIdx = (r + (c ~/ 2)) % palette.length;
        BubbleColor col = palette[colorIdx];

        // Metallic dark-gray special bubble placement
        if (r == 3 && c == 3) {
          col = BubbleColor.stone;
        } else if (levelId >= 3 && r == 1 && c == 4) {
          col = BubbleColor.bomb;
        } else if (levelId >= 7 && r == 4 && c == 2) {
          col = BubbleColor.lightning;
        }

        initialBubbles['${r}_$c'] = col;
      }
    }

    final totalBubbles = initialBubbles.length;
    final targetScore = totalBubbles * 120;

    return LevelConfig(
      id: levelId,
      worldId: worldId,
      title: 'Level $levelId',
      difficulty: difficulty,
      maxMoves: maxMoves,
      targetScore: targetScore,
      availableColors: palette,
      initialBubbles: initialBubbles,
      starThresholds: [
        (targetScore * 0.5).round(),
        (targetScore * 0.8).round(),
        (targetScore * 1.0).round(),
      ],
    );
  }
}
