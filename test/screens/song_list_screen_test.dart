import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/screens/home_shell.dart';
import 'package:lyricchord/widgets/song_card.dart';

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

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          songRepositoryProvider.overrideWithValue(repo),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: HomeShell()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the app bar has a Settings button', (tester) async {
    await pumpSongbook(tester);

    expect(find.byTooltip('Settings'), findsOneWidget);
  });

  testWidgets('lists the seeded songs with their counts', (tester) async {
    await pumpSongbook(tester);

    expect(find.byType(SongCard), findsNWidgets(6));
    expect(find.text('All Songs (6)'), findsOneWidget);
    expect(find.text('Starred (2)'), findsOneWidget);
  });

  testWidgets('shows newest activity first', (tester) async {
    await pumpSongbook(tester);

    final titles = tester
        .widgetList<SongCard>(find.byType(SongCard))
        .map((card) => card.song.title)
        .toList();
    expect(titles, [
      'Krishna Nee Begane Baro (Raga Yamunakalyani)',
      'Raghupati Raghava Raja Ram (Raga Mishra Gara)',
      'Vathapi Ganapathim (Raga Hamsadhvani)',
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
    expect(find.byType(SongCard), findsNWidgets(6));
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

    await tester.tap(find.text('Starred (2)'));
    await tester.pumpAndSettle();

    expect(find.byType(SongCard), findsNWidgets(2));
    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(find.text('Vathapi Ganapathim (Raga Hamsadhvani)'), findsOneWidget);
  });

  testWidgets('tapping the star updates the starred count live', (
    tester,
  ) async {
    await pumpSongbook(tester);

    await tester.tap(find.byIcon(Icons.star_border).first);
    await tester.pumpAndSettle();

    expect(find.text('Starred (3)'), findsOneWidget);
  });

  testWidgets('delete asks first, then removes the song', (tester) async {
    await pumpSongbook(tester);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('Delete song?'), findsOneWidget);

    // Cancel keeps the song.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(SongCard), findsNWidgets(6));

    // Confirming removes it and the counts follow.
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(SongCard), findsNWidgets(5));
    expect(find.text('All Songs (5)'), findsOneWidget);
  });

  testWidgets('duplicate adds a copy of the song to the list', (tester) async {
    await pumpSongbook(tester);

    // The list is newest-first, so the first duplicate icon is Krishna Nee Begane Baro.
    await tester.tap(find.byIcon(Icons.content_copy_outlined).first);
    await tester.pumpAndSettle();

    expect(find.byType(SongCard), findsNWidgets(7));
    expect(
      find.text('Krishna Nee Begane Baro (Raga Yamunakalyani) (Copy)'),
      findsOneWidget,
    );
    expect(find.text('All Songs (7)'), findsOneWidget);
    // The original is still there.
    expect(
      find.text('Krishna Nee Begane Baro (Raga Yamunakalyani)'),
      findsOneWidget,
    );
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

    // Unstar all starred songs, then switch to the Starred filter.
    while (find.byIcon(Icons.star).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.star).first);
      await tester.pumpAndSettle();
    }

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
    // The right pane now shows the real performance view for the song.
    expect(
      find.textContaining('Auto-scroll', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('long press enters selection mode and toggles selection', (
    tester,
  ) async {
    await pumpSongbook(tester);

    await tester.longPress(find.text('Amazing Grace'));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);
    expect(find.byType(Checkbox), findsNWidgets(6));

    // Tap another song to select it
    await tester.tap(find.text('Jingle Bells'));
    await tester.pumpAndSettle();

    expect(find.text('2 selected'), findsOneWidget);

    // Tap close to cancel selection mode
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('2 selected'), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets(
    'select all and deselect all button toggles selection of all songs',
    (tester) async {
      await pumpSongbook(tester);

      await tester.longPress(find.text('Amazing Grace'));
      await tester.pumpAndSettle();

      // Tap select all button
      await tester.tap(find.byIcon(Icons.select_all));
      await tester.pumpAndSettle();

      expect(find.text('6 selected'), findsOneWidget);

      // Tap deselect all button
      await tester.tap(find.byIcon(Icons.deselect));
      await tester.pumpAndSettle();

      expect(find.text('6 selected'), findsNothing);
    },
  );
}
