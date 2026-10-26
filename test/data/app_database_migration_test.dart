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
    'INSERT INTO song_notes (title, lyrics, timestamp) '
    "VALUES ('Old Western Song', '[C]hello there', 1000)",
  );
  db.execute(
    'INSERT INTO song_notes (title, lyrics, timestamp) '
    "VALUES ('Old Indian Song', '{raga: Mohanam}\n{tala: Adi}\n[Sa]ri ga', 2000)",
  );
  db.execute(
    'INSERT INTO setlists (name, created_at, updated_at) '
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

/// Builds a schema version 10 database — everything the app had before the
/// `scroll_speed_set` column was added.
void buildVersion10Database(File file) {
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
      scroll_measures INTEGER NOT NULL DEFAULT 32,
      raga TEXT NOT NULL DEFAULT '',
      tala TEXT NOT NULL DEFAULT '',
      tradition TEXT NOT NULL DEFAULT ''
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
    'INSERT INTO song_notes (title, lyrics, timestamp, scroll_speed) '
    "VALUES ('Speed Chosen By Hand', '[C]hello', 1000, 0.4)",
  );
  db.execute(
    'INSERT INTO song_notes (title, lyrics, timestamp) '
    "VALUES ('Speed Never Touched', '[C]hello', 2000)",
  );
  db.execute('PRAGMA user_version = 10');
  db.close();
}

/// Builds a database whose *last* non-null song columns — `title`,
/// `timestamp` and `scroll_speed_set` — and the setlist columns are nullable
/// and hold NULL, stamped at [version].
///
/// The field report: a phone upgraded from an old build showed an empty
/// songbook, and every import failed its duplicate-title check with "Null
/// check operator used on a null value", even after the other columns were
/// repaired.
void buildDatabaseWithNullTitleTimeAndSetlist(
  File file, {
  required int version,
}) {
  final db = sqlite3.open(file.path);
  db.execute('''
    CREATE TABLE song_notes (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      artist TEXT NOT NULL DEFAULT '',
      lyrics TEXT NOT NULL DEFAULT '',
      key TEXT NOT NULL DEFAULT 'C',
      bpm INTEGER NOT NULL DEFAULT 120,
      favorite INTEGER NOT NULL DEFAULT 0,
      timestamp INTEGER,
      scroll_speed REAL NOT NULL DEFAULT 1.0,
      scroll_measures INTEGER NOT NULL DEFAULT 32,
      raga TEXT NOT NULL DEFAULT '',
      tala TEXT NOT NULL DEFAULT '',
      tradition TEXT NOT NULL DEFAULT '',
      scroll_speed_set INTEGER
    )''');
  db.execute('''
    CREATE TABLE setlists (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      description TEXT,
      created_at INTEGER,
      updated_at INTEGER
    )''');
  db.execute('''
    CREATE TABLE setlist_items (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      setlist_id INTEGER NOT NULL REFERENCES setlists(id) ON DELETE CASCADE,
      song_id INTEGER NOT NULL REFERENCES song_notes(id) ON DELETE CASCADE,
      sort_order INTEGER
    )''');
  db.execute(
    'INSERT INTO song_notes (title, lyrics, timestamp, scroll_speed_set) '
    "VALUES ('Kanyaka Mariyam Innal', '[Em]hello', 2000, 0)",
  );
  // Title, timestamp and scroll_speed_set all NULL.
  db.execute("INSERT INTO song_notes (lyrics) VALUES ('[C]no name')");
  // A song with a title but no time or speed flag.
  db.execute(
    "INSERT INTO song_notes (title, lyrics) VALUES ('Untitled Song', '[G]x')",
  );
  db.execute('INSERT INTO setlists (id) VALUES (1)');
  db.execute('INSERT INTO setlist_items (setlist_id, song_id) VALUES (1, 1)');
  db.execute('PRAGMA user_version = $version');
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

  group('schema version 11 upgrade', () {
    test(
      'marks a song whose speed was set by hand, and leaves the rest',
      () async {
        buildVersion10Database(file);

        final db = AppDatabase.forTesting(NativeDatabase(file));
        addTearDown(db.close);

        final songs = await SongRepository(db).watchAllSongs().first;
        final chosen = songs.firstWhere(
          (s) => s.title == 'Speed Chosen By Hand',
        );
        final untouched = songs.firstWhere(
          (s) => s.title == 'Speed Never Touched',
        );

        // 0.4x could only have been picked by the user, so the song keeps it.
        expect(chosen.scrollSpeedSet, isTrue);
        expect(chosen.scrollSpeed, closeTo(0.4, 1e-9));

        // Still at the old column default, so it counts as never set and will
        // follow the starting speed from Settings.
        expect(untouched.scrollSpeedSet, isFalse);
      },
    );
  });

  // Version 10 runs the upgrade; version 11 is already current, so only the
  // repair in `beforeOpen` can fix it.
  group('NULL title, timestamp and setlist columns', () {
    for (final version in [10, 11]) {
      test('a version $version database reads every song back', () async {
        buildDatabaseWithNullTitleTimeAndSetlist(file, version: version);

        final db = AppDatabase.forTesting(NativeDatabase(file));
        addTearDown(db.close);

        final songs = await SongRepository(db).watchAllSongs().first;

        expect(songs, hasLength(3));
        // The newest song first; the two with no time sort to the end.
        expect(songs.first.title, 'Kanyaka Mariyam Innal');
        final nameless = songs.firstWhere((s) => s.lyrics == '[C]no name');
        expect(nameless.title, 'Untitled Song');
        expect(nameless.timestamp, 0);
        expect(nameless.scrollSpeedSet, isFalse);
      });

      test('version $version: the import duplicate check works', () async {
        buildDatabaseWithNullTitleTimeAndSetlist(file, version: version);

        final db = AppDatabase.forTesting(NativeDatabase(file));
        addTearDown(db.close);
        final repository = SongRepository(db);

        final found = await repository.findByTitle('Kanyaka Mariyam Innal');
        expect(found?.lyrics, '[Em]hello');
        expect(await repository.findByTitle('Untitled Song'), isNotNull);
        expect(await repository.findByTitle('No Such Song'), isNull);
      });

      test('version $version: setlists read back with defaults', () async {
        buildDatabaseWithNullTitleTimeAndSetlist(file, version: version);

        final db = AppDatabase.forTesting(NativeDatabase(file));
        addTearDown(db.close);

        final setlists = await SetlistRepository(db).watchAllSetlists().first;

        expect(setlists, hasLength(1));
        expect(setlists.single.name, 'Setlist');
        expect(setlists.single.description, '');
      });
    }
  });

  // Versions 1–7 had no `raga`, `tala` or `tradition` columns. The version 4
  // and 8 steps read songs, so those columns must exist before they run.
  group('upgrade from an early schema version', () {
    for (final version in [1, 2, 3, 7]) {
      test('a version $version database opens and reads back', () async {
        buildEarlyDatabase(file, version: version);

        final db = AppDatabase.forTesting(NativeDatabase(file));
        addTearDown(db.close);

        final songs = await SongRepository(db).watchAllSongs().first;
        final old = songs.firstWhere((s) => s.title == 'Old Early Song');
        expect(old.lyrics, '[C]hello there');
        expect(old.scrollSpeedSet, isFalse);
        // Below version 4 the upgrade adds the classical sample songs (a
        // version 4–7 database already received them back then).
        if (version < 4) {
          expect(
            songs.map((s) => s.title),
            contains('Vathapi Ganapathim (Raga Hamsadhvani)'),
          );
        }

        final setlists = await SetlistRepository(db).watchAllSetlists().first;
        expect(setlists, isA<List<Object>>());

        final userVersion = await db
            .customSelect('PRAGMA user_version')
            .getSingle();
        expect(userVersion.read<int>('user_version'), db.schemaVersion);
      });
    }
  });
}

/// Builds a database at an early schema [version] (1 to 7) by hand.
///
/// Version 1 has only the songs table; version 2 adds the setlist tables;
/// version 3 adds the per-song scroll columns. Nothing else changed in the
/// table shape until version 9.
void buildEarlyDatabase(File file, {required int version}) {
  final scrollColumns = version >= 3
      ? ', scroll_speed REAL NOT NULL DEFAULT 1.0, '
            'scroll_measures INTEGER NOT NULL DEFAULT 32'
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
      timestamp INTEGER NOT NULL$scrollColumns
    )''');
  if (version >= 2) {
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
  }
  db.execute(
    'INSERT INTO song_notes (title, lyrics, timestamp) '
    "VALUES ('Old Early Song', '[C]hello there', 1000)",
  );
  db.execute('PRAGMA user_version = $version');
  db.close();
}
