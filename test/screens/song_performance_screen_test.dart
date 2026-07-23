import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyriccord/models/song_note.dart';
import 'package:lyriccord/providers/auto_scroll_provider.dart';
import 'package:lyriccord/providers/database_provider.dart';
import 'package:lyriccord/providers/theme_mode_provider.dart';
import 'package:lyriccord/screens/song_performance_screen.dart';
import 'package:lyriccord/widgets/chord_sheet_view.dart';
import 'package:lyriccord/widgets/performance_controls.dart';

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
  Future<void> pumpPerformance(WidgetTester tester, {int songId = 1}) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(500, 1000);
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

  testWidgets('shows the song and its written chords', (tester) async {
    await pumpPerformance(tester);

    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(sheetChords(tester), ['G']);
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
    // Manual mode by default: the speed chips are there.
    expect(find.text('1x'), findsOneWidget);
  });

  testWidgets('switching to Tempo mode shows the measures stepper', (
    tester,
  ) async {
    await pumpPerformance(tester);

    await tester.tap(find.text('T'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('More measures'), findsOneWidget);
    expect(find.byTooltip('Fewer measures'), findsOneWidget);
    expect(find.textContaining('BPM'), findsOneWidget);
  });

  // Play/pause is tested against PerformanceControls on its own, so the real
  // scrolling ticker (which keeps scheduling frames and never settles) is not
  // started by the full screen.
  testWidgets('tapping play flips the auto-scroll playing state', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: PerformanceControls(currentKey: 'C', bpm: 120, active: true),
          ),
        ),
      ),
    );

    // The controls are always visible now — no expand tap needed.
    expect(container.read(autoScrollProvider).isPlaying, isFalse);

    await tester.tap(find.byTooltip('Play'));
    await tester.pump();
    expect(container.read(autoScrollProvider).isPlaying, isTrue);

    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    expect(container.read(autoScrollProvider).isPlaying, isFalse);
  });
}
