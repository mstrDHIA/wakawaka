import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../providers/playlist_manager_provider.dart';
import 'new_playlist_dialog.dart';

class PlaylistSelector extends StatelessWidget {
  const PlaylistSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF13132A),
      child: Row(
        children: [
          // Dropdown
          Expanded(
            child: Consumer<PlaylistManagerProvider>(
              builder: (context, manager, _) {
                final names = manager.playlistNames;
                final active = manager.activePlaylistName;
                return DropdownButton<String>(
                  value: names.contains(active) ? active : null,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1C1C38),
                  items: names.map((name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFFF0F0FF),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      manager.switchPlaylist(value);
                    }
                  },
                  underline: const SizedBox(),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          // New button
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'New Playlist',
            onPressed: () => _showNewPlaylistDialog(context),
          ),
          // Save button
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () {
              // Persist is automatic; give visual feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Playlist saved!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Playlist',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  void _showNewPlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const NewPlaylistDialog(),
    );
  }

  void _confirmDelete(BuildContext context) {
    final manager = context.read<PlaylistManagerProvider>();
    final name = manager.activePlaylistName;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              manager.deletePlaylist(name);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
