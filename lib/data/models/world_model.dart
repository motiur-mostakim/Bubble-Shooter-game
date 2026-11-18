import 'package:flutter/material.dart';

class WorldModel {
  final int id;
  final String name;
  final String description;
  final String themeId;
  final Color primaryColor;
  final Color accentColor;
  final List<Color> backgroundGradient;
  final int requiredStarsToUnlock;
  final int startLevel;
  final int endLevel;

  const WorldModel({
    required this.id,
    required this.name,
    required this.description,
    required this.themeId,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundGradient,
    required this.requiredStarsToUnlock,
    required this.startLevel,
    required this.endLevel,
  });
}
