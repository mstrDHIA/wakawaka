import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../providers/player_provider.dart';
import '../../../../../../providers/playlist_provider.dart';

class TrackInfo extends StatelessWidget {
  const TrackInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Track title
        Consumer<PlaylistProvider>(
          builder: (context, playlist, _) {
            final track = playlist.currentTrack;
            String title;
            if (track != null && track.title.isNotEmpty) {
              title = track.title;
            } else if (track != null) {
              title = track.url;
            } else {
              title = 'No track selected';
            }
            return Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF0F0FF),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Status label
        Consumer<PlayerProvider>(
          builder: (context, player, _) {
            final statusColor = _statusColor(player.status);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _statusLabel(player.status),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (player.status == PlaybackStatus.error &&
                    (player.errorMessage?.isNotEmpty ?? false))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      player.errorMessage!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF44336),
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        // Timer
        Consumer<PlayerProvider>(
          builder: (context, player, _) {
            final pos = _formatDuration(player.position);
            final dur = _formatDuration(player.duration);
            return Text(
              '$pos / $dur',
              style: const TextStyle(color: Color(0xFF6666AA), fontSize: 12),
            );
          },
        ),
      ],
    );
  }

  Color _statusColor(dynamic status) {
    switch (status.toString()) {
      case 'PlaybackStatus.playing':
        return const Color(0xFF4CAF50);
      case 'PlaybackStatus.paused':
        return const Color(0xFFFF9800);
      case 'PlaybackStatus.loading':
        return const Color(0xFFC264FE);
      case 'PlaybackStatus.error':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF6666AA);
    }
  }

  String _statusLabel(dynamic status) {
    switch (status.toString()) {
      case 'PlaybackStatus.playing':
        return 'Playing';
      case 'PlaybackStatus.paused':
        return 'Paused';
      case 'PlaybackStatus.loading':
        return 'Loading...';
      case 'PlaybackStatus.error':
        return 'Error';
      default:
        return 'Stopped';
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
