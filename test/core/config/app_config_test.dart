import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/core/config/app_config.dart';

void main() {
  group('LocalizedText', () {
    const text = LocalizedText.byLocale({'en': 'Hello', 'ml': 'നമസ്കാരം'});

    test('resolves the exact language', () {
      expect(text.resolve('ml'), 'നമസ്കാരം');
    });

    test('falls back to English for a language it does not have', () {
      expect(text.resolve('sa'), 'Hello');
    });

    test('falls back to any entry when there is no English', () {
      expect(const LocalizedText.byLocale({'ml': 'x'}).resolve('sa'), 'x');
    });

    test('a plain text is the same in every language', () {
      expect(const LocalizedText.plain('VS Code').resolve('ml'), 'VS Code');
    });

    test('reads a string, a map, and falls back on anything else', () {
      expect(LocalizedText.fromJson('a').resolve('en'), 'a');
      expect(LocalizedText.fromJson({'en': 'b', 'x': 3}).resolve('en'), 'b');
      expect(LocalizedText.fromJson(42, fallback: 'f').resolve('en'), 'f');
      expect(LocalizedText.fromJson(<String, Object>{}).isEmpty, isTrue);
    });
  });

  group('AppConfig.fromJson', () {
    test('reads the guideline shape', () {
      final config = AppConfig.fromJson({
        'appName': {'en': 'LyricChord'},
        'description': 'Notebook',
        'version': '1.2.3',
        'build': '4',
        'details': {
          'author': {'en': 'Someone'},
          'email': 'a@b.c',
        },
      });

      expect(config.appName.resolve('en'), 'LyricChord');
      expect(config.description.resolve('ml'), 'Notebook');
      expect(config.version, '1.2.3');
      expect(config.build, '4');
      expect(config.details.keys, ['author', 'email']);
    });

    test('never throws on wrong types; each field falls back on its own', () {
      final config = AppConfig.fromJson({
        'appName': 7,
        'version': 1,
        'details': ['not', 'a', 'map'],
      });

      expect(config.appName.resolve('en'), 'LyricChord');
      expect(config.version, AppConfig.fallback.version);
      expect(config.details, isEmpty);
    });

    test('drops detail rows with no usable value', () {
      final config = AppConfig.fromJson({
        'details': {'author': 5, 'license': 'MIT'},
      });

      expect(config.details.keys, ['license']);
    });
  });
}
