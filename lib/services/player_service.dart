import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

class PlayerService {
  static const Map<String, String> _youtubeHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
    'Referer': 'https://www.youtube.com/',
    'Origin': 'https://www.youtube.com',
  };

  late final Player _player;
  late final Stream<bool> _playingStream;
  late final Stream<Duration> _positionStream;
  late final Stream<Duration> _durationStream;
  late final Stream<bool> _completedStream;
  late final Stream<String> _errorStream;

  PlayerService() {
    _log('init player');
    _player = Player(
      configuration: const PlayerConfiguration(title: 'Wakawaka Audio Player'),
    );

    _playingStream = _player.stream.playing;
    _positionStream = _player.stream.position;
    _durationStream = _player.stream.duration;
    _completedStream = _player.stream.completed;
    _errorStream = _player.stream.error;
    _errorStream.listen((message) {
      if (message.trim().isNotEmpty) {
        _log('backend error stream: $message');
      }
    });
  }

  Future<void> play(String url, {Map<String, String>? headers}) async {
    _log(
      'play: url=${_shortUrl(url)}, headers=${headers?.keys.toList() ?? []}',
    );
    final media = Media(url, httpHeaders: headers);
    await _player.open(media, play: true);
  }

  Future<bool> tryPlay(String url) async {
    _log('tryPlay start: ${_shortUrl(url)}');
    final attempts = <({String name, Map<String, String>? headers})>[
      (name: 'no-headers', headers: null),
      (name: 'youtube-headers', headers: _youtubeHeaders),
    ];

    for (final attempt in attempts) {
      _log('tryPlay attempt=${attempt.name}');
      final success = await _openAndAwaitPlayback(
        url,
        headers: attempt.headers,
        timeout: const Duration(seconds: 5),
      );
      if (success) {
        _log('tryPlay success on ${attempt.name}');
        return true;
      }
      _log('tryPlay failed on ${attempt.name}; stopping player');
      await _player.stop();
    }
    _log('tryPlay failed for all attempts: ${_shortUrl(url)}');
    return false;
  }

  Future<void> pause() async {
    _log('pause');
    await _player.pause();
  }

  Future<void> resume() async {
    _log('resume');
    await _player.play();
  }

  Future<void> stop() async {
    _log('stop');
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    _log('seek: $position');
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    _log('setVolume: $volume');
    // media_kit volume is 0-100
    await _player.setVolume((volume * 100).clamp(0.0, 100.0));
  }

  Stream<bool> get playingStream => _playingStream;
  Stream<Duration> get positionStream => _positionStream;
  Stream<Duration> get durationStream => _durationStream;
  Stream<bool> get completedStream => _completedStream;
  Stream<String> get errorStream => _errorStream;

  Future<void> dispose() async {
    _log('dispose');
    await _player.dispose();
  }

  Future<bool> _openAndAwaitPlayback(
    String url, {
    required Map<String, String>? headers,
    required Duration timeout,
  }) async {
    try {
      _log(
        'open+await: url=${_shortUrl(url)}, headers=${headers == null ? 'none' : 'youtube'}',
      );
      await _player
          .open(Media(url, httpHeaders: headers), play: true)
          .timeout(timeout);

      if (_player.state.playing) {
        _log('open+await: player.state.playing=true');
        return true;
      }

      await _player.stream.playing
          .firstWhere((playing) => playing)
          .timeout(timeout);
      _log('open+await: playing stream emitted true');
      return true;
    } on TimeoutException {
      _log('open+await timeout after ${timeout.inSeconds}s');
      return false;
    } catch (e) {
      _log('open+await exception: $e');
      return false;
    }
  }

  void _log(String message) {
    debugPrint('[PlayerService] $message');
  }

  String _shortUrl(String url) {
    if (url.length <= 110) return url;
    return '${url.substring(0, 80)}...${url.substring(url.length - 25)}';
  }
}
