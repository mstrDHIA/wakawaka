import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../providers/playlist_provider.dart';

class UrlInputBar extends StatefulWidget {
  const UrlInputBar({super.key});

  @override
  State<UrlInputBar> createState() => _UrlInputBarState();
}

class _UrlInputBarState extends State<UrlInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF13132A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Paste YouTube URL...',
              suffixIcon: Icon(Icons.link),
            ),
            onSubmitted: (_) => _addTrack(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addTrack,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6666AA),
                  side: const BorderSide(color: Color(0xFF6666AA)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addTrack() {
    final url = _controller.text.trim();
    if (url.isEmpty) return;
    final provider = context.read<PlaylistProvider>();
    final listId = Uri.tryParse(url)?.queryParameters['list'];
    if (listId != null) {
      unawaited(provider.addPlaylistTracks(url));
    } else {
      provider.addTrack(url);
    }
    _controller.clear();
  }

  void _clear() {
    context.read<PlaylistProvider>().clearTracks();
    _controller.clear();
  }
}
