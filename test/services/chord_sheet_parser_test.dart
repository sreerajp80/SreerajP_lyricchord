import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/chord_sheet_parser.dart';

void main() {
  const parser = ChordSheetParser();

  group('parseLine', () {
    test('splits a chord from the words that follow it', () {
      final line = parser.parseLine('[G]Amazing [D]grace');

      expect(line.segments, [
        const ChordSegment(chord: 'G', text: 'Amazing '),
        const ChordSegment(chord: 'D', text: 'grace'),
      ]);
    });

    test('keeps the words before the first chord', () {
      final line = parser.parseLine('There [Am]is a house');

      expect(line.segments, [
        const ChordSegment(text: 'There '),
        const ChordSegment(chord: 'Am', text: 'is a house'),
      ]);
    });

    test('handles a chord in the middle of a word', () {
      final line = parser.parseLine('a[C]maz[F]ing');

      expect(line.segments, [
        const ChordSegment(text: 'a'),
        const ChordSegment(chord: 'C', text: 'maz'),
        const ChordSegment(chord: 'F', text: 'ing'),
      ]);
    });

    test('keeps a chord that ends the line', () {
      final line = parser.parseLine('sound [G]');

      expect(line.segments, [
        const ChordSegment(text: 'sound '),
        const ChordSegment(chord: 'G', text: ''),
      ]);
    });

    test('a line with no chords is one plain segment', () {
      final line = parser.parseLine('just some words');

      expect(line.segments, [const ChordSegment(text: 'just some words')]);
    });

    test('an unclosed bracket stays plain text', () {
      final line = parser.parseLine('oops [G');

      expect(line.isBlank, isFalse);
      expect(line.segments.single.chord, isNull);
      expect(line.segments.single.text, 'oops [G');
    });

    test('an empty marker stays plain text', () {
      final line = parser.parseLine('a[]b');

      expect(line.segments.single.text, 'a[]b');
    });

    test('a whitespace-only line is blank', () {
      expect(parser.parseLine('   ').isBlank, isTrue);
      expect(parser.parseLine('').isBlank, isTrue);
    });
  });

  group('parse', () {
    test('keeps blank lines so verses stay apart', () {
      final lines = parser.parse('[C]one\n\n[G]two');

      expect(lines.length, 3);
      expect(lines[1].isBlank, isTrue);
      expect(lines[2].segments.single.chord, 'G');
    });

    test('handles Windows line endings', () {
      final lines = parser.parse('one\r\ntwo');

      expect(lines.length, 2);
      expect(lines[1].segments.single.text, 'two');
    });

    test('empty lyrics give no lines', () {
      expect(parser.parse(''), isEmpty);
    });
  });

  group('chordsUsed', () {
    test('lists each chord once, in the order it appears', () {
      final chords = parser.chordsUsed('[G]a [D]b [G]c\n[Em]d');

      expect(chords, ['G', 'D', 'Em']);
    });

    test('is empty for lyrics with no chords', () {
      expect(parser.chordsUsed('no chords here'), isEmpty);
    });
  });
}
