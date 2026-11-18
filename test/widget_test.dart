import 'package:flutter_test/flutter_test.dart';
import 'package:bubble_shooting_game/app/app.dart';
import 'package:bubble_shooting_game/data/models/player_data.dart';
import 'package:bubble_shooting_game/data/repositories/player_repository.dart';

class TestPlayerRepository implements PlayerRepository {
  PlayerData _player = const PlayerData(onboardingCompleted: true);

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
  testWidgets('Bubble Quest App loads splash screen', (WidgetTester tester) async {
    final repo = TestPlayerRepository();
    await tester.pumpWidget(BubbleQuestApp(playerRepository: repo));

    expect(find.text('BUBBLE QUEST'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 4));
  });
}
