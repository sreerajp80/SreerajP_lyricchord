import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/widgets/chord_reference_dialog.dart';
import 'package:lyricchord/widgets/guitar_chord_diagram.dart';
import 'package:lyricchord/widgets/harmonium_chord_diagram.dart';
import 'package:lyricchord/widgets/swara_keyboard_diagram.dart';

/// Pumps [dialog] on its own so the tabs and diagrams can be inspected.
Future<void> _pump(WidgetTester tester, Widget dialog) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: dialog)),
    ),
  );
}

void main() {
  testWidgets('shows both tabs and the chord names', (tester) async {
    await _pump(tester, const ChordReferenceDialog(chords: ['C', 'G', 'Am']));

    // Both tabs are present.
    expect(find.text('Guitar'), findsOneWidget);
    expect(find.text('Harmonium'), findsOneWidget);

    // The guitar tab shows a diagram per chord.
    expect(find.byType(GuitarChordDiagram), findsNWidgets(3));
    expect(find.text('C'), findsWidgets);
  });

  testWidgets('switching to the Harmonium tab shows keyboard diagrams', (
    tester,
  ) async {
    await _pump(tester, const ChordReferenceDialog(chords: ['C', 'G']));

    await tester.tap(find.text('Harmonium'));
    await tester.pumpAndSettle();

    expect(find.byType(HarmoniumChordDiagram), findsNWidgets(2));
  });

  testWidgets('an empty chord list shows a friendly message', (tester) async {
    await _pump(tester, const ChordReferenceDialog(chords: []));

    expect(find.text('No chords in this song'), findsOneWidget);
    expect(find.byType(GuitarChordDiagram), findsNothing);
  });

  group('swara mode', () {
    testWidgets('shows one keyboard per swara and no tabs', (tester) async {
      await _pump(
        tester,
        const ChordReferenceDialog(
          chords: ['Sa', 'Ma', 'Pa', 'Ni'],
          swaraMode: true,
        ),
      );

      expect(find.text('Swara Reference'), findsOneWidget);
      expect(find.byType(SwaraKeyboardDiagram), findsNWidgets(4));

      // A swara is one note, not a chord — there is nothing to finger.
      expect(find.text('Guitar'), findsNothing);
      expect(find.text('Harmonium'), findsNothing);
      expect(find.byType(GuitarChordDiagram), findsNothing);
      expect(find.byType(HarmoniumChordDiagram), findsNothing);
    });

    testWidgets('never draws a chord shape for a swara', (tester) async {
      // The bug: `Sa` fell through to root 0 and drew C major, and `Ga` parsed
      // as a G chord. Neither may happen again.
      await _pump(
        tester,
        const ChordReferenceDialog(chords: ['Sa', 'Ga'], swaraMode: true),
      );

      expect(find.byType(HarmoniumChordDiagram), findsNothing);
      expect(find.text('Sa'), findsOneWidget);
      expect(find.text('Ga'), findsOneWidget);
    });

    testWidgets('an empty list says there are no swaras', (tester) async {
      await _pump(
        tester,
        const ChordReferenceDialog(chords: [], swaraMode: true),
      );

      expect(find.text('No swaras in this song'), findsOneWidget);
      expect(find.text('No chords in this song'), findsNothing);
    });

    testWidgets('a Western song is untouched by the flag default', (
      tester,
    ) async {
      await _pump(tester, const ChordReferenceDialog(chords: ['C', 'G']));

      expect(find.text('Chord Reference'), findsOneWidget);
      expect(find.byType(SwaraKeyboardDiagram), findsNothing);
    });
  });
}
