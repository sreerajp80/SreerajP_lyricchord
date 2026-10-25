import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/core/errors/app_exception.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/models/setlist.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/setlist_provider.dart';
import 'package:lyricchord/screens/setlist_detail_screen.dart';

import '../helpers/fake_setlist_repository.dart';
import '../helpers/fake_song_repository.dart';
import '../helpers/tooltip_expectations.dart';

const _songA = SongNote(
  id: 1,
  title: 'Song A',
  artist: 'Band',
  key: 'G',
  bpm: 90,
  timestamp: 1,
);
const _songB = SongNote(id: 2, title: 'Song B', key: 'D', timestamp: 2);
const _songC = SongNote(id: 3, title: 'Song C', key: 'E', timestamp: 3);

void main() {
  late FakeSetlistRepository setlists;
  late FakeSongRepository songs;
  late ProviderContainer container;

  tearDown(() async {
    await setlists.dispose();
    await songs.dispose();
  });

  Future<void> pump(WidgetTester tester, Setlist setlist) async {
    songs = FakeSongRepository(const [_songA, _songB, _songC]);
    setlists = FakeSetlistRepository(
      songs: const [_songA, _songB, _songC],
      initial: [setlist],
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
          routes: [
            GoRoute(
              path: 'setlists/:id',
              builder: (_, state) => SetlistDetailScreen(
                setlistId: int.parse(state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/song/:id',
          builder: (_, state) => Text(
            'song ${state.pathParameters['id']} '
            'in ${state.uri.queryParameters['setlistId']}',
          ),
        ),
        GoRoute(
          path: '/air-qr-transmit',
          builder: (_, _) => const Text('air qr'),
        ),
      ],
    );
    addTearDown(router.dispose);
    container = ProviderContainer(
      overrides: [
        setlistRepositoryProvider.overrideWithValue(setlists),
        songRepositoryProvider.overrideWithValue(songs),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    router.push('/setlists/${setlist.id}');
    await tester.pumpAndSettle();
  }

  const gig = Setlist(
    id: 4,
    name: 'Gig',
    description: 'At the hall',
    createdAt: 0,
    updatedAt: 0,
    songs: [_songA, _songB],
  );

  testWidgets('shows the songs in order with their details', (tester) async {
    await pump(tester, gig);

    expect(find.text('Gig'), findsOneWidget);
    expect(find.text('At the hall'), findsOneWidget);
    expect(find.text('2 Songs'), findsOneWidget);
    final a = tester.getTopLeft(find.text('Song A'));
    final b = tester.getTopLeft(find.text('Song B'));
    expect(a.dy, lessThan(b.dy));
    expect(find.text('Key: D • 120 BPM'), findsOneWidget);
    expect(find.text('Perform Setlist'), findsOneWidget);
    expectAllIconButtonsHaveTooltips(tester);
  });

  testWidgets('Perform Setlist starts the first song', (tester) async {
    await pump(tester, gig);

    await tester.tap(find.text('Perform Setlist'));
    await tester.pumpAndSettle();

    expect(find.text('song 1 in 4'), findsOneWidget);
    expect(container.read(activeSetlistIdProvider), 4);
  });

  testWidgets('tapping a song starts the setlist there', (tester) async {
    await pump(tester, gig);

    await tester.tap(find.text('Song B'));
    await tester.pumpAndSettle();

    expect(find.text('song 2 in 4'), findsOneWidget);
  });

  testWidgets('removing a song keeps the rest', (tester) async {
    await pump(tester, gig);

    await tester.tap(find.byTooltip('Remove from setlist').first);
    await tester.pumpAndSettle();

    expect(setlists.songIdsOf(4), [2]);
    expect(find.text('Song A'), findsNothing);
    expect(find.text('1 Song'), findsOneWidget);
  });

  testWidgets('Add Songs adds the picked songs', (tester) async {
    await pump(tester, gig);

    await tester.tap(find.text('Add Songs'));
    await tester.pumpAndSettle();
    expect(find.text('Add Songs to Setlist'), findsOneWidget);

    await tester.tap(find.text('Song C'));
    await tester.pump();
    await tester.tap(find.text('Done (3)'));
    await tester.pumpAndSettle();

    expect(setlists.songIdsOf(4), [1, 2, 3]);
  });

  testWidgets('deleting asks first, then leaves the screen', (tester) async {
    await pump(tester, gig);

    await tester.tap(find.byTooltip('Delete setlist'));
    await tester.pumpAndSettle();
    expect(find.text('Delete setlist?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(setlists.contains(4), isTrue);

    await tester.tap(find.byTooltip('Delete setlist'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));

    // Frame by frame: the screen must close without ever drawing the deleted
    // setlist as "not found".
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.text('Setlist not found.'), findsNothing);
    }
    await tester.pumpAndSettle();

    expect(setlists.contains(4), isFalse);
    expect(find.text('home'), findsOneWidget);
    expect(find.text('Deleted setlist "Gig".'), findsOneWidget);
  });

  testWidgets('a failed delete says so and keeps the setlist', (tester) async {
    await pump(tester, gig);
    setlists.deleteError = const StorageException(
      'Could not delete setlist.',
      kind: StorageFailure.deleteSetlist,
    );

    await tester.tap(find.byTooltip('Delete setlist'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(setlists.contains(4), isTrue);
    expect(find.text('home'), findsOneWidget);
    expect(find.text('Deleted setlist "Gig".'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text('Could not delete setlist.'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('an empty setlist offers to add songs and cannot be sent', (
    tester,
  ) async {
    await pump(
      tester,
      const Setlist(id: 5, name: 'Empty', createdAt: 0, updatedAt: 0),
    );

    expect(find.text('No songs in this setlist'), findsOneWidget);
    expect(find.text('Perform Setlist'), findsNothing);

    await tester.tap(find.byTooltip('Send via AirQR'));
    await tester.pump();
    expect(find.text('No songs in setlist to share.'), findsOneWidget);
  });

  testWidgets('a missing setlist says so', (tester) async {
    await pump(tester, gig);
    await setlists.deleteSetlist(4);
    await tester.pumpAndSettle();

    expect(find.text('Setlist not found.'), findsOneWidget);
  });
}
