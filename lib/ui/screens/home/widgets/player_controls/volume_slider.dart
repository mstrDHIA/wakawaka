import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../providers/player_provider.dart';

class VolumeSlider extends StatelessWidget {
  const VolumeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.volume_down, size: 20, color: Color(0xFF6666AA)),
            SizedBox(
              width: 100,
              child: Slider(
                value: player.volume,
                onChanged: (v) => player.setVolume(v),
              ),
            ),
            const Icon(Icons.volume_up, size: 20, color: Color(0xFF6666AA)),
          ],
        );
      },
    );
  }
}
