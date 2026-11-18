import 'package:flutter/material.dart';

enum BubbleColor {
  red,
  blue,
  green,
  yellow,
  purple,
  orange,
  cyan,
  pink,
  // Special non-matching / powerup colors
  rainbow,
  bomb,
  lightning,
  stone,
  ice,
}

extension BubbleColorX on BubbleColor {
  Color get color {
    switch (this) {
      case BubbleColor.red:
        return const Color(0xFFFF4B4B);
      case BubbleColor.blue:
        return const Color(0xFF29B6F6);
      case BubbleColor.green:
        return const Color(0xFF66BB6A);
      case BubbleColor.yellow:
        return const Color(0xFFFFCA28);
      case BubbleColor.purple:
        return const Color(0xFFAB47BC);
      case BubbleColor.orange:
        return const Color(0xFFFF7043);
      case BubbleColor.cyan:
        return const Color(0xFF26C6DA);
      case BubbleColor.pink:
        return const Color(0xFFEC407A);
      case BubbleColor.rainbow:
        return const Color(0xFFFFFFFF);
      case BubbleColor.bomb:
        return const Color(0xFF37474F);
      case BubbleColor.lightning:
        return const Color(0xFFFFD54F);
      case BubbleColor.stone:
        return const Color(0xFF78909C);
      case BubbleColor.ice:
        return const Color(0xFFE0F7FA);
    }
  }

  Color get secondaryColor {
    switch (this) {
      case BubbleColor.red:
        return const Color(0xFFB71C1C);
      case BubbleColor.blue:
        return const Color(0xFF0277BD);
      case BubbleColor.green:
        return const Color(0xFF2E7D32);
      case BubbleColor.yellow:
        return const Color(0xFFF57F17);
      case BubbleColor.purple:
        return const Color(0xFF6A1B9A);
      case BubbleColor.orange:
        return const Color(0xFFD84315);
      case BubbleColor.cyan:
        return const Color(0xFF00838F);
      case BubbleColor.pink:
        return const Color(0xFFAD1457);
      case BubbleColor.rainbow:
        return const Color(0xFF8E24AA);
      case BubbleColor.bomb:
        return const Color(0xFF212121);
      case BubbleColor.lightning:
        return const Color(0xFFFF8F00);
      case BubbleColor.stone:
        return const Color(0xFF37474F);
      case BubbleColor.ice:
        return const Color(0xFF80DEEA);
    }
  }

  bool get isSpecial =>
      this == BubbleColor.rainbow ||
      this == BubbleColor.bomb ||
      this == BubbleColor.lightning ||
      this == BubbleColor.stone ||
      this == BubbleColor.ice;

  bool get isObstacle => this == BubbleColor.stone || this == BubbleColor.ice;

  String get spriteAssetPath {
    switch (this) {
      case BubbleColor.red:
        return 'game/bubbles/bubble_red.png';
      case BubbleColor.blue:
      case BubbleColor.cyan:
        return 'game/bubbles/bubble_blue.png';
      case BubbleColor.green:
        return 'game/bubbles/bubble_green.png';
      case BubbleColor.purple:
      case BubbleColor.pink:
        return 'game/bubbles/bubble_purple.png';
      case BubbleColor.yellow:
        return 'game/bubbles/bubble_yellow.png';
      case BubbleColor.orange:
        return 'game/bubbles/bubble_orange.png';
      case BubbleColor.rainbow:
      case BubbleColor.bomb:
      case BubbleColor.lightning:
      case BubbleColor.stone:
      case BubbleColor.ice:
      default:
        return 'game/bubbles/bubble_metallic.png';
    }
  }

  String getThemeSpriteAssetPath(String themeId) {
    if (themeId == 'fantasy_temple') {
      switch (this) {
        case BubbleColor.red:
        case BubbleColor.orange:
          return 'themes/fantasy_temple/bubbles/red.png';
        case BubbleColor.blue:
        case BubbleColor.cyan:
          return 'themes/fantasy_temple/bubbles/blue.png';
        case BubbleColor.green:
          return 'themes/fantasy_temple/bubbles/green.png';
        case BubbleColor.purple:
        case BubbleColor.pink:
          return 'themes/fantasy_temple/bubbles/purple.png';
        case BubbleColor.yellow:
          return 'themes/fantasy_temple/bubbles/yellow.png';
        case BubbleColor.rainbow:
          return 'themes/fantasy_temple/bubbles/rainbow.png';
        case BubbleColor.bomb:
        case BubbleColor.lightning:
        case BubbleColor.stone:
        case BubbleColor.ice:
        default:
          return 'themes/fantasy_temple/bubbles/crystal.png';
      }
    } else if (themeId == 'green_forest') {
      switch (this) {
        case BubbleColor.red:
        case BubbleColor.orange:
          return 'themes/green_forest/bubbles/red_clover.png';
        case BubbleColor.blue:
        case BubbleColor.cyan:
          return 'themes/green_forest/bubbles/blue_clover.png';
        case BubbleColor.green:
          return 'themes/green_forest/bubbles/green_clover.png';
        case BubbleColor.purple:
        case BubbleColor.pink:
          return 'themes/green_forest/bubbles/purple_clover.png';
        case BubbleColor.yellow:
          return 'themes/green_forest/bubbles/yellow_clover.png';
        case BubbleColor.rainbow:
          return 'themes/green_forest/bubbles/green_clover.png';
        case BubbleColor.bomb:
        case BubbleColor.lightning:
        case BubbleColor.stone:
        case BubbleColor.ice:
        default:
          return 'themes/green_forest/bubbles/metallic_special_bubble.png';
      }
    }
    return spriteAssetPath;
  }
}

class BubbleModel {
  final String id;
  final int row;
  final int col;
  final BubbleColor color;
  final bool isPopping;
  final bool isFalling;

  const BubbleModel({
    required this.id,
    required this.row,
    required this.col,
    required this.color,
    this.isPopping = false,
    this.isFalling = false,
  });

  BubbleModel copyWith({
    String? id,
    int? row,
    int? col,
    BubbleColor? color,
    bool? isPopping,
    bool? isFalling,
  }) {
    return BubbleModel(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      color: color ?? this.color,
      isPopping: isPopping ?? this.isPopping,
      isFalling: isFalling ?? this.isFalling,
    );
  }
}
