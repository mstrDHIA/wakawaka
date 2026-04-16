import 'package:flutter/material.dart';

import 'seek_bar.dart';
import 'transport_buttons.dart';
import 'loop_shuffle_toggles.dart';
import 'volume_slider.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF13132A),
      child: Column(
        children: [
          const SeekBar(),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TransportButtons(),
              const SizedBox(width: 16),
              const LoopShuffleToggles(),
              const SizedBox(width: 16),
              const VolumeSlider(),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
