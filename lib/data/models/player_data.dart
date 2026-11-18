import 'dart:convert';

class PlayerData {
  final int coins;
  final int gems;
  final int currentLevel;
  final Map<int, int> levelStars; // levelId -> star count (1-3)
  final Map<int, int> levelScores; // levelId -> best score
  final List<int> unlockedWorlds;
  final List<String> unlockedThemes;
  final String selectedTheme;
  final int rainbowBoosters;
  final int bombBoosters;
  final int lightningBoosters;
  final int extraMovesBoosters;
  final String lastDailyRewardClaimDate;
  final int dailyRewardStreak;
  final List<String> completedMissions;
  final List<String> unlockedAchievements;
  final bool onboardingCompleted;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;

  const PlayerData({
    this.coins = 500,
    this.gems = 20,
    this.currentLevel = 1,
    this.levelStars = const {},
    this.levelScores = const {},
    this.unlockedWorlds = const [1],
    this.unlockedThemes = const ['fantasy_temple', 'green_forest'],
    this.selectedTheme = 'fantasy_temple',
    this.rainbowBoosters = 2,
    this.bombBoosters = 2,
    this.lightningBoosters = 2,
    this.extraMovesBoosters = 2,
    this.lastDailyRewardClaimDate = '',
    this.dailyRewardStreak = 0,
    this.completedMissions = const [],
    this.unlockedAchievements = const [],
    this.onboardingCompleted = false,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
  });

  PlayerData copyWith({
    int? coins,
    int? gems,
    int? currentLevel,
    Map<int, int>? levelStars,
    Map<int, int>? levelScores,
    List<int>? unlockedWorlds,
    List<String>? unlockedThemes,
    String? selectedTheme,
    int? rainbowBoosters,
    int? bombBoosters,
    int? lightningBoosters,
    int? extraMovesBoosters,
    String? lastDailyRewardClaimDate,
    int? dailyRewardStreak,
    List<String>? completedMissions,
    List<String>? unlockedAchievements,
    bool? onboardingCompleted,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
  }) {
    return PlayerData(
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      currentLevel: currentLevel ?? this.currentLevel,
      levelStars: levelStars ?? this.levelStars,
      levelScores: levelScores ?? this.levelScores,
      unlockedWorlds: unlockedWorlds ?? this.unlockedWorlds,
      unlockedThemes: unlockedThemes ?? this.unlockedThemes,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      rainbowBoosters: rainbowBoosters ?? this.rainbowBoosters,
      bombBoosters: bombBoosters ?? this.bombBoosters,
      lightningBoosters: lightningBoosters ?? this.lightningBoosters,
      extraMovesBoosters: extraMovesBoosters ?? this.extraMovesBoosters,
      lastDailyRewardClaimDate:
          lastDailyRewardClaimDate ?? this.lastDailyRewardClaimDate,
      dailyRewardStreak: dailyRewardStreak ?? this.dailyRewardStreak,
      completedMissions: completedMissions ?? this.completedMissions,
      unlockedAchievements:
          unlockedAchievements ?? this.unlockedAchievements,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'gems': gems,
      'currentLevel': currentLevel,
      'levelStars': levelStars.map((k, v) => MapEntry(k.toString(), v)),
      'levelScores': levelScores.map((k, v) => MapEntry(k.toString(), v)),
      'unlockedWorlds': unlockedWorlds,
      'unlockedThemes': unlockedThemes,
      'selectedTheme': selectedTheme,
      'rainbowBoosters': rainbowBoosters,
      'bombBoosters': bombBoosters,
      'lightningBoosters': lightningBoosters,
      'extraMovesBoosters': extraMovesBoosters,
      'lastDailyRewardClaimDate': lastDailyRewardClaimDate,
      'dailyRewardStreak': dailyRewardStreak,
      'completedMissions': completedMissions,
      'unlockedAchievements': unlockedAchievements,
      'onboardingCompleted': onboardingCompleted,
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'hapticsEnabled': hapticsEnabled,
    };
  }

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    Map<int, int> parseMap(dynamic map) {
      if (map is! Map) return {};
      final res = <int, int>{};
      map.forEach((key, value) {
        final k = int.tryParse(key.toString());
        final v = int.tryParse(value.toString());
        if (k != null && v != null) res[k] = v;
      });
      return res;
    }

    return PlayerData(
      coins: json['coins'] ?? 500,
      gems: json['gems'] ?? 20,
      currentLevel: json['currentLevel'] ?? 1,
      levelStars: parseMap(json['levelStars']),
      levelScores: parseMap(json['levelScores']),
      unlockedWorlds: List<int>.from(json['unlockedWorlds'] ?? [1]),
      unlockedThemes:
          List<String>.from(json['unlockedThemes'] ?? ['fantasy_temple', 'green_forest']),
      selectedTheme: json['selectedTheme'] ?? 'fantasy_temple',
      rainbowBoosters: json['rainbowBoosters'] ?? 2,
      bombBoosters: json['bombBoosters'] ?? 2,
      lightningBoosters: json['lightningBoosters'] ?? 2,
      extraMovesBoosters: json['extraMovesBoosters'] ?? 2,
      lastDailyRewardClaimDate: json['lastDailyRewardClaimDate'] ?? '',
      dailyRewardStreak: json['dailyRewardStreak'] ?? 0,
      completedMissions:
          List<String>.from(json['completedMissions'] ?? []),
      unlockedAchievements:
          List<String>.from(json['unlockedAchievements'] ?? []),
      onboardingCompleted: json['onboardingCompleted'] ?? false,
      soundEnabled: json['soundEnabled'] ?? true,
      musicEnabled: json['musicEnabled'] ?? true,
      hapticsEnabled: json['hapticsEnabled'] ?? true,
    );
  }

  String serialize() => jsonEncode(toJson());

  factory PlayerData.deserialize(String source) =>
      PlayerData.fromJson(jsonDecode(source));
}
