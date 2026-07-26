import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/chord_suggestion_service.dart';

void main() {
  const service = ChordSuggestionService();

  group('parseKey', () {
    test('reads a plain major key', () {
      expect(
        service.parseKey('C'),
        const ParsedKey(rootSemitone: 0, minor: false, useFlats: false),
      );
    });

    test('reads a minor key', () {
      expect(
        service.parseKey('Am'),
        const ParsedKey(rootSemitone: 9, minor: true, useFlats: false),
      );
    });

    test('reads a sharp minor key', () {
      expect(
        service.parseKey('F#m'),
        const ParsedKey(rootSemitone: 6, minor: true, useFlats: false),
      );
    });

    test('reads a flat key and remembers the flat spelling', () {
      expect(
        service.parseKey('Bb'),
        const ParsedKey(rootSemitone: 10, minor: false, useFlats: true),
      );
    });

    test('accepts lower case and longer minor words', () {
      expect(service.parseKey('d minor')?.minor, isTrue);
      expect(service.parseKey('gmin')?.minor, isTrue);
    });

    test('does not read "maj" as minor', () {
      expect(service.parseKey('Cmaj7')?.minor, isFalse);
    });

    test('returns null for text that is not a key', () {
      expect(service.parseKey(''), isNull);
      expect(service.parseKey('   '), isNull);
      expect(service.parseKey('hello'), isNull);
      expect(service.parseKey('9'), isNull);
    });
  });

  group('suggestionsForKey', () {
    test('C major gives the usual C chords', () {
      expect(service.suggestionsForKey('C'), [
        'C',
        'Dm',
        'Em',
        'F',
        'G',
        'Am',
        'G7',
        'Bb',
      ]);
    });

    test('G major is built from G', () {
      expect(service.suggestionsForKey('G'), [
        'G',
        'Am',
        'Bm',
        'C',
        'D',
        'Em',
        'D7',
        'F',
      ]);
    });

    test('a flat key is spelled with flats', () {
      final chords = service.suggestionsForKey('Bb');
      expect(chords.first, 'Bb');
      expect(chords, contains('Eb'));
      expect(chords.any((c) => c.contains('#')), isFalse);
    });

    test('A minor gives the usual minor-key chords', () {
      expect(service.suggestionsForKey('Am'), [
        'Am',
        'Bdim',
        'C',
        'Dm',
        'Em',
        'F',
        'G',
        'E7',
      ]);
    });

    test('F# minor is built from F#', () {
      final chords = service.suggestionsForKey('F#m');
      expect(chords.first, 'F#m');
      expect(chords, contains('C#m'));
    });

    test('an unreadable key falls back to C major instead of throwing', () {
      expect(service.suggestionsForKey(''), service.suggestionsForKey('C'));
      expect(service.suggestionsForKey('???'), service.suggestionsForKey('C'));
    });

    test('always returns a usable list', () {
      for (final key in ['C', 'Am', 'Bb', 'F#m', '', 'x', 'H']) {
        expect(service.suggestionsForKey(key), isNotEmpty, reason: 'key: $key');
      }
    });
  });
}
