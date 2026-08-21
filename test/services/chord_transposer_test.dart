import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/chord_transposer.dart';

void main() {
  const transposer = ChordTransposer();

  group('transposeChord', () {
    test('moves a plain chord up and down', () {
      expect(transposer.transposeChord('C', 2), 'D');
      expect(transposer.transposeChord('D', -2), 'C');
    });

    test('keeps the suffix', () {
      expect(transposer.transposeChord('Am7', 3), 'Cm7');
      expect(transposer.transposeChord('Dsus4', 2), 'Esus4');
      expect(transposer.transposeChord('Gmaj7', 1), 'G#maj7');
      expect(transposer.transposeChord('Bdim', 1), 'Cdim');
    });

    test('wraps around past B', () {
      expect(transposer.transposeChord('B', 1), 'C');
      expect(transposer.transposeChord('C', -1), 'B');
      expect(transposer.transposeChord('A', 14), 'B');
    });

    test('moves both halves of a slash chord', () {
      expect(transposer.transposeChord('C/E', 2), 'D/F#');
      expect(transposer.transposeChord('G/B', -2), 'F/A');
    });

    test('writes flats when asked', () {
      expect(transposer.transposeChord('C', 1, useFlats: true), 'Db');
      expect(transposer.transposeChord('C', 1), 'C#');
      expect(transposer.transposeChord('Bb', 2, useFlats: true), 'C');
    });

    test('leaves things that are not chords alone', () {
      expect(transposer.transposeChord('x', 2), 'x');
      expect(transposer.transposeChord('Verse', 2), 'Verse');
      expect(transposer.transposeChord('   ', 2), '   ');
      expect(transposer.transposeChord('', 2), '');
      expect(transposer.transposeChord('C/x', 2), 'C/x');
    });

    test('zero semitones changes nothing', () {
      expect(transposer.transposeChord('F#m', 0), 'F#m');
    });
  });

  group('transposeKey', () {
    test('moves a major key', () {
      expect(transposer.transposeKey('C', 2), 'D');
      expect(transposer.transposeKey('G', 5), 'C');
    });

    test('moves a minor key and keeps the wording', () {
      expect(transposer.transposeKey('Am', 2), 'Bm');
      expect(transposer.transposeKey('Amin', 3), 'Cmin');
    });

    test('picks the spelling musicians expect', () {
      expect(transposer.transposeKey('C', 1), 'Db');
      expect(transposer.transposeKey('A', 1), 'Bb');
      expect(transposer.transposeKey('C', 6), 'F#');
      expect(transposer.transposeKey('Am', 1), 'Bbm');
      expect(transposer.transposeKey('Am', 11), 'G#m');
    });

    test('an unreadable key comes back unchanged', () {
      expect(transposer.transposeKey('', 2), '');
      expect(transposer.transposeKey('???', 2), '???');
    });
  });

  group('transposeLyrics', () {
    test('moves every chord and leaves the words alone', () {
      final moved = transposer.transposeLyrics(
        '[G]Amazing [D]grace, how [G]sweet',
        2,
        'G',
      );

      expect(moved, '[A]Amazing [E]grace, how [A]sweet');
    });

    test('spells the result to match the new key', () {
      // G up one semitone is Ab, a flat key, so the chords use flats.
      final moved = transposer.transposeLyrics('[G]a [C]b', 1, 'G');

      expect(moved, '[Ab]a [Db]b');
    });

    test('handles slash chords inside lyrics', () {
      expect(transposer.transposeLyrics('[C/E]word', 2, 'C'), '[D/F#]word');
    });

    test('leaves an unclosed bracket alone', () {
      expect(transposer.transposeLyrics('[G oops', 2, 'C'), '[G oops');
    });

    test('zero semitones returns the same text', () {
      expect(transposer.transposeLyrics('[G]a', 0, 'G'), '[G]a');
    });
  });

  group('chordsUsed', () {
    test('lists the transposed chords once each', () {
      final chords = transposer.chordsUsed('[G]a [D]b [G]c', 2, 'G');

      expect(chords, ['A', 'E']);
    });
  });

  group('Indian notation is left alone', () {
    test('a swara marker survives a transpose unchanged', () {
      // Swaras are already relative to Sa, so moving the tonic moves them with
      // it — the written notation must not change.
      expect(
        transposer.transposeLyrics('[S]Krishna nee be[M]gane baro', 2, 'E'),
        '[S]Krishna nee be[M]gane baro',
      );
    });

    test('a swaram line is untouched', () {
      const swaram = 'Sa - Ri - Ga - Ma - | Pa - Dha - Ni - Sa -';

      expect(transposer.transposeLyrics(swaram, 5, 'C'), swaram);
    });

    test('a raga directive is untouched', () {
      expect(
        transposer.transposeLyrics('{raga: Yamunakalyani}', 3, 'E'),
        '{raga: Yamunakalyani}',
      );
    });

    test('Ga and Dha are not mistaken for G and D chords', () {
      // These two are the trap: a swara token read one letter at a time looks
      // like a Western chord, and used to come back as `[Aa]` and `[Eha]`.
      const sheet =
          '{raga: Yamunakalyani}\n'
          '[Sa]Varanasyaam Va[Ga]rada Na[Dha]yakham';

      expect(transposer.transposeLyrics(sheet, 2, 'C'), sheet);
    });

    test('single-letter Ga and Dha markers are safe too', () {
      const sheet =
          '{raga: Hamsadhvani}\n[S]Bhoothadi Sam[G]sevitha [D]Charanam';

      expect(transposer.transposeLyrics(sheet, 5, 'C'), sheet);
    });

    test('the stored tradition overrides a misspelt raga header', () {
      // This is the bug the tradition column exists to fix. `{ragam:}` is not
      // `{raga:}`, so sniffing the text calls this a Western song — and `[Ga]`
      // and `[Dha]` then read as the chords G and D and get rewritten. Passing
      // the song's saved tradition stops that.
      const sheet = '{ragam: Kalyani}\n[Ga]la la [Dha]la la';

      expect(transposer.transposeLyrics(sheet, 2, 'C', isIndian: true), sheet);
    });

    test('without the flag, a misspelt header still fools the sniffer', () {
      // Documents why the column is needed: the text alone cannot tell.
      const sheet = '{ragam: Kalyani}\n[Ga]la la [Dha]la la';

      final moved = transposer.transposeLyrics(sheet, 2, 'C');
      expect(moved, contains('[Aa]'));
      expect(moved, contains('[Eha]'));
    });

    test('isIndian: false transposes a Western song that mentions a raga', () {
      // The flag is the authority in both directions. A Western song whose
      // lyrics happen to contain a raga line is still a chord sheet.
      const sheet = '{raga: not really}\n[C]la la';

      expect(
        transposer.transposeLyrics(sheet, 2, 'C', isIndian: false),
        contains('[D]'),
      );
    });

    test('chordsUsed honours the stored tradition', () {
      const sheet = '{ragam: Kalyani}\n[Sa]la [Ma]la';

      expect(transposer.chordsUsed(sheet, 2, 'C', isIndian: true), [
        'Sa',
        'Ma',
      ]);
    });

    test('chordsUsed returns the swaras as written', () {
      const sheet =
          '{raga: Yamunakalyani}\n'
          '[Sa]Krishna nee be[Ma]gane baro';

      expect(transposer.chordsUsed(sheet, 2, 'E'), ['Sa', 'Ma']);
    });

    test('a Western song with the same letters still transposes', () {
      // The song decides, not the token: without a raga, `[G]` and `[D]` are
      // ordinary chords and must still move.
      expect(transposer.transposeLyrics('[G]a [D]b', 2, 'G'), '[A]a [E]b');
    });
  });

  group('useFlatsAfter', () {
    test('is true only for keys normally written with flats', () {
      expect(transposer.useFlatsAfter('G', 1), isTrue); // Ab
      expect(transposer.useFlatsAfter('C', 2), isFalse); // D
      expect(transposer.useFlatsAfter('Am', 1), isTrue); // Bb minor
      expect(transposer.useFlatsAfter('Am', 4), isFalse); // C# minor
    });
  });
}
