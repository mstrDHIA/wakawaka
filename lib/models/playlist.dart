import 'track.dart';

class Playlist {
  final String name;
  final List<Track> tracks;

  const Playlist({
    required this.name,
    this.tracks = const [],
  });

  Playlist copyWith({String? name, List<Track>? tracks}) {
    return Playlist(
      name: name ?? this.name,
      tracks: tracks ?? this.tracks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tracks': tracks.map((t) => t.toJson()).toList(),
    };
  }

  factory Playlist.fromJson(String name, List<dynamic> tracksJson) {
    final tracks = tracksJson
        .map((json) => Track.fromJson(json as Map<String, dynamic>))
        .toList();
    return Playlist(name: name, tracks: tracks);
  }
}
