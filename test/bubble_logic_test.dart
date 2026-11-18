import 'package:flutter_test/flutter_test.dart';
import 'package:bubble_shooting_game/data/models/bubble_type.dart';
import 'package:bubble_shooting_game/features/gameplay/game/logic/hex_grid_helper.dart';
import 'package:bubble_shooting_game/features/gameplay/game/logic/bubble_matcher.dart';
import 'package:bubble_shooting_game/features/gameplay/game/logic/floating_bubble_detector.dart';

void main() {
  group('HexGridHelper tests', () {
    test('Neighbors count and validity for even row', () {
      final neighbors = HexGridHelper.getNeighbors(0, 0);
      expect(neighbors.isNotEmpty, isTrue);
    });

    test('Nearest grid position calculation', () {
      final center = HexGridHelper.getBubbleCenter(
        row: 2,
        col: 3,
        startX: 0,
        startY: 0,
        bubbleDiameter: 40,
      );
      final pos = HexGridHelper.getNearestGridPosition(
        posX: center.x,
        posY: center.y,
        startX: 0,
        startY: 0,
        bubbleDiameter: 40,
      );
      expect(pos, equals((2, 3)));
    });
  });

  group('BubbleMatcher tests', () {
    test('3 connected same color bubbles match', () {
      final gridMap = <String, BubbleModel>{
        '0_0': const BubbleModel(id: '0_0', row: 0, col: 0, color: BubbleColor.red),
        '0_1': const BubbleModel(id: '0_1', row: 0, col: 1, color: BubbleColor.red),
        '1_0': const BubbleModel(id: '1_0', row: 1, col: 0, color: BubbleColor.red),
      };

      final matches = BubbleMatcher.findMatches(
        gridMap: gridMap,
        startRow: 0,
        startCol: 0,
        shotColor: BubbleColor.red,
      );

      expect(matches.length, equals(3));
    });

    test('2 connected same color bubbles do not match threshold', () {
      final gridMap = <String, BubbleModel>{
        '0_0': const BubbleModel(id: '0_0', row: 0, col: 0, color: BubbleColor.red),
        '0_1': const BubbleModel(id: '0_1', row: 0, col: 1, color: BubbleColor.red),
        '0_2': const BubbleModel(id: '0_2', row: 0, col: 2, color: BubbleColor.blue),
      };

      final matches = BubbleMatcher.findMatches(
        gridMap: gridMap,
        startRow: 0,
        startCol: 0,
        shotColor: BubbleColor.red,
      );

      expect(matches.length, equals(2));
    });
  });

  group('FloatingBubbleDetector tests', () {
    test('Bubbles disconnected from top ceiling are detected as floating', () {
      // Row 0 has bubble (0,0), Row 1 has (1,0) connected to (0,0).
      // Row 3 has (3,0) isolated from top!
      final gridMap = <String, BubbleModel>{
        '0_0': const BubbleModel(id: '0_0', row: 0, col: 0, color: BubbleColor.red),
        '1_0': const BubbleModel(id: '1_0', row: 1, col: 0, color: BubbleColor.blue),
        '3_0': const BubbleModel(id: '3_0', row: 3, col: 0, color: BubbleColor.green),
      };

      final floating = FloatingBubbleDetector.findFloatingBubbles(gridMap);
      expect(floating.length, equals(1));
      expect(floating.first.id, equals('3_0'));
    });
  });
}
