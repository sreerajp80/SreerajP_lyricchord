import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:lyriccord/core/constants/app_constants.dart';

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

/// The drift database plus the song-notes data access methods.
///
/// Seeds the three classic songs the first time the database is created
/// (matching the Android app's prepopulate callback). Seeding runs only in
/// [MigrationStrategy.onCreate], so a returning user's real songs are never
/// touched.
@DriftDatabase(tables: [SongNotes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test constructor — pass `NativeDatabase.memory()` for an in-memory database.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedClassicSongs();
    },
  );

  /// All songs, newest activity first, as a live stream.
  Stream<List<SongNoteRow>> watchAllSongs() {
    return (select(
      songNotes,
    )..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  }

  /// A single song by id as a live stream; emits `null` if it does not exist.
  Stream<SongNoteRow?> watchSongById(int id) {
    return (select(
      songNotes,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// A single song by id, read once. `null` if it does not exist.
  ///
  /// The editor wants a snapshot, not a live stream — a stream would fight
  /// with what the user is typing.
  Future<SongNoteRow?> findSongById(int id) {
    return (select(songNotes)..where((t) => t.id.equals(id))).getSingleOrNull();
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

  Future<void> _seedClassicSongs() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    // Later index => higher timestamp => shown first (newest activity first),
    // matching the Android insertion order.
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
}

/// Opens the on-device database file lazily, in the app documents directory.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}
