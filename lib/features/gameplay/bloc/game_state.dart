import 'package:equatable/equatable.dart';
import '../../../data/models/level_config.dart';
import '../../../data/models/player_data.dart';

enum GameStatus { initial, loading, playing, paused, won, lost }

class GameState extends Equatable {
  final GameStatus status;
  final LevelConfig? levelConfig;
  final PlayerData playerData;
  final int currentScore;
  final int remainingMoves;
  final int starsEarned;
  final int coinsEarned;

  const GameState({
    this.status = GameStatus.initial,
    this.levelConfig,
    this.playerData = const PlayerData(),
    this.currentScore = 0,
    this.remainingMoves = 0,
    this.starsEarned = 0,
    this.coinsEarned = 0,
  });

  GameState copyWith({
    GameStatus? status,
    LevelConfig? levelConfig,
    PlayerData? playerData,
    int? currentScore,
    int? remainingMoves,
    int? starsEarned,
    int? coinsEarned,
  }) {
    return GameState(
      status: status ?? this.status,
      levelConfig: levelConfig ?? this.levelConfig,
      playerData: playerData ?? this.playerData,
      currentScore: currentScore ?? this.currentScore,
      remainingMoves: remainingMoves ?? this.remainingMoves,
      starsEarned: starsEarned ?? this.starsEarned,
      coinsEarned: coinsEarned ?? this.coinsEarned,
    );
  }

  @override
  List<Object?> get props => [
        status,
        levelConfig,
        playerData,
        currentScore,
        remainingMoves,
        starsEarned,
        coinsEarned,
      ];
}
