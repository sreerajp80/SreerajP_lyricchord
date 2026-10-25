import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/core/utils/formatting_locale.dart';

void main() {
  group('formattingLocale', () {
    test('keeps a language intl knows', () {
      expect(formattingLocale('en'), 'en');
      expect(formattingLocale('ml'), 'ml');
    });

    test('Sanskrit has no intl data, so it is formatted as English', () {
      expect(formattingLocale('sa'), 'en');
    });

    test('an unknown language also falls back to English', () {
      expect(formattingLocale('zz'), 'en');
    });
  });

  group('formatFixed', () {
    test('always shows the asked-for decimals', () {
      expect(formatFixed(1, 2, 'en'), '1.00');
      expect(formatFixed(0.4, 2, 'en'), '0.40');
      expect(formatFixed(3.5, 1, 'en'), '3.5');
      expect(formatFixed(7, 0, 'en'), '7');
    });

    test('Sanskrit and Malayalam give the same digits as English today', () {
      expect(formatFixed(1.25, 2, 'sa'), '1.25');
      expect(formatFixed(1.25, 2, 'ml'), '1.25');
    });

    test('does not group thousands', () {
      expect(formatFixed(12345, 0, 'en'), '12345');
    });
  });
}
