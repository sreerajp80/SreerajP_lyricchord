import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/providers/metronome_runtime_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/services/metronome_calculator.dart';

void main() {
  Future<ProviderContainer> makeContainer([
    Map<String, Object> initialPrefs = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(initialPrefs);
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  group('effectiveBpm', () {
    test("follows the song's tempo when nothing is overridden", () {
      const runtime = MetronomeRuntime(lastBpm: 90);
      expect(runtime.effectiveBpm(140), 140);
    });

    test('the hand-set tempo beats the song tempo', () {
      const runtime = MetronomeRuntime(overrideBpm: 75, lastBpm: 90);
      expect(runtime.effectiveBpm(140), 75);
    });

    test('falls back to the last tempo when the song has none', () {
      const runtime = MetronomeRuntime(lastBpm: 90);
      // This is the case that used to leave the button dead.
      expect(runtime.effectiveBpm(0), 90);
    });

    test('clamps a silly song tempo into the allowed range', () {
      const runtime = MetronomeRuntime();
      expect(runtime.effectiveBpm(5000), MetronomeCalculator.maxBpm);
      expect(runtime.effectiveBpm(1), MetronomeCalculator.minBpm);
    });
  });

  test('starts with no override and the default tempo', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    final runtime = container.read(metronomeRuntimeProvider);
    expect(runtime.overrideBpm, isNull);
    expect(runtime.isOverridden, isFalse);
    expect(runtime.lastBpm, MetronomeRuntime.defaultBpm);
  });

  test('reads the remembered last tempo on build', () async {
    final container = await makeContainer({'metronome_last_bpm': 132});
    addTearDown(container.dispose);

    expect(container.read(metronomeRuntimeProvider).lastBpm, 132);
  });

  test('ignores a nonsense saved tempo', () async {
    final container = await makeContainer({'metronome_last_bpm': 0});
    addTearDown(container.dispose);

    expect(
      container.read(metronomeRuntimeProvider).lastBpm,
      MetronomeRuntime.defaultBpm,
    );
  });

  test('setOverride saves it as the last tempo used', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    await container.read(metronomeRuntimeProvider.notifier).setOverride(144);

    final runtime = container.read(metronomeRuntimeProvider);
    expect(runtime.overrideBpm, 144);
    expect(runtime.lastBpm, 144);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('metronome_last_bpm'), 144);
  });

  test('setOverride clamps to the allowed range', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);
    final notifier = container.read(metronomeRuntimeProvider.notifier);

    await notifier.setOverride(1000);
    expect(
      container.read(metronomeRuntimeProvider).overrideBpm,
      MetronomeCalculator.maxBpm,
    );

    await notifier.setOverride(-5);
    expect(
      container.read(metronomeRuntimeProvider).overrideBpm,
      MetronomeCalculator.minBpm,
    );
  });

  test('nudge starts from the song tempo on the first press', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    await container
        .read(metronomeRuntimeProvider.notifier)
        .nudge(1, songBpm: 120);

    expect(container.read(metronomeRuntimeProvider).overrideBpm, 121);
  });

  test('nudge cannot go past the limits', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);
    final notifier = container.read(metronomeRuntimeProvider.notifier);

    await notifier.setOverride(MetronomeCalculator.maxBpm);
    await notifier.nudge(1, songBpm: 120);
    expect(
      container.read(metronomeRuntimeProvider).overrideBpm,
      MetronomeCalculator.maxBpm,
    );
  });

  test('useSongTempo drops the override but keeps the last tempo', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);
    final notifier = container.read(metronomeRuntimeProvider.notifier);

    await notifier.setOverride(144);
    notifier.useSongTempo();

    final runtime = container.read(metronomeRuntimeProvider);
    expect(runtime.overrideBpm, isNull);
    expect(runtime.isOverridden, isFalse);
    expect(runtime.lastBpm, 144);
    expect(runtime.effectiveBpm(120), 120, reason: 'back to the song');
  });

  test('setFromTaps sets the tempo from the tap gaps', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    final ok = await container
        .read(metronomeRuntimeProvider.notifier)
        .setFromTaps([Duration.zero, const Duration(milliseconds: 500)]);

    expect(ok, isTrue);
    expect(container.read(metronomeRuntimeProvider).overrideBpm, 120);
  });

  test('setFromTaps changes nothing on a single tap', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    final ok = await container
        .read(metronomeRuntimeProvider.notifier)
        .setFromTaps([Duration.zero]);

    expect(ok, isFalse);
    expect(container.read(metronomeRuntimeProvider).overrideBpm, isNull);
  });
}
