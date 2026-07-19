import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyriccord/providers/database_provider.dart';
import 'package:lyriccord/screens/home_shell.dart';
import 'package:lyriccord/widgets/song_card.dart';

import '../helpers/fake_song_repository.dart';

void main() {
  late FakeSongRepository repo;

  setUp(() {
    repo = FakeSongRepository.seeded();
  });

  tearDown(() async {
    await repo.dispose();
  });

  /// Pumps the songbook at a given window width, so we can test both the phone
  /// (< 600 dp) and the tablet (>= 600 dp) layout.
  Future<void> pumpSongbook(WidgetTester tester, {double width = 400}) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = Size(width, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [songRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: HomeShell()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists the seeded songs with their counts', (tester) async {
    await pumpSongbook(tester);

    expect(find.byType(SongCard), findsNWidgets(3));
    expect(find.text('All Songs (3)'), findsOneWidget);
    expect(find.text('Starred (1)'), findsOneWidget);
  });

  testWidgets('shows newest activity first', (tester) async {
    await pumpSongbook(tester);

    final titles = tester
        .widgetList<SongCard>(find.byType(SongCard))
        .map((card) => card.song.title)
        .toList();
    expect(titles, [
      'Jingle Bells',
      'House of the Rising Sun',
      'Amazing Grace',
    ]);
  });

  testWidgets('search narrows the list and clearing restores it', (
    tester,
  ) async {
    await pumpSongbook(tester);

    await tester.enterText(find.byType(TextField), 'jingle');
    await tester.pumpAndSettle();
    expect(find.byType(SongCard), findsOneWidget);
    expect(find.text('Jingle Bells'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.byType(SongCard), findsNWidgets(3));
  });

  testWidgets('search also matches the artist and the lyrics', (tester) async {
    await pumpSongbook(tester);

    await tester.enterText(find.byType(TextField), 'pierpont');
    await tester.pumpAndSettle();
    expect(find.text('Jingle Bells'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'new orleans');
    await tester.pumpAndSettle();
    expect(find.text('House of the Rising Sun'), findsOneWidget);
    expect(find.byType(SongCard), findsOneWidget);
  });

  testWidgets('a search with no match shows the "No matches" state', (
    tester,
  ) async {
    await pumpSongbook(tester);

    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pumpAndSettle();

    expect(find.byType(SongCard), findsNothing);
    expect(find.text('No matches'), findsOneWidget);
  });

  testWidgets('the Starred filter shows only starred songs', (tester) async {
    await pumpSongbook(tester);

    await tester.tap(find.text('Starred (1)'));
    await tester.pumpAndSettle();

    expect(find.byType(SongCard), findsOneWidget);
    expect(find.text('Amazing Grace'), findsOneWidget);
  });

  testWidgets('tapping the star updates the starred count live', (
    tester,
  ) async {
    await pumpSongbook(tester);

    await tester.tap(find.byIcon(Icons.star_border).first);
    await tester.pumpAndSettle();

    expect(find.text('Starred (2)'), findsOneWidget);
  });

  testWidgets('delete asks first, then removes the song', (tester) async {
    await pumpSongbook(tester);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('Delete song?'), findsOneWidget);

    // Cancel keeps the song.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(SongCard), findsNWidgets(3));

    // Confirming removes it and the counts follow.
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(SongCard), findsNWidgets(2));
    expect(find.text('All Songs (2)'), findsOneWidget);
  });

  testWidgets('the empty songbook state appears when there are no songs', (
    tester,
  ) async {
    repo = FakeSongRepository();

    await pumpSongbook(tester);

    expect(find.byType(SongCard), findsNothing);
    expect(find.text('Your songbook is empty'), findsOneWidget);
  });

  testWidgets('the Starred filter has its own empty state', (tester) async {
    await pumpSongbook(tester);

    // Unstar the only starred song, then switch to the Starred filter.
    await tester.tap(find.byIcon(Icons.star));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Starred (0)'));
    await tester.pumpAndSettle();

    expect(find.text('No starred songs'), findsOneWidget);
  });

  testWidgets('phone width (< 600 dp) shows a single pane', (tester) async {
    await pumpSongbook(tester, width: 400);

    expect(find.text('Pick a song'), findsNothing);
  });

  testWidgets('tablet width (>= 600 dp) shows the dual pane', (tester) async {
    await pumpSongbook(tester, width: 900);

    // The right pane starts on its welcome state.
    expect(find.text('Pick a song'), findsOneWidget);

    // Tapping a card opens it in the right pane instead of navigating.
    await tester.tap(find.text('Amazing Grace'));
    await tester.pumpAndSettle();

    expect(find.text('Pick a song'), findsNothing);
    expect(find.text('Performance view (Phase 4)'), findsOneWidget);
  });
}
