import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/star_rating_bar.dart';
import '../../data/models/player_data.dart';
import '../../data/models/world_model.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/static_data/levels_data.dart';
import '../gameplay/screens/game_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  final WorldModel world;
  final PlayerRepository playerRepository;

  const LevelSelectionScreen({
    super.key,
    required this.world,
    required this.playerRepository,
  });

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  PlayerData _player = const PlayerData();

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  Future<void> _loadPlayer() async {
    final player = await widget.playerRepository.loadPlayer();
    setState(() => _player = player);
  }

  @override
  Widget build(BuildContext context) {
    final levels = List.generate(
      widget.world.endLevel - widget.world.startLevel + 1,
      (idx) => LevelsData.getLevel(widget.world.startLevel + idx),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.world.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.world.name,
                      style: AppTextStyles.title(fontSize: 24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final lvl = levels[index];
                    final isUnlocked = lvl.id <= _player.currentLevel;
                    final stars = _player.levelStars[lvl.id] ?? 0;
                    final bestScore = _player.levelScores[lvl.id] ?? 0;

                    return GestureDetector(
                      onTap: isUnlocked
                          ? () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) => GameScreen(
                                        levelId: lvl.id,
                                        playerRepository: widget.playerRepository,
                                      ),
                                    ),
                                  )
                                  .then((_) => _loadPlayer());
                            }
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? AppColors.cardBg
                              : Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isUnlocked
                                ? widget.world.accentColor
                                : Colors.grey.shade700,
                            width: 2,
                          ),
                          boxShadow: [
                            if (isUnlocked)
                              BoxShadow(
                                color: widget.world.accentColor
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isUnlocked) ...[
                              Text(
                                '${lvl.id}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      color: widget.world.accentColor,
                                      blurRadius: 4,
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              StarRatingBar(stars: stars, starSize: 16),
                              if (bestScore > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Score: $bestScore',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ]
                            ] else ...[
                              const Icon(
                                Icons.lock,
                                color: Colors.grey,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Level ${lvl.id}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
