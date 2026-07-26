import 'package:drift/drift.dart';

import 'package:lyricchord/core/errors/app_exception.dart';
import 'package:lyricchord/data/app_database.dart';
import 'package:lyricchord/models/setlist.dart';
import 'package:lyricchord/models/song_note.dart';

/// Data access for setlists / gig playlists.
class SetlistRepository {
  final AppDatabase _db;

  SetlistRepository(this._db);

  /// Watch all setlists with their ordered songs populated.
  Stream<List<Setlist>> watchAllSetlists() {
    return _db.watchAllSetlists().asyncMap((setlistRows) async {
      final list = <Setlist>[];
      for (final row in setlistRows) {
        final songRows = await _db.getSongsForSetlist(row.id);
        list.add(_toModel(row, songRows));
      }
      return list;
    });
  }

  /// Watch single setlist with songs populated.
  Stream<Setlist?> watchSetlistById(int id) {
    return _db.watchSetlistById(id).asyncMap((row) async {
      if (row == null) return null;
      final songRows = await _db.getSongsForSetlist(id);
      return _toModel(row, songRows);
    });
  }

  /// Insert a new setlist and optionally its initial song IDs.
  Future<int> insertSetlist({
    required String name,
    String description = '',
    List<int> songIds = const [],
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await _db.insertSetlist(
        SetlistsCompanion.insert(
          name: name,
          description: Value(description),
          createdAt: now,
          updatedAt: now,
        ),
      );
      if (songIds.isNotEmpty) {
        await _db.setSetlistSongs(id, songIds);
      }
      return id;
    } catch (e) {
      throw StorageException('Could not create setlist.', cause: e);
    }
  }

  /// Update setlist metadata and optionally song list.
  Future<void> updateSetlist({
    required int id,
    required String name,
    String description = '',
    List<int>? songIds,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await (_db.update(_db.setlists)..where((t) => t.id.equals(id))).write(
        SetlistsCompanion(
          name: Value(name),
          description: Value(description),
          updatedAt: Value(now),
        ),
      );
      if (songIds != null) {
        await _db.setSetlistSongs(id, songIds);
      }
    } catch (e) {
      throw StorageException('Could not update setlist.', cause: e);
    }
  }

  /// Reorders or replaces songs in a setlist.
  Future<void> reorderSongs(int setlistId, List<int> songIds) async {
    try {
      await _db.setSetlistSongs(setlistId, songIds);
    } catch (e) {
      throw StorageException('Could not update setlist songs.', cause: e);
    }
  }

  /// Adds a single song to a setlist if it's not already in it.
  Future<void> addSongToSetlist(int setlistId, int songId) async {
    try {
      final currentSongs = await _db.getSongsForSetlist(setlistId);
      final currentIds = currentSongs.map((s) => s.id).toList();
      if (!currentIds.contains(songId)) {
        currentIds.add(songId);
        await _db.setSetlistSongs(setlistId, currentIds);
      }
    } catch (e) {
      throw StorageException('Could not add song to setlist.', cause: e);
    }
  }

  /// Deletes a setlist by id.
  Future<void> deleteSetlist(int id) async {
    try {
      await _db.deleteSetlistById(id);
    } catch (e) {
      throw StorageException('Could not delete setlist.', cause: e);
    }
  }

  Setlist _toModel(SetlistRow row, List<SongNoteRow> songRows) {
    return Setlist(
      id: row.id,
      name: row.name,
      description: row.description,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      songs: songRows.map(_toSongModel).toList(growable: false),
    );
  }

  SongNote _toSongModel(SongNoteRow row) => SongNote(
    id: row.id,
    title: row.title,
    artist: row.artist,
    lyrics: row.lyrics,
    key: row.key,
    bpm: row.bpm,
    favorite: row.favorite,
    timestamp: row.timestamp,
  );
}
