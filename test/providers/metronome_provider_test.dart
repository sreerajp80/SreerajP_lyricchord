import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyriccord/providers/metronome_provider.dart';
import 'package:lyriccord/providers/theme_mode_provider.dart';

void main() {
  Future<ProviderContainer> makeContainer(
    Map<String, Object> initialPrefs,
  ) async {
    SharedPreferences.setMockInitialValues(initialPrefs);
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  test('defaults to off with flash and click pre-armed', () async {
    final container = await makeContainer({});
    addTearDown(container.dispose);

    final settings = container.read(metronomeSettingsProvider);
    expect(settings.enabled, isFalse);
    expect(settings.flash, isTrue);
    expect(settings.click, isTrue);
  });

  test('reads the saved values on build', () async {
    final container = await makeContainer({
      'metronome_enabled': true,
      'metronome_flash': false,
      'metronome_click': false,
    });
    addTearDown(container.dispose);

    final settings = container.read(metronomeSettingsProvider);
    expect(settings.enabled, isTrue);
    expect(settings.flash, isFalse);
    expect(settings.click, isFalse);
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
}
