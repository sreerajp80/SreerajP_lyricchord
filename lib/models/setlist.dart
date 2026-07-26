import 'package:lyricchord/models/song_note.dart';

/// Represents a setlist / gig playlist grouping ordered songs.
class Setlist {
  final int id;
  final String name;
  final String description;
  final int createdAt;
  final int updatedAt;
  final List<SongNote> songs;

  const Setlist({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
    this.songs = const [],
  });

  Setlist copyWith({
    int? id,
    String? name,
    String? description,
    int? createdAt,
    int? updatedAt,
    List<SongNote>? songs,
  }) {
    return Setlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      songs: songs ?? this.songs,
    );
  }

  int get songCount => songs.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Setlist &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          _listEquals(songs, other.songs);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    createdAt,
    updatedAt,
    Object.hashAll(songs),
  );

  static bool _listEquals(List<SongNote> a, List<SongNote> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }
}
