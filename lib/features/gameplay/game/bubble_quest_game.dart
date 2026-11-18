import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../core/audio/audio_service.dart';
import '../../../data/models/bubble_type.dart';
import '../../../data/models/level_config.dart';
import '../../../data/models/theme_model.dart';
import '../../../data/static_data/themes_data.dart';
import 'components/bubble_component.dart';
import 'components/cannon_component.dart';
import 'components/particle_component.dart';
import 'components/score_popup_component.dart';
import 'components/trajectory_component.dart';
import 'logic/bubble_matcher.dart';
import 'logic/floating_bubble_detector.dart';
import 'logic/hex_grid_helper.dart';

class BubbleQuestGame extends FlameGame with PanDetector, TapCallbacks {
  final LevelConfig levelConfig;
  final ThemeModel activeTheme;
  final Function(int score, int remainingMoves) onStateChanged;
  final Function(int finalScore, int stars) onLevelWon;
  final Function() onLevelLost;

  late Map<String, BubbleComponent> gridMap;
  late int remainingMoves;
  int currentScore = 0;
  bool isShooting = false;
  bool isGameOver = false;

  // Responsive layout boundaries & geometry
  double minX = 0;
  double maxX = 400;
  double topY = 85.0;
  double startX = 10;
  double bubbleDiameter = 38.0;

  // Preloaded Game Sprites
  final Map<BubbleColor, Sprite> bubbleSprites = {};
  Sprite? cannonBaseSprite;
  Sprite? shooterCloverSprite;
  Sprite? aimDotSprite;
  Sprite? popEffectSprite;
  Sprite? sparkleSprite;
  Sprite? explosionSprite;

  // Game elements
  late CannonComponent cannon;
  late TrajectoryComponent trajectory;
  late ParticleComponent particles;

  // Active shot bubble
  BubbleComponent? activeShooter;
  Vector2 shooterVelocity = Vector2.zero();
  BubbleColor readyColor = BubbleColor.red;
  BubbleColor nextColor = BubbleColor.blue;

  final Random _rng = Random();

  BubbleQuestGame({
    required this.levelConfig,
    ThemeModel? activeTheme,
    Color? themeColor,
    required this.onStateChanged,
    required this.onLevelWon,
    required this.onLevelLost,
  }) : activeTheme = activeTheme ??
            ThemesData.themes.firstWhere(
              (t) => t.primaryColor == themeColor,
              orElse: () => ThemesData.themes.first,
            );

  @override
  Color backgroundColor() => Colors.transparent;

  void _updateLayoutDimensions() {
    minX = 0;
    maxX = size.x;
    // Responsive topY under top HUD (~12% of height, min 85px)
    topY = max(85.0, size.y * 0.12);
    // Bubble diameter calculated dynamically to fit available screen width
    double availableWidth = size.x - 16.0;
    bubbleDiameter = availableWidth / HexGridHelper.evenRowCols;
    startX = (size.x - (HexGridHelper.evenRowCols * bubbleDiameter)) / 2.0;
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    if (isLoaded) {
      _updateLayoutDimensions();
      final cannonY = newSize.y - max(85.0, newSize.y * 0.13);
      cannon.position = Vector2(newSize.x / 2.0, cannonY);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    Flame.images.prefix = 'assets/';

    // Preload sprite assets
    await _preloadGameSprites();

    _updateLayoutDimensions();

    remainingMoves = levelConfig.maxMoves;

    gridMap = {};

    // Components
    particles = ParticleComponent(
      popSprite: popEffectSprite,
      sparkleSprite: sparkleSprite,
      explosionSprite: explosionSprite,
    );
    add(particles);

    trajectory = TrajectoryComponent(
      accentColor: activeTheme.accentColor,
      aimDotSprite: aimDotSprite,
    );
    add(trajectory);

    // Initialize ready & next bubble colors from palette
    readyColor = _randomPaletteColor();
    nextColor = _randomPaletteColor();

    final cannonY = size.y - max(85.0, size.y * 0.13);
    final cannonPos = Vector2(size.x / 2.0, cannonY);
    cannon = CannonComponent(
      position: cannonPos,
      readyColor: readyColor,
      nextColor: nextColor,
      activeTheme: activeTheme,
      baseSprite: cannonBaseSprite,
      cloverSprite: shooterCloverSprite,
      bubbleSprites: bubbleSprites,
    );
    add(cannon);

    _setupGrid();
  }

  Future<void> _preloadGameSprites() async {
    for (final bColor in BubbleColor.values) {
      try {
        final spritePath = bColor.getThemeSpriteAssetPath(activeTheme.id);
        final sprite = await Sprite.load(spritePath);
        bubbleSprites[bColor] = sprite;
      } catch (e) {
        // Fallback drawing handles missing sprites gracefully
      }
    }

    if (activeTheme.specialBubbleAsset != null) {
      try {
        final specSprite = await Sprite.load(activeTheme.specialBubbleAsset!);
        bubbleSprites[BubbleColor.bomb] = specSprite;
        bubbleSprites[BubbleColor.lightning] = specSprite;
        bubbleSprites[BubbleColor.stone] = specSprite;
        bubbleSprites[BubbleColor.ice] = specSprite;
      } catch (e) {}
    }

    if (activeTheme.rainbowBubbleAsset != null) {
      try {
        final rainbowSprite = await Sprite.load(activeTheme.rainbowBubbleAsset!);
        bubbleSprites[BubbleColor.rainbow] = rainbowSprite;
      } catch (e) {}
    }

    try {
      final baseAsset = activeTheme.cannonBaseAsset ?? 'game/shooter/shooter_base.png';
      cannonBaseSprite = await Sprite.load(baseAsset);
    } catch (e) {}

    try {
      final readyAsset = activeTheme.readyBubbleAsset ?? 'game/shooter/shooter_clover.png';
      shooterCloverSprite = await Sprite.load(readyAsset);
    } catch (e) {}

    try {
      final aimAsset = activeTheme.aimDotAsset ?? 'game/effects/aim_dot.png';
      aimDotSprite = await Sprite.load(aimAsset);
    } catch (e) {}

    try {
      popEffectSprite = await Sprite.load('game/effects/bubble_pop.png');
      sparkleSprite = await Sprite.load('game/effects/sparkle.png');
      explosionSprite = await Sprite.load('game/effects/explosion.png');
    } catch (e) {}
  }

  BubbleColor _randomPaletteColor() {
    if (levelConfig.availableColors.isEmpty) return BubbleColor.red;
    return levelConfig
        .availableColors[_rng.nextInt(levelConfig.availableColors.length)];
  }

  void _setupGrid() {
    levelConfig.initialBubbles.forEach((key, color) {
      final parts = key.split('_');
      final r = int.parse(parts[0]);
      final c = int.parse(parts[1]);

      final center = HexGridHelper.getBubbleCenter(
        row: r,
        col: c,
        startX: startX,
        startY: topY,
        bubbleDiameter: bubbleDiameter,
      );

      final bubble = BubbleComponent(
        color: color,
        radius: bubbleDiameter / 2,
        position: Vector2(center.x, center.y),
        bubbleSkinType: activeTheme.bubbleSkinType,
        sprite: bubbleSprites[color],
      );

      gridMap[key] = bubble;
      add(bubble);
    });
  }

  void applyPowerUp(BubbleColor specialColor) {
    if (isShooting || isGameOver) return;
    readyColor = specialColor;
    cannon.updateColors(readyColor, nextColor);
  }

  void swapBubbles() {
    if (isShooting || isGameOver) return;
    final temp = readyColor;
    readyColor = nextColor;
    nextColor = temp;
    cannon.updateColors(readyColor, nextColor);
    AudioService.instance.playButtonClick();
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (isShooting || isGameOver) return;
    _updateAimAngle(info.eventPosition.global);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isShooting || isGameOver) return;
    _updateAimAngle(info.eventPosition.global);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (isShooting || isGameOver) return;
    trajectory.isAiming = false;
    _shootBubble();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isShooting || isGameOver) return;
    _updateAimAngle(event.canvasPosition);
    _shootBubble();
  }

  void _updateAimAngle(Vector2 touchPos) {
    final cannonPos = cannon.position;
    final dx = touchPos.x - cannonPos.x;
    final dy = touchPos.y - cannonPos.y;

    // Angle relative to horizontal right
    double angle = atan2(dy, dx);
    // Restrict cannon angle to upward arc (-160 deg to -20 deg)
    angle = angle.clamp(-pi * 0.88, -pi * 0.12);

    cannon.aimAngle = angle;
    trajectory.updateAim(
      origin: cannonPos,
      angle: angle,
      isAiming: true,
      minX: minX + bubbleDiameter / 2,
      maxX: maxX - bubbleDiameter / 2,
      topY: topY + bubbleDiameter / 2,
    );
  }

  void _shootBubble() {
    if (isShooting || isGameOver || remainingMoves <= 0) return;

    isShooting = true;
    cannon.triggerRecoil();

    final cannonPos = cannon.position;
    final speed = 800.0;
    shooterVelocity = Vector2(cos(cannon.aimAngle), sin(cannon.aimAngle)) * speed;

    Sprite? shotSprite = bubbleSprites[readyColor];
    if (readyColor == BubbleColor.green && shooterCloverSprite != null && activeTheme.id == 'green_forest') {
      shotSprite = shooterCloverSprite;
    }

    activeShooter = BubbleComponent(
      color: readyColor,
      radius: bubbleDiameter / 2,
      position: cannonPos.clone(),
      bubbleSkinType: activeTheme.bubbleSkinType,
      sprite: shotSprite,
    );
    add(activeShooter!);

    AudioService.instance.playShoot();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isShooting && activeShooter != null) {
      _updateShooterPhysics(dt);
    }
  }

  void _updateShooterPhysics(double dt) {
    final shooter = activeShooter!;
    final radius = bubbleDiameter / 2;
    shooter.position += shooterVelocity * dt;

    // 1. Side wall bounces
    if (shooter.position.x <= minX + radius) {
      shooter.position.x = minX + radius;
      shooterVelocity.x = -shooterVelocity.x;
    } else if (shooter.position.x >= maxX - radius) {
      shooter.position.x = maxX - radius;
      shooterVelocity.x = -shooterVelocity.x;
    }

    // 2. Ceiling collision
    bool hitCeiling = shooter.position.y <= topY + radius;

    // 3. Grid bubble collision
    bool hitBubble = false;
    gridMap.forEach((_, b) {
      if (!b.isPopping && !b.isFalling) {
        final distSq = (shooter.position - b.position).length2;
        if (distSq <= (bubbleDiameter * 0.88) * (bubbleDiameter * 0.88)) {
          hitBubble = true;
        }
      }
    });

    if (hitCeiling || hitBubble) {
      _onShooterCollided();
    }
  }

  void _onShooterCollided() {
    final shooter = activeShooter!;

    // Find nearest hex grid position
    final (row, col) = HexGridHelper.getNearestGridPosition(
      posX: shooter.position.x,
      posY: shooter.position.y,
      startX: startX,
      startY: topY,
      bubbleDiameter: bubbleDiameter,
    );

    final center = HexGridHelper.getBubbleCenter(
      row: row,
      col: col,
      startX: startX,
      startY: topY,
      bubbleDiameter: bubbleDiameter,
    );

    shooter.position = Vector2(center.x, center.y);

    final shotColor = shooter.color;
    final key = '${row}_$col';
    gridMap[key] = shooter;

    remainingMoves--;
    onStateChanged(currentScore, remainingMoves);

    // Matching logic
    final gridModelMap = gridMap.map(
      (k, b) => MapEntry(
        k,
        BubbleModel(id: k, row: b.position.y ~/ 1, col: b.position.x ~/ 1, color: b.color),
      ),
    );

    final matchedModels = BubbleMatcher.findMatches(
      gridMap: gridModelMap,
      startRow: row,
      startCol: col,
      shotColor: shotColor,
    );

    if (matchedModels.length >= 3 || shotColor.isSpecial) {
      // Pop matching bubbles
      int popScore = matchedModels.length * 100;
      currentScore += popScore;

      for (final m in matchedModels) {
        final bComponent = gridMap[m.id];
        if (bComponent != null) {
          bComponent.isPopping = true;
          particles.explodeAt(
            bComponent.position,
            bComponent.color.color,
            themeColors: activeTheme.particleColors,
          );
          gridMap.remove(m.id);
        }
      }

      AudioService.instance.playPop();

      add(ScorePopupComponent(
        text: '+$popScore',
        position: Vector2(center.x, center.y),
      ));

      // Floating bubbles check
      final remainingModelMap = gridMap.map(
        (k, b) => MapEntry(
          k,
          BubbleModel(
            id: k,
            row: int.parse(k.split('_')[0]),
            col: int.parse(k.split('_')[1]),
            color: b.color,
          ),
        ),
      );

      final floatingModels =
          FloatingBubbleDetector.findFloatingBubbles(remainingModelMap);

      if (floatingModels.isNotEmpty) {
        int dropScore = floatingModels.length * 200;
        currentScore += dropScore;

        for (final f in floatingModels) {
          final bComponent = gridMap[f.id];
          if (bComponent != null) {
            bComponent.isFalling = true;
            gridMap.remove(f.id);
          }
        }

        AudioService.instance.playCombo();

        add(ScorePopupComponent(
          text: 'BONUS +$dropScore',
          position: Vector2(center.x, center.y - 30),
          textColor: Colors.orangeAccent,
        ));
      }
    }

    activeShooter = null;
    isShooting = false;

    // Reset cannon ready & next colors
    readyColor = nextColor;
    nextColor = _randomPaletteColor();
    cannon.updateColors(readyColor, nextColor);

    onStateChanged(currentScore, remainingMoves);

    _checkWinLoseConditions();
  }

  void _checkWinLoseConditions() {
    if (isGameOver) return;

    // Win condition: grid cleared or target score reached!
    bool gridCleared = gridMap.values.every((b) => b.isPopping || b.isFalling);

    if (gridCleared || currentScore >= levelConfig.targetScore) {
      isGameOver = true;
      final stars = levelConfig.calculateStars(currentScore);
      AudioService.instance.playWin();
      onLevelWon(currentScore, max(1, stars));
    } else if (remainingMoves <= 0) {
      isGameOver = true;
      AudioService.instance.playLose();
      onLevelLost();
    }
  }

  void addExtraMoves(int moves) {
    remainingMoves += moves;
    isGameOver = false;
    onStateChanged(currentScore, remainingMoves);
  }
}
