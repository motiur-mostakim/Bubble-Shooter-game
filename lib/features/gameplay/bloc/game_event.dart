import 'package:equatable/equatable.dart';
import '../../../data/models/bubble_type.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class StartLevelEvent extends GameEvent {
  final int levelId;
  const StartLevelEvent(this.levelId);

  @override
  List<Object?> get props => [levelId];
}

class UpdateGameStateEvent extends GameEvent {
  final int score;
  final int remainingMoves;
  const UpdateGameStateEvent(this.score, this.remainingMoves);

  @override
  List<Object?> get props => [score, remainingMoves];
}

class UsePowerUpEvent extends GameEvent {
  final BubbleColor powerUpColor;
  const UsePowerUpEvent(this.powerUpColor);

  @override
  List<Object?> get props => [powerUpColor];
}

class LevelWonEvent extends GameEvent {
  final int score;
  final int stars;
  const LevelWonEvent(this.score, this.stars);

  @override
  List<Object?> get props => [score, stars];
}

class LevelLostEvent extends GameEvent {
  const LevelLostEvent();
}

class BuyExtraMovesEvent extends GameEvent {
  const BuyExtraMovesEvent();
}
