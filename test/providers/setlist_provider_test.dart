import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/data/app_database.dart';
import 'package:lyricchord/models/setlist.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/setlist_provider.dart';

import '../helpers/test_database.dart';

void main() {
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

  /// The next value of [provider] that satisfies [test].
  Future<T> nextValue<T>(
    StreamProvider<T> provider,
    bool Function(T value) test,
  ) async {
    final sub = container.listen(provider, (_, _) {});
    addTearDown(sub.close);
    while (true) {
      final value = container.read(provider).value;
      if (value != null && test(value)) return value;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  test('setlistsStreamProvider streams the seeded setlist', () async {
    final setlists = await nextValue<List<Setlist>>(
      setlistsStreamProvider,
      (list) => list.isNotEmpty,
    );

    expect(setlists.single.name, 'Sunday Gig');
    expect(setlists.single.songs, isNotEmpty);
  });

  test('setlistsStreamProvider sees a new setlist', () async {
    await nextValue<List<Setlist>>(
      setlistsStreamProvider,
      (list) => list.isNotEmpty,
    );

    await container
        .read(setlistRepositoryProvider)
        .insertSetlist(name: 'Wedding');

    final setlists = await nextValue<List<Setlist>>(
      setlistsStreamProvider,
      (list) => list.length == 2,
    );
    expect(setlists.map((s) => s.name), contains('Wedding'));
  });

  test('setlistByIdProvider follows one setlist and its songs', () async {
    final repo = container.read(setlistRepositoryProvider);
    final id = await repo.insertSetlist(name: 'Short', songIds: [1]);

    final first = await nextValue<Setlist?>(
      setlistByIdProvider(id),
      (s) => s != null,
    );
    expect(first!.songs.map((s) => s.id), [1]);

    await repo.addSongToSetlist(id, 2);
    final second = await nextValue<Setlist?>(
      setlistByIdProvider(id),
      (s) => s != null && s.songCount == 2,
    );
    expect(second!.songs.map((s) => s.id), [1, 2]);
  });

  test('activeSetlistIdProvider starts empty and can be set', () {
    expect(container.read(activeSetlistIdProvider), isNull);

    container.read(activeSetlistIdProvider.notifier).setActiveSetlist(3);
    expect(container.read(activeSetlistIdProvider), 3);

    container.read(activeSetlistIdProvider.notifier).setActiveSetlist(null);
    expect(container.read(activeSetlistIdProvider), isNull);
  });
}
