import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/theme_environment_widget.dart';
import '../../../data/repositories/player_repository.dart';
import '../../../data/static_data/themes_data.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';

import '../game/bubble_quest_game.dart';
import '../widgets/game_hud.dart';
import '../widgets/game_pause_dialog.dart';
import '../widgets/lose_dialog.dart';
import '../widgets/power_ups_bar.dart';
import '../widgets/win_dialog.dart';

class GameScreen extends StatefulWidget {
  final int levelId;
  final PlayerRepository playerRepository;

  const GameScreen({
    super.key,
    required this.levelId,
    required this.playerRepository,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  BubbleQuestGame? _game;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(playerRepository: widget.playerRepository)
        ..add(StartLevelEvent(widget.levelId)),
      child: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state.status == GameStatus.won) {
            _showWinDialog(context, state);
          } else if (state.status == GameStatus.lost) {
            _showLoseDialog(context, state);
          }
        },
        builder: (context, state) {
          if (state.status == GameStatus.loading || state.levelConfig == null) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.coinGold),
              ),
            );
          }

          // Keep the completed level's environment behind its result dialog.
          // Apply the next theme when a new game is created.
          final selectedThemeId = state.status == GameStatus.won && _game != null
              ? _game!.activeTheme.id
              : state.playerData.selectedTheme;
          final activeTheme = ThemesData.themes.firstWhere(
            (t) => t.id == selectedThemeId,
            orElse: () => ThemesData.themes.first,
          );

          if (_game == null ||
              _game!.levelConfig.id != state.levelConfig!.id ||
              _game!.activeTheme.id != activeTheme.id) {
            _game = BubbleQuestGame(
              levelConfig: state.levelConfig!,
              activeTheme: activeTheme,
              onStateChanged: (score, moves) {
                context
                    .read<GameBloc>()
                    .add(UpdateGameStateEvent(score, moves));
              },
              onLevelWon: (finalScore, stars) {
                context
                    .read<GameBloc>()
                    .add(LevelWonEvent(finalScore, stars));
              },
              onLevelLost: () {
                context.read<GameBloc>().add(const LevelLostEvent());
              },
            );
          }

          return Scaffold(
            body: ThemeEnvironmentWidget(
              theme: activeTheme,
              child: SafeArea(
                child: Stack(
                  children: [
                    // Flame Canvas (Layer 5)
                    GameWidget(game: _game!),

                    // Top HUD (Layer 8)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: GameHud(
                        levelId: state.levelConfig!.id,
                        score: state.currentScore,
                        remainingMoves: state.remainingMoves,
                        targetScore: state.levelConfig!.targetScore,
                        onPausePressed: () => _showPauseDialog(context),
                      ),
                    ),

                    // Bottom Power-ups Bar (Layer 8)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: PowerUpsBar(
                        playerData: state.playerData,
                        onUsePowerUp: (powerUpColor) {
                          _game?.applyPowerUp(powerUpColor);
                          context
                              .read<GameBloc>()
                              .add(UsePowerUpEvent(powerUpColor));
                        },
                        onSwapBubbles: () {
                          _game?.swapBubbles();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPauseDialog(BuildContext context) {
    final bloc = context.read<GameBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GamePauseDialog(
        onResume: () => Navigator.of(context).pop(),
        onRestart: () {
          Navigator.of(context).pop();
          setState(() {
            _game = null;
          });
          bloc.add(StartLevelEvent(widget.levelId));
        },
        onQuit: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showWinDialog(BuildContext context, GameState state) {
    final bloc = context.read<GameBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WinDialog(
        score: state.currentScore,
        stars: state.starsEarned,
        coinsEarned: state.coinsEarned,
        onNextLevel: () {
          Navigator.of(context).pop();
          final nextId = (state.levelConfig?.id ?? 1) + 1;
          setState(() {
            _game = null;
          });
          bloc.add(StartLevelEvent(nextId));
        },
        onReplay: () {
          Navigator.of(context).pop();
          setState(() {
            _game = null;
          });
          bloc.add(StartLevelEvent(state.levelConfig?.id ?? 1));
        },
        onHome: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showLoseDialog(BuildContext context, GameState state) {
    final bloc = context.read<GameBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoseDialog(
        score: state.currentScore,
        canBuyMoves: state.playerData.coins >= 100,
        onBuyExtraMoves: () {
          Navigator.of(context).pop();
          _game?.addExtraMoves(5);
          bloc.add(const BuyExtraMovesEvent());
        },
        onRetry: () {
          Navigator.of(context).pop();
          setState(() {
            _game = null;
          });
          bloc.add(StartLevelEvent(state.levelConfig?.id ?? 1));
        },
        onHome: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
