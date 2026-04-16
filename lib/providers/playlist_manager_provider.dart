import 'package:flutter/foundation.dart';

import '../models/playlist.dart';
import '../services/storage_service.dart';

class PlaylistManagerProvider extends ChangeNotifier {
  final StorageService _storage;
  Map<String, Playlist> _playlists = {};
  String _activePlaylistName = 'Default';

  PlaylistManagerProvider(this._storage) {
    _init();
  }

  Future<void> _init() async {
    _playlists = await _storage.loadAll();
    if (!_playlists.containsKey(_activePlaylistName)) {
      _activePlaylistName = _playlists.keys.firstOrNull ?? 'Default';
      if (_playlists.isEmpty) {
        _playlists['Default'] = const Playlist(name: 'Default');
      }
    }
    notifyListeners();
  }

  Map<String, Playlist> get playlists => Map.unmodifiable(_playlists);
  List<String> get playlistNames => _playlists.keys.toList();
  String get activePlaylistName => _activePlaylistName;
  Playlist? get activePlaylist => _playlists[_activePlaylistName];

  Future<void> createPlaylist(String name) async {
    if (_playlists.containsKey(name) || name.trim().isEmpty) return;
    final playlist = Playlist(name: name.trim());
    _playlists[name.trim()] = playlist;
    _activePlaylistName = name.trim();
    notifyListeners();
    await _persist();
  }

  Future<void> deletePlaylist(String name) async {
    if (!_playlists.containsKey(name)) return;
    _playlists.remove(name);
    if (_activePlaylistName == name) {
      _activePlaylistName = _playlists.containsKey('Default')
          ? 'Default'
          : (_playlists.keys.firstOrNull ?? '');
    }
    notifyListeners();
    await _persist();
  }

  Future<void> renamePlaylist(String oldName, String newName) async {
    if (!_playlists.containsKey(oldName) || newName.trim().isEmpty) return;
    final playlist = _playlists.remove(oldName)!;
    // Re-create with new name
    _playlists[newName.trim()] = Playlist(
      name: newName.trim(),
      tracks: playlist.tracks,
    );
    if (_activePlaylistName == oldName) {
      _activePlaylistName = newName.trim();
    }
    notifyListeners();
    await _persist();
  }

  Future<void> switchPlaylist(String name) async {
    if (!_playlists.containsKey(name)) return;
    _activePlaylistName = name;
    notifyListeners();
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    _playlists[playlist.name] = playlist;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    await _storage.saveAll(_playlists);
  }
}
