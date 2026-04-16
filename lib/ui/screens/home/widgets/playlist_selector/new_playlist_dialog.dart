import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../providers/playlist_manager_provider.dart';

class NewPlaylistDialog extends StatefulWidget {
  const NewPlaylistDialog({super.key});

  @override
  State<NewPlaylistDialog> createState() => _NewPlaylistDialogState();
}

class _NewPlaylistDialogState extends State<NewPlaylistDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Playlist'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Playlist name',
        ),
        onSubmitted: (_) => _create(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _create,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _create() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      context.read<PlaylistManagerProvider>().createPlaylist(name);
      Navigator.of(context).pop();
    }
  }
}
