/// One song sheet — the single domain entity of LyricCord.
///
/// Ported 1:1 from the Android Room `SongNote` entity. Immutable: use
/// [copyWith] to make a changed copy instead of mutating in place. This model
/// is pure — it has no drift or database imports so the domain layer stays free
/// of storage details.
class SongNote {
  /// Primary key. `0` means "not yet saved" (the database assigns the real id).
  final int id;

  /// Song title.
  final String title;

  /// Artist / band. May be empty.
  final String artist;

  /// Lyrics with inline `[Chord]` markers.
  final String lyrics;

  /// Original key (e.g. `C`, `Am`).
  final String key;

  /// Tempo in beats per minute.
  final int bpm;

  /// Whether the song is starred.
  final bool favorite;

  /// Last-modified time, in milliseconds since the Unix epoch.
  final int timestamp;

  const SongNote({
    this.id = 0,
    required this.title,
    this.artist = '',
    this.lyrics = '',
    this.key = 'C',
    this.bpm = 120,
    this.favorite = false,
    required this.timestamp,
  });

  SongNote copyWith({
    int? id,
    String? title,
    String? artist,
    String? lyrics,
    String? key,
    int? bpm,
    bool? favorite,
    int? timestamp,
  }) {
    return SongNote(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      lyrics: lyrics ?? this.lyrics,
      key: key ?? this.key,
      bpm: bpm ?? this.bpm,
      favorite: favorite ?? this.favorite,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SongNote &&
        other.id == id &&
        other.title == title &&
        other.artist == artist &&
        other.lyrics == lyrics &&
        other.key == key &&
        other.bpm == bpm &&
        other.favorite == favorite &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, artist, lyrics, key, bpm, favorite, timestamp);

  @override
  String toString() =>
      'SongNote(id: $id, title: $title, artist: $artist, key: $key, '
      'bpm: $bpm, favorite: $favorite)';
}
