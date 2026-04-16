import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/playlist.dart';

class StorageService {
  static const _key = 'playlists_v1';

  Future<Map<String, Playlist>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null || jsonString.isEmpty) {
        return {'Default': const Playlist(name: 'Default')};
      }

      final Map<String, dynamic> data = jsonDecode(jsonString);
      final result = <String, Playlist>{};

      for (final entry in data.entries) {
        final name = entry.key;
        final tracksJson = entry.value as List;
        result[name] = Playlist.fromJson(name, tracksJson);
      }

      if (result.isEmpty) {
        return {'Default': const Playlist(name: 'Default')};
      }

      return result;
    } catch (e) {
      return {'Default': const Playlist(name: 'Default')};
    }
  }

  Future<void> saveAll(Map<String, Playlist> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonMap = <String, dynamic>{};
      for (final entry in data.entries) {
        jsonMap[entry.key] = entry.value.toJson()['tracks'];
      }
      await prefs.setString(_key, jsonEncode(jsonMap));
    } catch (e) {
      // Silently fail — data will be lost until next successful save
    }
  }
}
