import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/providers/metronome_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/services/metronome_audio_service.dart';

import '../helpers/fake_metronome_audio.dart';

void main() {
  late FakeMetronomeAudio audio;

  Future<ProviderContainer> makeContainer(
    Map<String, Object> initialPrefs,
  ) async {
    SharedPreferences.setMockInitialValues(initialPrefs);
    final prefs = await SharedPreferences.getInstance();
    audio = FakeMetronomeAudio();
    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        // No real audio device in a test.
        metronomeAudioProvider.overrideWithValue(audio),
      ],
    );
  }

  test('defaults to off with everything else pre-armed', () async {
    final container = await makeContainer({});
    addTearDown(container.dispose);

    final settings = container.read(metronomeSettingsProvider);
    expect(settings.enabled, isFalse);
    expect(settings.flash, isTrue);
    expect(settings.click, isTrue);
    expect(settings.volume, 0.8);
    expect(settings.beatsPerBar, 4);
    expect(settings.accent, isTrue);
  });

  test('reads the saved values on build', () async {
    final container = await makeContainer({
      'metronome_enabled': true,
      'metronome_flash': false,
      'metronome_click': false,
      'metronome_volume': 0.5,
      'metronome_beats_per_bar': 3,
      'metronome_accent': false,
    });
    addTearDown(container.dispose);

    final settings = container.read(metronomeSettingsProvider);
    expect(settings.enabled, isTrue);
    expect(settings.flash, isFalse);
    expect(settings.click, isFalse);
    expect(settings.volume, 0.5);
    expect(settings.beatsPerBar, 3);
    expect(settings.accent, isFalse);
  });

  test('ignores a saved beats-per-bar that is not on offer', () async {
    // A stale or hand-edited preference must not leave the picker with nothing
    // selected.
    final container = await makeContainer({'metronome_beats_per_bar': 7});
    addTearDown(container.dispose);

    expect(container.read(metronomeSettingsProvider).beatsPerBar, 4);
  });

  test('setEnabled saves the flag', () async {
    final container = await makeContainer({});
    addTearDown(container.dispose);

    await container.read(metronomeSettingsProvider.notifier).setEnabled(true);

    expect(container.read(metronomeSettingsProvider).enabled, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('metronome_enabled'), isTrue);
  });

  test('setFlash saves the flag', () async {
    final container = await makeContainer({});
    addTearDown(container.dispose);

    await container.read(metronomeSettingsProvider.notifier).setFlash(false);

    expect(container.read(metronomeSettingsProvider).flash, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('metronome_flash'), isFalse);
  });

  test('setClick saves the flag', () async {
    final container = await makeContainer({});
    addTearDown(container.dispose);

    await container.read(metronomeSettingsProvider.notifier).setClick(false);

    expect(container.read(metronomeSettingsProvider).click, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('metronome_click'), isFalse);
  });

  test('setVolume saves it and tells the players', () async {
    final container = await makeContainer({});
    addTearDown(container.dispose);

    await container.read(metronomeSettingsProvider.notifier).setVolume(0.35);

    expect(container.read(metronomeSettingsProvider).volume, 0.35);
    expect(audio.volume, 0.35, reason: 'the live click must change too');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('metronome_volume'), 0.35);
  });

  test('setVolume clamps to 0.0-1.0', () async {
    final container = await makeContainer({});
    addTearDown(container.dispose);
    final notifier = container.read(metronomeSettingsProvider.notifier);

    await notifier.setVolume(5);
    expect(container.read(metronomeSettingsProvider).volume, 1.0);

    await notifier.setVolume(-2);
    expect(container.read(metronomeSettingsProvider).volume, 0.0);
  });

  test('setBeatsPerBar saves an offered value', () async {
    final container = await makeContainer({});
    addTearDown(container.dispose);

    await container.read(metronomeSettingsProvider.notifier).setBeatsPerBar(3);

    expect(container.read(metronomeSettingsProvider).beatsPerBar, 3);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('metronome_beats_per_bar'), 3);
  });

  test('setBeatsPerBar refuses a value that is not on offer', () async {
    final container = await makeContainer({});
    addTearDown(container.dispose);

    await container.read(metronomeSettingsProvider.notifier).setBeatsPerBar(7);

    expect(container.read(metronomeSettingsProvider).beatsPerBar, 4);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('metronome_beats_per_bar'), isNull);
  });

  test('setAccent saves the flag', () async {
    final container = await makeContainer({});
    addTearDown(container.dispose);

    await container.read(metronomeSettingsProvider.notifier).setAccent(false);

    expect(container.read(metronomeSettingsProvider).accent, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('metronome_accent'), isFalse);
  });
}
