import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/widgets/melody_beat_grid.dart';
import 'package:lyricchord/widgets/melody_keypad_sheet.dart';

void main() {
  /// Puts the sheet on screen and hands back what it pops.
  ///
  /// The sheet is opened for real (not built bare) so Cancel and Insert can be
  /// checked by what they return, which is the whole contract with the editor.
  Future<String?> pumpKeypad(
    WidgetTester tester, {
    String tala = '',
    String initialLine = '',
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(700, 1400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) =>
                      MelodyKeypadSheet(tala: tala, initialLine: initialLine),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  /// Taps a keypad key.
  ///
  /// Scoped to the button block, because the preview grid draws the same swara
  /// text as the key that wrote it — a bare `find.text('S')` would match both.
  Future<void> tapKey(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(of: find.byType(Wrap), matching: find.text(label)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('it opens empty with a hint and no grid', (tester) async {
    await pumpKeypad(tester);

    expect(find.text('Melody keypad'), findsOneWidget);
    expect(find.byType(MelodyBeatGrid), findsNothing);
    expect(find.textContaining('Tap a swara to start'), findsOneWidget);
  });

  testWidgets('tapping a swara draws the beat grid', (tester) async {
    await pumpKeypad(tester);

    await tapKey(tester, 'G3');

    expect(find.byType(MelodyBeatGrid), findsOneWidget);
    expect(find.textContaining('Tap a swara to start'), findsNothing);
  });

  testWidgets('with no tala it counts beats but says nothing about fit', (
    tester,
  ) async {
    await pumpKeypad(tester);

    await tapKey(tester, 'S');
    expect(find.text('1 beat'), findsOneWidget);

    await tapKey(tester, 'R2');
    expect(find.text('2 beats'), findsOneWidget);
  });

  testWidgets('with a tala it counts towards the cycle', (tester) async {
    await pumpKeypad(tester, tala: 'Rupaka');

    await tapKey(tester, 'S');
    // Rupaka is six beats.
    expect(find.text('1 of 6 beats'), findsOneWidget);
  });

  testWidgets('a line that fills the tala says so', (tester) async {
    await pumpKeypad(tester, tala: 'Rupaka');

    for (var i = 0; i < 6; i++) {
      await tapKey(tester, 'S');
    }

    expect(find.text('6 beats — fits Rupaka'), findsOneWidget);
  });

  testWidgets('a bar line adds no beat', (tester) async {
    await pumpKeypad(tester, tala: 'Rupaka');

    await tapKey(tester, 'S');
    await tapKey(tester, 'Bar |');

    expect(find.text('1 of 6 beats'), findsOneWidget);
  });

  testWidgets('Insert hands the editor the finished melody line', (
    tester,
  ) async {
    String? popped;

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(700, 1400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                popped = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const MelodyKeypadSheet(tala: 'Adi'),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tapKey(tester, 'G3');
    await tapKey(tester, 'Share -');
    await tapKey(tester, 'M1');
    await tapKey(tester, 'Hold ,');
    await tester.tap(find.widgetWithText(FilledButton, 'Insert'));
    await tester.pumpAndSettle();

    expect(popped, '{melody} G3-M1 ,');
  });

  testWidgets('Insert is dead until something is entered', (tester) async {
    await pumpKeypad(tester);

    final insert = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Insert'),
    );
    expect(insert.onPressed, isNull);
  });

  testWidgets('an existing line is loaded for editing', (tester) async {
    await pumpKeypad(tester, tala: 'Adi', initialLine: '{melody} S R2 G3 M1');

    expect(find.byType(MelodyBeatGrid), findsOneWidget);
    expect(find.text('4 of 8 beats'), findsOneWidget);
  });

  testWidgets('backspace removes the last beat', (tester) async {
    await pumpKeypad(tester, tala: 'Adi', initialLine: '{melody} S R2 G3');

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pumpAndSettle();

    expect(find.text('2 of 8 beats'), findsOneWidget);
  });

  testWidgets('the mark buttons are dead with no note to mark', (tester) async {
    await pumpKeypad(tester);

    final slide = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Slide !'),
    );
    expect(slide.onPressed, isNull);
  });

  testWidgets('a mark lights up once it is on the note', (tester) async {
    await pumpKeypad(tester);

    await tapKey(tester, 'S');
    await tapKey(tester, 'Octave ↑');

    // A lit key is a FilledButton; an unlit one is outlined.
    expect(find.widgetWithText(FilledButton, 'Octave ↑'), findsOneWidget);
  });

  testWidgets('Cancel with nothing entered just closes', (tester) async {
    await pumpKeypad(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Melody keypad'), findsNothing);
  });

  testWidgets('Cancel asks before throwing tapped work away', (tester) async {
    await pumpKeypad(tester);

    await tapKey(tester, 'S');
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Discard this melody?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Melody keypad'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Melody keypad'), findsNothing);
  });
}
