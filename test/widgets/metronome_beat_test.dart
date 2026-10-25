import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/services/metronome_audio_service.dart';
import 'package:lyricchord/widgets/metronome_beat.dart';

import '../helpers/fake_metronome_audio.dart';

void main() {
  late FakeMetronomeAudio audio;

  /// The widget's time source, wired to the test's fake clock.
  ///
  /// `tester.pump(duration)` moves the fake clock forward and fires the timers
  /// that are due. A real [Stopwatch] would not move at all, so the widget would
  /// think no time had passed and keep pushing the next beat further away.
  Duration Function() testClock(WidgetTester tester) {
    final epoch = tester.binding.clock.now();
    return () => tester.binding.clock.now().difference(epoch);
  }

  Future<void> pumpButton(
    WidgetTester tester, {
    required int bpm,
    bool active = true,
    Map<String, Object> prefs = const {'metronome_enabled': true},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final sp = await SharedPreferences.getInstance();
    audio = FakeMetronomeAudio();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sp),
          metronomeAudioProvider.overrideWithValue(audio),
        ],
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MetronomeBeat(
              bpm: bpm,
              active: active,
              nowOverride: testClock(tester),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// Taps the button and lets the first beat land.
  Future<void> start(WidgetTester tester) async {
    await tester.tap(find.byType(MetronomeBeat));
    await tester.pump();
  }

  /// Stops the beat so no timer is left running when the test ends.
  Future<void> stop(WidgetTester tester) async {
    await tester.tap(find.byType(MetronomeBeat));
    await tester.pump();
  }

  testWidgets('starts stopped, showing the timer icon', (tester) async {
    await pumpButton(tester, bpm: 120);

    expect(find.byIcon(Icons.av_timer), findsOneWidget);
    expect(audio.played, isEmpty);
  });

  testWidgets('tapping starts the beat and counts the bar', (tester) async {
    await pumpButton(tester, bpm: 120);

    await start(tester);

    // Running: the icon is replaced by the counted beat number.
    expect(find.byIcon(Icons.av_timer), findsNothing);
    expect(find.text('1'), findsOneWidget);

    await stop(tester);
    expect(find.byIcon(Icons.av_timer), findsOneWidget);
  });

  testWidgets('the first beat clicks straight away, not one beat late', (
    tester,
  ) async {
    await pumpButton(tester, bpm: 120);

    await start(tester);

    expect(audio.played, ['accent'], reason: 'beat 1 of the bar is accented');
    await stop(tester);
  });

  testWidgets('loads the click before the first beat', (tester) async {
    await pumpButton(tester, bpm: 120);

    await start(tester);

    expect(audio.prepareCount, 1);
    await stop(tester);
  });

  testWidgets('accents beat 1 of every bar in 4/4', (tester) async {
    await pumpButton(
      tester,
      bpm: 120, // 500 ms a beat
      prefs: const {'metronome_enabled': true, 'metronome_beats_per_bar': 4},
    );

    await start(tester);
    // Run through five more beats.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(audio.accents, [true, false, false, false, true, false]);
    await stop(tester);
  });

  testWidgets('accents every third beat in 3/4', (tester) async {
    await pumpButton(
      tester,
      bpm: 120,
      prefs: const {'metronome_enabled': true, 'metronome_beats_per_bar': 3},
    );

    await start(tester);
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(audio.accents, [true, false, false, true]);
    await stop(tester);
  });

  testWidgets('with accent off every beat is a normal click', (tester) async {
    await pumpButton(
      tester,
      bpm: 120,
      prefs: const {'metronome_enabled': true, 'metronome_accent': false},
    );

    await start(tester);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(audio.played, everyElement('normal'));
    await stop(tester);
  });

  testWidgets('the counted number follows the bar', (tester) async {
    await pumpButton(tester, bpm: 120);

    await start(tester);
    expect(find.text('1'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('2'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('3'), findsOneWidget);

    // Beats 4 then back to 1.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('1'), findsOneWidget);

    await stop(tester);
  });

  testWidgets('with Click off it still flashes but makes no sound', (
    tester,
  ) async {
    await pumpButton(
      tester,
      bpm: 120,
      prefs: const {'metronome_enabled': true, 'metronome_click': false},
    );

    await start(tester);
    await tester.pump(const Duration(milliseconds: 500));

    expect(audio.played, isEmpty);
    // Still counting, so the beat itself is running.
    expect(find.text('2'), findsOneWidget);
    await stop(tester);
  });

  testWidgets('the beat keeps time over many beats', (tester) async {
    await pumpButton(tester, bpm: 120);

    await start(tester);
    // 10 seconds at 120 BPM is 20 beats; the first already fired at the start.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(audio.played.length, 21);
    await stop(tester);
  });

  testWidgets('a song with no tempo can still start, using the last tempo', (
    tester,
  ) async {
    // This used to be a dead button showing "No tempo set".
    await pumpButton(
      tester,
      bpm: 0,
      prefs: const {'metronome_enabled': true, 'metronome_last_bpm': 60},
    );

    await start(tester);

    expect(audio.played, hasLength(1));
    // 60 BPM is one beat a second.
    await tester.pump(const Duration(seconds: 1));
    expect(audio.played, hasLength(2));

    await stop(tester);
  });

  testWidgets('stops when the page is swiped away', (tester) async {
    SharedPreferences.setMockInitialValues({'metronome_enabled': true});
    final sp = await SharedPreferences.getInstance();
    audio = FakeMetronomeAudio();
    final clock = testClock(tester);

    Widget build({required bool active}) => ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        metronomeAudioProvider.overrideWithValue(audio),
      ],
      child: MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MetronomeBeat(bpm: 120, active: active, nowOverride: clock),
        ),
      ),
    );

    await tester.pumpWidget(build(active: true));
    await start(tester);
    expect(audio.played, hasLength(1));

    // The song is swiped away.
    await tester.pumpWidget(build(active: false));
    await tester.pump();

    final countAfterSwipe = audio.played.length;
    await tester.pump(const Duration(seconds: 2));
    expect(
      audio.played.length,
      countAfterSwipe,
      reason: 'no click may keep playing off-screen',
    );
    expect(find.byIcon(Icons.av_timer), findsOneWidget);
  });
}
