import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/models/pitch_drone_settings.dart';
import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/screens/pitch_drone_settings_screen.dart';
import 'package:lyricchord/services/pitch_drone_audio_service.dart';

import '../helpers/fake_pitch_drone_audio.dart';

void main() {
  late FakePitchDroneAudio audio;

  Future<void> pumpScreen(
    WidgetTester tester,
    Map<String, Object> initialPrefs,
  ) async {
    SharedPreferences.setMockInitialValues(initialPrefs);
    final prefs = await SharedPreferences.getInstance();
    audio = FakePitchDroneAudio();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          pitchDroneAudioProvider.overrideWithValue(audio),
        ],
        child: const MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PitchDroneSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Brings [finder] into the test viewport before tapping or reading it.
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 120);
    await tester.pumpAndSettle();
  }

  ListTile tileFor(WidgetTester tester, String title) {
    return tester.widget<ListTile>(
      find.ancestor(of: find.text(title), matching: find.byType(ListTile)),
    );
  }

  Map<String, Object> prefsFor({
    PitchTradition naming = PitchTradition.carnatic,
    DroneMode mode = DroneMode.classical,
    String saKey = 'G',
    String selectedKey = 'C',
  }) {
    return {
      AppConstants.prefPitchNaming: naming.storageKey,
      AppConstants.prefDroneMode: mode.storageKey,
      AppConstants.prefSaKey: saKey,
      AppConstants.prefPitchDroneKey: selectedKey,
    };
  }

  testWidgets('shows every section heading', (tester) async {
    await pumpScreen(tester, prefsFor());

    for (final heading in [
      'Pitch naming',
      'Indian songs',
      'Western songs',
      'All songs',
      'Try it out',
    ]) {
      await scrollTo(tester, find.text(heading));
      expect(find.text(heading), findsOneWidget, reason: heading);
    }
  });

  testWidgets('Carnatic naming points at the Indian songs section', (
    tester,
  ) async {
    await pumpScreen(tester, prefsFor());

    expect(
      find.text(
        'Songs with no raga or tala use the Indian songs settings below.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Western naming points at the Western songs section', (
    tester,
  ) async {
    await pumpScreen(tester, prefsFor(naming: PitchTradition.western));

    expect(
      find.text(
        'Songs with no raga or tala use the Western songs settings below.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the test line names the Sa and the Classical drone when '
      'naming is Carnatic', (tester) async {
    await pumpScreen(
      tester,
      prefsFor(
        // A Western drone mode must not leak into an Indian song.
        mode: DroneMode.western,
      ),
    );

    final line = find.textContaining('Test plays: Classical drone on 5 kattai');
    await scrollTo(tester, line);
    expect(line, findsOneWidget);
  });

  testWidgets('the test buttons play the Sa in Classical mode when naming is '
      'Carnatic', (tester) async {
    await pumpScreen(tester, prefsFor(mode: DroneMode.western));

    final button = find.text('Test Pitch Cue');
    await scrollTo(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    // The Sa, not the Western default key, and a plain cue, not a chord.
    expect(audio.cueKeys, ['G']);
    expect(audio.chordCueKeys, isEmpty);
  });

  testWidgets('the test buttons use the Western key and mode when naming is '
      'Western', (tester) async {
    await pumpScreen(
      tester,
      prefsFor(
        naming: PitchTradition.western,
        mode: DroneMode.western,
        selectedKey: 'D',
      ),
    );

    final button = find.text('Test Chord Cue');
    await scrollTo(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(audio.chordCueKeys.single, startsWith('D/'));
    expect(audio.cueKeys, isEmpty);
  });

  testWidgets('Drone Interval stays visible in both drone modes', (
    tester,
  ) async {
    await pumpScreen(tester, prefsFor());
    expect(find.text('Drone Interval'), findsOneWidget);

    await pumpScreen(tester, prefsFor(mode: DroneMode.western));
    expect(find.text('Drone Interval'), findsOneWidget);
  });

  testWidgets('chord quality is shown but disabled while the drone mode is '
      'Classical', (tester) async {
    await pumpScreen(tester, prefsFor());

    final row = find.text('Chord quality');
    await scrollTo(tester, row);

    expect(row, findsOneWidget);
    expect(tileFor(tester, 'Chord quality').enabled, isFalse);
    expect(
      find.text('Used only when the drone mode above is Western'),
      findsOneWidget,
    );
  });

  testWidgets('chord quality is enabled while the drone mode is Western', (
    tester,
  ) async {
    await pumpScreen(tester, prefsFor(mode: DroneMode.western));

    final row = find.text('Chord quality');
    await scrollTo(tester, row);

    expect(tileFor(tester, 'Chord quality').enabled, isTrue);
  });
}
