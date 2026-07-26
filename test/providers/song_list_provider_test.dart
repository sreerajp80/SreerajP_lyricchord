import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/data/app_database.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/song_list_provider.dart';

import '../helpers/test_database.dart';

void main() {
  group('filterSongs (pure)', () {
    final songs = [
      _song(
        id: 1,
        title: 'Amazing Grace',
        artist: 'Traditional',
        lyrics: 'how sweet the sound',
        favorite: true,
      ),
      _song(
        id: 2,
        title: 'Jingle Bells',
        artist: 'Pierpont',
        lyrics: 'dashing through the snow',
      ),
      _song(
        id: 3,
        title: 'House of the Rising Sun',
        artist: 'The Animals',
        lyrics: 'there is a house in New Orleans',
      ),
    ];

    test('an empty query keeps every song', () {
      final result = filterSongs(songs, filter: SongFilter.all, query: '');
      expect(result, hasLength(3));
    });

    test('matches the title, ignoring case', () {
      final result = filterSongs(
        songs,
        filter: SongFilter.all,
        query: 'jingle',
      );
      expect(result.single.title, 'Jingle Bells');
    });

    test('matches the artist', () {
      final result = filterSongs(
        songs,
        filter: SongFilter.all,
        query: 'animals',
      );
      expect(result.single.title, 'House of the Rising Sun');
    });

    test('matches the lyrics', () {
      final result = filterSongs(songs, filter: SongFilter.all, query: 'snow');
      expect(result.single.title, 'Jingle Bells');
    });

    test('the starred filter keeps only favorites', () {
      final result = filterSongs(songs, filter: SongFilter.starred, query: '');
      expect(result.single.title, 'Amazing Grace');
    });

    test('the starred filter and the search apply together', () {
      final result = filterSongs(
        songs,
        filter: SongFilter.starred,
        query: 'jingle',
      );
      expect(result, isEmpty);
    });

    test('no match gives an empty list', () {
      final result = filterSongs(
        songs,
        filter: SongFilter.all,
        query: 'nothing here',
      );
      expect(result, isEmpty);
    });
  });

  group('providers over a real database', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = newInMemoryDatabase();
      container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    /// Keeps the stream alive and waits for its first value.
    Future<void> primeSongs() async {
      container.listen(songsStreamProvider, (_, _) {});
      await container.read(songsStreamProvider.future);
    }

    /// Waits until [check] passes.
    ///
    /// After a write, drift pushes a new value through the stream on a later
    /// event-loop turn. Awaiting `songsStreamProvider.future` again would
    /// return the value we already have, so we wait for the change itself.
    /// Fails loudly if it never arrives.
    Future<void> waitUntil(bool Function() check) async {
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (!check()) {
        if (DateTime.now().isAfter(deadline)) {
          fail('The expected change did not arrive within 5 seconds.');
        }
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
    }

    test('counts report the seeded songs and the one starred song', () async {
      await primeSongs();

      final counts = container.read(songCountsProvider);
      expect(counts.total, 3);
      expect(counts.starred, 1);
    });

    test('changing the search narrows the visible list', () async {
      await primeSongs();
      expect(container.read(filteredSongsProvider), hasLength(3));

      container.read(searchQueryProvider.notifier).setQuery('  JINGLE ');
      expect(
        container.read(filteredSongsProvider).single.title,
        'Jingle Bells',
      );

      container.read(searchQueryProvider.notifier).clear();
      expect(container.read(filteredSongsProvider), hasLength(3));
    });

    test('switching to the starred filter shows only favorites', () async {
      await primeSongs();

      container.read(songFilterProvider.notifier).setFilter(SongFilter.starred);
      expect(
        container.read(filteredSongsProvider).single.title,
        'Amazing Grace',
      );
    });

    test('starring a song updates the counts live', () async {
      await primeSongs();

      final jingle = container
          .read(filteredSongsProvider)
          .firstWhere((s) => s.title == 'Jingle Bells');
      await container.read(songRepositoryProvider).toggleFavorite(jingle);
      await waitUntil(() => container.read(songCountsProvider).starred == 2);

      expect(container.read(songCountsProvider).starred, 2);
    });

    test('deleting a song updates the counts live', () async {
      await primeSongs();

      final first = container.read(filteredSongsProvider).first;
      await container.read(songRepositoryProvider).delete(first.id);
      await waitUntil(() => container.read(songCountsProvider).total == 2);

      expect(container.read(songCountsProvider).total, 2);
    });

    test('the selected song id starts empty and can be set and cleared', () {
      expect(container.read(selectedSongIdProvider), isNull);

      container.read(selectedSongIdProvider.notifier).select(7);
      expect(container.read(selectedSongIdProvider), 7);

      container.read(selectedSongIdProvider.notifier).select(null);
      expect(container.read(selectedSongIdProvider), isNull);
    });
  });
}

SongNote _song({
  required int id,
  required String title,
  String artist = '',
  String lyrics = '',
  bool favorite = false,
}) => SongNote(
  id: id,
  title: title,
  artist: artist,
  lyrics: lyrics,
  favorite: favorite,
  timestamp: id,
);
