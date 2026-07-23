@Timeout(Duration(seconds: 30))
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyriccord/core/constants/app_constants.dart';
import 'package:lyriccord/providers/database_provider.dart';
import 'package:lyriccord/providers/theme_mode_provider.dart';
import 'package:lyriccord/screens/song_editor_screen.dart';
import 'package:lyriccord/widgets/chord_inserter_bar.dart';

import '../helpers/fake_song_repository.dart';

void main() {
  late FakeSongRepository repo;

  setUp(() {
    repo = FakeSongRepository.seeded();
  });

  tearDown(() async {
    await repo.dispose();
  });

  /// Advances a fixed number of frames instead of [WidgetTester.pumpAndSettle].
  ///
  /// The editor keeps a text field focused after most actions, and its cursor
  /// timer keeps rescheduling frames, so `pumpAndSettle` never settles and hangs
  /// for the full 10-minute timeout. Bounded pumping runs the same async work
  /// (loads, saves, dialog transitions all complete) without waiting for a quiet
  /// frame that never comes.
  Future<void> settle(WidgetTester tester, [int frames = 30]) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> pumpEditor(
    WidgetTester tester, {
    int? songId,
    List<String> savedChords = const [],
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(500, 1100);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      if (savedChords.isNotEmpty) AppConstants.prefCustomChords: savedChords,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          songRepositoryProvider.overrideWithValue(repo),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(home: SongEditorScreen(songId: songId)),
      ),
    );
    await settle(tester);
  }

  /// The lyrics field is the only borderless multi-line field on the screen.
  Finder lyricsField() => find.byWidgetPredicate(
    (w) => w is TextField && w.maxLines == null && w.expands,
  );

  testWidgets('a new song opens an empty editor in C', (tester) async {
    await pumpEditor(tester);

    expect(find.text('New Song Note'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'C'), findsOneWidget);
    // The C-major suggestions are on the toolbar.
    expect(find.widgetWithText(ActionChip, 'Dm'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'G7'), findsOneWidget);
  });

  testWidgets('an existing song opens with its values', (tester) async {
    await pumpEditor(tester, songId: 1);

    expect(find.text('Edit Song Note'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Amazing Grace'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Traditional'), findsOneWidget);
    expect(find.widgetWithText(TextField, '80'), findsOneWidget);
  });

  testWidgets('the suggestions follow the key that is typed', (tester) async {
    await pumpEditor(tester);

    await tester.enterText(find.widgetWithText(TextField, 'C'), 'Am');
    await settle(tester);

    expect(find.widgetWithText(ActionChip, 'Am'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Bdim'), findsOneWidget);
  });

  testWidgets('tapping a chord inserts it into the lyrics', (tester) async {
    await pumpEditor(tester);

    await tester.tap(find.widgetWithText(ActionChip, 'F'));
    await settle(tester);

    final field = tester.widget<TextField>(lyricsField());
    expect(field.controller!.text, '[F]');
  });

  testWidgets('a custom chord is added to the toolbar', (tester) async {
    await pumpEditor(tester);

    // 'Custom' is the last chip in the horizontal toolbar and starts off-screen
    // on this narrow test view, so bring it into view before tapping.
    final customChip = find.widgetWithText(ActionChip, 'Custom');
    await tester.ensureVisible(customChip);
    await settle(tester);
    await tester.tap(customChip);
    await settle(tester);

    await tester.enterText(find.byType(TextField).last, 'Cmaj7');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await settle(tester);

    expect(find.widgetWithText(ActionChip, 'Cmaj7'), findsOneWidget);
    final field = tester.widget<TextField>(lyricsField());
    expect(field.controller!.text, '[Cmaj7]');
  });

  testWidgets('saved custom chords from Settings appear in the toolbar', (
    tester,
  ) async {
    await pumpEditor(tester, savedChords: ['Dsus4', 'Cadd9']);

    expect(find.widgetWithText(ActionChip, 'Dsus4'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Cadd9'), findsOneWidget);
    // The key's own chords are still there, and nothing is doubled.
    expect(find.widgetWithText(ActionChip, 'Dm'), findsOneWidget);
  });

  testWidgets('a saved chord that matches a suggestion is not doubled', (
    tester,
  ) async {
    // 'Dm' is already a C-major suggestion.
    await pumpEditor(tester, savedChords: ['Dm']);

    expect(find.widgetWithText(ActionChip, 'Dm'), findsOneWidget);
  });

  testWidgets('saving a new song stores it', (tester) async {
    await pumpEditor(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Song title'),
      'My New Song',
    );
    await tester.enterText(lyricsField(), 'a line of words');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await settle(tester);

    final songs = repo.currentSongs;
    expect(songs.map((s) => s.title), contains('My New Song'));
    expect(
      songs.firstWhere((s) => s.title == 'My New Song').lyrics,
      'a line of words',
    );
  });

  testWidgets('editing an existing song updates it', (tester) async {
    await pumpEditor(tester, songId: 1);

    await tester.enterText(
      find.widgetWithText(TextField, 'Amazing Grace'),
      'Amazing Grace (live)',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await settle(tester);

    final songs = repo.currentSongs;
    expect(songs, hasLength(3));
    expect(songs.map((s) => s.title), contains('Amazing Grace (live)'));
  });

  testWidgets('Save as copy stores a new song and keeps the original', (
    tester,
  ) async {
    await pumpEditor(tester, songId: 1);

    // Change the key first, so the copy is a real arrangement variant.
    await tester.enterText(find.widgetWithText(TextField, 'G'), 'A');
    await settle(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await settle(tester);
    await tester.tap(find.text('Save as copy'));
    await settle(tester);

    final songs = repo.currentSongs;
    expect(songs, hasLength(4));
    final copy = songs.firstWhere((s) => s.title == 'Amazing Grace (Copy)');
    expect(copy.key, 'A');
    // The original is untouched.
    final original = songs.firstWhere((s) => s.id == 1);
    expect(original.title, 'Amazing Grace');
    expect(original.key, 'G');
  });

  testWidgets('Save as copy is not offered for a new song', (tester) async {
    await pumpEditor(tester);

    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('undo reverts a lyrics edit', (tester) async {
    await pumpEditor(tester);

    // Focus the field first, the way a user does before typing. This commits an
    // empty baseline to the undo history (an unfocused empty field has no valid
    // selection, so no baseline). The history is throttled (~500ms), so let each
    // step settle before the next.
    await tester.tap(lyricsField());
    await settle(tester, 40);
    await tester.enterText(lyricsField(), 'a first line');
    await settle(tester, 40);

    await tester.tap(find.byTooltip('Undo'));
    await settle(tester);

    final field = tester.widget<TextField>(lyricsField());
    expect(field.controller!.text, '');
  });

  testWidgets('cancel asks before throwing edits away', (tester) async {
    await pumpEditor(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Song title'),
      'Half written',
    );
    await tester.tap(find.byIcon(Icons.close));
    await settle(tester);

    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Keep editing'));
    await settle(tester);

    expect(find.byType(ChordInserterBar), findsOneWidget);
    expect(repo.currentSongs, hasLength(3));
  });
}
