import 'package:drift/drift.dart';

import 'package:lyricchord/core/errors/app_exception.dart';
import 'package:lyricchord/core/utils/song_copy.dart';
import 'package:lyricchord/data/app_database.dart';
import 'package:lyricchord/models/song_note.dart';

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

  /// All songs read once, newest activity first.
  Future<List<SongNote>> getAllSongs() async {
    try {
      final rows = await _db.getAllSongs();
      return rows.map(_toModel).toList(growable: false);
    } catch (e) {
      throw StorageException('Could not load songs.', cause: e);
    }
  }

  /// A single song by id as a live stream; emits `null` if it does not exist.
  Stream<SongNote?> watchSongById(int id) {
    return _db
        .watchSongById(id)
        .map((row) => row == null ? null : _toModel(row));
  }

  /// One song by id, read once. Returns `null` if it does not exist.
  ///
  /// Used by the editor, which loads the song into its fields and then owns
  /// the text until it is saved.
  Future<SongNote?> findById(int id) async {
    try {
      final row = await _db.findSongById(id);
      return row == null ? null : _toModel(row);
    } catch (e) {
      throw StorageException('Could not open the song.', cause: e);
    }
  }

  /// One song matching [title] (case-insensitive), read once. Returns `null` if not found.
  Future<SongNote?> findByTitle(String title) async {
    try {
      final row = await _db.findSongByTitle(title);
      return row == null ? null : _toModel(row);
    } catch (e) {
      throw StorageException('Could not search for song by title.', cause: e);
    }
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

  /// Saves the auto-scroll speed and measures for one song.
  ///
  /// Writes only those two columns, so `timestamp` stays as it was and the song
  /// keeps its place in the songbook order.
  Future<void> saveScrollSettings(
    int songId, {
    required double speed,
    required int measures,
  }) async {
    try {
      await _db.updateScrollSettings(songId, speed, measures);
    } catch (e) {
      throw StorageException('Could not save the scroll speed.', cause: e);
    }
  }

  /// Flips the starred flag on [song] and saves it.
  ///
  /// Kept here so widgets never have to build a changed copy themselves.
  Future<void> toggleFavorite(SongNote song) {
    return update(song.copyWith(favorite: !song.favorite));
  }

  /// Saves a fresh copy of [song] and returns the new song's id.
  ///
  /// The copy is a new row (id `0` so the database assigns one), titled
  /// `"<title> (Copy)"`, unstarred, and stamped with the current time so it
  /// lands at the top of the songbook. The original is left untouched.
  Future<int> duplicate(SongNote song) {
    return insert(
      song.copyWith(
        id: 0,
        title: copiedTitle(song.title),
        favorite: false,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
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
    scrollSpeed: row.scrollSpeed,
    scrollMeasures: row.scrollMeasures,
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
        scrollSpeed: Value(song.scrollSpeed),
        scrollMeasures: Value(song.scrollMeasures),
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
    scrollSpeed: Value(song.scrollSpeed),
    scrollMeasures: Value(song.scrollMeasures),
  );
}
