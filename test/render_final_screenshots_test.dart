import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bubble_shooting_game/core/widgets/theme_environment_widget.dart';
import 'package:bubble_shooting_game/data/models/player_data.dart';
import 'package:bubble_shooting_game/data/repositories/player_repository.dart';
import 'package:bubble_shooting_game/data/static_data/themes_data.dart';
import 'package:bubble_shooting_game/features/gameplay/screens/game_screen.dart';

class MockPlayerRepository implements PlayerRepository {
  PlayerData _player;
  MockPlayerRepository(this._player);

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
  testWidgets('Render and save clover_forest_final.png and underwater_final.png', (WidgetTester tester) async {
    final size = const Size(390, 844);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;

    // 1. Render Clover Forest Theme Gameplay
    final cloverRepo = MockPlayerRepository(const PlayerData(selectedTheme: 'green_forest'));
    final cloverKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: cloverKey,
          child: GameScreen(
            levelId: 1,
            playerRepository: cloverRepo,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final RenderRepaintBoundary cloverBoundary =
        cloverKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image cloverImage = await cloverBoundary.toImage(pixelRatio: 1.0);
    final cloverByteData = await cloverImage.toByteData(format: ui.ImageByteFormat.png);
    if (cloverByteData != null) {
      final bytes = cloverByteData.buffer.asUint8List();
      File('clover_forest_final.png').writeAsBytesSync(bytes);
      print('Saved clover_forest_final.png (390x844)');
    }

    // 2. Render Underwater Theme Gameplay
    final underwaterRepo = MockPlayerRepository(const PlayerData(selectedTheme: 'ocean_world'));
    final underwaterKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: underwaterKey,
          child: GameScreen(
            levelId: 1,
            playerRepository: underwaterRepo,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final RenderRepaintBoundary underwaterBoundary =
        underwaterKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image underwaterImage = await underwaterBoundary.toImage(pixelRatio: 1.0);
    final underwaterByteData = await underwaterImage.toByteData(format: ui.ImageByteFormat.png);
    if (underwaterByteData != null) {
      final bytes = underwaterByteData.buffer.asUint8List();
      File('underwater_final.png').writeAsBytesSync(bytes);
      print('Saved underwater_final.png (390x844)');
    }

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
