import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../providers/player_provider.dart';

class SeekBar extends StatelessWidget {
  const SeekBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        final value = player.duration.inMilliseconds > 0
            ? player.position.inMilliseconds / player.duration.inMilliseconds
            : 0.0;
        return Slider(
          value: value.clamp(0.0, 1.0),
          onChanged: (v) {
            // Optimistic local preview — handled by slider itself
          },
          onChangeEnd: (v) {
            player.seek(v);
          },
        );
      },
    );
  }
}
