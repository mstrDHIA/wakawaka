class Track {
  final String url;
  final String title;
  final String thumbnailUrl;

  const Track({
    required this.url,
    this.title = '',
    this.thumbnailUrl = '',
  });

  Track copyWith({String? title, String? thumbnailUrl}) {
    return Track(
      url: url,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      url: json['url'] as String? ?? '',
      title: json['title'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
    );
  }

  @override
  String toString() => title.isNotEmpty ? title : url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track && runtimeType == other.runtimeType && url == other.url;

  @override
  int get hashCode => url.hashCode;
}
