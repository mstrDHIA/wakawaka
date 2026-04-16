# Wakawaka

A cross-platform YouTube audio player built with Flutter. Stream audio from any YouTube video or playlist — no video download, no ads, just audio.

## Goal

Wakawaka lets you listen to YouTube content as audio on Android, Linux (Ubuntu), and Windows from a single codebase. It manages multiple named playlists, persists them between sessions, and provides a clean dark-themed player interface.

---

## Features

- **Stream YouTube audio** — paste any YouTube URL and play it instantly; no file download required
- **Playlist management** — create, rename, and delete named playlists; add and remove tracks freely
- **Persistent library** — playlists and tracks survive app restarts via local storage
- **Now Playing panel** — shows track thumbnail, title, and channel with live playback status
- **Full transport controls** — play/pause, previous, next, seek bar with elapsed/total time
- **Loop & shuffle** — per-playlist loop-one, loop-all, and shuffle toggles
- **Volume control** — inline slider with mute support
- **Multi-client fallback** — retries multiple YouTube stream sources automatically if one is blocked
- **Dark theme** — deep purple/indigo palette optimized for low-light use

---

## How Wakawaka bypasses YouTube ads

Wakawaka never loads the YouTube website or its player. Instead it talks directly to YouTube's internal streaming APIs, which serve raw audio URLs — no ad insertion pipeline is ever involved.

### 1. Direct stream manifest extraction

`youtube_explode_dart` calls YouTube's private `/youtubei/v1/player` endpoint directly, the same endpoint the official apps use internally. The response is a **stream manifest** — a list of direct CDN URLs for the audio data. Because the request never goes through the web player, YouTube has no opportunity to inject pre-roll or mid-roll ads.

### 2. Client impersonation with multi-client fallback

YouTube's bot-detection is tuned for web browsers. Wakawaka impersonates first-party app clients, tried in this order until one succeeds:

| Priority | Client | Why it works |
|----------|--------|--------------|
| 1 | `androidVr` | Native app path, exempt from "Sign in to confirm" bot challenges |
| 2 | `ios` | Apple app client, treated as trusted first-party |
| 3 | `ios` + `tv` | Paired fallback for restricted content |
| 4 | `ios` + `safari` + `tv` | Broader fallback combo |
| 5 | `mweb` + `mediaConnect` + `tv` | Last resort mobile/connected-TV path |

Android client streams are deliberately **skipped** — Google throttles and signs those URLs in a way that breaks direct playback outside the official Android app.

### 3. Header spoofing as a last resort

If a CDN URL still requires authentication context, `PlayerService.tryPlay()` retries with spoofed HTTP headers that make the request look like it came from Chrome on an Android device:

```
User-Agent: Mozilla/5.0 (Linux; Android 14; Pixel 7) ... Mobile Safari/537.36
Referer:    https://www.youtube.com/
Origin:     https://www.youtube.com
```

Each URL is tried first *without* headers (faster, cleaner), then with YouTube headers, with a 5-second timeout per attempt. Up to 5 candidate URLs are cycled through before giving up.

### 4. Throttle-aware stream ranking

Streams are ranked before playback. Non-throttled streams are preferred over throttled ones, and MP4/AAC containers are preferred over WebM. This avoids the slow-ramp-up behaviour YouTube applies to streams it suspects are being accessed outside its player.

> **Note:** Wakawaka does not interact with YouTube's ad serving infrastructure in any way. It simply uses the same streaming endpoints that official YouTube apps use, without the surrounding player UI that ads are injected into.

---

## Requirements

| Platform | Minimum |
|----------|---------|
| Android  | API 21 (Android 5.0) |
| Linux    | Ubuntu 20.04+ |
| Windows  | Windows 10+ |

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.x** with Dart **3.x**
- Git

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/your-username/wakawaka.git
cd wakawaka/wakawaka
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
# Android (device or emulator)
flutter run

# Linux
flutter run -d linux

# Windows
flutter run -d windows
```

### 4. Build a release APK (Android)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Usage

1. **Create a playlist** — tap the playlist dropdown and choose "New playlist", enter a name.
2. **Add a track** — paste a YouTube URL into the input bar at the bottom of the track list and press Add.
3. **Play** — tap any track in the list to start playback.
4. **Control playback** — use the transport bar to play/pause, skip, seek, adjust volume, or toggle loop/shuffle.
5. **Switch playlists** — select a different playlist from the dropdown; the current playlist keeps its position.
6. **Remove a track** — long-press or swipe a track tile for removal options.

---

## Project Structure

```
lib/
  main.dart                  # Entry point, permission requests, provider setup
  models/                    # Track, Playlist data classes
  services/
    youtube_service.dart     # YouTube URL resolution + multi-client stream fallback
    player_service.dart      # media_kit wrapper, tryPlay with header retry
    storage_service.dart     # shared_preferences persistence
  providers/
    playlist_manager_provider.dart  # Full playlist library
    playlist_provider.dart          # Active playlist + current index
    player_provider.dart            # Playback state, position, error handling
  ui/
    app_theme.dart           # Color constants and ThemeData
    screens/home/            # Home screen and all widgets
```

---

## Tech Stack

| Concern | Package |
|---------|---------|
| YouTube extraction | `youtube_explode_dart` |
| Audio playback | `media_kit` + `media_kit_libs_audio` |
| State management | `provider` |
| Persistent storage | `shared_preferences` |
| HTTP client | `dio` |
| Thumbnails | `cached_network_image` |
| Permissions | `permission_handler` |

---

## License

MIT
