import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../models/track.dart';
import '../../../../../../providers/player_provider.dart';
import '../../../../../../providers/playlist_provider.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final int index;
  final bool isCurrent;

  const TrackTile({
    super.key,
    required this.track,
    required this.index,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = track.title.isNotEmpty ? track.title : track.url;
    return GestureDetector(
      onDoubleTap: () {
        final playlist = context.read<PlaylistProvider>();
        playlist.jumpTo(index);
        final track = playlist.currentTrack;
        if (track != null) {
          context.read<PlayerProvider>().loadAndPlay(track);
        }
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2A2A55),
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Color(0xFF6666AA)),
          ),
        ),
        title: Text(
          displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isCurrent ? const Color(0xFFC264FE) : const Color(0xFFF0F0FF),
          ),
        ),
        selected: isCurrent,
        selectedTileColor: const Color(0xFF3D1A6E),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          onPressed: () {
            context.read<PlaylistProvider>().removeTrack(index);
          },
          tooltip: 'Remove',
        ),
        onTap: () {
          final playlist = context.read<PlaylistProvider>();
          playlist.jumpTo(index);
          final track = playlist.currentTrack;
          if (track != null) {
            context.read<PlayerProvider>().loadAndPlay(track);
          }
        },
      ),
    );
  }
}
