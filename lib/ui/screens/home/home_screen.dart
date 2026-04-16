import 'package:flutter/material.dart';

import 'widgets/playlist_selector/playlist_selector.dart';
import 'widgets/track_list/track_list_panel.dart';
import 'widgets/now_playing/now_playing_panel.dart';
import 'widgets/player_controls/player_controls.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar — Playlist selector
            const PlaylistSelector(),
            // Main content area
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 600) {
                    // Wide layout: NowPlaying + TrackList side by side
                    return const Row(
                      children: [
                        NowPlayingPanel(),
                        Expanded(
                          child: TrackListPanel(),
                        ),
                      ],
                    );
                  } else {
                    // Narrow layout: stacked vertically
                    return const Column(
                      children: [
                        SizedBox(
                          height: 280,
                          child: NowPlayingPanel(),
                        ),
                        Expanded(
                          child: TrackListPanel(),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            // Bottom bar — Player controls
            const PlayerControls(),
          ],
        ),
      ),
    );
  }
}
