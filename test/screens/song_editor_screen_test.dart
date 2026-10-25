@Timeout(Duration(seconds: 30))
library;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/screens/song_editor_screen.dart';
import 'package:lyricchord/widgets/chord_inserter_bar.dart';

import '../helpers/fake_song_repository.dart';
import '../helpers/tooltip_expectations.dart';

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
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SongEditorScreen(songId: songId),
        ),
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
    expectAllIconButtonsHaveTooltips(tester);

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
    expect(songs, hasLength(6));
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
    expect(songs, hasLength(7));
    final copy = songs.firstWhere((s) => s.title == 'Amazing Grace (Copy)');
    expect(copy.key, 'A');
    // The original is untouched.
    final original = songs.firstWhere((s) => s.id == 1);
    expect(original.title, 'Amazing Grace');
    expect(original.key, 'G');
  });

  testWidgets('Save as copy is not offered for a new song', (tester) async {
    await pumpEditor(tester);

    // The menu itself is there — it carries "Paste Carnatic", which is
    // useful while writing a new song. Only the copy item is withheld, because
    // plain Save already creates a new song.
    await tester.tap(find.byIcon(Icons.more_vert));
    await settle(tester);

    expect(find.text('Save as copy'), findsNothing);
    expect(find.text('Paste Carnatic'), findsOneWidget);
  });

  testWidgets('pasting notation needs a tala to check against', (tester) async {
    await pumpEditor(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await settle(tester);
    await tester.tap(find.text('Paste Carnatic'));
    await settle(tester);

    // Without a {tala: ...} line there is nothing to check the cycles against,
    // so the user is told rather than handed a silent wrong answer.
    expect(find.textContaining('tala'), findsWidgets);
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

  testWidgets('focusing the lyrics field folds the meta fields away', (
    tester,
  ) async {
    await pumpEditor(tester, songId: 1);

    // The meta fields show at first.
    expect(find.widgetWithText(TextField, 'Amazing Grace'), findsOneWidget);

    // Focusing the lyrics collapses them into a summary row.
    await tester.tap(lyricsField());
    await settle(tester);

    expect(find.widgetWithText(TextField, 'Amazing Grace'), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);

    // Tapping the summary opens the fields back up.
    await tester.tap(find.byIcon(Icons.expand_more));
    await settle(tester);

    expect(find.widgetWithText(TextField, 'Amazing Grace'), findsOneWidget);
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
    expect(repo.currentSongs, hasLength(6));
  });

  group('melody keypad', () {
    /// Taps a key in the keypad's button block.
    ///
    /// Scoped to the buttons, because the preview grid draws the same swara
    /// text as the key that wrote it.
    Future<void> tapKey(WidgetTester tester, String label) async {
      await tester.tap(
        find.descendant(of: find.byType(Wrap), matching: find.text(label)),
      );
      await settle(tester);
    }

    Future<void> openKeypad(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.more_vert));
      await settle(tester);
      await tester.tap(find.text('Melody keypad'));
      await settle(tester);
    }

    testWidgets('the menu offers the keypad', (tester) async {
      await pumpEditor(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await settle(tester);

      expect(find.text('Melody keypad'), findsOneWidget);
    });

    testWidgets('it opens without a tala, unlike the notation paste', (
      tester,
    ) async {
      await pumpEditor(tester);
      await openKeypad(tester);

      // A melody can be tapped out with no tala — the tala only counts beats.
      expect(find.text('Melody keypad'), findsOneWidget);
    });

    testWidgets('inserting adds the line at the caret', (tester) async {
      await pumpEditor(tester);
      await openKeypad(tester);

      await tapKey(tester, 'S');
      await tapKey(tester, 'G3');
      await tester.tap(find.widgetWithText(FilledButton, 'Insert'));
      await settle(tester);

      final field = tester.widget<TextField>(lyricsField());
      expect(field.controller!.text, '{melody} S G3\n');
    });

    testWidgets('with the caret on a melody line it replaces that line', (
      tester,
    ) async {
      await pumpEditor(tester);

      await tester.enterText(lyricsField(), 'Sing\n{melody} S R2\nMore');
      await settle(tester);

      // Put the caret inside the melody line.
      final controller = tester.widget<TextField>(lyricsField()).controller!;
      controller.selection = const TextSelection.collapsed(offset: 12);
      await settle(tester);

      await openKeypad(tester);
      await tapKey(tester, 'G3');
      await tester.tap(find.widgetWithText(FilledButton, 'Insert'));
      await settle(tester);

      // The old line is gone, not duplicated, and the lyrics around it stay.
      expect(controller.text, 'Sing\n{melody} S R2 G3\nMore');
    });

    testWidgets('with the caret on a lyric line it adds a new line', (
      tester,
    ) async {
      await pumpEditor(tester);

      await tester.enterText(lyricsField(), 'Sing');
      await settle(tester);

      await openKeypad(tester);
      await tapKey(tester, 'S');
      await tester.tap(find.widgetWithText(FilledButton, 'Insert'));
      await settle(tester);

      final controller = tester.widget<TextField>(lyricsField()).controller!;
      expect(controller.text, 'Sing\n{melody} S\n');
    });
  });

  group('notation picker', () {
    /// The Notation dropdown, which decides Key vs Raga + Tala.
    Finder notationPicker() =>
        find.byType(DropdownButtonFormField<PitchTradition>);

    Future<void> chooseNotation(WidgetTester tester, String label) async {
      await tester.tap(notationPicker());
      await settle(tester);
      await tester.tap(find.text(label).last);
      await settle(tester);
    }

    testWidgets('a new song starts Western and shows the Key field', (
      tester,
    ) async {
      await pumpEditor(tester);

      expect(find.text('Original key'), findsOneWidget);
      expect(find.text('Raga'), findsNothing);
      expect(find.text('Tala'), findsNothing);
    });

    testWidgets('choosing Carnatic swaps Key for Raga and Tala', (
      tester,
    ) async {
      await pumpEditor(tester);

      await chooseNotation(tester, 'Carnatic');

      // An Indian sheet is written in swaras, so there is no key to transpose.
      expect(find.text('Original key'), findsNothing);
      expect(find.text('Raga'), findsOneWidget);
      expect(find.text('Tala'), findsOneWidget);
    });

    testWidgets('an Indian song opens with its raga and tala filled in', (
      tester,
    ) async {
      // Song 4 is seeded as Carnatic in the fake repository.
      await pumpEditor(tester, songId: 4);

      expect(find.widgetWithText(TextField, 'Hamsadhvani'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Adi'), findsOneWidget);
      expect(find.text('Original key'), findsNothing);
    });

    testWidgets('a tala from the other tradition warns but does not block', (
      tester,
    ) async {
      await pumpEditor(tester);
      await chooseNotation(tester, 'Carnatic');

      await tester.enterText(
        find.widgetWithText(TextField, 'Adi, Keherwa'),
        'Keherwa',
      );
      await settle(tester);

      expect(find.textContaining('usually a Hindustani tala'), findsOneWidget);

      // The warning is advice, not a gate — saving still works.
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await settle(tester);

      expect(repo.currentSongs, hasLength(7));
      final saved = repo.currentSongs.firstWhere((s) => s.tala == 'Keherwa');
      expect(saved.tradition, PitchTradition.carnatic);
    });

    testWidgets('a matching tala shows no warning', (tester) async {
      await pumpEditor(tester);
      await chooseNotation(tester, 'Carnatic');

      await tester.enterText(
        find.widgetWithText(TextField, 'Adi, Keherwa'),
        'Adi',
      );
      await settle(tester);

      expect(find.textContaining('usually a'), findsNothing);
    });

    testWidgets('switching back to Western clears the raga and tala', (
      tester,
    ) async {
      await pumpEditor(tester);
      await chooseNotation(tester, 'Carnatic');

      await tester.enterText(
        find.widgetWithText(TextField, 'Kalyani, Yaman'),
        'Kalyani',
      );
      await settle(tester);

      await chooseNotation(tester, 'Western');
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await settle(tester);

      // A stale raga left behind would make the song look Indian again.
      final saved = repo.currentSongs.firstWhere((s) => s.id == 7);
      expect(saved.raga, isEmpty);
      expect(saved.tradition, PitchTradition.western);
      expect(saved.isIndian, isFalse);
    });

    testWidgets('an Indian song saves its tradition', (tester) async {
      await pumpEditor(tester);
      await chooseNotation(tester, 'Hindustani');

      await tester.enterText(
        find.widgetWithText(TextField, 'Kalyani, Yaman'),
        'Yaman',
      );
      await settle(tester);

      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await settle(tester);

      final saved = repo.currentSongs.firstWhere((s) => s.id == 7);
      expect(saved.raga, 'Yaman');
      expect(saved.tradition, PitchTradition.hindustani);
      expect(saved.isIndian, isTrue);
    });
  });
}
