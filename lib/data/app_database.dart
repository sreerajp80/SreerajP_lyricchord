import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
// Both are pure logic — no storage, no UI, no navigation. Imported here only so
// the version 9 backfill classifies old songs by exactly the same rule the rest
// of the app uses, instead of a second copy that could drift out of step.
import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/services/chord_sheet_parser.dart';
import 'package:lyricchord/services/pitch_naming_service.dart';

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

  /// Manual auto-scroll speed the user last set for this song (schema
  /// version 3). Saved per song so a sheet opens at the speed it was performed
  /// at last time.
  RealColumn get scrollSpeed => real().withDefault(const Constant(1.0))();

  /// Tempo-Auto length in measures the user last set for this song (schema
  /// version 3).
  IntColumn get scrollMeasures => integer().withDefault(const Constant(32))();

  /// Raga name for an Indian song, `''` for a Western one (schema version 9).
  TextColumn get raga => text().withDefault(const Constant(''))();

  /// Tala name for an Indian song, `''` for a Western one (schema version 9).
  TextColumn get tala => text().withDefault(const Constant(''))();

  /// `western`, `carnatic`, `hindustani`, or `''` when not yet classified
  /// (schema version 9).
  ///
  /// Stored rather than worked out from the lyrics on every read. The old
  /// behaviour keyed off a `{raga: …}` header line, so a typo such as
  /// `{ragam: …}` made an Indian song look Western — and the transposer would
  /// then shift its `[Sa]` and `[Ma]` markers as if they were chord letters,
  /// quietly corrupting the sheet.
  TextColumn get tradition => text().withDefault(const Constant(''))();
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
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedClassicSongs();
      await _seedClassicSetlists();
      // The seed songs carry their raga and tala as `{…}` header lines, so the
      // same backfill the upgrade uses fills their columns in. Keeping one code
      // path means a fresh install and an upgraded one classify identically.
      await _backfillSongTraditions();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(setlists);
        await m.createTable(setlistItems);
      }
      if (from < 3) {
        // Existing songs take the column defaults (1.0x, 32 measures), so an
        // upgrade never changes how a song already scrolls.
        await m.addColumn(songNotes, songNotes.scrollSpeed);
        await m.addColumn(songNotes, songNotes.scrollMeasures);
      }
      if (from < 4) {
        await _seedMissingClassicSongs();
      }
      if (from < 8) {
        // v5, v6 and v7 also rewrote these songs' text. This replaces all of
        // it: the classical songs are written in swaras, spelled in full
        // (`[Sa]`, not `[S]`), and their markers now match the Swaram block.
        await _rewriteClassicalSongsInSwaraNotation();
      }
      if (from < 9) {
        // Adding a column that is already there is a hard SQLite error, which
        // would leave the upgrade half-applied and the app unable to open. Ask
        // the table what it has first, so re-running this step is harmless.
        final existing = await _songColumnNames();
        for (final column in [
          songNotes.raga,
          songNotes.tala,
          songNotes.tradition,
        ]) {
          if (!existing.contains(column.name)) {
            await m.addColumn(songNotes, column);
          }
        }
        // Older builds added some columns without a NOT NULL default, so on
        // those devices the rows hold NULL. Drift declares them non-null, and
        // its row mapper ends every non-null column with `!` — so one NULL
        // makes reading any song throw "Null check operator used on a null
        // value", which fails the upgrade and stops the whole app from opening.
        // Heal the data before anything reads it back.
        await _healNullSongColumns();
        await _backfillSongTraditions();
      }
      if (from < 10) {
        // The sample song shipped as a stub: two invented charanams, a wrong
        // second line, and no melody. Replace it with the real words plus a
        // `{melody}` line for each, so the melody player has something to show.
        await _rewriteKrishnaSample();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
      // Safety net for a device already stamped at version 9 with NULLs left
      // in place: onUpgrade will never run again there, so the repair above
      // would never fire. Once the data is clean this touches no rows.
      await _healNullSongColumns();
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

  /// Writes only the auto-scroll columns of one song.
  ///
  /// Deliberately not a `replace()`: the songbook is ordered by `timestamp`, so
  /// a speed change must leave `timestamp` (and every other column) alone —
  /// setting a scroll speed is not editing the song.
  Future<void> updateScrollSettings(int id, double speed, int measures) async {
    await (update(songNotes)..where((t) => t.id.equals(id))).write(
      SongNotesCompanion(
        scrollSpeed: Value(speed),
        scrollMeasures: Value(measures),
      ),
    );
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
        ..._classicalSeedSongs(now),
      ]);
    });
  }

  Future<void> _seedMissingClassicSongs() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existingSongs = await getAllSongs();
    final existingTitles = existingSongs
        .map((s) => s.title.trim().toLowerCase())
        .toSet();

    final classicalSongs = _classicalSeedSongs(now);

    for (final song in classicalSongs) {
      if (!existingTitles.contains(song.title.value.trim().toLowerCase())) {
        await insertSong(song);
      }
    }
  }

  /// Rewrites the three seeded classical songs in swara notation.
  ///
  /// They used to carry Western chords (`[E]Krishna nee be[A]gane baro`), which
  /// is wrong for Carnatic music: an Indian song is written in swaras. Later
  /// they carried single letters (`[S]`) that did not always agree with the
  /// song's own Swaram block. This puts back the full, correct text.
  ///
  /// Matching is by title, so a song the user renamed or wrote themselves is
  /// left alone.
  Future<void> _rewriteClassicalSongsInSwaraNotation() async {
    final existingSongs = await getAllSongs();

    for (final song in existingSongs) {
      final lyrics = _classicalLyricsFor(song.title);
      if (lyrics == null) continue;

      await updateSong(
        SongNotesCompanion(
          id: Value(song.id),
          title: Value(song.title),
          artist: Value(song.artist),
          key: Value(song.key),
          bpm: Value(song.bpm),
          favorite: Value(song.favorite),
          timestamp: Value(song.timestamp),
          scrollSpeed: Value(song.scrollSpeed),
          scrollMeasures: Value(song.scrollMeasures),
          lyrics: Value(lyrics),
        ),
      );
    }
  }

  /// Replaces the Krishna Nee sample song's stub text with the full words and
  /// melody lines (schema version 10).
  ///
  /// Matching is on the **text**, not the title. The older
  /// [_rewriteClassicalSongsInSwaraNotation] matched by title alone, which
  /// would throw away a song the user had written or edited under the same
  /// name. Here, a song is only touched when its lyrics still equal the text
  /// version 9 seeded, so any edit of the user's survives untouched.
  Future<void> _rewriteKrishnaSample() async {
    final existingSongs = await getAllSongs();

    for (final song in existingSongs) {
      if (song.lyrics.trim() != _krishnaNeeLyricsV9.trim()) continue;

      // A targeted write, not `replace()`: the songbook is ordered by
      // `timestamp`, and fixing the seeded text must not push the song to the
      // top of the list as if the user had just edited it. `tala` is written
      // too because the new text adds a `{tala}` header the old text did not
      // have, and the column has to agree with the words.
      await (update(songNotes)..where((t) => t.id.equals(song.id))).write(
        const SongNotesCompanion(
          lyrics: Value(_krishnaNeeLyrics),
          raga: Value('Yamunakalyani'),
          tala: Value('Misra Chapu'),
        ),
      );
    }
  }

  /// Every `song_notes` column drift declares non-null, with the SQL literal to
  /// put back when a row holds NULL instead.
  ///
  /// `id`, `title` and `timestamp` are left out on purpose: they are NOT NULL in
  /// every schema this app has ever written, so a NULL there is not a shape we
  /// can invent a sensible value for.
  static const Map<String, String> _songColumnDefaults = {
    'artist': "''",
    'lyrics': "''",
    'key': "'C'",
    'bpm': '120',
    'favorite': '0',
    'scroll_speed': '1.0',
    'scroll_measures': '32',
    'raga': "''",
    'tala': "''",
    'tradition': "''",
  };

  /// Replaces NULL with the declared default in every non-null `song_notes`
  /// column.
  ///
  /// Older builds added some of these columns without a NOT NULL default, so on
  /// those phones the rows hold NULL. Drift declares the columns non-null and
  /// ends every one with `!` in its row mapper, so a single NULL makes reading
  /// *any* song throw "Null check operator used on a null value" — which leaves
  /// the songbook permanently empty.
  ///
  /// Safe to run on a healthy database (the columns are NOT NULL there, so the
  /// `WHERE` matches nothing) and safe on an old database that does not have a
  /// column yet (the column check skips it).
  Future<void> _healNullSongColumns() async {
    final existing = await _songColumnNames();
    for (final entry in _songColumnDefaults.entries) {
      if (existing.contains(entry.key)) {
        await customStatement(
          'UPDATE song_notes SET ${entry.key} = ${entry.value} '
          'WHERE ${entry.key} IS NULL',
        );
      }
    }
  }

  /// The column names the `song_notes` table currently has on disk.
  Future<Set<String>> _songColumnNames() async {
    final rows = await customSelect("PRAGMA table_info('song_notes')").get();
    return rows.map((row) => row.read<String>('name')).toSet();
  }

  /// Fills in `raga`, `tala` and `tradition` for songs written before those
  /// columns existed (schema version 9).
  ///
  /// Reads each song's `{raga: …}` and `{tala: …}` header lines and classifies
  /// it once, so the answer stops depending on re-parsing the lyrics. The
  /// lyrics text itself is left exactly as the user wrote it — the header lines
  /// stay, and the parser keeps hiding them from the sheet — so nothing the
  /// user sees changes after the upgrade.
  ///
  /// The fallback is fixed to Carnatic rather than the user's "Pitch naming"
  /// setting on purpose: a migration must give every device the same answer,
  /// otherwise the same song reads Carnatic on one phone and Hindustani on
  /// another.
  ///
  /// Nothing in here is allowed to throw. Drift runs the whole upgrade in one
  /// transaction, so a single unreadable or malformed song would roll the
  /// migration back, leave the version stamp behind, and make every later
  /// launch retry — and fail — the same work. That shows up as a songbook that
  /// is slow to open and then permanently empty. A song we cannot classify is
  /// left with empty raga and tala instead.
  Future<void> _backfillSongTraditions() async {
    const parser = ChordSheetParser();
    const naming = PitchNamingService();

    // Deliberately not `getAllSongs()`: that builds a full typed row per song,
    // so every column has to be readable just to reach `id` and `lyrics`. A
    // migration must not depend on columns it is in the middle of filling in.
    final rows = await customSelect('SELECT id, lyrics FROM song_notes').get();

    // One write pass instead of one statement per song, so a large songbook
    // does not make the first launch after the upgrade crawl.
    await batch((batch) {
      for (final row in rows) {
        final int songId;
        try {
          songId = row.read<int>('id');
        } catch (_) {
          // No usable primary key — there is nothing we could update.
          continue;
        }

        var raga = '';
        var tala = '';
        var tradition = PitchTradition.western;
        try {
          // `readNullable`: an old phone can hold NULL here, and `read<String>`
          // would throw on it.
          final sheet = parser.parseSheet(
            row.readNullable<String>('lyrics') ?? '',
          );
          raga = sheet.raga ?? '';
          tala = sheet.tala ?? '';
          tradition = naming.detect(
            raga: sheet.raga,
            tala: sheet.tala,
            fallback: PitchTradition.carnatic,
          );
        } catch (_) {
          // Unreadable or malformed lyrics: fall back to the Western default
          // rather than failing the whole upgrade. The user can still open the
          // song and set its raga by hand.
        }

        // A targeted write, not `replace()`: this must touch only the three new
        // columns and leave `timestamp` alone, or the upgrade would reorder the
        // whole songbook.
        batch.update(
          songNotes,
          SongNotesCompanion(
            raga: Value(raga),
            tala: Value(tala),
            tradition: Value(tradition.storageKey),
          ),
          where: (t) => t.id.equals(songId),
        );
      }
    });
  }

  /// The swara lyrics for a seeded classical song [title], or `null` when the
  /// title is not one of them.
  String? _classicalLyricsFor(String title) {
    final name = title.toLowerCase();
    if (name.contains('vathapi')) return _vathapiLyrics;
    if (name.contains('raghupati')) return _raghupatiLyrics;
    if (name.contains('krishna nee')) return _krishnaNeeLyrics;
    return null;
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

// --- Classical seed songs ---------------------------------------------------
//
// These three are written in Indian notation, not Western: the markers hold
// swaras and the raga and tala are `{…}` header lines, which the sheet shows
// above the song instead of drawing as lyrics. Swaras are spelled in full
// (`[Sa]`, `[Ma]`) so the markers read the same way as the Swaram block.
//
// The `key` column still holds a tonic, but nothing shows it for these songs:
// a Western note letter has no place on an Indian sheet, and a swara is
// already named relative to Sa. It is kept only so the column is never empty.
//
// Defined once and used by first-run seeding, by the "seed anything missing"
// upgrade, and by the v7 rewrite, so the three copies cannot drift apart.

/// The seeded classical songs, timestamped from [now].
List<SongNotesCompanion> _classicalSeedSongs(int now) => [
  SongNotesCompanion.insert(
    title: 'Vathapi Ganapathim (Raga Hamsadhvani)',
    artist: const Value('Muthuswami Dikshitar'),
    key: const Value('C'),
    bpm: const Value(72),
    lyrics: const Value(_vathapiLyrics),
    favorite: const Value(true),
    timestamp: now + 3,
  ),
  SongNotesCompanion.insert(
    title: 'Raghupati Raghava Raja Ram (Raga Mishra Gara)',
    artist: const Value('Traditional Bhajan'),
    key: const Value('D'),
    bpm: const Value(84),
    lyrics: const Value(_raghupatiLyrics),
    favorite: const Value(false),
    timestamp: now + 4,
  ),
  SongNotesCompanion.insert(
    title: 'Krishna Nee Begane Baro (Raga Yamunakalyani)',
    artist: const Value('Vyasatirtha'),
    key: const Value('E'),
    bpm: const Value(68),
    lyrics: const Value(_krishnaNeeLyrics),
    favorite: const Value(false),
    timestamp: now + 5,
  ),
];

/// Hamsadhvani uses S R G P N — it has no Ma and no Dha.
const String _vathapiLyrics =
    '{raga: Hamsadhvani}\n'
    '{tala: Adi}\n'
    '\n'
    'Pallavi:\n'
    '[Sa]Vathapi Gana[Pa]pathim Bha[Sa]jeham\n'
    '[Sa]Varanasyaam Va[Ga]rada Na[Pa]yakham\n'
    '\n'
    'Anupallavi:\n'
    '[Sa]Bhoothadi Sam[Ga]sevitha [Pa]Charanam\n'
    '[Sa]Bhootha Bouthika [Ni]Prapancha [Sa]Karanam\n'
    '\n'
    'Swaram:\n'
    'Sa - Ri - Ga - Pa - Ni - Sa - | Sa - Ni - Pa - Ga - Ri - Sa -';

const String _raghupatiLyrics =
    '{raga: Mishra Gara}\n'
    '{tala: Keherwa}\n'
    '\n'
    '[Sa]Raghupati [Pa]Raghava [Ma]Raja [Sa]Ram,\n'
    '[Sa]Patita [Pa]Pavana [Ni]Sita [Sa]Ram.\n'
    '\n'
    '[Sa]Sita [Pa]Ram [Ma]Sita [Sa]Ram,\n'
    '[Sa]Bhaja [Pa]Pyare [Ni]Tukaram / [Sa]Sita Ram.\n'
    '\n'
    'Swaram:\n'
    'Sa - Sa - Pa - Pa - | Ma - Ma - Sa - Sa -\n'
    'Sa - Sa - Pa - Pa - | Ni - Ni - Sa - Sa -';

const String _krishnaNeeLyrics =
    '{raga: Yamunakalyani}\n'
    '{tala: Misra Chapu}\n'
    '{sruti: madhyama}\n'
    '\n'
    'Pallavi:\n'
    '[Sa]krishna nee bEganE baarO\n'
    '{melody} , , Sa | Ga3 ,-Ma1 | Ri2 ,\n'
    '{melody} Sa-Ni3 Ri2-Sa Ni3-Da2 | , Ni3 | ,-Ri2 ,\n'
    '{melody} , , Ga3-Ma1 | Ri2 , | Sa ,\n'
    '{melody} Da2-Ni3 Ri2-Da2 Sa | , , | , ,\n'
    '\n'
    'Anupallavi:\n'
    '[Ga3]bEganE baarO mukhavannu tOrO\n'
    '{melody} , , Ga3 | Ga3 Ri2 | Ga3 Ma2\n'
    '{melody} Pa , , | Ga3-Ma2 Pa | Pa ,\n'
    '{melody} , , Ma2-Pa | Da2 , | Da2 Pa\n'
    '{melody} Pa , ,-Ni3 | Da2-Pa-Pa-, , | Ma2-Da2 Pa-Ma2\n'
    '\n'
    'caraNam 1:\n'
    'kaalaalandhugE gejje nIlada baavuli\n'
    'nIlavarNane naaTya vaaduta baarO\n'
    '\n'
    'caraNam 2:\n'
    '[Ma2]Udiyalli udigejje beraLalli ungura\n'
    '{melody} , , Ma2-Da2 | Pa-Ma2 Ri2 | Ga3 Ma2\n'
    '{melody} Pa Pa , | Ga3-Ma2 Pa | Pa ,\n'
    '{melody} , , Ma2-Pa | Da2 , | Da2 Pa\n'
    '{melody} Pa , ,-Ni3 | Da2-Pa-Pa-, , | Ma2-Da2 Pa-Ma2\n'
    '[Ga3]koraLalli haakida vaijayantiya maalE\n'
    '{melody} Ga3 , Ga3-Ma2 | Ga3 , | Ga3 ,\n'
    '{melody} Ga3 , , | Ga3 Ri2 | Ga3-Ma2 Da2-Pa\n'
    '{melody} Pa , Ga3-Ma2 | Ga3 Ri2 | Ri2 Sa\n'
    '{melody} Ni3-Sa Ri2-Ga3 Ma2-Pa | Ri2 , | Sa ,\n'
    '\n'
    'caraNam 3:\n'
    '[Ma2]kaashi peethambara kaiyalli koLalu\n'
    '{melody} , , Ma2-Da2 | Pa-Ma2 Ri2 | , Ga3-Ma2\n'
    '{melody} Pa , , | Pa , | Pa ,\n'
    '{melody} , , Ma2-Pa | Da2 , | Da2 Pa\n'
    '{melody} Pa , ,-Ni3 | Da2-Pa-Pa-, , | Ma2-Da2 Pa-Ma2\n'
    '[Ga3]pUsida shreegandha mayyOLagamma\n'
    '{melody} Ga3 , Ga3-Ma2 | Ga3 , | Ga3 ,\n'
    '{melody} Ga3 Ri2-Ga3 ,-Ri2 | , Ri2-Ga3 | Ma2-Pa ,\n'
    '{melody} Pa , Ga3-Ma2 | Ga3 Ri2 | Ri2 Sa\n'
    '{melody} Ni3-Sa Ri2-Ga3 Ma2-Da2-Pa-Pa | Ri2 , | Sa ,\n'
    '\n'
    'caraNam 4:\n'
    '[Ma2]taayige baayalli jagavannu torida\n'
    '{melody} , , Ma2-Da2 | Pa-Ma2 Ga3-Ri2 | Ga3 Ma2\n'
    '{melody} Pa , , | Pa , | Pa ,\n'
    '{melody} , , Ma2-Pa | Da2 , | Da2 Pa\n'
    '{melody} Pa , ,-Ni3 | Da2-Pa-Pa-, , | Ma2-Da2 Pa-Ma2\n'
    '[Ga3]jagadhOddhaaraka namma uDupi shree krishna\n'
    '{melody} Ga3 , Ga3-Ma2 | Ga3 , | Ga3 ,\n'
    '{melody} Ga3 Ri2-Ga3 ,-Ri2 | , Ri2-Ga3 | Ga3-Ma2 Da2-Pa\n'
    '{melody} Pa , Ga3-Ma2 | Ga3 Ri2 | Ri2 Sa\n'
    '{melody} Ni3-Sa Ri2-Ga3 Ma2-Da2-Pa-Pa | Ri2 , | Sa ,\n'
    '\n'
    'Swaram:\n'
    'Sa - Ri2 - Ga3 - Ma2 - Pa - Da2 - Ni3 - Sa -\n'
    'Sa - Ni3 - Da2 - Pa - Ma2 - Ga3 - Ri2 - Sa -';

/// The text the Krishna Nee sample song carried before schema version 10.
///
/// Kept so the version 10 upgrade can tell an untouched seeded song from one
/// the user has edited or written themselves, and only rewrite the former.
const String _krishnaNeeLyricsV9 =
    '{raga: Yamunakalyani}\n'
    '\n'
    'Pallavi:\n'
    '[Sa]Krishna nee be[Ma]gane baro [Sa]\n'
    '[Sa]Begane baro mukha[Pa]thanaye baro [Sa]\n'
    '\n'
    'Charanam:\n'
    '[Sa]Jalakaara [Ma]kaalinali [Sa]nartana maadidha\n'
    '[Sa]Helalalaagaadho [Pa]chinni krish[Sa]na\n'
    '\n'
    'Swaram:\n'
    'Sa - Ri - Ga - Ma - Pa - Dha - Ni - Sa -\n'
    'Sa - Ni - Dha - Pa - Ma - Ga - Ri - Sa -';

/// Opens the on-device database file lazily, in the app documents directory.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}
