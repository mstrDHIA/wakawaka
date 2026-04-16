import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../providers/playlist_provider.dart';
import 'track_tile.dart';
import 'url_input_bar.dart';

class TrackListPanel extends StatelessWidget {
  const TrackListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Consumer<PlaylistProvider>(
            builder: (context, playlist, _) {
              final tracks = playlist.tracks;
              if (tracks.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.playlist_add,
                        size: 48,
                        color: Color(0xFF6666AA),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No tracks yet',
                        style: TextStyle(color: Color(0xFF6666AA)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Add a YouTube URL below',
                        style: TextStyle(
                          color: Color(0xFF6666AA),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  final isCurrent = index == playlist.currentIndex;
                  return TrackTile(
                    track: track,
                    index: index,
                    isCurrent: isCurrent,
                  );
                },
              );
            },
          ),
        ),
        const UrlInputBar(),
      ],
    );
  }
}
