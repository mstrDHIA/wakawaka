import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../providers/player_provider.dart';
import '../../../../../../providers/playlist_provider.dart';

class TransportButtons extends StatelessWidget {
  const TransportButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          tooltip: 'Previous',
          onPressed: () {
            final playlist = context.read<PlaylistProvider>();
            if (playlist.hasPrev) {
              playlist.prev();
              final track = playlist.currentTrack;
              if (track != null) {
                context.read<PlayerProvider>().loadAndPlay(track);
              }
            }
          },
        ),
        Consumer<PlayerProvider>(
          builder: (context, player, _) {
            return IconButton(
              icon: Icon(
                player.isPlaying ? Icons.pause : Icons.play_arrow,
                color: const Color(0xFFC264FE),
                size: 36,
              ),
              tooltip: player.isPlaying ? 'Pause' : 'Play',
              onPressed: () {
                if (player.isPlaying) {
                  player.pause();
                } else if (player.isPaused) {
                  player.resume();
                } else {
                  final playlist = context.read<PlaylistProvider>();
                  final track = playlist.currentTrack;
                  if (track != null) {
                    player.loadAndPlay(track);
                  }
                }
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          tooltip: 'Next',
          onPressed: () {
            final playlist = context.read<PlaylistProvider>();
            if (playlist.hasNext) {
              playlist.next();
              final track = playlist.currentTrack;
              if (track != null) {
                context.read<PlayerProvider>().loadAndPlay(track);
              }
            }
          },
        ),
      ],
    );
  }
}
