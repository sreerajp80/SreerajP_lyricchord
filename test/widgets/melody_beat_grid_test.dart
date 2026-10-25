import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/services/melody_parser_service.dart';
import 'package:lyricchord/widgets/melody_beat_grid.dart';

void main() {
  const parser = MelodyParser();

  Future<void> pumpGrid(
    WidgetTester tester,
    String melody, {
    int? currentBeat,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MelodyBeatGrid(
            line: parser.parse(melody),
            currentBeat: currentBeat,
          ),
        ),
      ),
    );
  }

  testWidgets('draws one box per beat', (tester) async {
    await pumpGrid(tester, '{melody} S R G M');
    expect(find.text('S'), findsOneWidget);
    expect(find.text('R'), findsOneWidget);
    expect(find.text('G'), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
  });

  testWidgets('a bar line becomes a gap, not a box', (tester) async {
    await pumpGrid(tester, '{melody} P , M | G , | R S');
    // The seven sung beats are drawn; the two bar lines are spacing only.
    expect(find.text('|'), findsNothing);
    expect(find.text(','), findsNWidgets(2));
    expect(find.text('P'), findsOneWidget);
    expect(find.text('S'), findsOneWidget);
  });

  testWidgets('groups the beats the tala way', (tester) async {
    await pumpGrid(tester, '{melody} P , M | G , | R S');
    // Three groups means two gaps between them.
    final gaps = tester
        .widgetList<SizedBox>(find.byType(SizedBox))
        .where((box) => box.width == 14);
    expect(gaps.length, 2);
  });

  testWidgets('shows the writer\'s own spelling', (tester) async {
    await pumpGrid(tester, '{melody} Ma2 M2 .N3');
    expect(find.text('Ma2'), findsOneWidget);
    expect(find.text('M2'), findsOneWidget);
    expect(find.text('.N3'), findsOneWidget);
  });

  testWidgets('a shared beat stays one box', (tester) async {
    await pumpGrid(tester, '{melody} G3-R2 S');
    expect(find.text('G3-R2'), findsOneWidget);
    expect(find.text('S'), findsOneWidget);
  });

  testWidgets('highlights the beat that is sounding', (tester) async {
    await pumpGrid(tester, '{melody} S R G', currentBeat: 1);

    final context = tester.element(find.byType(MelodyBeatGrid));
    final scheme = Theme.of(context).colorScheme;

    Color backgroundOf(String label) {
      final container = tester.widget<Container>(
        find
            .ancestor(of: find.text(label), matching: find.byType(Container))
            .first,
      );
      return (container.decoration! as BoxDecoration).color!;
    }

    expect(backgroundOf('R'), scheme.primary);
    expect(backgroundOf('S'), isNot(scheme.primary));
  });

  testWidgets('marks an unreadable beat without dropping it', (tester) async {
    await pumpGrid(tester, '{melody} S Q G');
    expect(find.text('Q'), findsOneWidget);

    final context = tester.element(find.byType(MelodyBeatGrid));
    final scheme = Theme.of(context).colorScheme;
    final container = tester.widget<Container>(
      find.ancestor(of: find.text('Q'), matching: find.byType(Container)).first,
    );
    expect(
      (container.decoration! as BoxDecoration).color,
      scheme.errorContainer,
    );
  });

  testWidgets('an empty line draws nothing', (tester) async {
    await pumpGrid(tester, '{melody}');
    expect(find.byType(Container), findsNothing);
  });

  testWidgets('a long line scrolls instead of overflowing', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpGrid(tester, '{melody} S R G M | P D N S | R G M P | D N S R');
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
