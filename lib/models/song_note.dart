import 'package:lyricchord/models/pitch_tradition.dart';

/// One song sheet — the single domain entity of LyricChord.
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

  /// Manual auto-scroll speed last used for this song, as a multiplier.
  final double scrollSpeed;

  /// Tempo-Auto length in measures last used for this song.
  final int scrollMeasures;

  /// True once a manual scroll speed has been set for this song.
  ///
  /// False means "never set", so the song opens at the starting speed from
  /// Settings rather than at [scrollSpeed].
  final bool scrollSpeedSet;

  /// Raga name for an Indian song, empty for a Western one (schema version 9).
  final String raga;

  /// Tala name for an Indian song, empty for a Western one (schema version 9).
  ///
  /// Also decides Carnatic vs Hindustani — `PitchNamingService.detect` reads
  /// the tala name, not the raga, because tala names split cleanly between the
  /// two traditions while raga names are often shared.
  final String tala;

  /// Which tradition this song is written in (schema version 9).
  ///
  /// `null` means the song predates the field or was built from text that has
  /// not been classified yet; callers should fall back to [isIndian], which
  /// reads the raga instead. Stored so a typo in a `{raga: …}` header can never
  /// silently turn an Indian sheet Western and let the transposer rewrite its
  /// swaras.
  final PitchTradition? tradition;

  const SongNote({
    this.id = 0,
    required this.title,
    this.artist = '',
    this.lyrics = '',
    this.key = 'C',
    this.bpm = 120,
    this.favorite = false,
    required this.timestamp,
    this.scrollSpeed = 1.0,
    this.scrollMeasures = 32,
    this.scrollSpeedSet = false,
    this.raga = '',
    this.tala = '',
    this.tradition,
  });

  /// True when this song is written in Indian notation — swaras, not chords.
  ///
  /// Prefers the stored [tradition]. Only when that is unset does it fall back
  /// to "does it name a raga", which is what the app did everywhere before the
  /// field existed.
  bool get isIndian => tradition == null
      ? raga.trim().isNotEmpty
      : tradition != PitchTradition.western;

  SongNote copyWith({
    int? id,
    String? title,
    String? artist,
    String? lyrics,
    String? key,
    int? bpm,
    bool? favorite,
    int? timestamp,
    double? scrollSpeed,
    int? scrollMeasures,
    bool? scrollSpeedSet,
    String? raga,
    String? tala,
    PitchTradition? tradition,
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
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      scrollMeasures: scrollMeasures ?? this.scrollMeasures,
      scrollSpeedSet: scrollSpeedSet ?? this.scrollSpeedSet,
      raga: raga ?? this.raga,
      tala: tala ?? this.tala,
      tradition: tradition ?? this.tradition,
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
        other.timestamp == timestamp &&
        other.scrollSpeed == scrollSpeed &&
        other.scrollMeasures == scrollMeasures &&
        other.scrollSpeedSet == scrollSpeedSet &&
        other.raga == raga &&
        other.tala == tala &&
        other.tradition == tradition;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    artist,
    lyrics,
    key,
    bpm,
    favorite,
    timestamp,
    scrollSpeed,
    scrollMeasures,
    scrollSpeedSet,
    raga,
    tala,
    tradition,
  );

  @override
  String toString() =>
      'SongNote(id: $id, title: $title, artist: $artist, key: $key, '
      'bpm: $bpm, favorite: $favorite)';
}
