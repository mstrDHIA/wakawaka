import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TrackThumbnail extends StatelessWidget {
  final String thumbnailUrl;

  const TrackThumbnail({super.key, required this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF1C1C38),
      ),
      child: thumbnailUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => const Center(
                child: Icon(
                  Icons.music_note,
                  size: 48,
                  color: Color(0xFFC264FE),
                ),
              ),
              errorWidget: (_, __, ___) => const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Color(0xFF6666AA),
                ),
              ),
            )
          : const Center(
              child: Icon(
                Icons.music_note,
                size: 48,
                color: Color(0xFFC264FE),
              ),
            ),
    );
  }
}
