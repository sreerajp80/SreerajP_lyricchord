import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/core/utils/line_break_utils.dart';

void main() {
  group('normalizeLineBreaks', () {
    test('normalizes CRLF to LF', () {
      expect(normalizeLineBreaks('a\r\nb\r\nc'), 'a\nb\nc');
    });

    test('normalizes CR to LF', () {
      expect(normalizeLineBreaks('a\rb\rc'), 'a\nb\nc');
    });

    test('normalizes Unicode line separator U+2028 to LF', () {
      expect(normalizeLineBreaks('a\u2028b\u2028c'), 'a\nb\nc');
    });

    test('normalizes Unicode paragraph separator U+2029 to double LF', () {
      expect(normalizeLineBreaks('a\u2029b'), 'a\n\nb');
    });

    test('normalizes next-line and form-feed', () {
      expect(normalizeLineBreaks('a\u0085b\u000Cc'), 'a\nb\nc');
    });

    test('unescapes literal newlines when no real newlines exist', () {
      expect(normalizeLineBreaks(r'a\nb\nc'), 'a\nb\nc');
      expect(normalizeLineBreaks(r'a\r\nb'), 'a\nb');
    });

    test('leaves already clean newlines untouched', () {
      expect(normalizeLineBreaks('a\nb\nc'), 'a\nb\nc');
    });
  });
}
