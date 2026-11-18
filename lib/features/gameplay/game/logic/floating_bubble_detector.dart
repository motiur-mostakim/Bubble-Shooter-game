import 'dart:collection';
import '../../../../data/models/bubble_type.dart';
import 'hex_grid_helper.dart';

class FloatingBubbleDetector {
  /// Detects all bubbles in the grid that are detached from the top ceiling (row == 0).
  static List<BubbleModel> findFloatingBubbles(Map<String, BubbleModel> gridMap) {
    if (gridMap.isEmpty) return [];

    final connectedKeys = <String>{};
    final queue = Queue<(int, int)>();

    // Add all top ceiling bubbles (row == 0) to the queue
    gridMap.forEach((key, bubble) {
      if (bubble.row == 0) {
        connectedKeys.add(key);
        queue.add((bubble.row, bubble.col));
      }
    });

    // BFS to find all bubbles connected to the top row
    while (queue.isNotEmpty) {
      final curr = queue.removeFirst();
      final neighbors = HexGridHelper.getNeighbors(curr.$1, curr.$2);

      for (final n in neighbors) {
        final nKey = '${n.$1}_${n.$2}';
        if (gridMap.containsKey(nKey) && !connectedKeys.contains(nKey)) {
          connectedKeys.add(nKey);
          queue.add(n);
        }
      }
    }

    // Any bubble in gridMap not connected to top row is floating
    final floatingBubbles = <BubbleModel>[];
    gridMap.forEach((key, bubble) {
      if (!connectedKeys.contains(key)) {
        floatingBubbles.add(bubble);
      }
    });

    return floatingBubbles;
  }
}
