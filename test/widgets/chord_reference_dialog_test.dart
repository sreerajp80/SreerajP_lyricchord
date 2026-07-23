import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyriccord/widgets/chord_reference_dialog.dart';
import 'package:lyriccord/widgets/guitar_chord_diagram.dart';
import 'package:lyriccord/widgets/harmonium_chord_diagram.dart';

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
}
