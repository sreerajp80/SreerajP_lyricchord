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
    // One outer Wrap holding one Wrap per tala group.
    final outer = tester.widget<Wrap>(find.byType(Wrap).first);
    expect(outer.spacing, 14);
    expect(outer.children.length, 3);
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

  testWidgets('a long line wraps onto more rows instead of overflowing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpGrid(tester, '{melody} S R G M | P D N S | R G M P | D N S R');
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsNothing);

    // The first and the last beat sit on different rows, and both are on
    // screen.
    final first = tester.getTopLeft(find.text('S').first);
    final last = tester.getTopLeft(find.text('R').last);
    expect(last.dy, greaterThan(first.dy));
    expect(last.dx, lessThan(320));
  });

  testWidgets('a group that fits on a row is not split', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpGrid(tester, '{melody} S R G M | P D N Sa');
    // The second group moves down as a whole: its first and last beat share a
    // row.
    final p = tester.getTopLeft(find.text('P'));
    final sa = tester.getTopLeft(find.text('Sa'));
    expect(sa.dy, p.dy);
  });

  testWidgets('a group wider than the row breaks between boxes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(200, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpGrid(tester, '{melody} S R G M P D N S R G M P');
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrolls the sheet to keep the sounding beat in view', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 300));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = ScrollController();
    addTearDown(controller.dispose);
    final line = parser.parse('{melody} S R G M | P D N S | R G M P | D N S Q');

    Widget sheet(int? currentBeat) => MaterialApp(
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lyrics above push the grid below the screen.
              const SizedBox(height: 600),
              MelodyBeatGrid(line: line, currentBeat: currentBeat),
            ],
          ),
        ),
      ),
    );

    await tester.pumpWidget(sheet(null));
    expect(controller.offset, 0);

    // The last beat is the 'Q', which has a text of its own to find.
    final lastBeat = line.beats.length - 1;
    await tester.pumpWidget(sheet(lastBeat));
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
    final box = tester.getRect(find.text('Q'));
    expect(box.bottom, lessThanOrEqualTo(300));
    expect(box.top, greaterThanOrEqualTo(0));
  });

  testWidgets('does not scroll when the sounding beat is already visible', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final line = parser.parse('{melody} S R G');

    Widget sheet(int? currentBeat) => MaterialApp(
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              MelodyBeatGrid(line: line, currentBeat: currentBeat),
              const SizedBox(height: 2000),
            ],
          ),
        ),
      ),
    );

    await tester.pumpWidget(sheet(0));
    await tester.pumpWidget(sheet(1));
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
  });
}
