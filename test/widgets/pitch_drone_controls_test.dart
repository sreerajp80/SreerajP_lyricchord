import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/providers/pitch_drone_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/services/pitch_drone_audio_service.dart';
import 'package:lyricchord/widgets/pitch_drone_controls.dart';

import '../helpers/fake_pitch_drone_audio.dart';

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
}
