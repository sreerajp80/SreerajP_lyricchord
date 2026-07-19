import 'package:drift/drift.dart';

import 'package:lyriccord/core/errors/app_exception.dart';
import 'package:lyriccord/data/app_database.dart';
import 'package:lyriccord/models/song_note.dart';

/// Data access for songs. Wraps the drift [AppDatabase] and exposes only pure
/// [SongNote] models and streams, so callers never see drift row types.
///
/// Database failures are wrapped in [StorageException] (architecture §10) so the
/// UI can show a `SnackBar` instead of crashing.
class SongRepository {
  final AppDatabase _db;

  SongRepository(this._db);

  /// All songs, newest activity first, as a live stream.
  Stream<List<SongNote>> watchAllSongs() {
    return _db.watchAllSongs().map(
      (rows) => rows.map(_toModel).toList(growable: false),
    );
  }

  /// A single song by id as a live stream; emits `null` if it does not exist.
  Stream<SongNote?> watchSongById(int id) {
    return _db
        .watchSongById(id)
        .map((row) => row == null ? null : _toModel(row));
  }

  /// Inserts a new song and returns its assigned id.
  Future<int> insert(SongNote song) async {
    try {
      return await _db.insertSong(_toInsertCompanion(song));
    } catch (e) {
      throw StorageException('Could not save the song.', cause: e);
    }
  }

  /// Updates an existing song (matched by [SongNote.id]).
  Future<void> update(SongNote song) async {
    try {
      await _db.updateSong(_toRowCompanion(song));
    } catch (e) {
      throw StorageException('Could not update the song.', cause: e);
    }
  }

  /// Deletes a song by id.
  Future<void> delete(int id) async {
    try {
      await _db.deleteSongById(id);
    } catch (e) {
      throw StorageException('Could not delete the song.', cause: e);
    }
  }

  SongNote _toModel(SongNoteRow row) => SongNote(
    id: row.id,
    title: row.title,
    artist: row.artist,
    lyrics: row.lyrics,
    key: row.key,
    bpm: row.bpm,
    favorite: row.favorite,
    timestamp: row.timestamp,
  );

  /// For inserts: omit `id` so the database assigns it.
  SongNotesCompanion _toInsertCompanion(SongNote song) =>
      SongNotesCompanion.insert(
        title: song.title,
        artist: Value(song.artist),
        lyrics: Value(song.lyrics),
        key: Value(song.key),
        bpm: Value(song.bpm),
        favorite: Value(song.favorite),
        timestamp: song.timestamp,
      );

  /// For updates/replace: include the `id` so drift matches the right row.
  SongNotesCompanion _toRowCompanion(SongNote song) => SongNotesCompanion(
    id: Value(song.id),
    title: Value(song.title),
    artist: Value(song.artist),
    lyrics: Value(song.lyrics),
    key: Value(song.key),
    bpm: Value(song.bpm),
    favorite: Value(song.favorite),
    timestamp: Value(song.timestamp),
  );
}
