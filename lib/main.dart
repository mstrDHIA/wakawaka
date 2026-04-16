import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'providers/playlist_manager_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/player_provider.dart';
import 'services/storage_service.dart';
import 'services/youtube_service.dart';
import 'services/player_service.dart';
import 'ui/app_theme.dart';
import 'ui/screens/home/home_screen.dart';

Future<void> _requestPermissions() async {
  await Permission.notification.request();
  await Permission.bluetoothConnect.request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await _requestPermissions();
  runApp(const WakawakaApp());
}

class WakawakaApp extends StatelessWidget {
  const WakawakaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. PlaylistManagerProvider — manages all playlists
        ChangeNotifierProvider(
          create: (_) => PlaylistManagerProvider(StorageService()),
        ),
        // 2. PlaylistProvider — manages active playlist tracks + index
        ChangeNotifierProvider(
          create: (ctx) {
            final provider = PlaylistProvider(YoutubeService());
            // Link to manager once available
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final manager = ctx.read<PlaylistManagerProvider>();
              provider.setManager(manager);
              provider.updateFrom(manager);
            });
            return provider;
          },
        ),
        // 3. PlayerProvider — manages audio playback
        ChangeNotifierProvider(
          create: (ctx) {
            final provider = PlayerProvider(
              PlayerService(),
              YoutubeService(),
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final playlistProvider = ctx.read<PlaylistProvider>();
              provider.setPlaylistProvider(playlistProvider);
            });
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Wakawaka',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
