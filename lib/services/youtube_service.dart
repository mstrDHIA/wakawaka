import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  /// Extracts audio stream URL, title, and thumbnail URL from a YouTube video URL.
  /// Returns (streamUrl, title, thumbnailUrl).
  Future<(String, String, String)> getAudioStream(String url) async {
    final (candidates, title, thumbnailUrl) = await getAudioStreamCandidates(
      url,
    );
    return (candidates.first, title, thumbnailUrl);
  }

  /// Extracts candidate audio stream URLs (ordered by compatibility), title, and thumbnail URL.
  /// Returns (streamUrls, title, thumbnailUrl).
  Future<(List<String>, String, String)> getAudioStreamCandidates(
    String url,
  ) async {
    _log('getAudioStreamCandidates: input=$url');
    try {
      final videoIdStr = _parseVideoId(url);
      if (videoIdStr == null) {
        throw Exception('Could not parse video ID from URL: $url');
      }
      _log('parsed videoId=$videoIdStr');

      final videoId = VideoId(videoIdStr);
      final manifest = await _loadManifestWithFallback(videoId);
      _log(
        'manifest loaded: audioOnly=${manifest.audioOnly.length}, hls=${manifest.hls.length}',
      );
      final candidateUrls = _pickAudioStreamCandidates(manifest);

      final thumbnailUrl =
          'https://img.youtube.com/vi/${videoId.value}/mqdefault.jpg';

      final video = await _yt.videos.get(videoId);
      final title = video.title;
      _log('video metadata loaded: title="$title"');
      _log(
        'candidate URLs (${candidateUrls.length}): ${candidateUrls.map(_shortUrl).join(' | ')}',
      );

      return (candidateUrls, title, thumbnailUrl);
    } catch (e) {
      _log('getAudioStreamCandidates failed: $e');
      throw Exception('Failed to extract audio: $e');
    }
  }

  /// Fast path — fetches title only, used for background metadata update after addTrack.
  Future<String> getTitle(String url) async {
    try {
      final videoIdStr = _parseVideoId(url);
      if (videoIdStr == null) return '';

      final videoId = VideoId(videoIdStr);
      final video = await _yt.videos.get(videoId);
      return video.title;
    } catch (e) {
      return '';
    }
  }

  String? _parseVideoId(String url) {
    try {
      return VideoId.parseVideoId(url);
    } catch (e) {
      _log('parse video ID failed: $e');
      return null;
    }
  }

  List<String> _pickAudioStreamCandidates(StreamManifest manifest) {
    final audioStreams = manifest.audioOnly.toList();
    if (audioStreams.isEmpty) {
      throw Exception('No audio streams found for this video.');
    }

    _log('audio-only raw stream dump:');
    for (final stream in audioStreams) {
      final c = stream.url.queryParameters['c'] ?? 'unknown';
      _log(
        '  itag=${stream.tag} c=$c container=${stream.container.name} bitrate=${stream.bitrate.bitsPerSecond}',
      );
    }

    final rankedAudioOnly = List<AudioOnlyStreamInfo>.from(audioStreams)
      ..sort((a, b) {
        final aPriority = _audioPriority(a);
        final bPriority = _audioPriority(b);
        if (aPriority != bPriority) return aPriority.compareTo(bPriority);
        return b.bitrate.compareTo(a.bitrate);
      });

    final rankedHls = manifest.hls.whereType<HlsAudioStreamInfo>().toList()
      ..sort((a, b) => b.bitrate.compareTo(a.bitrate));

    final urls = LinkedHashSet<String>();
    for (final stream in rankedAudioOnly.take(6)) {
      if (_isAndroidClientStream(stream.url)) {
        _log('  skip android stream itag=${stream.tag}');
        continue;
      }
      urls.add(stream.url.toString());
    }
    for (final stream in rankedHls.take(3)) {
      if (_isAndroidClientStream(stream.url)) {
        _log('  skip android hls stream itag=${stream.tag}');
        continue;
      }
      urls.add(stream.url.toString());
    }

    // Last resort: if all filtered out, keep at least a few originals.
    if (urls.isEmpty) {
      _log('all candidates were filtered; adding unfiltered fallback URLs');
      for (final stream in rankedAudioOnly.take(3)) {
        urls.add(stream.url.toString());
      }
    }

    if (urls.isEmpty) {
      throw Exception('No playable audio stream URLs found.');
    }
    return urls.toList(growable: false);
  }

  int _audioPriority(AudioOnlyStreamInfo stream) {
    final containerRank = switch (stream.container) {
      StreamContainer.mp4 => 0,
      StreamContainer.webM => 1,
      _ => 2,
    };

    // Prefer non-throttled URLs first.
    final throttleRank = stream.isThrottled ? 1 : 0;
    return containerRank * 10 + throttleRank;
  }

  bool _isAndroidClientStream(Uri uri) {
    final client = (uri.queryParameters['c'] ?? '').toUpperCase();
    return client.startsWith('ANDROID');
  }

  Future<StreamManifest> _loadManifestWithFallback(VideoId videoId) async {
    final strategies =
        <
          ({String name, List<YoutubeApiClient> clients, bool requireWatchPage})
        >[
          // androidVr uses a native app path that is not subject to the
          // "Sign in to confirm you're not a bot" web-client challenge.
          (
            name: 'androidVr watch',
            clients: [YoutubeApiClient.androidVr],
            requireWatchPage: true,
          ),
          (
            name: 'androidVr no-watch',
            clients: [YoutubeApiClient.androidVr],
            requireWatchPage: false,
          ),
          // ios alone — without safari (WEB clientName) which triggers bot checks.
          (
            name: 'ios watch',
            clients: [YoutubeApiClient.ios],
            requireWatchPage: true,
          ),
          (
            name: 'ios+tv no-watch',
            clients: [YoutubeApiClient.ios, YoutubeApiClient.tv],
            requireWatchPage: false,
          ),
          // Original combos kept as final fallback.
          (
            name: 'ios+safari+tv watch',
            clients: [
              YoutubeApiClient.ios,
              YoutubeApiClient.safari,
              YoutubeApiClient.tv,
            ],
            requireWatchPage: true,
          ),
          (
            name: 'mweb+mediaConnect+tv no-watch',
            clients: [
              YoutubeApiClient.mweb,
              YoutubeApiClient.mediaConnect,
              YoutubeApiClient.tv,
            ],
            requireWatchPage: false,
          ),
        ];

    Object? lastError;
    for (final strategy in strategies) {
      try {
        _log(
          'manifest strategy: ${strategy.name} (watchPage=${strategy.requireWatchPage})',
        );
        final manifest = await _yt.videos.streamsClient.getManifest(
          videoId,
          ytClients: strategy.clients,
          requireWatchPage: strategy.requireWatchPage,
        );
        _log('manifest strategy succeeded: ${strategy.name}');
        return manifest;
      } catch (e) {
        lastError = e;
        _log('manifest strategy failed: ${strategy.name} -> $e');
      }
    }

    throw Exception(lastError ?? 'Unable to load stream manifest.');
  }

  void _log(String message) {
    debugPrint('[YoutubeService] $message');
  }

  String _shortUrl(String url) {
    if (url.length <= 110) return url;
    return '${url.substring(0, 80)}...${url.substring(url.length - 25)}';
  }

  bool isPlaylistUrl(String url) {
    try {
      return Uri.parse(url).queryParameters.containsKey('list');
    } catch (_) {
      return false;
    }
  }

  Stream<(String, String, String)> getPlaylistTracks(String url) async* {
    final listId = Uri.parse(url).queryParameters['list'];
    if (listId == null) throw Exception('No playlist ID in URL');
    _log('getPlaylistTracks: listId=$listId');
    final playlistId = PlaylistId(listId);
    await for (final video in _yt.playlists.getVideos(playlistId)) {
      _log('playlist track: ${video.id.value} "${video.title}"');
      yield (
        'https://www.youtube.com/watch?v=${video.id.value}',
        video.title,
        'https://img.youtube.com/vi/${video.id.value}/mqdefault.jpg',
      );
    }
  }

  void dispose() {
    _log('dispose');
    _yt.close();
  }
}
