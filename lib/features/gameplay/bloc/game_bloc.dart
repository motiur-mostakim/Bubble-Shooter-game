import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/bubble_type.dart';
import '../../../data/repositories/player_repository.dart';
import '../../../data/static_data/levels_data.dart';
import '../../../data/static_data/themes_data.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final PlayerRepository playerRepository;

  GameBloc({required this.playerRepository}) : super(const GameState()) {
    on<StartLevelEvent>(_onStartLevel);
    on<UpdateGameStateEvent>(_onUpdateGameState);
    on<UsePowerUpEvent>(_onUsePowerUp);
    on<LevelWonEvent>(_onLevelWon);
    on<LevelLostEvent>(_onLevelLost);
    on<BuyExtraMovesEvent>(_onBuyExtraMoves);
  }

  Future<void> _onStartLevel(
      StartLevelEvent event, Emitter<GameState> emit) async {
    emit(state.copyWith(status: GameStatus.loading));

    final player = await playerRepository.loadPlayer();
    final config = LevelsData.getLevel(event.levelId);

    emit(GameState(
      status: GameStatus.playing,
      levelConfig: config,
      playerData: player,
      currentScore: 0,
      remainingMoves: config.maxMoves,
      starsEarned: 0,
      coinsEarned: 0,
    ));
  }

  void _onUpdateGameState(
      UpdateGameStateEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(
      currentScore: event.score,
      remainingMoves: event.remainingMoves,
    ));
  }

  Future<void> _onUsePowerUp(
      UsePowerUpEvent event, Emitter<GameState> emit) async {
    final player = state.playerData;
    final color = event.powerUpColor;

    int rB = player.rainbowBoosters;
    int bB = player.bombBoosters;
    int lB = player.lightningBoosters;

    if (color == BubbleColor.rainbow && rB > 0) rB--;
    if (color == BubbleColor.bomb && bB > 0) bB--;
    if (color == BubbleColor.lightning && lB > 0) lB--;

    final updatedPlayer = player.copyWith(
      rainbowBoosters: rB,
      bombBoosters: bB,
      lightningBoosters: lB,
    );

    await playerRepository.savePlayer(updatedPlayer);
    emit(state.copyWith(playerData: updatedPlayer));
  }

  Future<void> _onLevelWon(LevelWonEvent event, Emitter<GameState> emit) async {
    final currentLevel = state.levelConfig?.id ?? 1;
    final player = state.playerData;

    final coinsGained = (event.score ~/ 10) + (event.stars * 50);

    final updatedStars = Map<int, int>.from(player.levelStars);
    final previousStars = updatedStars[currentLevel] ?? 0;
    updatedStars[currentLevel] = max(previousStars, event.stars);

    final updatedScores = Map<int, int>.from(player.levelScores);
    final previousScore = updatedScores[currentLevel] ?? 0;
    updatedScores[currentLevel] = max(previousScore, event.score);

    final availableThemes = ThemesData.themes
        .where((theme) =>
            player.unlockedThemes.contains(theme.id) || theme.isDefault)
        .toList();
    final currentThemeIndex = availableThemes.indexWhere(
      (theme) => theme.id == player.selectedTheme,
    );
    final nextTheme = availableThemes.isEmpty
        ? player.selectedTheme
        : availableThemes[(currentThemeIndex + 1) % availableThemes.length].id;

    final nextLevel = max(player.currentLevel, currentLevel + 1);

    // Check unlocking worlds (e.g. world 2 unlocks at level 6, world 3 at 11, etc.)
    final unlockedWorlds = List<int>.from(player.unlockedWorlds);
    final nextWorldId = ((nextLevel - 1) ~/ 5) + 1;
    if (!unlockedWorlds.contains(nextWorldId) && nextWorldId <= 6) {
      unlockedWorlds.add(nextWorldId);
    }

    final updatedPlayer = player.copyWith(
      coins: player.coins + coinsGained,
      currentLevel: nextLevel,
      levelStars: updatedStars,
      levelScores: updatedScores,
      unlockedWorlds: unlockedWorlds,
      selectedTheme: nextTheme,
    );

    await playerRepository.savePlayer(updatedPlayer);

    emit(state.copyWith(
      status: GameStatus.won,
      playerData: updatedPlayer,
      starsEarned: event.stars,
      coinsEarned: coinsGained,
    ));
  }

  void _onLevelLost(LevelLostEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(status: GameStatus.lost));
  }

  Future<void> _onBuyExtraMoves(
      BuyExtraMovesEvent event, Emitter<GameState> emit) async {
    final player = state.playerData;
    if (player.coins >= 100) {
      final updatedPlayer = player.copyWith(coins: player.coins - 100);
      await playerRepository.savePlayer(updatedPlayer);
      emit(state.copyWith(
        status: GameStatus.playing,
        playerData: updatedPlayer,
        remainingMoves: state.remainingMoves + 5,
      ));
    }
  }
}
