import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bubble_shooting_game/core/widgets/theme_environment_widget.dart';
import 'package:bubble_shooting_game/data/models/player_data.dart';
import 'package:bubble_shooting_game/data/repositories/player_repository.dart';
import 'package:bubble_shooting_game/data/static_data/themes_data.dart';
import 'package:bubble_shooting_game/features/gameplay/screens/game_screen.dart';

class MockPlayerRepository implements PlayerRepository {
  PlayerData _player;
  MockPlayerRepository([this._player = const PlayerData()]);

  @override
  Future<PlayerData> loadPlayer() async => _player;

  @override
  Future<void> savePlayer(PlayerData player) async {
    _player = player;
  }

  @override
  Future<void> resetProgress() async {
    _player = const PlayerData();
  }
}

void main() {
  final testSizes = [
    const Size(320, 568),
    const Size(360, 800),
    const Size(375, 812),
    const Size(390, 844),
    const Size(393, 852),
    const Size(402, 874),
    const Size(430, 932),
    const Size(440, 956),
  ];

  group('Responsive Screen Testing', () {
    for (final screenSize in testSizes) {
      testWidgets('Renders GameScreen without layout errors at ${screenSize.width}x${screenSize.height}',
          (WidgetTester tester) async {
        final repo = MockPlayerRepository();

        tester.view.physicalSize = screenSize * tester.view.devicePixelRatio;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(
              levelId: 1,
              playerRepository: repo,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify HUD components build correctly
        expect(find.text('LEVEL 1'), findsOneWidget);
        expect(find.text('MOVES'), findsOneWidget);

        // Verify no Flutter render overflow errors occurred
        expect(tester.takeException(), isNull);

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
      });
    }
  });

  group('Theme Environment Tests', () {
    testWidgets('Renders Fantasy Temple theme environment correctly', (WidgetTester tester) async {
      final fantasyTheme = ThemesData.themes.firstWhere((t) => t.id == 'fantasy_temple');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeEnvironmentWidget(
              theme: fantasyTheme,
              child: const Text('Fantasy Gameplay Area'),
            ),
          ),
        ),
      );

      expect(find.text('Fantasy Gameplay Area'), findsOneWidget);
    });

    testWidgets('Renders Green Forest theme environment correctly', (WidgetTester tester) async {
      final forestTheme = ThemesData.themes.firstWhere((t) => t.id == 'green_forest');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeEnvironmentWidget(
              theme: forestTheme,
              child: const Text('Forest Gameplay Area'),
            ),
          ),
        ),
      );

      expect(find.text('Forest Gameplay Area'), findsOneWidget);
    });
  });
}
