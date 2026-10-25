import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/core/utils/text_decoding.dart';

/// [text] as UTF-16 bytes with a byte-order mark.
List<int> _utf16(String text, {required bool bigEndian}) {
  final out = <int>[
    if (bigEndian) ...[0xFE, 0xFF] else ...[0xFF, 0xFE],
  ];
  for (final unit in text.codeUnits) {
    final hi = (unit >> 8) & 0xFF;
    final lo = unit & 0xFF;
    out.addAll(bigEndian ? [hi, lo] : [lo, hi]);
  }
  return out;
}

void main() {
  group('decodeImportedBytes', () {
    test('decodes standard UTF-8', () {
      final bytes = Uint8List.fromList(utf8.encode('Hello World\nLine 2'));
      expect(decodeImportedBytes(bytes), 'Hello World\nLine 2');
    });

    test('strips UTF-8 BOM', () {
      final bytes = Uint8List.fromList([
        0xEF,
        0xBB,
        0xBF,
        ...utf8.encode('Song Title\nLine'),
      ]);
      expect(decodeImportedBytes(bytes), 'Song Title\nLine');
    });

    test('keeps Malayalam text in UTF-8', () {
      const text = 'ടെസ്റ്റ്\n[C]പാട്ട്';
      expect(decodeImportedBytes(Uint8List.fromList(utf8.encode(text))), text);
    });

    test('decodes UTF-16 LE with BOM', () {
      const text = 'Song Title\r\nLine 2 ടെസ്റ്റ്';
      final bytes = Uint8List.fromList(_utf16(text, bigEndian: false));
      expect(decodeImportedBytes(bytes), text);
    });

    test('decodes UTF-16 BE with BOM', () {
      const text = 'Song Title\r\nLine 2 ടെസ്റ്റ്';
      final bytes = Uint8List.fromList(_utf16(text, bigEndian: true));
      expect(decodeImportedBytes(bytes), text);
    });

    test('UTF-16 LE at an odd byte offset does not throw', () {
      // A view that starts on an odd offset used to make Uint16List.view throw.
      const text = 'Odd offset';
      final backing = Uint8List.fromList([
        0,
        ..._utf16(text, bigEndian: false),
      ]);
      final view = Uint8List.sublistView(backing, 1);
      expect(view.offsetInBytes, 1);
      expect(decodeImportedBytes(view), text);
    });

    test('an odd trailing UTF-16 byte is dropped, not a crash', () {
      final bytes = Uint8List.fromList([
        ..._utf16('Hi', bigEndian: false),
        0x41,
      ]);
      expect(decodeImportedBytes(bytes), 'Hi');
    });

    test('malformed UTF-8 does not throw', () {
      final bytes = Uint8List.fromList([0x41, 0xC3, 0x28, 0x42]);
      expect(() => decodeImportedBytes(bytes), returnsNormally);
    });

    test('empty input gives an empty string', () {
      expect(decodeImportedBytes(Uint8List(0)), '');
      expect(decodeImportedBytes(Uint8List.fromList([0xFF, 0xFE])), '');
    });
  });

  group('looksLikeBinary', () {
    test('a PNG file is binary', () {
      final png = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      ]);
      expect(looksLikeBinary(png), isTrue);
    });

    test('a zero byte in text means binary', () {
      final bytes = Uint8List.fromList([...utf8.encode('[C]hello'), 0]);
      expect(looksLikeBinary(bytes), isTrue);
    });

    test('mostly invalid UTF-8 is binary', () {
      final bytes = Uint8List.fromList(
        List<int>.generate(400, (i) => 0x80 + (i % 0x40)),
      );
      expect(looksLikeBinary(bytes), isTrue);
    });

    test('ChordPro text in English and Malayalam is not binary', () {
      final bytes = Uint8List.fromList(
        utf8.encode('{title: പാട്ട്}\n[C]hello [G]there\nമലയാളം വരി'),
      );
      expect(looksLikeBinary(bytes), isFalse);
    });

    test('UTF-16 text with a byte-order mark is not binary', () {
      final bytes = Uint8List.fromList(
        _utf16('{title: Song}\n[C]hi', bigEndian: false),
      );
      expect(looksLikeBinary(bytes), isFalse);
    });

    test('one cut letter at the end of the probe is not binary', () {
      final text = utf8.encode('a' * 8191 + 'മ');
      expect(looksLikeBinary(Uint8List.fromList(text)), isFalse);
    });

    test('empty input is not binary', () {
      expect(looksLikeBinary(Uint8List(0)), isFalse);
    });
  });
}
