import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/data/app_database.dart';
import 'package:lyricchord/models/import_settings.dart';
import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/repositories/song_repository.dart';
import 'package:lyricchord/services/import_service.dart';
import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late SongRepository repository;
  late ImportService service;

  setUp(() async {
    db = newInMemoryDatabase();
    repository = SongRepository(db);
    service = ImportService(repository: repository);
  });

  tearDown(() async {
    await db.close();
  });

  group('ImportService Duplicate Strategy', () {
    test('imports unique song without duplicates', () async {
      const content = '''
{title: New Unique Song}
{artist: Test Artist}
[G]Lyrics line
''';

      final res = await service.importContent(
        content: content,
        strategy: ImportDuplicateStrategy.renameImported,
      );

      expect(res.importedSongs.length, 1);
      expect(res.importedSongs.first.title, 'New Unique Song');

      final found = await repository.findByTitle('New Unique Song');
      expect(found, isNotNull);
    });

    test('strategy: overwrite updates existing song', () async {
      final existingId = await repository.insert(
        const SongNote(
          title: 'Duplicate Test Song',
          artist: 'Old Artist',
          lyrics: '[C]Old lyrics',
          timestamp: 1000,
        ),
      );

      const newContent = '''
{title: Duplicate Test Song}
{artist: New Artist}
[G]New lyrics
''';

      final res = await service.importContent(
        content: newContent,
        strategy: ImportDuplicateStrategy.overwrite,
      );

      expect(res.importedSongs.length, 1);
      expect(res.importedIds.first, existingId);

      final updated = await repository.findById(existingId);
      expect(updated?.lyrics, '[G]New lyrics');
    });

    test(
      'strategy: renameImported renames imported song title with timestamp',
      () async {
        final initialSongsCount = (await repository.getAllSongs()).length;

        await repository.insert(
          const SongNote(
            title: 'Duplicate Test Song',
            artist: 'Artist',
            lyrics: '[C]Old lyrics',
            timestamp: 1000,
          ),
        );

        const newContent = '''
{title: Duplicate Test Song}
{artist: Artist}
[G]New lyrics
''';

        final res = await service.importContent(
          content: newContent,
          strategy: ImportDuplicateStrategy.renameImported,
        );

        expect(res.importedSongs.length, 1);
        expect(
          res.importedSongs.first.title,
          startsWith('Duplicate Test Song ('),
        );

        final allSongs = await repository.getAllSongs();
        expect(allSongs.length, initialSongsCount + 2);
      },
    );

    test(
      'strategy: renameExisting renames existing song title and inserts imported song with original title',
      () async {
        final existingId = await repository.insert(
          const SongNote(
            title: 'Duplicate Test Song',
            artist: 'Original Artist',
            lyrics: '[C]Original lyrics',
            timestamp: 1000,
          ),
        );

        const newContent = '''
{title: Duplicate Test Song}
{artist: New Artist}
[G]New lyrics
''';

        final res = await service.importContent(
          content: newContent,
          strategy: ImportDuplicateStrategy.renameExisting,
        );

        expect(res.importedSongs.length, 1);
        expect(res.importedSongs.first.title, 'Duplicate Test Song');

        final renamedOldSong = await repository.findById(existingId);
        expect(renamedOldSong?.title, startsWith('Duplicate Test Song ('));

        final importedSong = await repository.findByTitle(
          'Duplicate Test Song',
        );
        expect(importedSong?.lyrics, '[G]New lyrics');
      },
    );

    test('strategy: userSuggested uses title prompt result', () async {
      await repository.insert(
        const SongNote(
          title: 'Duplicate Test Song',
          artist: 'Original Artist',
          lyrics: '[C]Original lyrics',
          timestamp: 1000,
        ),
      );

      const newContent = '''
{title: Duplicate Test Song}
{artist: New Artist}
[G]New lyrics
''';

      final res = await service.importContent(
        content: newContent,
        strategy: ImportDuplicateStrategy.userSuggested,
        onAskUserTitle: ({required importedSong, required existingSong}) async {
          return 'Duplicate Test Song (Custom Version)';
        },
      );

      expect(res.importedSongs.length, 1);
      expect(
        res.importedSongs.first.title,
        'Duplicate Test Song (Custom Version)',
      );

      final customSong = await repository.findByTitle(
        'Duplicate Test Song (Custom Version)',
      );
      expect(customSong, isNotNull);
    });
  });

  group('ImportService keeps Indian song details', () {
    const carnaticContent = '''
{title: Duplicate Test Song}
{raga: Mohanam}
{tala: Adi}
S R G P D S'
''';

    Future<int> insertWesternFavorite() => repository.insert(
      const SongNote(
        title: 'Duplicate Test Song',
        lyrics: '[C]Old lyrics',
        favorite: true,
        timestamp: 1000,
        tradition: PitchTradition.western,
      ),
    );

    test('overwrite carries raga, tala and tradition', () async {
      final existingId = await insertWesternFavorite();

      await service.importContent(
        content: carnaticContent,
        strategy: ImportDuplicateStrategy.overwrite,
      );

      final updated = await repository.findById(existingId);
      expect(updated?.raga, 'Mohanam');
      expect(updated?.tala, 'Adi');
      expect(updated?.tradition, PitchTradition.carnatic);
      expect(updated?.isIndian, isTrue);
      // The user's own star survives the overwrite.
      expect(updated?.favorite, isTrue);
    });

    test('typing the same name in the prompt overwrites fully too', () async {
      final existingId = await insertWesternFavorite();

      await service.importContent(
        content: carnaticContent,
        strategy: ImportDuplicateStrategy.userSuggested,
        onAskUserTitle:
            ({required importedSong, required existingSong}) async =>
                'duplicate test song',
      );

      final updated = await repository.findById(existingId);
      expect(updated?.title, 'Duplicate Test Song');
      expect(updated?.raga, 'Mohanam');
      expect(updated?.tradition, PitchTradition.carnatic);
    });

    test('importSongs saves the given songs exactly', () async {
      const song = SongNote(
        title: 'Previewed Song',
        artist: 'Someone',
        lyrics: 'Chorus line {in braces}\n[G]Words',
        key: 'G',
        bpm: 90,
        timestamp: 0,
        raga: 'Kalyani',
        tala: 'Rupakam',
        tradition: PitchTradition.carnatic,
      );

      final res = await service.importSongs(
        songs: const [song],
        strategy: ImportDuplicateStrategy.renameImported,
      );

      final saved = await repository.findById(res.importedIds.single);
      expect(saved?.lyrics, song.lyrics);
      expect(saved?.key, 'G');
      expect(saved?.bpm, 90);
      expect(saved?.raga, 'Kalyani');
      expect(saved?.tala, 'Rupakam');
      expect(saved?.tradition, PitchTradition.carnatic);
    });
  });
}
