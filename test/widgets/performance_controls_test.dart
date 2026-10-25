import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/widgets/performance_controls.dart';
import '../helpers/tooltip_expectations.dart';

/// The status line above the chord sheet.
///
/// The rule under test: a song written in swaras shows **no key**. A Western
/// note letter has no place on an Indian sheet, and a swara is already named
/// relative to Sa, so a key would add nothing.
void main() {
  Future<void> pumpControls(
    WidgetTester tester, {
    String currentKey = 'G',
    String? raga,
    String? tala,
    bool hasMelody = false,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(500, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PerformanceControls(
              currentKey: currentKey,
              bpm: 120,
              active: true,
              hasMelody: hasMelody,
              raga: raga,
              tala: tala,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the read-out and the icons sit at the right edge', (
    tester,
  ) async {
    // The mode buttons hold the left edge; the speed, the two toggles and the
    // pitch button belong hard against the right, not bunched up beside them.
    await pumpControls(tester, hasMelody: true);

    final modes = tester.getRect(find.text('M'));
    final speed = tester.getRect(find.text('1.00x'));
    final pitch = tester.getRect(find.byTooltip('Pitch pipe & drone'));
    final row = tester.getRect(find.byType(PerformanceControls));

    expect(speed.left, greaterThan(modes.right));
    expect(find.byTooltip('Hide chords'), findsOneWidget);
    expect(find.byTooltip('Hide melody'), findsOneWidget);
    // The last icon ends within 20 px of the right edge of the header.
    expect(row.right - pitch.right, lessThan(20));
    // And they are all on one line with the mode buttons.
    expect(speed.center.dy, closeTo(modes.center.dy, 1));
  });

  testWidgets('a Western song shows its key', (tester) async {
    await pumpControls(tester);

    expect(find.textContaining('Key G'), findsOneWidget);
    expect(find.textContaining('120 BPM'), findsOneWidget);
  });

  testWidgets('a raga song shows no key', (tester) async {
    await pumpControls(tester, raga: 'Mishra Gara', tala: 'Keherwa');

    expect(find.textContaining('Key'), findsNothing);
    expect(find.textContaining('Sa ='), findsNothing);
    expect(find.textContaining('120 BPM'), findsOneWidget);
  });

  testWidgets('a raga song still shows its raga and tala', (tester) async {
    await pumpControls(tester, raga: 'Mishra Gara', tala: 'Keherwa');

    expect(find.textContaining('Raga Mishra Gara'), findsOneWidget);
    expect(find.textContaining('Tala Keherwa'), findsOneWidget);
  });

  testWidgets('an empty raga counts as a Western song', (tester) async {
    await pumpControls(tester, raga: '');

    expect(find.textContaining('Key G'), findsOneWidget);
  });

  group('pitch pipe button', () {
    testWidgets('is on the ordinary song screen, not only in Stage Mode', (
      tester,
    ) async {
      await pumpControls(tester);

      expect(
        find.byTooltip('Pitch pipe & drone'),
        findsOneWidget,
        reason: 'a singer needs a starting note without entering Stage Mode',
      );
    });

    testWidgets('opens the sheet on the song key', (tester) async {
      await pumpControls(tester);

      await tester.tap(find.byTooltip('Pitch pipe & drone'));
      await tester.pumpAndSettle();
      expectAllIconButtonsHaveTooltips(tester);

      expect(find.text('Pitch Pipe & Drone'), findsOneWidget);
      expect(find.text('Song key:  G'), findsOneWidget);
    });

    testWidgets('passes the raga and tala through, so naming is Indian', (
      tester,
    ) async {
      await pumpControls(tester, raga: 'Mishra Gara', tala: 'Keherwa');

      await tester.tap(find.byTooltip('Pitch pipe & drone'));
      await tester.pumpAndSettle();

      expect(find.textContaining('safed'), findsWidgets);
    });
  });
}
