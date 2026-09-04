import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:lyricchord/data/app_database.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/repositories/song_repository.dart';

/// Opens the database file the same way the app does, pragmas and all.
///
/// The app itself uses `NativeDatabase.createInBackground`, which cannot take a
/// plain file path in a test without spawning an isolate, so this uses the
/// direct constructor with the same [applyPragmas] setup.
AppDatabase openFile(File file) {
  return AppDatabase.forTesting(NativeDatabase(file, setup: applyPragmas));
}

void main() {
  late Directory tempDir;
  late File dbFile;

  setUpAll(() {
    // This file opens the same database twice on purpose — that is the bug it
    // guards against — so drift's warning about it is just noise here.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('lyricchord_db_test');
    dbFile = File('${tempDir.path}/songs.sqlite');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('connection setup', () {
    test('turns on WAL, a busy timeout, and foreign keys', () {
      final raw = sqlite3.open(dbFile.path);
      addTearDown(raw.close);
      applyPragmas(raw);

      expect(raw.select('PRAGMA journal_mode;').first.values.first, 'wal');
      expect(raw.select('PRAGMA busy_timeout;').first.values.first, 5000);
      expect(raw.select('PRAGMA foreign_keys;').first.values.first, 1);
    });

    // Regression test for the file-open import failing with
    // "Could not search for song by title". Two Flutter engines each opened
    // their own connection to this one file, and the second failed at once
    // instead of waiting for the lock.
    test(
      'a second connection can still read and write the same file',
      () async {
        final first = openFile(dbFile);
        final firstRepo = SongRepository(first);
        await firstRepo.insert(
          const SongNote(
            id: 0,
            title: 'ദൈവം കനിവായ് തന്നതല്ലേ ഈ ജന്മം',
            lyrics: '[C]line',
            timestamp: 1,
          ),
        );

        // The first connection stays open, exactly as it does in the app — the
        // database is never closed there.
        final second = openFile(dbFile);
        final secondRepo = SongRepository(second);

        final found = await secondRepo.findByTitle(
          'ദൈവം കനിവായ് തന്നതല്ലേ ഈ ജന്മം',
        );
        expect(found, isNotNull);

        // And a write from the second connection also goes through.
        final id = await secondRepo.insert(
          const SongNote(id: 0, title: 'Second Song', lyrics: '', timestamp: 2),
        );
        expect(id, greaterThan(0));

        // The first connection sees it.
        expect(await firstRepo.findByTitle('Second Song'), isNotNull);

        await second.close();
        await first.close();
      },
    );
  });
}
