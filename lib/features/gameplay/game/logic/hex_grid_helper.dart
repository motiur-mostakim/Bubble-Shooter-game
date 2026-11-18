import 'dart:math';

class HexGridHelper {
  static const int maxRows = 14;
  static const int evenRowCols = 8;
  static const int oddRowCols = 7;

  static int getColsForRow(int row) => (row % 2 == 0) ? evenRowCols : oddRowCols;

  static Point<double> getBubbleCenter({
    required int row,
    required int col,
    required double startX,
    required double startY,
    required double bubbleDiameter,
  }) {
    final rowHeight = bubbleDiameter * 0.8660254; // sqrt(3)/2
    final radius = bubbleDiameter / 2.0;
    final xShift = (row % 2 == 1) ? radius : 0.0;

    final x = startX + xShift + (col * bubbleDiameter) + radius;
    final y = startY + (row * rowHeight) + radius;
    return Point<double>(x, y);
  }

  static (int, int) getNearestGridPosition({
    required double posX,
    required double posY,
    required double startX,
    required double startY,
    required double bubbleDiameter,
  }) {
    int bestRow = 0;
    int bestCol = 0;
    double minDistanceSq = double.infinity;

    for (int r = 0; r < maxRows; r++) {
      final cols = getColsForRow(r);
      for (int c = 0; c < cols; c++) {
        final center = getBubbleCenter(
          row: r,
          col: c,
          startX: startX,
          startY: startY,
          bubbleDiameter: bubbleDiameter,
        );
        final dx = posX - center.x;
        final dy = posY - center.y;
        final distSq = dx * dx + dy * dy;

        if (distSq < minDistanceSq) {
          minDistanceSq = distSq;
          bestRow = r;
          bestCol = c;
        }
      }
    }

    return (bestRow, bestCol);
  }

  static List<(int, int)> getNeighbors(int row, int col) {
    final neighbors = <(int, int)>[];
    final isEven = (row % 2 == 0);

    final potential = isEven
        ? [
            (row, col - 1),
            (row, col + 1),
            (row - 1, col - 1),
            (row - 1, col),
            (row + 1, col - 1),
            (row + 1, col),
          ]
        : [
            (row, col - 1),
            (row, col + 1),
            (row - 1, col),
            (row - 1, col + 1),
            (row + 1, col),
            (row + 1, col + 1),
          ];

    for (final pos in potential) {
      final r = pos.$1;
      final c = pos.$2;
      if (r >= 0 && r < maxRows) {
        final maxC = getColsForRow(r);
        if (c >= 0 && c < maxC) {
          neighbors.add((r, c));
        }
      }
    }

    return neighbors;
  }
}
