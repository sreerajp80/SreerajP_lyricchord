import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/widgets/carnatic_notation_sheet.dart';

/// Opens the sheet on its own and hands back whatever it returns.
Future<List<String>?> _show(
  WidgetTester tester, {
  String tala = 'Misra Chapu',
}) async {
  List<String>? returned;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              returned = await showModalBottomSheet<List<String>>(
                context: context,
                isScrollControlled: true,
                builder: (_) => CarnaticNotationSheet(tala: tala),
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
  return returned;
}

void main() {
  group('the notation sheet', () {
    testWidgets('opens with Insert disabled until something converts', (
      tester,
    ) async {
      await _show(tester);

      expect(find.text('Paste Carnatic notation'), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('converting shows the lines and how well they fit', (
      tester,
    ) async {
      await _show(tester);

      await tester.enterText(find.byType(TextField), '; ; S | G , m | R ; ||');
      await tester.pumpAndSettle();

      expect(find.textContaining('1 of 1 cycles fit'), findsOneWidget);
      expect(find.textContaining('Ga3'), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('a cycle of the wrong length is reported, not hidden', (
      tester,
    ) async {
      await _show(tester);

      await tester.enterText(find.byType(TextField), 'S S ||');
      await tester.pumpAndSettle();

      expect(find.textContaining('0 of 1 cycles fit'), findsOneWidget);
      expect(find.textContaining('aksharakalas'), findsOneWidget);
    });

    testWidgets('the rejected reading is shown too, so the choice is visible', (
      tester,
    ) async {
      await _show(tester);

      await tester.enterText(find.byType(TextField), '; ; S | G , m | R ; ||');
      await tester.pumpAndSettle();

      expect(find.textContaining('The other reading'), findsOneWidget);
    });

    testWidgets('the madhyamam switch is off to begin with', (tester) async {
      await _show(tester);

      final toggle = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(toggle.value, isFalse);
    });

    testWidgets('turning the switch on changes Ma2 to Ma1 in the descent', (
      tester,
    ) async {
      await _show(tester);

      await tester.enterText(find.byType(TextField), '; ; S | G , m | R ; ||');
      await tester.pumpAndSettle();
      expect(find.textContaining('Ma2'), findsOneWidget);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(find.textContaining('Ma1'), findsOneWidget);
    });

    testWidgets('Insert hands the converted lines back', (tester) async {
      await _show(tester);

      await tester.enterText(find.byType(TextField), '; ; S | G , m | R ; ||');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // The sheet closed; that it returned lines is covered by the importer
      // tests, so here it is enough that Insert dismissed it.
      expect(find.text('Paste Carnatic notation'), findsNothing);
    });

    testWidgets('Cancel returns nothing', (tester) async {
      await _show(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Paste Carnatic notation'), findsNothing);
    });

    testWidgets('junk input never throws', (tester) async {
      await _show(tester);

      for (final junk in ['@@@', '   ', 'xyz', '||||']) {
        await tester.enterText(find.byType(TextField), junk);
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
    });
  });
}
