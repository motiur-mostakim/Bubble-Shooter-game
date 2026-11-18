import 'package:flutter_test/flutter_test.dart';
import 'package:bubble_shooting_game/data/models/bubble_type.dart';
import 'package:bubble_shooting_game/data/models/player_data.dart';
import 'package:bubble_shooting_game/data/repositories/player_repository.dart';
import 'package:bubble_shooting_game/features/gameplay/bloc/game_bloc.dart';
import 'package:bubble_shooting_game/features/gameplay/bloc/game_event.dart';
import 'package:bubble_shooting_game/features/gameplay/bloc/game_state.dart';

class MockPlayerRepository implements PlayerRepository {
  PlayerData _player = const PlayerData();

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
  group('GameBloc Tests', () {
    late MockPlayerRepository repo;
    late GameBloc bloc;

    setUp(() {
      repo = MockPlayerRepository();
      bloc = GameBloc(playerRepository: repo);
    });

    test('Initial status is initial', () {
      expect(bloc.state.status, equals(GameStatus.initial));
    });

    test('StartLevelEvent initializes state correctly', () async {
      bloc.add(const StartLevelEvent(1));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<GameState>().having((s) => s.status, 'status', GameStatus.loading),
          isA<GameState>()
              .having((s) => s.status, 'status', GameStatus.playing)
              .having((s) => s.levelConfig?.id, 'levelId', 1),
        ]),
      );
    });

    test('LevelWonEvent updates player coins and stars', () async {
      bloc.add(const StartLevelEvent(1));
      await bloc.stream.firstWhere((s) => s.status == GameStatus.playing);

      bloc.add(const LevelWonEvent(1500, 3));

      final state = await bloc.stream.firstWhere((s) => s.status == GameStatus.won);
      expect(state.starsEarned, equals(3));
      expect(state.coinsEarned, greaterThan(0));

      final savedPlayer = await repo.loadPlayer();
      expect(savedPlayer.levelStars[1], equals(3));
      expect(savedPlayer.currentLevel, equals(2));
    });

    test('UsePowerUpEvent deducts booster count', () async {
      bloc.add(const StartLevelEvent(1));
      await bloc.stream.firstWhere((s) => s.status == GameStatus.playing);

      bloc.add(const UsePowerUpEvent(BubbleColor.bomb));
      final state = await bloc.stream.first;
      expect(state.playerData.bombBoosters, equals(1));
    });
  });
}
