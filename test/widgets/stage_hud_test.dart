import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/stage_mode_provider.dart';
import 'package:lyricchord/widgets/stage_hud.dart';
import '../helpers/tooltip_expectations.dart';

void main() {
  late ProviderContainer container;

  Future<void> pumpHud(
    WidgetTester tester, {
    bool visible = true,
    String? raga,
    String? tala,
    VoidCallback? onHelpPressed,
  }) async {
    container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(stageModeProvider.notifier).enter();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StageHud(
              visible: visible,
              title: 'Jingle Bells',
              currentKey: 'G',
              bpm: 120,
              raga: raga,
              tala: tala,
              onHelpPressed: onHelpPressed,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  AutoScrollSettings scroll() => container.read(autoScrollProvider);

  testWidgets('shows the song read-out and the current speed', (tester) async {
    await pumpHud(tester);

    expect(find.textContaining('Jingle Bells'), findsOneWidget);
    expect(find.textContaining('Key G'), findsOneWidget);
    expect(find.textContaining('120 BPM'), findsOneWidget);
    expect(find.text('1.00x'), findsOneWidget);
  });

  testWidgets('a raga song shows raga and tala instead of a key', (
    tester,
  ) async {
    await pumpHud(tester, raga: 'Mishra Gara', tala: 'Keherwa');

    expect(find.textContaining('Raga Mishra Gara'), findsOneWidget);
    expect(find.textContaining('Tala Keherwa'), findsOneWidget);
    expect(find.textContaining('120 BPM'), findsOneWidget);
    // A Western note letter has no place on a swara sheet.
    expect(find.textContaining('Key G'), findsNothing);
  });

  testWidgets('a raga song with no tala still hides the key', (tester) async {
    await pumpHud(tester, raga: 'Hamsadhvani');

    expect(find.textContaining('Raga Hamsadhvani'), findsOneWidget);
    expect(find.textContaining('Tala'), findsNothing);
    expect(find.textContaining('Key G'), findsNothing);
  });

  testWidgets('the exit button leaves Stage Mode but not the song', (
    tester,
  ) async {
    await pumpHud(tester);

    await tester.tap(find.byIcon(Icons.fullscreen_exit));
    await tester.pump();
    expectAllIconButtonsHaveTooltips(tester);

    expect(container.read(stageModeProvider).enabled, isFalse);
  });

  testWidgets('the play button starts and stops the scroll', (tester) async {
    await pumpHud(tester);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    expect(scroll().isPlaying, isTrue);

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(scroll().isPlaying, isFalse);
  });

  testWidgets('the stepper changes the speed and the label follows', (
    tester,
  ) async {
    await pumpHud(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(scroll().speed, closeTo(1.05, 1e-9));
    expect(find.text('1.05x'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(scroll().speed, closeTo(1.0, 1e-9));
  });

  testWidgets('switching to Tempo swaps the stepper over to bars', (
    tester,
  ) async {
    await pumpHud(tester);

    await tester.tap(find.text('T'));
    await tester.pump();

    expect(find.text('${AutoScrollSettings.defaultMeasures}'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(
      scroll().measures,
      AutoScrollSettings.defaultMeasures + AutoScrollSettings.measuresStep,
    );
  });

  testWidgets('while hidden it takes no taps', (tester) async {
    await pumpHud(tester, visible: false);

    // Hit-testing is off while the bar is away, so a tap where a button used
    // to be does nothing instead of exiting Stage Mode by accident.
    await tester.tap(find.byIcon(Icons.fullscreen_exit), warnIfMissed: false);
    await tester.pump();

    expect(container.read(stageModeProvider).enabled, isTrue);
  });

  testWidgets('tapping help button invokes onHelpPressed callback', (
    tester,
  ) async {
    var helped = false;
    await pumpHud(tester, onHelpPressed: () => helped = true);

    await tester.tap(find.byTooltip('Gestures help'));
    await tester.pump();

    expect(helped, isTrue);
  });
}
