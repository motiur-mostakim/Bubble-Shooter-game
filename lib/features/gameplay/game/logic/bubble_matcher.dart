import 'dart:collection';
import '../../../../data/models/bubble_type.dart';
import 'hex_grid_helper.dart';

class BubbleMatcher {
  /// Finds all connected bubbles matching the shot color or special effect starting at (startRow, startCol).
  static List<BubbleModel> findMatches({
    required Map<String, BubbleModel> gridMap,
    required int startRow,
    required int startCol,
    required BubbleColor shotColor,
  }) {
    final startKey = '${startRow}_$startCol';
    if (!gridMap.containsKey(startKey)) return [];

    // Check for Bomb powerup effect
    if (shotColor == BubbleColor.bomb) {
      return _findBombArea(gridMap, startRow, startCol);
    }

    // Check for Lightning powerup effect
    if (shotColor == BubbleColor.lightning) {
      return _findRowArea(gridMap, startRow);
    }

    final targetColor = (shotColor == BubbleColor.rainbow)
        ? _inferRainbowMatchColor(gridMap, startRow, startCol)
        : shotColor;

    final visited = <String>{};
    final matches = <BubbleModel>[];
    final queue = Queue<(int, int)>();

    queue.add((startRow, startCol));
    visited.add(startKey);

    while (queue.isNotEmpty) {
      final curr = queue.removeFirst();
      final key = '${curr.$1}_${curr.$2}';
      final bubble = gridMap[key];

      if (bubble == null) continue;

      // Obstacles like stone/ice cannot match normally unless popped by bomb/lightning
      if (bubble.color.isObstacle) continue;

      // Check color match
      final isMatch = (targetColor == null) ||
          (bubble.color == targetColor) ||
          (bubble.color == BubbleColor.rainbow) ||
          (targetColor == BubbleColor.rainbow);

      if (isMatch) {
        matches.add(bubble);
        final neighbors = HexGridHelper.getNeighbors(curr.$1, curr.$2);
        for (final n in neighbors) {
          final nKey = '${n.$1}_${n.$2}';
          if (!visited.contains(nKey) && gridMap.containsKey(nKey)) {
            visited.add(nKey);
            queue.add(n);
          }
        }
      }
    }

    return matches;
  }

  static BubbleColor? _inferRainbowMatchColor(
      Map<String, BubbleModel> gridMap, int r, int c) {
    final neighbors = HexGridHelper.getNeighbors(r, c);
    for (final n in neighbors) {
      final bubble = gridMap['${n.$1}_${n.$2}'];
      if (bubble != null && !bubble.color.isSpecial) {
        return bubble.color;
      }
    }
    return null;
  }

  static List<BubbleModel> _findBombArea(
      Map<String, BubbleModel> gridMap, int r, int c) {
    final affectedKeys = <String>{'${r}_$c'};
    final step1 = HexGridHelper.getNeighbors(r, c);

    for (final n in step1) {
      affectedKeys.add('${n.$1}_${n.$2}');
      final step2 = HexGridHelper.getNeighbors(n.$1, n.$2);
      for (final n2 in step2) {
        affectedKeys.add('${n2.$1}_${n2.$2}');
      }
    }

    final result = <BubbleModel>[];
    for (final key in affectedKeys) {
      if (gridMap.containsKey(key)) {
        result.add(gridMap[key]!);
      }
    }
    return result;
  }

  static List<BubbleModel> _findRowArea(
      Map<String, BubbleModel> gridMap, int r) {
    final result = <BubbleModel>[];
    gridMap.forEach((key, bubble) {
      if (bubble.row == r) {
        result.add(bubble);
      }
    });
    return result;
  }
}
