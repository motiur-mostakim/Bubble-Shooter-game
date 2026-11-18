import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/player_data.dart';

class LocalStorage {
  static const String _playerDataKey = 'bubble_quest_player_data';

  static Future<PlayerData> loadPlayerData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_playerDataKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return const PlayerData();
    }
    try {
      return PlayerData.deserialize(jsonStr);
    } catch (e) {
      return const PlayerData();
    }
  }

  static Future<bool> savePlayerData(PlayerData playerData) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_playerDataKey, playerData.serialize());
  }

  static Future<bool> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_playerDataKey);
  }
}
