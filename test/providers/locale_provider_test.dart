import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/providers/locale_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';

void main() {
  Future<(ProviderContainer, SharedPreferences)> containerWith(
    Map<String, Object> saved,
  ) async {
    SharedPreferences.setMockInitialValues(saved);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return (container, prefs);
  }

  test('follows the phone when nothing is saved', () async {
    final (container, _) = await containerWith({});
    expect(container.read(localeProvider), isNull);
  });

  test('reads a saved language before anything else happens', () async {
    final (container, _) = await containerWith({'app_language': 'en'});
    expect(container.read(localeProvider), const Locale('en'));
  });

  test(
    'a saved language the app has no strings for follows the phone',
    () async {
      final (container, _) = await containerWith({'app_language': 'zz'});
      expect(container.read(localeProvider), isNull);
    },
  );

  test('choosing a language saves it and applies it at once', () async {
    final (container, prefs) = await containerWith({});

    await container.read(localeProvider.notifier).setLanguage('en');

    expect(container.read(localeProvider), const Locale('en'));
    expect(prefs.getString('app_language'), 'en');
  });

  test('System default saves "system" and follows the phone', () async {
    final (container, prefs) = await containerWith({'app_language': 'en'});

    await container
        .read(localeProvider.notifier)
        .setLanguage(systemLanguageValue);

    expect(container.read(localeProvider), isNull);
    expect(prefs.getString('app_language'), 'system');
  });

  test('an unknown value is saved as System default', () async {
    final (container, prefs) = await containerWith({});

    await container.read(localeProvider.notifier).setLanguage('xx');

    expect(container.read(localeProvider), isNull);
    expect(prefs.getString('app_language'), 'system');
  });

  group('resolveAppLocale', () {
    const supported = [Locale('en'), Locale('ml'), Locale('sa')];

    test('uses the phone language when the app has it', () {
      expect(
        resolveAppLocale(const Locale('ml', 'IN'), supported),
        const Locale('ml'),
      );
    });

    test('otherwise uses the template language', () {
      expect(resolveAppLocale(const Locale('hi'), supported), supported.first);
      expect(resolveAppLocale(null, supported), supported.first);
    });
  });
}
