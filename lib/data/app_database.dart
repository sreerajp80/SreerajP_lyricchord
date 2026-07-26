import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:lyricchord/core/constants/app_constants.dart';

part 'app_database.g.dart';

/// The `song_notes` table (schema version 1). Columns match the pure
/// `SongNote` model 1:1 (ported from the Android Room entity).
@DataClassName('SongNoteRow')
class SongNotes extends Table {
  @override
  String get tableName => 'song_notes';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get artist => text().withDefault(const Constant(''))();
  TextColumn get lyrics => text().withDefault(const Constant(''))();
  TextColumn get key => text().withDefault(const Constant('C'))();
  IntColumn get bpm => integer().withDefault(const Constant(120))();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  IntColumn get timestamp => integer()();
}

/// The `setlists` table (schema version 2).
@DataClassName('SetlistRow')
class Setlists extends Table {
  @override
  String get tableName => 'setlists';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

/// The `setlist_items` table linking setlists to ordered song notes.
@DataClassName('SetlistItemRow')
class SetlistItems extends Table {
  @override
  String get tableName => 'setlist_items';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get setlistId => integer().customConstraint(
    'NOT NULL REFERENCES setlists(id) ON DELETE CASCADE',
  )();
  IntColumn get songId => integer().customConstraint(
    'NOT NULL REFERENCES song_notes(id) ON DELETE CASCADE',
  )();
  IntColumn get sortOrder => integer()();
}

/// The drift database plus data access methods for songs and setlists.
@DriftDatabase(tables: [SongNotes, Setlists, SetlistItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test constructor — pass `NativeDatabase.memory()` for an in-memory database.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedClassicSongs();
      await _seedClassicSetlists();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(setlists);
        await m.createTable(setlistItems);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );

  /// All songs, newest activity first, as a live stream.
  Stream<List<SongNoteRow>> watchAllSongs() {
    return (select(
      songNotes,
    )..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  }

  /// All songs read once, newest activity first.
  Future<List<SongNoteRow>> getAllSongs() {
    return (select(
      songNotes,
    )..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).get();
  }

  /// A single song by id as a live stream; emits `null` if it does not exist.
  Stream<SongNoteRow?> watchSongById(int id) {
    return (select(
      songNotes,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// A single song by id, read once. `null` if it does not exist.
  Future<SongNoteRow?> findSongById(int id) {
    return (select(songNotes)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Finds a song matching [title] (case-insensitive). Returns `null` if not found.
  Future<SongNoteRow?> findSongByTitle(String title) {
    final cleanTitle = title.trim().toLowerCase();
    return (select(songNotes)
          ..where((t) => t.title.lower().equals(cleanTitle))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Inserts a song and returns the new row id.
  Future<int> insertSong(SongNotesCompanion song) {
    return into(songNotes).insert(song);
  }

  /// Updates a song by primary key. Returns true if a row was changed.
  Future<bool> updateSong(SongNotesCompanion song) {
    return update(songNotes).replace(song);
  }

  /// Deletes a song by id. Returns the number of rows removed.
  Future<int> deleteSongById(int id) {
    return (delete(songNotes)..where((t) => t.id.equals(id))).go();
  }

  // --- SETLIST METHODS ---

  /// All setlists ordered by most recently updated first.
  Stream<List<SetlistRow>> watchAllSetlists() {
    return (select(
      setlists,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();
  }

  /// Single setlist by id.
  Stream<SetlistRow?> watchSetlistById(int id) {
    return (select(
      setlists,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Watch songs in a setlist in order of sortOrder.
  Stream<List<SongNoteRow>> watchSongsForSetlist(int setlistId) {
    final query =
        select(setlistItems).join([
            innerJoin(songNotes, songNotes.id.equalsExp(setlistItems.songId)),
          ])
          ..where(setlistItems.setlistId.equals(setlistId))
          ..orderBy([OrderingTerm.asc(setlistItems.sortOrder)]);

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(songNotes)).toList(),
    );
  }

  /// Get songs for a setlist snapshot once.
  Future<List<SongNoteRow>> getSongsForSetlist(int setlistId) async {
    final query =
        select(setlistItems).join([
            innerJoin(songNotes, songNotes.id.equalsExp(setlistItems.songId)),
          ])
          ..where(setlistItems.setlistId.equals(setlistId))
          ..orderBy([OrderingTerm.asc(setlistItems.sortOrder)]);

    final rows = await query.get();
    return rows.map((row) => row.readTable(songNotes)).toList();
  }

  /// Inserts a setlist and returns new id.
  Future<int> insertSetlist(SetlistsCompanion setlist) {
    return into(setlists).insert(setlist);
  }

  /// Updates setlist metadata (name, description, updatedAt).
  Future<bool> updateSetlist(SetlistsCompanion setlist) {
    return update(setlists).replace(setlist);
  }

  /// Deletes setlist by id.
  Future<int> deleteSetlistById(int id) {
    return (delete(setlists)..where((t) => t.id.equals(id))).go();
  }

  /// Replaces setlist song items with new ordered song id list.
  Future<void> setSetlistSongs(int setlistId, List<int> songIds) async {
    await transaction(() async {
      await (delete(
        setlistItems,
      )..where((t) => t.setlistId.equals(setlistId))).go();
      for (var i = 0; i < songIds.length; i++) {
        await into(setlistItems).insert(
          SetlistItemsCompanion.insert(
            setlistId: setlistId,
            songId: songIds[i],
            sortOrder: i,
          ),
        );
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      await (update(setlists)..where((t) => t.id.equals(setlistId))).write(
        SetlistsCompanion(updatedAt: Value(now)),
      );
    });
  }

  Future<void> _seedClassicSongs() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await batch((b) {
      b.insertAll(songNotes, [
        SongNotesCompanion.insert(
          title: 'Amazing Grace',
          artist: const Value('Traditional'),
          key: const Value('G'),
          bpm: const Value(80),
          lyrics: const Value(
            '[G]Amazing [G7]Grace, how [C]sweet the [G]sound,\n'
            'That [G]saved a [Em]wretch like [A7]me! [D7]\n'
            'I [G]once was [G7]lost, but [C]now am [G]found,\n'
            'Was [G]blind, but [D7]now I [G]see.',
          ),
          favorite: const Value(true),
          timestamp: now,
        ),
        SongNotesCompanion.insert(
          title: 'House of the Rising Sun',
          artist: const Value('Traditional Folk'),
          key: const Value('Am'),
          bpm: const Value(112),
          lyrics: const Value(
            'There [Am]is a [C]house in [D]New Or[F]leans,\n'
            'They [Am]call the [C]Rising [E]Sun.\n'
            "And it's [Am]been the [C]ruin of [D]many a [F]poor boy,\n"
            "And [Am]God, I [E]know I'm [Am]one. [E]",
          ),
          favorite: const Value(false),
          timestamp: now + 1,
        ),
        SongNotesCompanion.insert(
          title: 'Jingle Bells',
          artist: const Value('James Lord Pierpont'),
          key: const Value('G'),
          bpm: const Value(120),
          lyrics: const Value(
            '[G]Dashing through the snow, in a one-horse open [C]sleigh,\n'
            "O'er the fields we [D7]go, laughing all the [G]way!\n"
            'Bells on bobtails ring, making spirits [C]bright,\n'
            'What fun it is to [D7]ride and sing a sleighing song to[G]night!\n'
            '\n'
            '[G]Jingle bells, jingle bells, jingle all the [G7]way!\n'
            '[C]Oh what fun it [G]is to ride in a [A7]one-horse open [D7]sleigh, hey!\n'
            '[G]Jingle bells, jingle bells, jingle all the [G7]way!\n'
            '[C]Oh what fun it [G]is to ride in a [D7]one-horse open [G]sleigh.',
          ),
          favorite: const Value(false),
          timestamp: now + 2,
        ),
      ]);
    });
  }

  Future<void> _seedClassicSetlists() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final setlistId = await insertSetlist(
      SetlistsCompanion.insert(
        name: 'Sunday Gig',
        description: const Value('Acoustic live setlist'),
        createdAt: now,
        updatedAt: now,
      ),
    );
    // Add seed songs to Sunday Gig setlist in order: Amazing Grace (1), House of Rising Sun (2), Jingle Bells (3)
    await setSetlistSongs(setlistId, const [1, 2, 3]);
  }
}

/// Opens the on-device database file lazily, in the app documents directory.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}
