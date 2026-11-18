import '../../core/storage/local_storage.dart';
import '../models/player_data.dart';

abstract class PlayerRepository {
  Future<PlayerData> loadPlayer();
  Future<void> savePlayer(PlayerData player);
  Future<void> resetProgress();
}

class LocalPlayerRepository implements PlayerRepository {
  PlayerData? _cachedPlayer;

  @override
  Future<PlayerData> loadPlayer() async {
    if (_cachedPlayer != null) return _cachedPlayer!;
    _cachedPlayer = await LocalStorage.loadPlayerData();
    return _cachedPlayer!;
  }

  @override
  Future<void> savePlayer(PlayerData player) async {
    _cachedPlayer = player;
    await LocalStorage.savePlayerData(player);
  }

  @override
  Future<void> resetProgress() async {
    _cachedPlayer = const PlayerData();
    await LocalStorage.resetProgress();
  }
}
