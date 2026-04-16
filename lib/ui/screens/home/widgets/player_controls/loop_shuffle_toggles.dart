import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../providers/player_provider.dart';

class LoopShuffleToggles extends StatelessWidget {
  const LoopShuffleToggles({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.repeat,
                color: player.isLooping
                    ? const Color(0xFFC264FE)
                    : const Color(0xFF6666AA),
              ),
              tooltip: 'Loop',
              onPressed: () => player.toggleLoop(),
            ),
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: player.isShuffling
                    ? const Color(0xFFC264FE)
                    : const Color(0xFF6666AA),
              ),
              tooltip: 'Shuffle',
              onPressed: () => player.toggleShuffle(),
            ),
          ],
        );
      },
    );
  }
}
