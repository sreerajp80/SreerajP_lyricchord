import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/core/utils/line_break_utils.dart';
import 'package:lyricchord/screens/import_export_screen.dart';

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

  group('decodeImportedBytes', () {
    test('decodes standard UTF-8', () {
      final bytes = Uint8List.fromList(utf8.encode('Hello World\nLine 2'));
      expect(decodeImportedBytes(bytes), 'Hello World\nLine 2');
    });

    test('strips UTF-8 BOM', () {
      final bomAndText = [0xEF, 0xBB, 0xBF, ...utf8.encode('Song Title\nLine')];
      final bytes = Uint8List.fromList(bomAndText);
      expect(decodeImportedBytes(bytes), 'Song Title\nLine');
    });

    test('decodes UTF-16 LE with BOM', () {
      const text = 'Song Title\r\nLine 2';
      final units = text.codeUnits;
      final bytes = Uint8List(2 + units.length * 2);
      bytes[0] = 0xFF;
      bytes[1] = 0xFE;
      for (var i = 0; i < units.length; i++) {
        bytes[2 + i * 2] = units[i] & 0xFF;
        bytes[2 + i * 2 + 1] = (units[i] >> 8) & 0xFF;
      }
      expect(decodeImportedBytes(bytes), 'Song Title\r\nLine 2');
    });

    test('decodes UTF-16 BE with BOM', () {
      const text = 'Song Title\r\nLine 2';
      final units = text.codeUnits;
      final bytes = Uint8List(2 + units.length * 2);
      bytes[0] = 0xFE;
      bytes[1] = 0xFF;
      for (var i = 0; i < units.length; i++) {
        bytes[2 + i * 2] = (units[i] >> 8) & 0xFF;
        bytes[2 + i * 2 + 1] = units[i] & 0xFF;
      }
      expect(decodeImportedBytes(bytes), 'Song Title\r\nLine 2');
    });
  });
}
