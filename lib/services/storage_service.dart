import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../utils/app_utils.dart';

class StorageService {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveAccount({required String name, required String email, required String password, required String imageBase64}) async {
    final prefs = await _prefs;
    await prefs.setBool('accountCreated', true);
    await prefs.setBool('logged', true);
    await prefs.setString('accountName', name);
    await prefs.setString('accountEmail', email);
    await prefs.setString('accountPassword', password);
    await prefs.setString('profileImageBase64', imageBase64);
    await prefs.setStringList('favorites', []);
    await prefs.setString('customPlayersJson', '[]');
  }

  Future<bool> hasLoggedAccount() async {
    final prefs = await _prefs;
    return (prefs.getBool('logged') ?? false) && (prefs.getBool('accountCreated') ?? false);
  }

  Future<bool> login({required String email, required String password}) async {
    final prefs = await _prefs;
    if (!(prefs.getBool('accountCreated') ?? false)) return false;
    final ok = email == (prefs.getString('accountEmail') ?? '') && password == (prefs.getString('accountPassword') ?? '');
    if (ok) await prefs.setBool('logged', true);
    return ok;
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.setBool('logged', false);
  }

  Future<Map<String, String>> loadUser() async {
    final prefs = await _prefs;
    return {
      'name': prefs.getString('accountName') ?? '',
      'email': prefs.getString('accountEmail') ?? '',
      'image': prefs.getString('profileImageBase64') ?? '',
    };
  }

  Future<void> saveFavorites(List<int> ids) async {
    final prefs = await _prefs;
    await prefs.setStringList('favorites', ids.map((id) => id.toString()).toList());
  }

  Future<List<int>> loadFavorites() async {
    final prefs = await _prefs;
    final values = prefs.getStringList('favorites') ?? [];
    return values.where((e) => int.tryParse(e) != null).map(int.parse).toList();
  }

  Future<void> saveCustomPlayers(List<Player> players) async {
    final prefs = await _prefs;
    await prefs.setString('customPlayersJson', jsonEncode(players.map((p) => p.toJson()).toList()));
  }

  Future<List<Player>> loadCustomPlayers() async {
    final prefs = await _prefs;
    final text = prefs.getString('customPlayersJson') ?? '[]';
    try {
      final decoded = jsonDecode(text);
      if (decoded is List) {
        return decoded.whereType<Map>().map((e) => Player.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> saveSelectedFormation(String name) async {
    final prefs = await _prefs;
    await prefs.setString('formationName', name);
  }

  Future<String?> loadSelectedFormation() async {
    final prefs = await _prefs;
    return prefs.getString('formationName');
  }

  Future<void> saveLineup(String formationName, Map<int, int> lineup) async {
    final prefs = await _prefs;
    await prefs.setStringList(lineupKey(formationName), lineup.entries.map((e) => '${e.key}:${e.value}').toList());
    await prefs.setString('formationName', formationName);
  }

  Future<Map<int, int>> loadLineup(String formationName) async {
    final prefs = await _prefs;
    final values = prefs.getStringList(lineupKey(formationName)) ?? [];
    final map = <int, int>{};
    for (final item in values) {
      final p = item.split(':');
      if (p.length == 2) {
        final k = int.tryParse(p[0]);
        final v = int.tryParse(p[1]);
        if (k != null && v != null) map[k] = v;
      }
    }
    return map;
  }
}
