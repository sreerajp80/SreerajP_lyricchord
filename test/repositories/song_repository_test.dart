import 'package:flutter_test/flutter_test.dart';
import 'package:lyriccord/data/app_database.dart';
import 'package:lyriccord/models/song_note.dart';
import 'package:lyriccord/repositories/song_repository.dart';

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
    test('seeds the three classic songs on first open', () async {
      final songs = await repo.watchAllSongs().first;

      expect(songs, hasLength(3));
      expect(songs.map((s) => s.title).toSet(), {
        'Amazing Grace',
        'House of the Rising Sun',
        'Jingle Bells',
      });
    });

    test('Amazing Grace is the only starred seed song', () async {
      final songs = await repo.watchAllSongs().first;
      final starred = songs.where((s) => s.favorite).toList();

      expect(starred, hasLength(1));
      expect(starred.single.title, 'Amazing Grace');
      expect(starred.single.key, 'G');
      expect(starred.single.bpm, 80);
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
  });

  group('insert / update / delete', () {
    test('insert adds a song and returns its new id', () async {
      final id = await repo.insert(_newSong(title: 'My Song'));
      expect(id, greaterThan(0));

      final songs = await repo.watchAllSongs().first;
      expect(songs, hasLength(4));
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
      expect(emissions.first, 3);
      expect(emissions.last, 4);
    });
  });
}

SongNote _newSong({required String title}) => SongNote(
  title: title,
  artist: 'Tester',
  lyrics: '[C]La la la',
  key: 'C',
  bpm: 100,
  timestamp: DateTime.now().millisecondsSinceEpoch,
);
