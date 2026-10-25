import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/providers/metronome_runtime_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/services/metronome_calculator.dart';
import 'package:lyricchord/widgets/metronome_tempo_sheet.dart';
import '../helpers/tooltip_expectations.dart';

void main() {
  late ProviderContainer container;

  Future<void> pumpSheet(
    WidgetTester tester, {
    required int songBpm,
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final sp = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
    );
    addTearDown(container.dispose);

    // Tap times must come from the test's fake clock: a real stopwatch does not
    // move when `tester.pump(duration)` does.
    final epoch = tester.binding.clock.now();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MetronomeTempoSheet(
              songBpm: songBpm,
              nowOverride: () => tester.binding.clock.now().difference(epoch),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  int currentBpm(int songBpm) =>
      container.read(metronomeRuntimeProvider).effectiveBpm(songBpm);

  testWidgets("shows the song's tempo when nothing is set by hand", (
    tester,
  ) async {
    await pumpSheet(tester, songBpm: 130);

    expect(find.text('130'), findsOneWidget);
    expect(find.text("Using this song's saved tempo"), findsOneWidget);
  });

  testWidgets('says so when the song has no tempo', (tester) async {
    await pumpSheet(tester, songBpm: 0);

    expect(find.text('This song has no saved tempo'), findsOneWidget);
  });

  testWidgets('the + button speeds it up by one', (tester) async {
    await pumpSheet(tester, songBpm: 120);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expectAllIconButtonsHaveTooltips(tester);

    expect(currentBpm(120), 121);
    expect(find.text('121'), findsOneWidget);
    expect(find.text('Set by you for this session'), findsOneWidget);
  });

  testWidgets('the - button slows it down by one', (tester) async {
    await pumpSheet(tester, songBpm: 120);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();

    expect(currentBpm(120), 119);
  });

  testWidgets('cannot go past the fastest tempo', (tester) async {
    await pumpSheet(tester, songBpm: MetronomeCalculator.maxBpm);

    // At the top the + button is switched off.
    final plus = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.add),
        matching: find.byType(IconButton),
      ),
    );
    expect(plus.onPressed, isNull);
  });

  testWidgets('cannot go past the slowest tempo', (tester) async {
    await pumpSheet(tester, songBpm: MetronomeCalculator.minBpm);

    final minus = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.remove),
        matching: find.byType(IconButton),
      ),
    );
    expect(minus.onPressed, isNull);
  });

  testWidgets('tap tempo needs two taps before it sets anything', (
    tester,
  ) async {
    await pumpSheet(tester, songBpm: 120);

    await tester.tap(find.text('Tap tempo'));
    await tester.pumpAndSettle();

    // One tap alone gives no gap to measure.
    expect(container.read(metronomeRuntimeProvider).isOverridden, isFalse);
    expect(find.text('Keep tapping…'), findsOneWidget);
  });

  testWidgets('tapping twice sets the tempo from the gap', (tester) async {
    await pumpSheet(tester, songBpm: 120);

    await tester.tap(find.text('Tap tempo'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Tap tempo'));
    await tester.pumpAndSettle();

    // Half a second between taps is 120 BPM.
    expect(container.read(metronomeRuntimeProvider).overrideBpm, 120);
    expect(container.read(metronomeRuntimeProvider).isOverridden, isTrue);
  });

  testWidgets('four taps at 400 ms give 150 BPM', (tester) async {
    await pumpSheet(tester, songBpm: 120);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Tap tempo'));
      await tester.pump(const Duration(milliseconds: 400));
    }
    await tester.pumpAndSettle();

    expect(container.read(metronomeRuntimeProvider).overrideBpm, 150);
    expect(find.text('Steady'), findsOneWidget);
  });

  testWidgets('a long pause starts the tapping over', (tester) async {
    await pumpSheet(tester, songBpm: 120);

    // Two quick taps set a fast tempo.
    await tester.tap(find.text('Tap tempo'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Tap tempo'));
    await tester.pumpAndSettle();
    expect(container.read(metronomeRuntimeProvider).overrideBpm, 200);

    // Then the user wanders off and comes back. The stale gap must not be
    // averaged in.
    await tester.pump(const Duration(seconds: 10));
    await tester.tap(find.text('Tap tempo'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Tap tempo'));
    await tester.pumpAndSettle();

    expect(container.read(metronomeRuntimeProvider).overrideBpm, 100);
  });

  testWidgets('"Use song tempo" gives the song its tempo back', (tester) async {
    await pumpSheet(tester, songBpm: 120);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(container.read(metronomeRuntimeProvider).isOverridden, isTrue);

    await tester.tap(find.text('Use song tempo'));
    await tester.pumpAndSettle();

    expect(container.read(metronomeRuntimeProvider).isOverridden, isFalse);
    expect(currentBpm(120), 120);
  });

  testWidgets('"Use song tempo" is off when there is no song tempo', (
    tester,
  ) async {
    await pumpSheet(tester, songBpm: 0);

    final button = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('No song tempo'),
        matching: find.byType(TextButton),
      ),
    );
    expect(button.onPressed, isNull);
  });
}
