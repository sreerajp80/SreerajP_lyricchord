import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/providers/performance_provider.dart';
import 'package:lyricchord/widgets/transpose_sheet.dart';

import '../helpers/localized_app.dart';
import '../helpers/tooltip_expectations.dart';

void main() {
  Future<ProviderContainer> pump(
    WidgetTester tester, {
    String writtenKey = 'G',
    bool showTranspose = true,
    bool showMelodyToggle = false,
  }) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(
          Scaffold(
            body: TransposeSheet(
              writtenKey: writtenKey,
              showTranspose: showTranspose,
              showMelodyToggle: showMelodyToggle,
            ),
          ),
        ),
      ),
    );
    return container;
  }

  TextButton resetButton(WidgetTester tester) =>
      tester.widget<TextButton>(find.widgetWithText(TextButton, 'Reset'));

  testWidgets('shows the written key and a disabled Reset', (tester) async {
    await pump(tester);

    expect(find.text('Performance controls'), findsOneWidget);
    expect(find.text('G'), findsOneWidget);
    expect(resetButton(tester).onPressed, isNull);
    expectAllIconButtonsHaveTooltips(tester);
  });

  testWidgets('up and down move the shown key; Reset puts it back', (
    tester,
  ) async {
    final container = await pump(tester);

    await tester.tap(find.byTooltip('Transpose up'));
    await tester.pump();
    expect(find.text('Ab'), findsOneWidget);
    expect(container.read(performanceSettingsProvider).semitones, 1);
    expect(resetButton(tester).onPressed, isNotNull);

    await tester.tap(find.byTooltip('Transpose down'));
    await tester.tap(find.byTooltip('Transpose down'));
    await tester.pump();
    expect(find.text('F#'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(find.text('G'), findsOneWidget);
    expect(container.read(performanceSettingsProvider).semitones, 0);
  });

  testWidgets('the shown key uses the spelling musicians expect', (
    tester,
  ) async {
    await pump(tester, writtenKey: 'C');

    await tester.tap(find.byTooltip('Transpose up'));
    await tester.pump();

    expect(find.text('C#'), findsNothing);
    expect(find.text('Db'), findsOneWidget);
  });

  testWidgets('the chords switch toggles chords', (tester) async {
    final container = await pump(tester);

    await tester.tap(find.text('Show chords'));
    await tester.pump();

    expect(container.read(performanceSettingsProvider).showChords, isFalse);
  });

  testWidgets(
    'an Indian sheet hides transpose and can show the melody switch',
    (tester) async {
      final container = await pump(
        tester,
        showTranspose: false,
        showMelodyToggle: true,
      );

      expect(find.text('Transpose'), findsNothing);
      expect(find.byTooltip('Transpose up'), findsNothing);

      await tester.tap(find.text('Show melody'));
      await tester.pump();
      expect(container.read(performanceSettingsProvider).showMelody, isFalse);
    },
  );
}
