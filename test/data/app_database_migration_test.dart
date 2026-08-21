import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:lyricchord/data/app_database.dart';
import 'package:lyricchord/repositories/setlist_repository.dart';
import 'package:lyricchord/repositories/song_repository.dart';

/// Builds a schema version 8 database file by hand, using raw sqlite3 so drift
/// never runs its own migration over it.
///
/// [nullableSongTextColumns] reproduces the broken shape seen in the field: an
/// older build added `raga`, `tala` and `tradition` without a NOT NULL default,
/// so the rows hold NULL.
void buildVersion8Database(File file, {required bool nullableSongTextColumns}) {
  final extraColumns = nullableSongTextColumns
      ? ', raga TEXT, tala TEXT, tradition TEXT'
      : '';
  final db = sqlite3.open(file.path);
  db.execute('''
    CREATE TABLE song_notes (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      artist TEXT NOT NULL DEFAULT '',
      lyrics TEXT NOT NULL DEFAULT '',
      key TEXT NOT NULL DEFAULT 'C',
      bpm INTEGER NOT NULL DEFAULT 120,
      favorite INTEGER NOT NULL DEFAULT 0 CHECK (favorite IN (0, 1)),
      timestamp INTEGER NOT NULL,
      scroll_speed REAL NOT NULL DEFAULT 1.0,
      scroll_measures INTEGER NOT NULL DEFAULT 32$extraColumns
    )''');
  db.execute('''
    CREATE TABLE setlists (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL DEFAULT '',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )''');
  db.execute('''
    CREATE TABLE setlist_items (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      setlist_id INTEGER NOT NULL REFERENCES setlists(id) ON DELETE CASCADE,
      song_id INTEGER NOT NULL REFERENCES song_notes(id) ON DELETE CASCADE,
      sort_order INTEGER NOT NULL
    )''');
  db.execute(
    "INSERT INTO song_notes (title, lyrics, timestamp) "
    "VALUES ('Old Western Song', '[C]hello there', 1000)",
  );
  db.execute(
    "INSERT INTO song_notes (title, lyrics, timestamp) "
    "VALUES ('Old Indian Song', '{raga: Mohanam}\n{tala: Adi}\n[Sa]ri ga', 2000)",
  );
  db.execute(
    "INSERT INTO setlists (name, created_at, updated_at) "
    "VALUES ('Old Gig', 1000, 1000)",
  );
  db.execute(
    'INSERT INTO setlist_items (setlist_id, song_id, sort_order) '
    'VALUES (1, 1, 0), (1, 2, 1)',
  );
  db.execute('PRAGMA user_version = 8');
  db.close();
}

/// Builds a schema version 8 database whose *core* song columns are nullable
/// and actually hold NULL.
///
/// This is the worse shape of the same field fault: an old build created
/// `artist`, `lyrics` and `key` without NOT NULL defaults. Drift declares them
/// non-null, so one NULL made reading any song throw and left the songbook
/// permanently empty.
void buildVersion8DatabaseWithNullCoreColumns(File file, {String? lyrics}) {
  final db = sqlite3.open(file.path);
  db.execute('''
    CREATE TABLE song_notes (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      artist TEXT,
      lyrics TEXT,
      key TEXT,
      bpm INTEGER,
      favorite INTEGER,
      timestamp INTEGER NOT NULL,
      scroll_speed REAL,
      scroll_measures INTEGER
    )''');
  db.execute('''
    CREATE TABLE setlists (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL DEFAULT '',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )''');
  db.execute('''
    CREATE TABLE setlist_items (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      setlist_id INTEGER NOT NULL REFERENCES setlists(id) ON DELETE CASCADE,
      song_id INTEGER NOT NULL REFERENCES song_notes(id) ON DELETE CASCADE,
      sort_order INTEGER NOT NULL
    )''');
  // Every nullable column left NULL on purpose.
  db.execute(
    "INSERT INTO song_notes (title, timestamp) VALUES ('All NULL Song', 1000)",
  );
  final stmt = db.prepare(
    'INSERT INTO song_notes (title, lyrics, timestamp) VALUES (?, ?, ?)',
  );
  stmt.execute(['Second Song', lyrics ?? '{raga: Mohanam}\n[Sa]ri ga', 2000]);
  stmt.close();
  db.execute('PRAGMA user_version = 8');
  db.close();
}

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('lyricchord_migration');
    file = File('${dir.path}/app.sqlite');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  group('schema version 9 upgrade', () {
    test('loads setlists from a plain version 8 database', () async {
      buildVersion8Database(file, nullableSongTextColumns: false);

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final setlists = await SetlistRepository(db).watchAllSetlists().first;

      expect(setlists, hasLength(1));
      expect(setlists.single.songCount, 2);
    });

    test(
      'loads setlists when raga/tala/tradition already exist holding NULL',
      () async {
        // This is the crash reported from the Setlists screen: drift declares
        // those columns non-null, so its row mapper's `!` threw "Null check
        // operator used on a null value" and the upgrade never finished.
        buildVersion8Database(file, nullableSongTextColumns: true);

        final db = AppDatabase.forTesting(NativeDatabase(file));
        addTearDown(db.close);

        final setlists = await SetlistRepository(db).watchAllSetlists().first;

        expect(setlists, hasLength(1));
        expect(setlists.single.name, 'Old Gig');
        expect(setlists.single.songCount, 2);
      },
    );

    test('backfills the tradition of an old song with NULL columns', () async {
      buildVersion8Database(file, nullableSongTextColumns: true);

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final songs = await SongRepository(db).watchAllSongs().first;
      final indian = songs.firstWhere((s) => s.title == 'Old Indian Song');
      final western = songs.firstWhere((s) => s.title == 'Old Western Song');

      expect(indian.raga, 'Mohanam');
      expect(indian.tala, 'Adi');
      expect(indian.isIndian, isTrue);

      expect(western.raga, '');
      expect(western.tala, '');
      expect(western.isIndian, isFalse);
    });

    test('leaves the songbook order alone', () async {
      buildVersion8Database(file, nullableSongTextColumns: true);

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final songs = await SongRepository(db).watchAllSongs().first;

      expect(songs.map((s) => s.timestamp), [2000, 1000]);
    });
  });

  group('version 8 database with NULL core song columns', () {
    test('upgrades and reads every song back', () async {
      // The reported symptom: the songbook opened slowly and then showed
      // nothing at all. A NULL `lyrics` made the backfill throw, drift rolled
      // the whole upgrade back, and every later launch repeated the same
      // failed work.
      buildVersion8DatabaseWithNullCoreColumns(file);

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final songs = await SongRepository(db).watchAllSongs().first;

      expect(songs.map((s) => s.title), ['Second Song', 'All NULL Song']);
    });

    test('replaces the NULLs with the declared defaults', () async {
      buildVersion8DatabaseWithNullCoreColumns(file);

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final songs = await SongRepository(db).watchAllSongs().first;
      final blank = songs.firstWhere((s) => s.title == 'All NULL Song');

      expect(blank.artist, '');
      expect(blank.lyrics, '');
      expect(blank.key, 'C');
      expect(blank.bpm, 120);
      expect(blank.favorite, isFalse);
      expect(blank.scrollSpeed, 1.0);
      expect(blank.scrollMeasures, 32);
    });

    test('still backfills the songs it can read', () async {
      buildVersion8DatabaseWithNullCoreColumns(file);

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final songs = await SongRepository(db).watchAllSongs().first;
      final second = songs.firstWhere((s) => s.title == 'Second Song');

      expect(second.raga, 'Mohanam');
      expect(second.isIndian, isTrue);
    });

    test('completes even when a song holds junk lyrics', () async {
      buildVersion8DatabaseWithNullCoreColumns(
        file,
        lyrics: '{raga: ${'x' * 20000}\n{{{[[[]]]}}}\n  {tala:',
      );

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final songs = await SongRepository(db).watchAllSongs().first;

      expect(songs, hasLength(2));
    });
  });
}
