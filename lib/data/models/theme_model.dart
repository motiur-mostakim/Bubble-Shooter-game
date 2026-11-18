import 'package:flutter/material.dart';

class ThemeModel {
  final String id;
  final String name;
  final String description;
  final String skyAsset;
  final String distantAsset;
  final String midgroundAsset;
  final String leftDecorationAsset;
  final String rightDecorationAsset;
  final String bottomDecorationAsset;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final List<Color> gradientBackground;
  final Color cannonColor;
  final Color accentColor;
  final String
  particleType; // 'leaf', 'bubble', 'sparkle', 'star', 'firefly', 'snowflake'
  final String
  bubbleSkinType; // 'forest', 'ocean', 'candy', 'galaxy', 'fairy', 'winter'
  final List<Color> particleColors;
  final int unlockCostCoins;
  final int unlockCostGems;
  final bool isDefault;
  final String? cannonBaseAsset;
  final String? readyBubbleAsset;
  final String? specialBubbleAsset;
  final String? rainbowBubbleAsset;
  final String? aimDotAsset;

  /// When true the game draws glossy canvas bubbles instead of loading
  /// per-colour sprite sheets. Used by the illustrated jungle theme.
  final bool useProceduralBubbles;

  /// Visual style of the launcher. 'standard' draws the metal barrel,
  /// 'carrot' draws the illustrated carrot pot from the jungle theme.
  final String cannonStyle;

  const ThemeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.skyAsset,
    required this.distantAsset,
    required this.midgroundAsset,
    required this.leftDecorationAsset,
    required this.rightDecorationAsset,
    required this.bottomDecorationAsset,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.gradientBackground,
    required this.cannonColor,
    required this.accentColor,
    required this.particleType,
    required this.bubbleSkinType,
    required this.particleColors,
    this.unlockCostCoins = 0,
    this.unlockCostGems = 0,
    this.isDefault = false,
    this.cannonBaseAsset,
    this.readyBubbleAsset,
    this.specialBubbleAsset,
    this.rainbowBubbleAsset,
    this.aimDotAsset,
    this.useProceduralBubbles = false,
    this.cannonStyle = 'standard',
  });
}
