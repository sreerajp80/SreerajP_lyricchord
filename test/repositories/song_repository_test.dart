import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/data/app_database.dart';
import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/repositories/song_repository.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late SongRepository repo;

  setUp(() {
    db = newInMemoryDatabase();
    repo = SongRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('first-run seeding', () {
    test('seeds the classic songs on first open', () async {
      final songs = await repo.watchAllSongs().first;

      expect(songs, hasLength(6));
      expect(songs.map((s) => s.title).toSet(), {
        'Amazing Grace',
        'House of the Rising Sun',
        'Jingle Bells',
        'Vathapi Ganapathim (Raga Hamsadhvani)',
        'Raghupati Raghava Raja Ram (Raga Mishra Gara)',
        'Krishna Nee Begane Baro (Raga Yamunakalyani)',
      });
    });

    test('starred seed songs are marked favorite', () async {
      final songs = await repo.watchAllSongs().first;
      final starred = songs
          .where((s) => s.favorite)
          .map((s) => s.title)
          .toSet();

      expect(starred, {
        'Amazing Grace',
        'Vathapi Ganapathim (Raga Hamsadhvani)',
      });
    });

    test('songs are ordered newest activity first (timestamp desc)', () async {
      final songs = await repo.watchAllSongs().first;

      for (var i = 0; i < songs.length - 1; i++) {
        expect(
          songs[i].timestamp >= songs[i + 1].timestamp,
          isTrue,
          reason: 'song $i should not be older than song ${i + 1}',
        );
      }
    });

    test('schema v4 migration populates missing classical songs', () async {
      final existingBefore = await repo.watchAllSongs().first;
      expect(existingBefore, hasLength(6));

      // Re-invoking _seedMissingClassicSongs when songs exist does not duplicate them
      await db.migration.onUpgrade(db.createMigrator(), 3, 4);

      final existingAfter = await repo.watchAllSongs().first;
      expect(existingAfter, hasLength(6));
    });

    test(
      'schema v5 migration updates classical songs with hyphenated swaras',
      () async {
        await db.migration.onUpgrade(db.createMigrator(), 4, 5);

        final songs = await repo.watchAllSongs().first;
        final vathapi = songs.firstWhere((s) => s.title.contains('Vathapi'));
        expect(vathapi.lyrics, contains('Sa - Ri - Ga -'));
      },
    );

    test(
      'schema v6 migration updates classical songs with full swara names',
      () async {
        await db.migration.onUpgrade(db.createMigrator(), 5, 6);

        final songs = await repo.watchAllSongs().first;
        final vathapi = songs.firstWhere((s) => s.title.contains('Vathapi'));
        expect(vathapi.lyrics, contains('Sa - Ri - Ga -'));
      },
    );

    test('schema v8 migration writes markers in full swara names', () async {
      await db.migration.onUpgrade(db.createMigrator(), 7, 8);

      final songs = await repo.watchAllSongs().first;
      final vathapi = songs.firstWhere((s) => s.title.contains('Vathapi'));

      expect(vathapi.lyrics, contains('[Sa]Vathapi Gana[Pa]pathim'));
      // No single-letter markers left anywhere.
      expect(vathapi.lyrics, isNot(contains('[S]')));
      expect(vathapi.lyrics, isNot(contains('[G]')));
    });

    test(
      'schema v8 migration makes Raghupati match its Swaram block',
      () async {
        await db.migration.onUpgrade(db.createMigrator(), 7, 8);

        final songs = await repo.watchAllSongs().first;
        final raghupati = songs.firstWhere(
          (s) => s.title.contains('Raghupati'),
        );

        // The Swaram block is Sa Pa Ma Sa, then Sa Pa Ni Sa. The markers above
        // the words must say the same thing.
        expect(
          raghupati.lyrics,
          contains('[Sa]Raghupati [Pa]Raghava [Ma]Raja [Sa]Ram,'),
        );
        expect(
          raghupati.lyrics,
          contains('[Sa]Patita [Pa]Pavana [Ni]Sita [Sa]Ram.'),
        );
        expect(
          raghupati.lyrics,
          contains('[Sa]Sita [Pa]Ram [Ma]Sita [Sa]Ram,'),
        );
        expect(
          raghupati.lyrics,
          contains('[Sa]Bhaja [Pa]Pyare [Ni]Tukaram / [Sa]Sita Ram.'),
        );
      },
    );

    test('the migration leaves a song of the user\'s own alone', () async {
      // Matching is by title. A song whose title is not one of the three seeded
      // classical names is never rewritten.
      //
      // Note the limit of that rule: the match is a substring, so a song the
      // user titled "My Raghupati Notes" *would* be overwritten. Only the
      // seeded titles were ever meant to match.
      final id = await repo.insert(_newSong(title: 'My Own Song'));

      await db.migration.onUpgrade(db.createMigrator(), 7, 8);

      final songs = await repo.watchAllSongs().first;
      final mine = songs.firstWhere((s) => s.id == id);
      expect(mine.lyrics, '[C]La la la');
    });
  });

  group('schema v9 — tradition columns', () {
    /// Runs the version 9 step over songs already in the database.
    Future<void> upgradeToV9() =>
        db.migration.onUpgrade(db.createMigrator(), 8, 9);

    test('a song with no raga is classified Western', () async {
      final id = await repo.insert(_newSong(title: 'Plain Chords'));

      await upgradeToV9();

      final song = (await repo.findById(id))!;
      expect(song.tradition, PitchTradition.western);
      expect(song.raga, isEmpty);
      expect(song.tala, isEmpty);
      expect(song.isIndian, isFalse);
    });

    test('a raga with a Carnatic tala is classified Carnatic', () async {
      final id = await repo.insert(
        _newSong(
          title: 'Carnatic Piece',
          lyrics: '{raga: Kalyani}\n{tala: Adi}\n[Sa]la la',
        ),
      );

      await upgradeToV9();

      final song = (await repo.findById(id))!;
      expect(song.raga, 'Kalyani');
      expect(song.tala, 'Adi');
      expect(song.tradition, PitchTradition.carnatic);
    });

    test('a raga with a Hindustani tala is classified Hindustani', () async {
      final id = await repo.insert(
        _newSong(
          title: 'Hindustani Piece',
          lyrics: '{raga: Yaman}\n{tala: Keherwa}\n[Sa]la la',
        ),
      );

      await upgradeToV9();

      final song = (await repo.findById(id))!;
      expect(song.tala, 'Keherwa');
      expect(song.tradition, PitchTradition.hindustani);
    });

    test('a raga with no tala still counts as Indian', () async {
      // The tala is what tells Carnatic from Hindustani. With none, the
      // migration settles on Carnatic — the important part is that it never
      // falls back to Western and lets the transposer at the swaras.
      final id = await repo.insert(
        _newSong(title: 'No Tala', lyrics: '{raga: Bhairavi}\n[Sa]la la'),
      );

      await upgradeToV9();

      final song = (await repo.findById(id))!;
      expect(song.raga, 'Bhairavi');
      expect(song.tala, isEmpty);
      expect(song.isIndian, isTrue);
      expect(song.tradition, PitchTradition.carnatic);
    });

    test('the migration leaves the lyrics text untouched', () async {
      const text = '{raga: Kalyani}\n{tala: Adi}\n[Sa]la la';
      final id = await repo.insert(_newSong(title: 'Keep Text', lyrics: text));

      await upgradeToV9();

      expect((await repo.findById(id))!.lyrics, text);
    });

    test('the migration does not reorder the songbook', () async {
      final before = (await repo.watchAllSongs().first)
          .map((s) => s.timestamp)
          .toList();

      await upgradeToV9();

      final after = (await repo.watchAllSongs().first)
          .map((s) => s.timestamp)
          .toList();
      expect(after, before);
    });

    test('running the version 9 step twice is harmless', () async {
      // Adding a column that already exists is a hard SQLite error. The step
      // has to survive a re-run, or a half-applied upgrade would brick the app.
      await upgradeToV9();
      await upgradeToV9();

      expect(await repo.watchAllSongs().first, hasLength(6));
    });

    test(
      'the seeded classical songs come out Indian on a fresh install',
      () async {
        final songs = await repo.watchAllSongs().first;
        final indian = songs
            .where((s) => s.isIndian)
            .map((s) => s.title)
            .toSet();

        expect(indian, hasLength(3));
        expect(
          songs.where((s) => !s.isIndian).every((s) => s.raga.isEmpty),
          isTrue,
        );
      },
    );

    test('raga, tala and tradition survive a save and reload', () async {
      final id = await repo.insert(
        _newSong(title: 'Round Trip').copyWith(
          raga: 'Hamsadhvani',
          tala: 'Adi',
          tradition: PitchTradition.carnatic,
        ),
      );

      final song = (await repo.findById(id))!;
      expect(song.raga, 'Hamsadhvani');
      expect(song.tala, 'Adi');
      expect(song.tradition, PitchTradition.carnatic);
    });
  });

  group('insert / update / delete', () {
    test('insert adds a song and returns its new id', () async {
      final id = await repo.insert(_newSong(title: 'My Song'));
      expect(id, greaterThan(0));

      final songs = await repo.watchAllSongs().first;
      expect(songs, hasLength(7));
      expect(songs.any((s) => s.id == id && s.title == 'My Song'), isTrue);
    });

    test(
      'watchSongById returns the matching song and null when missing',
      () async {
        final id = await repo.insert(_newSong(title: 'Findable'));

        final found = await repo.watchSongById(id).first;
        expect(found, isNotNull);
        expect(found!.title, 'Findable');

        final missing = await repo.watchSongById(999999).first;
        expect(missing, isNull);
      },
    );

    test('update changes an existing song', () async {
      final id = await repo.insert(_newSong(title: 'Before'));
      final original = await repo.watchSongById(id).first;

      await repo.update(
        original!.copyWith(title: 'After', favorite: true, bpm: 90),
      );

      final updated = await repo.watchSongById(id).first;
      expect(updated!.title, 'After');
      expect(updated.favorite, isTrue);
      expect(updated.bpm, 90);
    });

    test('toggleFavorite flips the star both ways', () async {
      final id = await repo.insert(_newSong(title: 'Starrable'));
      final song = await repo.watchSongById(id).first;
      expect(song!.favorite, isFalse);

      await repo.toggleFavorite(song);
      final starred = await repo.watchSongById(id).first;
      expect(starred!.favorite, isTrue);

      await repo.toggleFavorite(starred);
      final unstarred = await repo.watchSongById(id).first;
      expect(unstarred!.favorite, isFalse);
    });

    test('delete removes a song', () async {
      final id = await repo.insert(_newSong(title: 'Doomed'));
      expect(await repo.watchSongById(id).first, isNotNull);

      await repo.delete(id);
      expect(await repo.watchSongById(id).first, isNull);
    });

    test('duplicate saves an unstarred copy and leaves the original', () async {
      final id = await repo.insert(
        _newSong(title: 'Original').copyWith(favorite: true, key: 'D', bpm: 88),
      );
      final original = await repo.watchSongById(id).first;

      final copyId = await repo.duplicate(original!);
      expect(copyId, isNot(id));

      final copy = await repo.watchSongById(copyId).first;
      expect(copy!.title, 'Original (Copy)');
      expect(copy.favorite, isFalse);
      // The rest of the song carries over unchanged.
      expect(copy.key, 'D');
      expect(copy.bpm, 88);
      expect(copy.lyrics, original.lyrics);

      // The original is untouched.
      final stillThere = await repo.watchSongById(id).first;
      expect(stillThere!.title, 'Original');
      expect(stillThere.favorite, isTrue);
    });
  });

  group('scroll settings', () {
    test('a new song starts at the default speed and measures', () async {
      final id = await repo.insert(_newSong(title: 'Fresh'));
      final song = await repo.findById(id);

      expect(song!.scrollSpeed, 1.0);
      expect(song.scrollMeasures, 32);
    });

    test('saveScrollSettings stores the speed and measures', () async {
      final id = await repo.insert(_newSong(title: 'Speedy'));

      await repo.saveScrollSettings(id, speed: 0.65, measures: 64);

      final song = await repo.findById(id);
      expect(song!.scrollSpeed, closeTo(0.65, 1e-9));
      expect(song.scrollMeasures, 64);
    });

    test('saveScrollSettings leaves the rest of the song alone', () async {
      final original = _newSong(title: 'Untouched');
      final id = await repo.insert(original);
      final before = await repo.findById(id);

      await repo.saveScrollSettings(id, speed: 1.85, measures: 8);

      final after = await repo.findById(id);
      // The songbook is ordered by timestamp, so a speed change must not move
      // the song to the top of the list.
      expect(after!.timestamp, before!.timestamp);
      expect(after.title, before.title);
      expect(after.lyrics, before.lyrics);
      expect(after.key, before.key);
      expect(after.bpm, before.bpm);
      expect(after.favorite, before.favorite);
    });

    test('an ordinary update keeps the saved scroll settings', () async {
      final id = await repo.insert(_newSong(title: 'Edited'));
      await repo.saveScrollSettings(id, speed: 0.55, measures: 12);

      final song = await repo.findById(id);
      await repo.update(song!.copyWith(title: 'Edited again'));

      final after = await repo.findById(id);
      expect(after!.title, 'Edited again');
      expect(after.scrollSpeed, closeTo(0.55, 1e-9));
      expect(after.scrollMeasures, 12);
    });
  });

  group('reactive streams', () {
    test('watchAllSongs emits again after an insert', () async {
      final emissions = <int>[];
      final sub = repo.watchAllSongs().listen((songs) {
        emissions.add(songs.length);
      });

      // Let the first (seeded) emission arrive, then insert.
      await Future<void>.delayed(Duration.zero);
      await repo.insert(_newSong(title: 'Reactive'));
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();
      expect(emissions.first, 6);
      expect(emissions.last, 7);
    });
  });
}

SongNote _newSong({required String title, String lyrics = '[C]La la la'}) =>
    SongNote(
      title: title,
      artist: 'Tester',
      lyrics: lyrics,
      key: 'C',
      bpm: 100,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
