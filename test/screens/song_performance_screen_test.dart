import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/screens/song_performance_screen.dart';
import 'package:lyricchord/services/melody_audio_service.dart';
import 'package:lyricchord/services/melody_player_service.dart';
import 'package:lyricchord/widgets/chord_sheet_view.dart';
import 'package:lyricchord/widgets/harmonium_chord_diagram.dart';
import 'package:lyricchord/widgets/swara_keyboard_diagram.dart';
import 'package:lyricchord/widgets/performance_controls.dart';
import 'package:lyricchord/widgets/scroll_gesture_layer.dart';

import '../helpers/fake_song_repository.dart';

void main() {
  late FakeSongRepository repo;

  setUp(() {
    repo = FakeSongRepository.seeded();
  });

  tearDown(() async {
    await repo.dispose();
  });

  /// Opens Amazing Grace (id 1, key G).
  Future<void> pumpPerformance(
    WidgetTester tester, {
    int songId = 1,
    double? startingSpeed,
    Size viewSize = const Size(500, 1000),
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = viewSize;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      AppConstants.prefDefaultScrollSpeed: ?startingSpeed,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          songRepositoryProvider.overrideWithValue(repo),
          sharedPreferencesProvider.overrideWithValue(prefs),
          // A melody row builds the player, so keep any real audio device out
          // of the test.
          melodyAudioProvider.overrideWithValue(_SilentMelodyAudio()),
        ],
        child: MaterialApp(home: SongPerformanceScreen(songId: songId)),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Opens the Performance-controls bottom sheet from the overflow menu.
  Future<void> openControlsSheet(WidgetTester tester) async {
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Performance controls'));
    await tester.pumpAndSettle();
  }

  /// The chords the sheet is currently drawing.
  List<String> sheetChords(WidgetTester tester) {
    final view = tester.widget<ChordSheetView>(find.byType(ChordSheetView));
    return view.lines.expand((line) => line.chords).toList();
  }

  ChordSheetView sheet(WidgetTester tester) =>
      tester.widget<ChordSheetView>(find.byType(ChordSheetView));

  /// All lyric text the sheet is currently drawing, joined into one string.
  String sheetText(WidgetTester tester) => sheet(
    tester,
  ).lines.expand((line) => line.segments).map((segment) => segment.text).join();

  /// The live auto-scroll values of the running screen. The speed is not
  /// written on screen any more — it is changed by tapping the sheet — so the
  /// provider is what the tests check.
  AutoScrollSettings scrollState(WidgetTester tester) =>
      ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
        listen: false,
      ).read(autoScrollProvider);

  /// Where to double-tap on the sheet. The gesture layer fills the space under
  /// the header, so its own halves — not the screen's — decide faster/slower.
  Offset sheetSpot(WidgetTester tester, {required bool upper}) {
    final rect = tester.getRect(find.byType(ScrollGestureLayer));
    return Offset(
      rect.center.dx,
      upper ? rect.top + rect.height * 0.25 : rect.top + rect.height * 0.75,
    );
  }

  /// Two quick taps at the same spot, inside the double-tap window.
  Future<void> doubleTapSheet(
    WidgetTester tester, {
    required bool upper,
  }) async {
    final spot = sheetSpot(tester, upper: upper);
    await tester.tapAt(spot);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(spot);
    await tester.pump();
  }

  testWidgets('shows the song and its written chords', (tester) async {
    await pumpPerformance(tester);

    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(sheetChords(tester), ['G']);
  });

  group('the reference guide follows the song\'s notation', () {
    testWidgets('a Western song offers the Chord Reference Guide', (
      tester,
    ) async {
      await pumpPerformance(tester);

      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();

      expect(find.text('Chord Reference Guide'), findsOneWidget);
      expect(find.text('Swara Reference'), findsNothing);
    });

    testWidgets('a raga song offers the Swara Reference instead', (
      tester,
    ) async {
      // Song 5 is "Raghupati Raghava Raja Ram", written in swaras.
      await pumpPerformance(tester, songId: 5);

      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();

      expect(find.text('Swara Reference'), findsOneWidget);
      expect(find.text('Chord Reference Guide'), findsNothing);
    });

    testWidgets('the Swara Reference draws a keyboard per swara, in pitch '
        'order', (tester) async {
      await pumpPerformance(tester, songId: 5);

      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Swara Reference'));
      await tester.pumpAndSettle();

      // The fixture uses Sa, Pa and Ma. They must be sorted low to high, so a
      // reference reads like a scale rather than in order of appearance.
      final labels = tester
          .widgetList<SwaraKeyboardDiagram>(find.byType(SwaraKeyboardDiagram))
          .map((d) => d.swara)
          .toList();

      expect(labels, ['Sa', 'Ma', 'Pa']);
      // Never a chord shape for a swara — that was the bug.
      expect(find.byType(HarmoniumChordDiagram), findsNothing);
    });
  });

  testWidgets('transpose up in the controls sheet moves the chords', (
    tester,
  ) async {
    await pumpPerformance(tester);
    await openControlsSheet(tester);

    await tester.tap(find.byTooltip('Transpose up'));
    await tester.pumpAndSettle();

    // G up one semitone is Ab, a flat key, so the chord is spelled with a flat.
    expect(sheetChords(tester), ['Ab']);
    expect(find.text('Ab'), findsWidgets);
  });

  testWidgets('transpose down moves the other way', (tester) async {
    await pumpPerformance(tester);
    await openControlsSheet(tester);

    await tester.tap(find.byTooltip('Transpose down'));
    await tester.pumpAndSettle();

    expect(sheetChords(tester), ['F#']);
  });

  testWidgets('reset returns the song to its written key', (tester) async {
    await pumpPerformance(tester);
    await openControlsSheet(tester);

    await tester.tap(find.byTooltip('Transpose up'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(sheetChords(tester), ['G']);
  });

  testWidgets('show chords in the controls sheet hides the badges', (
    tester,
  ) async {
    await pumpPerformance(tester);
    expect(sheet(tester).showChords, isTrue);

    await openControlsSheet(tester);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(sheet(tester).showChords, isFalse);
    // The lyrics are still there, chords are just not drawn.
    expect(find.textContaining('Amazing grace'), findsWidgets);
  });

  testWidgets('a vertical two-finger pinch zooms the lyric text', (
    tester,
  ) async {
    await pumpPerformance(tester);
    final start = sheet(tester).fontSize;

    // Two fingers at different spots on the sheet, moving apart vertically.
    final center = tester.getCenter(find.byType(ChordSheetView));
    final finger1 = await tester.startGesture(center - const Offset(0, 40));
    final finger2 = await tester.startGesture(center + const Offset(0, 40));
    await tester.pump();

    await finger1.moveBy(const Offset(0, -80));
    await finger2.moveBy(const Offset(0, 80));
    await tester.pump();

    await finger1.up();
    await finger2.up();
    await tester.pumpAndSettle();

    expect(sheet(tester).fontSize, greaterThan(start));
  });

  testWidgets('pinching in makes the lyric text smaller', (tester) async {
    await pumpPerformance(tester);
    final start = sheet(tester).fontSize;

    final center = tester.getCenter(find.byType(ChordSheetView));
    final finger1 = await tester.startGesture(center - const Offset(0, 40));
    final finger2 = await tester.startGesture(center + const Offset(0, 40));
    await tester.pump();

    await finger1.moveBy(const Offset(0, 15));
    await finger2.moveBy(const Offset(0, -15));
    await tester.pump();
    await finger1.moveBy(const Offset(0, 15));
    await finger2.moveBy(const Offset(0, -15));
    await tester.pump();

    await finger1.up();
    await finger2.up();
    await tester.pumpAndSettle();

    expect(sheet(tester).fontSize, lessThan(start));
  });

  testWidgets('stays on the same song after a save reorders the list', (
    tester,
  ) async {
    // Amazing Grace (id 1) is last in the newest-first list: [3, 2, 1].
    await pumpPerformance(tester);
    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(sheetText(tester), contains('Amazing grace'));

    // Saving a song bumps its timestamp, which moves it to the top of the
    // list — this is what happens right after editing it.
    final amazing = repo.currentSongs.firstWhere((s) => s.id == 1);
    await repo.update(amazing.copyWith(timestamp: 99));
    await tester.pumpAndSettle();

    // The pager must follow the song to its new place: the title and the
    // sheet still agree, and no other song's lyrics are shown.
    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(sheetText(tester), contains('Amazing grace'));
    expect(sheetText(tester), isNot(contains('New Orleans')));
    expect(sheetText(tester), isNot(contains('Dashing through')));
  });

  testWidgets('a short lyric line starts at the left, not the centre', (
    tester,
  ) async {
    // Regression: the performance Column used to default to centre alignment,
    // so the shrink-wrapping scroll view floated a short line in the middle of
    // the screen. It must hug the left padding edge instead.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(500, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final shortRepo = FakeSongRepository([
      const SongNote(
        id: 1,
        title: 'Untitled Song',
        artist: '',
        lyrics: 'Hi[C] there',
        key: 'C',
        bpm: 120,
        timestamp: 1,
      ),
    ]);
    addTearDown(shortRepo.dispose);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          songRepositoryProvider.overrideWithValue(shortRepo),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: SongPerformanceScreen(songId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    final lyricLeft = tester.getRect(find.text('Hi')).left;
    // The sheet uses 16 px of left padding; allow a little slack. A centred
    // short line would sit far to the right (well over 100 px on a 500 px
    // screen).
    expect(lyricLeft, lessThan(24));
  });

  testWidgets('a missing song shows a friendly message', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [songRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: SongPerformanceScreen(songId: 9999)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Song not found'), findsOneWidget);
  });

  testWidgets('the auto-scroll controls are visible without tapping', (
    tester,
  ) async {
    await pumpPerformance(tester);

    // The compact header is always visible now — no expand tap needed.
    expect(find.textContaining('Auto-scroll'), findsOneWidget);
    // The mode toggle uses single-letter labels (M / T) to save width.
    expect(find.text('M'), findsOneWidget);
    expect(find.text('T'), findsOneWidget);
    // Manual mode by default, at the starting speed.
    expect(scrollState(tester).speed, 1.00);
    expect(scrollState(tester).mode, AutoScrollMode.manual);
  });

  testWidgets('the controls row fits on a narrow phone', (tester) async {
    // 360 dp is the common small-phone width. The row holds the mode toggle,
    // play and full screen, so this guards against an overflow if any of them
    // grows again. The metronome is switched on because that is the widest the
    // row ever gets.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      AppConstants.prefMetronomeEnabled: true,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          songRepositoryProvider.overrideWithValue(repo),
          sharedPreferencesProvider.overrideWithValue(prefs),
          // A melody row builds the player, so keep any real audio device out
          // of the test.
          melodyAudioProvider.overrideWithValue(_SilentMelodyAudio()),
        ],
        child: const MaterialApp(home: SongPerformanceScreen(songId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Full screen'), findsOneWidget);
  });

  testWidgets('double-tapping the sheet changes the manual speed', (
    tester,
  ) async {
    await pumpPerformance(tester);

    await doubleTapSheet(tester, upper: true);
    expect(scrollState(tester).speed, closeTo(1.05, 1e-9));

    await doubleTapSheet(tester, upper: false);
    await doubleTapSheet(tester, upper: false);
    expect(scrollState(tester).speed, closeTo(0.95, 1e-9));
  });

  testWidgets('a song opens at the speed saved for it', (tester) async {
    repo = FakeSongRepository([
      const SongNote(
        id: 1,
        title: 'Slow One',
        lyrics: '[G]Take it easy',
        key: 'G',
        bpm: 80,
        timestamp: 1,
        scrollSpeed: 0.60,
        scrollMeasures: 48,
        scrollSpeedSet: true,
      ),
    ]);

    await pumpPerformance(tester);

    expect(scrollState(tester).speed, closeTo(0.60, 1e-9));
  });

  testWidgets('changing the speed saves it against the song', (tester) async {
    await pumpPerformance(tester);

    await doubleTapSheet(tester, upper: true);
    await tester.pumpAndSettle();

    // Wait past the debounce so the write goes through. (That the write waits
    // for the debounce is checked in the auto-scroll provider test.)
    await tester.pump(AutoScrollNotifier.saveDebounce);
    await tester.pumpAndSettle();

    final saved = repo.currentSongs.firstWhere((s) => s.id == 1);
    expect(saved.scrollSpeed, closeTo(1.05, 1e-9));
    expect(saved.timestamp, 1, reason: 'saving a speed is not an edit');
  });

  group('Stage Mode', () {
    testWidgets('the full screen button hides the top bar and shows the HUD', (
      tester,
    ) async {
      await pumpPerformance(tester);
      expect(find.byType(AppBar), findsOneWidget);

      await tester.tap(find.byTooltip('Full screen'));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsNothing);
      // The HUD opens with it, so the way back out is on screen at once.
      expect(find.byTooltip('Exit full screen'), findsOneWidget);
      // The normal controls header is gone — the lyrics have the whole screen.
      expect(find.byType(PerformanceControls), findsNothing);
    });

    testWidgets('the exit button brings the top bar back', (tester) async {
      await pumpPerformance(tester);

      await tester.tap(find.byTooltip('Full screen'));
      await tester.pumpAndSettle();
      // Dismiss the one-time gesture guide first.
      await tester.tap(find.text('Tap anywhere to start'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Exit full screen'));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(PerformanceControls), findsOneWidget);
    });

    testWidgets('the gesture guide is shown once and then remembered', (
      tester,
    ) async {
      await pumpPerformance(tester);

      await tester.tap(find.byTooltip('Full screen'));
      await tester.pumpAndSettle();
      expect(find.text('Tap anywhere to start'), findsOneWidget);

      await tester.tap(find.text('Tap anywhere to start'));
      await tester.pumpAndSettle();
      expect(find.text('Tap anywhere to start'), findsNothing);

      // Leaving and coming back does not show it again.
      await tester.tap(find.byTooltip('Exit full screen'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Full screen'));
      await tester.pumpAndSettle();
      expect(find.text('Tap anywhere to start'), findsNothing);
    });
  });

  testWidgets('in Tempo mode the double-taps change the bars', (tester) async {
    await pumpPerformance(tester);

    await tester.tap(find.text('T'));
    await tester.pumpAndSettle();
    final start = scrollState(tester).measures;

    await doubleTapSheet(tester, upper: true);
    expect(
      scrollState(tester).measures,
      start + AutoScrollSettings.measuresStep,
    );

    await doubleTapSheet(tester, upper: false);
    await doubleTapSheet(tester, upper: false);
    expect(
      scrollState(tester).measures,
      start - AutoScrollSettings.measuresStep,
    );

    // The status line still names the bars and the computed length. The
    // gesture's own flash says "24 bars" too, so more than one match is right.
    expect(find.textContaining('bars'), findsWidgets);
    expect(find.textContaining('BPM'), findsOneWidget);
  });

  // Play and pause is a two-finger tap on the sheet now — there is no button
  // to press. That gesture is tested in scroll_gesture_layer_test.dart, where
  // the real scrolling ticker (which keeps scheduling frames and never settles)
  // is not running.

  testWidgets('the header shows the speed and follows a double-tap', (
    tester,
  ) async {
    await pumpPerformance(tester);
    expect(find.text('1.00x'), findsOneWidget);

    await doubleTapSheet(tester, upper: true);
    await tester.pump();

    // Both the header read-out and the gesture's flash say the new value.
    expect(find.text('1.05x'), findsWidgets);
  });

  testWidgets('the header shows no speed in Tempo mode', (tester) async {
    await pumpPerformance(tester);

    await tester.tap(find.text('T'));
    await tester.pumpAndSettle();

    // The status line carries the bars and the length there instead.
    expect(find.text('1.00x'), findsNothing);
    expect(find.textContaining('bars'), findsOneWidget);
  });

  testWidgets('the header chords icon hides and shows the chords', (
    tester,
  ) async {
    await pumpPerformance(tester);
    expect(sheet(tester).showChords, isTrue);

    await tester.tap(find.byTooltip('Hide chords'));
    await tester.pumpAndSettle();
    expect(sheet(tester).showChords, isFalse);

    await tester.tap(find.byTooltip('Show chords'));
    await tester.pumpAndSettle();
    expect(sheet(tester).showChords, isTrue);
  });

  testWidgets('a song with no tune has no melody icon', (tester) async {
    // Amazing Grace has no {melody} line, so an icon there would do nothing.
    await pumpPerformance(tester);

    expect(find.byTooltip('Hide melody'), findsNothing);
    expect(find.byTooltip('Show melody'), findsNothing);
  });

  testWidgets('the header melody icon hides the melody rows', (tester) async {
    // Song 6 (Krishna Nee Begane Baro) is the fixture with a {melody} line.
    await pumpPerformance(tester, songId: 6);

    await tester.tap(find.byTooltip('Hide melody'));
    await tester.pumpAndSettle();

    expect(sheet(tester).showMelody, isFalse);
  });

  testWidgets('a one-finger drag moves the sheet while auto-scroll plays', (
    tester,
  ) async {
    // A song far taller than the window, so there is plenty to scroll through.
    repo = FakeSongRepository([
      SongNote(
        id: 1,
        title: 'Long One',
        lyrics: List.generate(120, (i) => '[G]Line number $i').join('\n'),
        key: 'G',
        bpm: 80,
        timestamp: 1,
      ),
    ]);

    // The ticker never settles, so every wait here is an explicit pump.
    await pumpPerformance(tester, viewSize: const Size(500, 400));
    final scroll = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
      listen: false,
    ).read(autoScrollProvider.notifier);

    // The sheet's own scroll view — a melody row has scrollables of its own.
    final position = tester
        .state<ScrollableState>(
          find
              .ancestor(
                of: find.byType(ChordSheetView),
                matching: find.byType(Scrollable),
              )
              .first,
        )
        .position;
    expect(position.maxScrollExtent, greaterThan(100));

    scroll.play();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final afterScrolling = position.pixels;
    expect(afterScrolling, greaterThan(0), reason: 'auto-scroll is running');

    // Put a finger down. The ticker must stand aside rather than jump the
    // sheet out from under the drag.
    final spot = sheetSpot(tester, upper: true);
    final finger = await tester.startGesture(spot);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      position.pixels,
      afterScrolling,
      reason: 'a held finger stops the ticker',
    );

    // Drag downwards, which pulls the sheet back up the song. Several small
    // moves, the way a real finger travels.
    for (var i = 0; i < 4; i++) {
      await finger.moveBy(const Offset(0, 20));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(
      position.pixels,
      lessThan(afterScrolling),
      reason: 'the drag scrolls the page',
    );

    // Let go: auto-scroll carries on from where the finger left the sheet.
    final droppedAt = position.pixels;
    await finger.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(position.pixels, greaterThan(droppedAt));

    // Stop the ticker so the test can finish.
    scroll.pause();
    await tester.pump();
  });

  testWidgets('vertical drag over lyrics locks out horizontal page swipe', (
    tester,
  ) async {
    await pumpPerformance(tester);
    expect(find.text('Amazing Grace'), findsOneWidget);

    final sheetFinder = find.byType(ChordSheetView);
    final startLocation = tester.getCenter(sheetFinder);

    // Simulate vertical drag with minor horizontal drift (dy > dx)
    await tester.dragFrom(startLocation, const Offset(5, -150));
    await tester.pumpAndSettle();

    // Should remain on Amazing Grace and NOT swipe to another song
    expect(find.text('Amazing Grace'), findsOneWidget);
  });

  testWidgets(
    'two-finger pinch zoom on multi-song pager stays on current song',
    (tester) async {
      await pumpPerformance(tester);
      expect(find.text('Amazing Grace'), findsOneWidget);
      final startSize = sheet(tester).fontSize;

      final center = tester.getCenter(find.byType(ChordSheetView));
      final finger1 = await tester.startGesture(center - const Offset(10, 40));
      final finger2 = await tester.startGesture(center + const Offset(10, 40));
      await tester.pump();

      // Move fingers apart vertically and slightly horizontally
      await finger1.moveBy(const Offset(-15, -60));
      await finger2.moveBy(const Offset(15, 60));
      await tester.pump();

      await finger1.up();
      await finger2.up();
      await tester.pumpAndSettle();

      // Font size should increase and current song must remain Amazing Grace
      expect(sheet(tester).fontSize, greaterThan(startSize));
      expect(find.text('Amazing Grace'), findsOneWidget);
    },
  );

  group('show / hide melody', () {
    // Song 6 (Krishna Nee Begane Baro) is the fixture with a {melody} line.
    const melodySongId = 6;

    testWidgets('the switch is only offered for a song with a tune', (
      tester,
    ) async {
      await pumpPerformance(tester);
      await openControlsSheet(tester);

      // Amazing Grace has no {melody} line, so no switch that would do nothing.
      expect(find.text('Show melody'), findsNothing);
      expect(find.text('Show chords'), findsOneWidget);
    });

    testWidgets('turning the switch off drops the melody rows', (tester) async {
      await pumpPerformance(tester, songId: melodySongId);
      expect(sheet(tester).showMelody, isTrue);

      await openControlsSheet(tester);
      expect(find.text('Show melody'), findsOneWidget);

      await tester.tap(find.text('Show melody'));
      await tester.pumpAndSettle();

      expect(sheet(tester).showMelody, isFalse);
      // The lyrics are untouched — only the tune rows go.
      expect(find.textContaining('krishna'), findsWidgets);
    });

    testWidgets('full screen never draws the melody rows', (tester) async {
      await pumpPerformance(tester, songId: melodySongId);

      await tester.tap(find.byTooltip('Full screen'));
      await tester.pumpAndSettle();

      expect(sheet(tester).showMelody, isFalse);
    });
  });

  group('starting scroll speed from Settings', () {
    testWidgets('a song with no speed of its own opens at the set speed', (
      tester,
    ) async {
      repo = FakeSongRepository([
        const SongNote(
          id: 1,
          title: 'Never Set',
          lyrics: '[G]Take it easy',
          key: 'G',
          bpm: 80,
          timestamp: 1,
        ),
      ]);

      await pumpPerformance(tester, startingSpeed: 0.20);

      expect(scrollState(tester).speed, closeTo(0.20, 1e-9));
    });

    testWidgets('a song with its own speed ignores the setting', (
      tester,
    ) async {
      repo = FakeSongRepository([
        const SongNote(
          id: 1,
          title: 'Set By Hand',
          lyrics: '[G]Take it easy',
          key: 'G',
          bpm: 80,
          timestamp: 1,
          scrollSpeed: 0.60,
          scrollSpeedSet: true,
        ),
      ]);

      await pumpPerformance(tester, startingSpeed: 0.20);

      expect(scrollState(tester).speed, closeTo(0.60, 1e-9));
    });
  });
}

/// A melody audio device that makes no sound.
class _SilentMelodyAudio implements MelodyAudio {
  @override
  Future<bool> play(MelodySchedule schedule, {bool loop = false}) async => true;

  @override
  Future<void> stop() async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> dispose() async {}
}
