import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/models/setlist.dart';
import 'package:lyricchord/widgets/song_meta_fields.dart';

import '../helpers/localized_app.dart';

void main() {
  late Map<String, String> changed;
  late List<PitchTradition> traditions;
  late List<int?> setlistPicks;

  setUp(() {
    changed = {};
    traditions = [];
    setlistPicks = [];
  });

  Future<void> pump(
    WidgetTester tester, {
    PitchTradition tradition = PitchTradition.western,
    bool withTradition = true,
    String? talaWarning,
    List<Setlist> setlists = const [],
  }) async {
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: SingleChildScrollView(
            child: SongMetaFields(
              titleController: TextEditingController(),
              artistController: TextEditingController(),
              keyController: TextEditingController(),
              bpmController: TextEditingController(),
              ragaController: TextEditingController(),
              talaController: TextEditingController(),
              onTitleChanged: (v) => changed['title'] = v,
              onArtistChanged: (v) => changed['artist'] = v,
              onKeyChanged: (v) => changed['key'] = v,
              onBpmChanged: (v) => changed['bpm'] = v,
              onRagaChanged: (v) => changed['raga'] = v,
              onTalaChanged: (v) => changed['tala'] = v,
              tradition: tradition,
              onTraditionChanged: withTradition ? traditions.add : null,
              talaWarning: talaWarning,
              availableSetlists: setlists,
              onSetlistChanged: setlistPicks.add,
            ),
          ),
        ),
      ),
    );
  }

  Finder field(String label) => find.widgetWithText(TextField, label);

  testWidgets('a Western song has a key box and no raga or tala', (
    tester,
  ) async {
    await pump(tester);

    expect(field('Title'), findsOneWidget);
    expect(field('Artist / Band'), findsOneWidget);
    expect(field('Original key'), findsOneWidget);
    expect(field('Tempo (BPM)'), findsOneWidget);
    expect(field('Raga'), findsNothing);
    expect(field('Tala'), findsNothing);
  });

  testWidgets('typing in each field reports the change', (tester) async {
    await pump(tester);

    await tester.enterText(field('Title'), 'Amazing Grace');
    await tester.enterText(field('Artist / Band'), 'Trad');
    await tester.enterText(field('Original key'), 'G');
    await tester.enterText(field('Tempo (BPM)'), '80');

    expect(changed, {
      'title': 'Amazing Grace',
      'artist': 'Trad',
      'key': 'G',
      'bpm': '80',
    });
  });

  testWidgets('the tempo box takes at most three digits', (tester) async {
    await pump(tester);

    await tester.enterText(field('Tempo (BPM)'), '12a345');

    final controller = tester
        .widget<TextField>(field('Tempo (BPM)'))
        .controller!;
    expect(controller.text, '123');
  });

  testWidgets('an Indian song shows raga and tala instead of the key', (
    tester,
  ) async {
    await pump(
      tester,
      tradition: PitchTradition.carnatic,
      talaWarning: 'Keherwa is a Hindustani tala.',
    );

    expect(field('Original key'), findsNothing);
    expect(field('Raga'), findsOneWidget);
    expect(field('Tala'), findsOneWidget);
    expect(find.text('Keherwa is a Hindustani tala.'), findsOneWidget);

    await tester.enterText(field('Raga'), 'Mohanam');
    await tester.enterText(field('Tala'), 'Adi');
    expect(changed['raga'], 'Mohanam');
    expect(changed['tala'], 'Adi');
  });

  testWidgets('the notation picker reports the chosen tradition', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('Western'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Carnatic').last);
    await tester.pumpAndSettle();

    expect(traditions, [PitchTradition.carnatic]);
  });

  testWidgets('no notation picker without a handler', (tester) async {
    await pump(tester, withTradition: false);

    expect(find.text('Notation'), findsNothing);
  });

  testWidgets('the setlist picker shows only when there are setlists', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Add to setlist'), findsNothing);

    await pump(
      tester,
      setlists: const [
        Setlist(id: 9, name: 'Sunday Gig', createdAt: 0, updatedAt: 0),
      ],
    );
    expect(find.text('Add to setlist'), findsOneWidget);

    await tester.tap(find.text('None (Do not add)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sunday Gig').last);
    await tester.pumpAndSettle();
    expect(setlistPicks, [9]);
  });
}
