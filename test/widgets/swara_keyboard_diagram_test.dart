import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/widgets/swara_keyboard_diagram.dart';

void main() {
  Future<void> pumpDiagram(WidgetTester tester, String swara) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: SwaraKeyboardDiagram(swara: swara)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('labels the diagram with the swara as written', (tester) async {
    await pumpDiagram(tester, 'Ma');

    expect(find.text('Ma'), findsOneWidget);
  });

  testWidgets('names the painted keyboard for a screen reader', (tester) async {
    await pumpDiagram(tester, 'Pa');

    expect(find.bySemanticsLabel('Swara diagram for Pa'), findsOneWidget);
  });

  testWidgets('a token it cannot place still draws, without crashing', (
    tester,
  ) async {
    // CLAUDE.md hard rule 4: never crash on odd input, never guess a note.
    await pumpDiagram(tester, 'Verse');

    expect(find.text('Verse'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a Carnatic numbered swara draws', (tester) async {
    await pumpDiagram(tester, 'R2');

    expect(find.text('R2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('two different swaras paint differently', (tester) async {
    // The bug this whole change fixes was every swara drawing the same thing.
    // The painter's equality is what decides whether the pixels differ, so
    // compare the two widgets' painters through shouldRepaint.
    await pumpDiagram(tester, 'Sa');
    final saPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(SwaraKeyboardDiagram),
        matching: find.byType(CustomPaint),
      ),
    );
    final saPainter = saPaint.painter!;

    await pumpDiagram(tester, 'Pa');
    final paPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(SwaraKeyboardDiagram),
        matching: find.byType(CustomPaint),
      ),
    );
    final paPainter = paPaint.painter!;

    expect(paPainter.shouldRepaint(saPainter), isTrue);
  });
}
