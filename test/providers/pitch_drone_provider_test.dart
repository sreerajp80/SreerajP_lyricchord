import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/providers/pitch_drone_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/services/pitch_drone_audio_service.dart';

import '../helpers/fake_pitch_drone_audio.dart';

void main() {
  late FakePitchDroneAudio audio;

  Future<ProviderContainer> makeContainer([
    Map<String, Object> initialPrefs = const {},
    bool succeed = true,
  ]) async {
    SharedPreferences.setMockInitialValues(initialPrefs);
    final prefs = await SharedPreferences.getInstance();
    audio = FakePitchDroneAudio(succeed: succeed);
    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        // No real audio device in a test.
        pitchDroneAudioProvider.overrideWithValue(audio),
      ],
    );
  }

  test('defaults are sensible and nothing is playing', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    final settings = container.read(pitchDroneProvider);
    expect(settings.selectedKey, 'C');
    expect(settings.saKey, 'C');
    expect(settings.pitchNaming, PitchTradition.carnatic);
    expect(settings.droneInterval, 'Pa');
    expect(settings.volume, 0.8);
    expect(settings.dronePlaying, isFalse);
    expect(settings.lastError, isNull);
  });

  test('reads saved values on build', () async {
    final container = await makeContainer({
      'pitch_drone_key': 'G',
      'pitch_sa_key': 'D#',
      'pitch_naming': 'hindustani',
      'pitch_drone_interval': 'Ma',
      'pitch_drone_volume': 0.5,
    });
    addTearDown(container.dispose);

    final settings = container.read(pitchDroneProvider);
    expect(settings.selectedKey, 'G');
    expect(settings.saKey, 'D#');
    expect(settings.pitchNaming, PitchTradition.hindustani);
    expect(settings.droneInterval, 'Ma');
    expect(settings.volume, 0.5);
  });

  test('an unrecognised saved naming falls back instead of crashing', () async {
    final container = await makeContainer({'pitch_naming': 'klingon'});
    addTearDown(container.dispose);

    expect(
      container.read(pitchDroneProvider).pitchNaming,
      PitchTradition.carnatic,
    );
  });

  test('a drone that never sounds is not reported as playing', () async {
    // This is the exact bug: the device created a player, never started it,
    // and the button still said "Stop Drone".
    final container = await makeContainer(const {}, false);
    addTearDown(container.dispose);

    final started = await container
        .read(pitchDroneProvider.notifier)
        .toggleDrone(key: 'G');

    expect(started, isFalse);
    final settings = container.read(pitchDroneProvider);
    expect(settings.dronePlaying, isFalse);
    expect(settings.lastError, 'Could not start the drone.');
  });

  test('a drone that does sound is reported as playing', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    final started = await container
        .read(pitchDroneProvider.notifier)
        .toggleDrone(key: 'G');

    expect(started, isTrue);
    expect(container.read(pitchDroneProvider).dronePlaying, isTrue);
    expect(container.read(pitchDroneProvider).lastError, isNull);
    expect(audio.droneStarts, ['G/Pa']);
  });

  test('a failed pitch cue reports an error', () async {
    final container = await makeContainer(const {}, false);
    addTearDown(container.dispose);

    final played = await container
        .read(pitchDroneProvider.notifier)
        .playPitchCue(key: 'A');

    expect(played, isFalse);
    expect(
      container.read(pitchDroneProvider).lastError,
      'Could not play the pitch cue.',
    );
  });

  test(
    'playing a cue for a song key does not change the saved default',
    () async {
      final container = await makeContainer({'pitch_drone_key': 'C'});
      addTearDown(container.dispose);

      await container.read(pitchDroneProvider.notifier).playPitchCue(key: 'G');

      expect(audio.cueKeys, ['G']);
      // The saved default is the user's, not the song's.
      expect(container.read(pitchDroneProvider).selectedKey, 'C');
    },
  );

  test('toggling again stops the drone', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);
    final notifier = container.read(pitchDroneProvider.notifier);

    await notifier.toggleDrone(key: 'G');
    await notifier.toggleDrone();

    expect(container.read(pitchDroneProvider).dronePlaying, isFalse);
    expect(audio.stopCount, 1);
  });

  test(
    'changing the interval keeps the pitch the drone is sounding on',
    () async {
      // The sheet can start the drone on a song's key without saving it. A later
      // interval change must not jump back to the saved default.
      final container = await makeContainer({'pitch_drone_key': 'C'});
      addTearDown(container.dispose);
      final notifier = container.read(pitchDroneProvider.notifier);

      await notifier.toggleDrone(key: 'G');
      await notifier.setDroneInterval('Ma');

      expect(audio.droneStarts, ['G/Pa', 'G/Ma']);
    },
  );

  test('setSaKey persists and does not touch the Western default', () async {
    final container = await makeContainer({'pitch_drone_key': 'C'});
    addTearDown(container.dispose);

    await container.read(pitchDroneProvider.notifier).setSaKey('F#');

    expect(container.read(pitchDroneProvider).saKey, 'F#');
    expect(container.read(pitchDroneProvider).selectedKey, 'C');
  });

  test('volume reaches the audio service', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    await container.read(pitchDroneProvider.notifier).setVolume(0.25);

    expect(container.read(pitchDroneProvider).volume, 0.25);
    expect(audio.volume, 0.25);
  });

  test('font scale cycles through the five tiers and wraps', () async {
    final container = await makeContainer({'stage_font_scale_index': 4});
    addTearDown(container.dispose);

    await container.read(pitchDroneProvider.notifier).cycleFontScale();

    expect(container.read(pitchDroneProvider).fontScaleIndex, 0);
  });
}
