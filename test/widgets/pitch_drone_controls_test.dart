import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/providers/pitch_drone_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/services/pitch_drone_audio_service.dart';
import 'package:lyricchord/widgets/pitch_drone_controls.dart';

import '../helpers/fake_pitch_drone_audio.dart';
import '../helpers/tooltip_expectations.dart';

void main() {
  late FakePitchDroneAudio audio;

  Future<Widget> wrap({
    String? songKey,
    String? raga,
    String? tala,
    Map<String, Object> prefs = const {},
    bool succeed = true,
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final stored = await SharedPreferences.getInstance();
    audio = FakePitchDroneAudio(succeed: succeed);

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(stored),
        pitchDroneAudioProvider.overrideWithValue(audio),
      ],
      child: MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PitchDroneControlsSheet(
            songKey: songKey,
            raga: raga,
            tala: tala,
          ),
        ),
      ),
    );
  }

  group('opening pitch', () {
    testWidgets('a Western song opens on the song key, not the saved default', (
      tester,
    ) async {
      // The reported bug: a song in G showed C.
      await tester.pumpWidget(
        await wrap(songKey: 'G', prefs: {'pitch_drone_key': 'C'}),
      );
      await tester.pumpAndSettle();
      expectAllIconButtonsHaveTooltips(tester);

      expect(find.text('Song key:  G'), findsOneWidget);

      await tester.tap(find.text('Pitch Cue (2s)'));
      await tester.pumpAndSettle();
      expect(audio.cueKeys, ['G']);
    });

    testWidgets('a minor song key resolves to its root', (tester) async {
      await tester.pumpWidget(await wrap(songKey: 'Am'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pitch Cue (2s)'));
      await tester.pumpAndSettle();
      expect(audio.cueKeys, ['A']);
    });

    testWidgets('a flat song key resolves to the sharp that sounds the same', (
      tester,
    ) async {
      await tester.pumpWidget(await wrap(songKey: 'Bb'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pitch Cue (2s)'));
      await tester.pumpAndSettle();
      expect(audio.cueKeys, ['A#']);
    });

    testWidgets('an unreadable song key falls back to the saved default', (
      tester,
    ) async {
      await tester.pumpWidget(
        await wrap(songKey: '???', prefs: {'pitch_drone_key': 'D'}),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pitch Cue (2s)'));
      await tester.pumpAndSettle();
      expect(audio.cueKeys, ['D']);
    });

    testWidgets('an Indian song opens on the saved Sa, not the written key', (
      tester,
    ) async {
      // A Carnatic kriti is written relative to Sa, so the written key is not
      // the pitch actually sung.
      await tester.pumpWidget(
        await wrap(
          songKey: 'C',
          raga: 'Hamsadhvani',
          tala: 'Adi',
          prefs: {'pitch_sa_key': 'G'},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your Sa:  5 kattai'), findsOneWidget);

      await tester.tap(find.text('Pitch Cue (2s)'));
      await tester.pumpAndSettle();
      expect(audio.cueKeys, ['G']);
    });
  });

  group('naming', () {
    testWidgets('a Carnatic song labels chips in kattai', (tester) async {
      await tester.pumpWidget(
        await wrap(raga: 'Hamsadhvani', tala: 'Adi', prefs: {}),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 kattai'), findsOneWidget);
      expect(find.text('5 kattai'), findsOneWidget);
    });

    testWidgets('a Hindustani song labels chips safed / kaali', (tester) async {
      await tester.pumpWidget(await wrap(raga: 'Mishra Gara', tala: 'Keherwa'));
      await tester.pumpAndSettle();

      expect(find.text('safed 1'), findsOneWidget);
      expect(find.text('kaali 1'), findsOneWidget);
    });

    testWidgets('an Indian sheet shows no Western letter anywhere', (
      tester,
    ) async {
      await tester.pumpWidget(await wrap(raga: 'Hamsadhvani', tala: 'Adi'));
      await tester.pumpAndSettle();

      // The whole point of the Indian naming: no letters on an Indian sheet.
      expect(find.textContaining('(C)'), findsNothing);
      expect(find.textContaining('(G)'), findsNothing);
      expect(find.textContaining('(C#)'), findsNothing);
    });

    testWidgets('a Western song labels chips with plain letters', (
      tester,
    ) async {
      await tester.pumpWidget(await wrap(songKey: 'G'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ChoiceChip, 'G'), findsOneWidget);
      expect(find.textContaining('kattai'), findsNothing);
      expect(find.textContaining('safed'), findsNothing);
    });

    testWidgets('the interval buttons are named Sa + Pa and Sa + Ma', (
      tester,
    ) async {
      await tester.pumpWidget(await wrap(songKey: 'G'));
      await tester.pumpAndSettle();

      expect(find.text('Sa + Pa (5th)'), findsOneWidget);
      expect(find.text('Sa + Ma (4th)'), findsOneWidget);
    });
  });

  group('choosing a different pitch', () {
    testWidgets('the tapped chip wins over the song key', (tester) async {
      await tester.pumpWidget(await wrap(songKey: 'G'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'E'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pitch Cue (2s)'));
      await tester.pumpAndSettle();
      expect(audio.cueKeys, ['E']);
    });

    testWidgets('the saved default is left alone', (tester) async {
      await tester.pumpWidget(
        await wrap(songKey: 'G', prefs: {'pitch_drone_key': 'C'}),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'E'));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PitchDroneControlsSheet)),
      );
      expect(container.read(pitchDroneProvider).selectedKey, 'C');
    });
  });

  group('failure is visible', () {
    testWidgets('a drone that will not start shows a SnackBar', (tester) async {
      await tester.pumpWidget(await wrap(songKey: 'G', succeed: false));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Shruti Drone'));
      await tester.pumpAndSettle();

      expect(find.text('Could not start the drone.'), findsOneWidget);
      // And the button must not pretend it is playing.
      expect(find.text('Stop Drone'), findsNothing);
    });

    testWidgets('a cue that will not play shows a SnackBar', (tester) async {
      await tester.pumpWidget(await wrap(songKey: 'G', succeed: false));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pitch Cue (2s)'));
      await tester.pumpAndSettle();

      expect(find.text('Could not play the pitch cue.'), findsOneWidget);
    });
  });

  group('Western chord drone', () {
    testWidgets(
      'switching to Western mode shows Major and Minor options and Chord Drone',
      (tester) async {
        await tester.pumpWidget(await wrap(songKey: 'G'));
        await tester.pumpAndSettle();

        // Initially Classical
        expect(find.text('Sa + Pa (5th)'), findsOneWidget);
        expect(find.text('Shruti Drone'), findsOneWidget);

        // Tap Western mode
        await tester.tap(find.text('Western (Chords)'));
        await tester.pumpAndSettle();

        expect(find.text('Major (maj)'), findsOneWidget);
        expect(find.text('Minor (min)'), findsOneWidget);
        expect(find.text('Chord Drone'), findsOneWidget);
        expect(find.text('Chord Cue (2s)'), findsOneWidget);
      },
    );

    testWidgets(
      'opening a minor song key pre-selects Minor and root pitch in Western mode',
      (tester) async {
        await tester.pumpWidget(
          await wrap(songKey: 'Am', prefs: {'pitch_drone_mode': 'western'}),
        );
        await tester.pumpAndSettle();

        expect(find.text('Chord Drone'), findsOneWidget);

        // Tap Chord Cue
        await tester.tap(find.text('Chord Cue (2s)'));
        await tester.pumpAndSettle();
        expect(audio.chordCueKeys, ['A/minor']);

        // Tap Chord Drone
        await tester.tap(find.text('Chord Drone'));
        await tester.pumpAndSettle();
        expect(audio.chordDroneStarts, ['A/minor']);
        expect(find.text('Stop Drone'), findsOneWidget);
      },
    );

    testWidgets(
      'switching quality from Minor to Major updates running chord drone',
      (tester) async {
        await tester.pumpWidget(
          await wrap(songKey: 'Am', prefs: {'pitch_drone_mode': 'western'}),
        );
        await tester.pumpAndSettle();

        // Start drone on A minor
        await tester.tap(find.text('Chord Drone'));
        await tester.pumpAndSettle();
        expect(audio.chordDroneStarts, ['A/minor']);

        // Tap Major
        await tester.tap(find.text('Major (maj)'));
        await tester.pumpAndSettle();
        expect(audio.chordDroneStarts, ['A/minor', 'A/major']);

        // Tap key C
        await tester.tap(find.widgetWithText(ChoiceChip, 'C'));
        await tester.pumpAndSettle();
        expect(audio.chordDroneStarts, ['A/minor', 'A/major', 'C/major']);
      },
    );

    testWidgets(
      'stopping the drone and restarting it on the same key works cleanly',
      (tester) async {
        await tester.pumpWidget(
          await wrap(songKey: 'C', prefs: {'pitch_drone_mode': 'western'}),
        );
        await tester.pumpAndSettle();

        // Start drone on C
        await tester.tap(find.text('Chord Drone'));
        await tester.pumpAndSettle();
        expect(audio.chordDroneStarts, ['C/major']);
        expect(find.text('Stop Drone'), findsOneWidget);

        // Stop drone
        await tester.tap(find.text('Stop Drone'));
        await tester.pumpAndSettle();
        expect(audio.stopCount, 1);
        expect(find.text('Chord Drone'), findsOneWidget);

        // Restart drone on same key C
        await tester.tap(find.text('Chord Drone'));
        await tester.pumpAndSettle();
        expect(audio.chordDroneStarts, ['C/major', 'C/major']);
        expect(find.text('Stop Drone'), findsOneWidget);
      },
    );

    testWidgets(
      'switching from Western to Classical while drone is playing transitions cleanly',
      (tester) async {
        await tester.pumpWidget(
          await wrap(songKey: 'C', prefs: {'pitch_drone_mode': 'western'}),
        );
        await tester.pumpAndSettle();

        // Start Western chord drone
        await tester.tap(find.text('Chord Drone'));
        await tester.pumpAndSettle();
        expect(audio.chordDroneStarts, ['C/major']);

        // Switch to Classical mode
        await tester.tap(find.text('Classical (Shruti)'));
        await tester.pumpAndSettle();

        // Should have stopped Western and started Classical drone on C
        expect(audio.stopCount, 1);
        expect(audio.droneStarts, ['C/Pa']);
        expect(find.text('Stop Drone'), findsOneWidget);
      },
    );
  });
}
