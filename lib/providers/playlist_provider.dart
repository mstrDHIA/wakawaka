import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/playlist.dart';
import '../models/track.dart';
import '../providers/playlist_manager_provider.dart';
import '../services/youtube_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final YoutubeService _youtube;
  PlaylistManagerProvider? _manager;
  Playlist _playlist = const Playlist(name: 'Default');
  int _currentIndex = -1;

  PlaylistProvider(this._youtube);

  void setManager(PlaylistManagerProvider manager) {
    _manager = manager;
  }

  void updateFrom(PlaylistManagerProvider manager) {
    _manager = manager;
    final active = manager.activePlaylist;
    if (active != null) {
      _playlist = active;
      _currentIndex = -1;
    }
    notifyListeners();
  }

  Playlist get activePlaylist => _playlist;
  int get currentIndex => _currentIndex;
  List<Track> get tracks => _playlist.tracks;
  Track? get currentTrack =>
      (_currentIndex >= 0 && _currentIndex < tracks.length)
          ? tracks[_currentIndex]
          : null;
  bool get hasNext => _currentIndex < tracks.length - 1;
  bool get hasPrev => _currentIndex > 0;
  int get trackCount => tracks.length;

  Future<void> addTrack(String url) async {
    if (url.trim().isEmpty) return;

    final track = Track(url: url.trim());
    final updatedTracks = List<Track>.from(_playlist.tracks)..add(track);
    _playlist = _playlist.copyWith(tracks: updatedTracks);
    _updateManager();
    notifyListeners();

    // Background fetch for metadata
    unawaited(_fetchMeta(url.trim(), updatedTracks.length - 1));
  }

  Future<void> _fetchMeta(String url, int index) async {
    try {
      final title = await _youtube.getTitle(url);
      final thumbnailUrl =
          'https://img.youtube.com/vi/${_parseVideoId(url)}/mqdefault.jpg';
      final updatedTrack = tracks[index].copyWith(
        title: title,
        thumbnailUrl: thumbnailUrl,
      );
      final updatedTracks = List<Track>.from(_playlist.tracks)
        ..[index] = updatedTrack;
      _playlist = _playlist.copyWith(tracks: updatedTracks);
      _updateManager();
      notifyListeners();
    } catch (e) {
      // Keep track with empty title — user can see URL instead
    }
  }

  String _parseVideoId(String url) {
    try {
      final match = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11})').firstMatch(url);
      return match?.group(1) ?? '';
    } catch (e) {
      return '';
    }
  }

  void removeTrack(int index) {
    if (index < 0 || index >= tracks.length) return;
    final updatedTracks = List<Track>.from(_playlist.tracks)..removeAt(index);
    _playlist = _playlist.copyWith(tracks: updatedTracks);
    if (_currentIndex == index) {
      _currentIndex = -1;
    } else if (_currentIndex > index) {
      _currentIndex--;
    }
    _updateManager();
    notifyListeners();
  }

  void clearTracks() {
    _playlist = _playlist.copyWith(tracks: []);
    _currentIndex = -1;
    _updateManager();
    notifyListeners();
  }

  void jumpTo(int index) {
    if (index < 0 || index >= tracks.length) return;
    _currentIndex = index;
    notifyListeners();
  }

  void next() {
    if (hasNext) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void prev() {
    if (hasPrev) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void updateCurrentTrackMeta(String title, String thumbnailUrl) {
    if (_currentIndex < 0 || _currentIndex >= tracks.length) return;
    final updatedTrack = tracks[_currentIndex].copyWith(
      title: title,
      thumbnailUrl: thumbnailUrl,
    );
    final updatedTracks = List<Track>.from(_playlist.tracks)
      ..[_currentIndex] = updatedTrack;
    _playlist = _playlist.copyWith(tracks: updatedTracks);
    _updateManager();
    notifyListeners();
  }

  void _updateManager() {
    _manager?.updatePlaylist(_playlist);
  }
}
