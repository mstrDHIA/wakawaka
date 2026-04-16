import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../providers/playlist_provider.dart';
import 'track_thumbnail.dart';
import 'track_info.dart';

class NowPlayingPanel extends StatelessWidget {
  const NowPlayingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF13132A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Now Playing',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6666AA),
            ),
          ),
          const SizedBox(height: 12),
          Consumer<PlaylistProvider>(
            builder: (context, playlist, _) {
              final track = playlist.currentTrack;
              return TrackThumbnail(
                thumbnailUrl: track?.thumbnailUrl ?? '',
              );
            },
          ),
          const SizedBox(height: 12),
          const TrackInfo(),
        ],
      ),
    );
  }
}
