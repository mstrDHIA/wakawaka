import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/track.dart';
import '../providers/playlist_provider.dart';
import '../services/player_service.dart';
import '../services/youtube_service.dart';

enum PlaybackStatus { stopped, loading, playing, paused, error }

class PlayerProvider extends ChangeNotifier {
  final PlayerService _player;
  final YoutubeService _youtube;
  PlaylistProvider? _playlistProvider;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<bool>? _completedSub;
  StreamSubscription<String>? _errorSub;
  Timer? _playbackStartTimeout;
  bool _isAttemptingPlayback = false;
  String? _lastAttemptError;

  PlaybackStatus _status = PlaybackStatus.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 0.8;
  bool _isLooping = false;
  bool _isShuffling = false;
  String? _errorMessage;

  PlayerProvider(this._player, this._youtube) {
    _log('init');
    _playingSub = _player.playingStream.listen((playing) {
      _log('playing stream event: $playing');
      if (playing) {
        _cancelPlaybackStartTimeout();
        if (_status != PlaybackStatus.playing) {
          _status = PlaybackStatus.playing;
          notifyListeners();
        }
      } else if (_status == PlaybackStatus.playing) {
        _status = PlaybackStatus.paused;
        notifyListeners();
      }
    });

    _positionSub = _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _durationSub = _player.durationStream.listen((dur) {
      _duration = dur;
      notifyListeners();
    });

    _completedSub = _player.completedStream.listen((completed) {
      _log('completed stream event: $completed');
      if (completed) {
        _onTrackCompleted();
      }
    });

    _errorSub = _player.errorStream.listen((message) {
      if (message.trim().isEmpty) return;
      _log('error stream event: $message');
      if (_isAttemptingPlayback) {
        _lastAttemptError = message;
        return;
      }
      _cancelPlaybackStartTimeout();
      _status = PlaybackStatus.error;
      _errorMessage = message;
      notifyListeners();
    });
  }

  void setPlaylistProvider(PlaylistProvider provider) {
    _playlistProvider = provider;
    _log('playlist provider set');
  }

  // Getters
  PlaybackStatus get status => _status;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  bool get isLooping => _isLooping;
  bool get isShuffling => _isShuffling;
  String? get errorMessage => _errorMessage;
  bool get isPlaying => _status == PlaybackStatus.playing;
  bool get isPaused => _status == PlaybackStatus.paused;

  Future<void> loadAndPlay(Track track) async {
    _log('loadAndPlay start: ${track.url}');
    _status = PlaybackStatus.loading;
    _errorMessage = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    _isAttemptingPlayback = true;
    _lastAttemptError = null;
    notifyListeners();
    _armPlaybackStartTimeout();

    try {
      final (streamUrls, title, thumb) = await _youtube
          .getAudioStreamCandidates(track.url);
      _log('stream candidates count=${streamUrls.length}');

      _playlistProvider?.updateCurrentTrackMeta(title, thumb);

      var started = false;
      final maxAttempts = min(streamUrls.length, 5);
      for (var i = 0; i < maxAttempts; i++) {
        final streamUrl = streamUrls[i];
        _log('attempt ${i + 1}/$maxAttempts -> ${_shortUrl(streamUrl)}');
        final success = await _player.tryPlay(streamUrl);
        if (success) {
          _log('attempt ${i + 1} succeeded');
          started = true;
          break;
        }
        _log('attempt ${i + 1} failed');
      }

      if (!started) {
        final details = _lastAttemptError?.isNotEmpty == true
            ? _lastAttemptError
            : 'No candidate stream URL could be opened.';
        throw Exception(details);
      }

      await _player.setVolume(_volume);
      _isAttemptingPlayback = false;
      _log('loadAndPlay success');
    } catch (e) {
      _isAttemptingPlayback = false;
      _cancelPlaybackStartTimeout();
      _status = PlaybackStatus.error;
      _errorMessage = _buildUserFacingError(e);
      _log('loadAndPlay error: $_errorMessage');
      notifyListeners();
    }
  }

  Future<void> pause() async {
    _log('pause');
    await _player.pause();
    _status = PlaybackStatus.paused;
    notifyListeners();
  }

  Future<void> resume() async {
    _log('resume');
    await _player.resume();
    _status = PlaybackStatus.playing;
    notifyListeners();
  }

  Future<void> stop() async {
    _log('stop');
    await _player.stop();
    _cancelPlaybackStartTimeout();
    _status = PlaybackStatus.stopped;
    notifyListeners();
  }

  Future<void> seek(double fraction) async {
    if (_duration.inMilliseconds > 0) {
      final position = _duration * fraction;
      _log('seek fraction=$fraction to $position');
      await _player.seek(position);
    }
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    _log('setVolume $_volume');
    await _player.setVolume(_volume);
    notifyListeners();
  }

  Future<void> toggleLoop() async {
    _isLooping = !_isLooping;
    if (_isLooping) _isShuffling = false;
    _log('toggleLoop -> $_isLooping');
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    _isShuffling = !_isShuffling;
    if (_isShuffling) _isLooping = false;
    _log('toggleShuffle -> $_isShuffling');
    notifyListeners();
  }

  void _onTrackCompleted() {
    _log('_onTrackCompleted loop=$_isLooping shuffle=$_isShuffling');
    _cancelPlaybackStartTimeout();
    if (_isLooping) {
      final track = _playlistProvider?.currentTrack;
      if (track != null) {
        _log('replaying same track');
        loadAndPlay(track);
      }
    } else if (_isShuffling) {
      final tracks = _playlistProvider?.tracks;
      if (tracks != null && tracks.isNotEmpty) {
        final random = Random();
        final randomIndex = random.nextInt(tracks.length);
        _log('shuffle jump index=$randomIndex');
        _playlistProvider?.jumpTo(randomIndex);
        final track = _playlistProvider?.currentTrack;
        if (track != null) {
          loadAndPlay(track);
        }
      } else {
        _status = PlaybackStatus.stopped;
        notifyListeners();
      }
    } else if (_playlistProvider?.hasNext ?? false) {
      _playlistProvider?.next();
      final track = _playlistProvider?.currentTrack;
      if (track != null) {
        _log('auto next track');
        loadAndPlay(track);
      }
    } else {
      _log('playlist ended -> stopped');
      _status = PlaybackStatus.stopped;
      notifyListeners();
    }
  }

  void _armPlaybackStartTimeout() {
    _cancelPlaybackStartTimeout();
    _playbackStartTimeout = Timer(const Duration(seconds: 30), () {
      if (_status == PlaybackStatus.loading) {
        _status = PlaybackStatus.error;
        _errorMessage =
            'Playback could not start. This usually means the stream URL was blocked or expired.';
        _log('playback start timeout');
        notifyListeners();
      }
    });
    _log('playback timeout armed');
  }

  void _cancelPlaybackStartTimeout() {
    _playbackStartTimeout?.cancel();
    _playbackStartTimeout = null;
  }

  @override
  void dispose() {
    _log('dispose');
    _cancelPlaybackStartTimeout();
    _playingSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _completedSub?.cancel();
    _errorSub?.cancel();
    unawaited(_player.dispose());
    _youtube.dispose();
    super.dispose();
  }

  void _log(String message) {
    debugPrint('[PlayerProvider] $message');
  }

  String _buildUserFacingError(Object error) {
    final raw = error.toString();
    final lower = raw.toLowerCase();

    if (lower.contains("sign in to confirm you’re not a bot") ||
        lower.contains("sign in to confirm you're not a bot")) {
      return 'YouTube is blocking stream extraction for this network/IP (not-a-bot challenge). Try another network, wait, then retry.';
    }
    if (lower.contains('videounplayableexception')) {
      return 'This YouTube video is currently blocked for direct audio extraction. Try another video or retry later.';
    }
    return 'Failed to play: $raw';
  }

  String _shortUrl(String url) {
    if (url.length <= 110) return url;
    return '${url.substring(0, 80)}...${url.substring(url.length - 25)}';
  }
}
