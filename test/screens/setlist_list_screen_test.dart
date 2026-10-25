import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/models/setlist.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/screens/setlist_list_screen.dart';

import '../helpers/fake_setlist_repository.dart';
import '../helpers/tooltip_expectations.dart';

const _songA = SongNote(id: 1, title: 'Song A', key: 'G', timestamp: 1);
const _songB = SongNote(id: 2, title: 'Song B', key: 'D', timestamp: 2);

void main() {
  late FakeSetlistRepository repo;

  tearDown(() async => repo.dispose());

  Future<GoRouter> pump(WidgetTester tester, List<Setlist> setlists) async {
    repo = FakeSetlistRepository(
      songs: const [_songA, _songB],
      initial: setlists,
    );
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SetlistListScreen()),
        GoRoute(
          path: '/setlists/:id',
          builder: (_, state) => Text('detail ${state.pathParameters['id']}'),
        ),
        GoRoute(
          path: '/song/:id',
          builder: (_, state) => Text(
            'song ${state.pathParameters['id']} '
            'in ${state.uri.queryParameters['setlistId']}',
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [setlistRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp.router(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('an empty library shows the empty state', (tester) async {
    await pump(tester, const []);

    expect(find.text('No setlists yet'), findsOneWidget);
    expect(find.text('Create Setlist'), findsOneWidget);
    expectAllIconButtonsHaveTooltips(tester);
  });

  testWidgets('lists each setlist with its song count', (tester) async {
    await pump(tester, const [
      Setlist(
        id: 1,
        name: 'Sunday Gig',
        createdAt: 0,
        updatedAt: 0,
        songs: [_songA, _songB],
      ),
      Setlist(id: 2, name: 'Rehearsal', createdAt: 0, updatedAt: 0),
    ]);

    expect(find.text('Sunday Gig'), findsOneWidget);
    expect(find.text('2 songs'), findsOneWidget);
    expect(find.text('Rehearsal'), findsOneWidget);
    expect(find.text('0 songs'), findsOneWidget);
    expect(find.text('New Setlist'), findsOneWidget);
    expectAllIconButtonsHaveTooltips(tester);
  });

  testWidgets('tapping a setlist opens it', (tester) async {
    await pump(tester, const [
      Setlist(id: 7, name: 'Gig', createdAt: 0, updatedAt: 0),
    ]);

    await tester.tap(find.text('Gig'));
    await tester.pumpAndSettle();

    expect(find.text('detail 7'), findsOneWidget);
  });

  testWidgets('Perform starts the first song of the setlist', (tester) async {
    await pump(tester, const [
      Setlist(
        id: 3,
        name: 'Gig',
        createdAt: 0,
        updatedAt: 0,
        songs: [_songB, _songA],
      ),
    ]);

    await tester.tap(find.text('Perform'));
    await tester.pumpAndSettle();

    expect(find.text('song 2 in 3'), findsOneWidget);
  });

  testWidgets('New Setlist creates one and opens it', (tester) async {
    await pump(tester, const []);

    await tester.tap(find.text('Create Setlist'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Wedding');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(repo.contains(1), isTrue);
    expect(find.text('detail 1'), findsOneWidget);
  });
}
