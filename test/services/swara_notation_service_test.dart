import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/services/swara_notation_service.dart';

void main() {
  const swara = SwaraNotation();

  group('swaraPosition', () {
    test('the full names are the shuddha (natural) positions', () {
      expect(swara.swaraPosition('Sa'), 0);
      expect(swara.swaraPosition('Ri'), 2);
      expect(swara.swaraPosition('Re'), 2);
      expect(swara.swaraPosition('Ga'), 4);
      expect(swara.swaraPosition('Ma'), 5);
      expect(swara.swaraPosition('Pa'), 7);
      expect(swara.swaraPosition('Dha'), 9);
      expect(swara.swaraPosition('Ni'), 11);
    });

    test('an uppercase single letter is shuddha', () {
      expect(swara.swaraPosition('S'), 0);
      expect(swara.swaraPosition('R'), 2);
      expect(swara.swaraPosition('G'), 4);
      expect(swara.swaraPosition('P'), 7);
      expect(swara.swaraPosition('D'), 9);
      expect(swara.swaraPosition('N'), 11);
    });

    test('a lowercase single letter is komal', () {
      expect(swara.swaraPosition('r'), 1);
      expect(swara.swaraPosition('g'), 3);
      expect(swara.swaraPosition('d'), 8);
      expect(swara.swaraPosition('n'), 10);
    });

    test('Sa, Pa and Ma have no komal form', () {
      // Lowering them would land on a different swara, so they stay put. This
      // is why `m` is still shuddha Ma and not Ga.
      expect(swara.swaraPosition('s'), 0);
      expect(swara.swaraPosition('p'), 7);
      expect(swara.swaraPosition('m'), 5);
    });

    test('M means shuddha Ma, not tivra', () {
      // Strict Hindustani shorthand reads M as tivra, but this app shipped
      // `[M]` meaning the ordinary Ma and users have that text on their phones.
      expect(swara.swaraPosition('M'), 5);
      expect(swara.swaraPosition('Ma'), 5);
    });

    test('tivra Ma is written M2, M-apostrophe or "Ma tivra"', () {
      expect(swara.swaraPosition('M2'), 6);
      expect(swara.swaraPosition("M'"), 6);
      expect(swara.swaraPosition('Ma tivra'), 6);
      expect(swara.swaraPosition('Ma teevra'), 6);
    });

    test('an explicit "komal" suffix lowers the note', () {
      expect(swara.swaraPosition('Ga komal'), 3);
      expect(swara.swaraPosition('Ni komal'), 10);
      expect(swara.swaraPosition('Ri komal'), 1);
    });

    test('the Carnatic numbered swaras read exactly', () {
      expect(swara.swaraPosition('R1'), 1);
      expect(swara.swaraPosition('R2'), 2);
      expect(swara.swaraPosition('R3'), 3);
      expect(swara.swaraPosition('G1'), 2);
      expect(swara.swaraPosition('G2'), 3);
      expect(swara.swaraPosition('G3'), 4);
      expect(swara.swaraPosition('M1'), 5);
      expect(swara.swaraPosition('D1'), 8);
      expect(swara.swaraPosition('D2'), 9);
      expect(swara.swaraPosition('D3'), 10);
      expect(swara.swaraPosition('N1'), 9);
      expect(swara.swaraPosition('N2'), 10);
      expect(swara.swaraPosition('N3'), 11);
    });

    test('a digit beats the case rule', () {
      // `r1` is the Carnatic R1, not "lowercase r made komal twice".
      expect(swara.swaraPosition('r1'), 1);
      expect(swara.swaraPosition('R₂'), 2);
    });

    test('two names for the same key agree', () {
      // R3 and G2 are one key, named differently depending on the raga.
      expect(swara.swaraPosition('R3'), swara.swaraPosition('G2'));
      expect(swara.swaraPosition('D3'), swara.swaraPosition('N2'));
    });

    test('octave marks do not change the position', () {
      expect(swara.swaraPosition('.P'), 7);
      expect(swara.swaraPosition('S.'), 0);
    });

    test('every position is reachable, and none is out of range', () {
      const written = [
        'Sa',
        'r',
        'R',
        'g',
        'G',
        'Ma',
        'M2',
        'Pa',
        'd',
        'D',
        'n',
        'N',
      ];
      final positions = written.map(swara.swaraPosition).toList();

      expect(positions, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
    });

    test('anything that is not a swara returns null, never a guess', () {
      expect(swara.swaraPosition('C'), isNull);
      expect(swara.swaraPosition('Am7'), isNull);
      expect(swara.swaraPosition('Verse'), isNull);
      expect(swara.swaraPosition(''), isNull);
      expect(swara.swaraPosition('   '), isNull);
      expect(swara.swaraPosition('R9'), isNull);
    });
  });

  group('isSwaraToken', () {
    test('accepts short symbols in either case', () {
      for (final symbol in SwaraNotation.swaraSymbols) {
        expect(swara.isSwaraToken(symbol), isTrue, reason: symbol);
        expect(swara.isSwaraToken(symbol.toLowerCase()), isTrue);
      }
    });

    test('accepts full names and common alternative spellings', () {
      for (final name in SwaraNotation.swaraFullNames) {
        expect(swara.isSwaraToken(name), isTrue, reason: name);
      }
      expect(swara.isSwaraToken('Re'), isTrue); // Hindustani spelling of Ri
      expect(swara.isSwaraToken('Dh'), isTrue); // short Dha
      expect(swara.isSwaraToken('sa'), isTrue);
    });

    test('ignores octave and variant marks', () {
      expect(swara.isSwaraToken("S'"), isTrue);
      expect(swara.isSwaraToken('.P'), isTrue);
      expect(swara.isSwaraToken('R1'), isTrue);
      expect(swara.isSwaraToken('M₂'), isTrue);
    });

    test('rejects Western chords and ordinary words', () {
      for (final text in ['C', 'F#m', 'B7', 'Am', 'Krishna', 'Pallavi:', '']) {
        expect(swara.isSwaraToken(text), isFalse, reason: text);
      }
    });
  });

  group('isSwaramLine', () {
    test('accepts a swaram passage with dashes and bar lines', () {
      expect(
        swara.isSwaramLine('Sa - Ri - Ga - Ma - | Pa - Dha - Ni - Sa -'),
        isTrue,
      );
      expect(swara.isSwaramLine('S R G M P D N'), isTrue);
    });

    test('rejects lyrics and an empty line', () {
      expect(swara.isSwaramLine('Krishna nee begane baro'), isFalse);
      expect(swara.isSwaramLine('Swaram:'), isFalse);
      // A line of separators alone has no swaras in it.
      expect(swara.isSwaramLine('- - |'), isFalse);
      expect(swara.isSwaramLine(''), isFalse);
    });

    test('rejects a line where only some tokens are swaras', () {
      expect(swara.isSwaramLine('Sa - Ri - and then Ga'), isFalse);
    });
  });

  group('talaBeats', () {
    test('knows the Carnatic talas', () {
      expect(swara.talaBeats('Adi'), 8);
      expect(swara.talaBeats('Rupaka'), 6);
      expect(swara.talaBeats('Misra Chapu'), 7);
      expect(swara.talaBeats('Khanda Chapu'), 5);
      expect(swara.talaBeats('Ata'), 14);
      expect(swara.talaBeats('Jhampa'), 10);
    });

    test('knows the Hindustani talas', () {
      expect(swara.talaBeats('Teental'), 16);
      expect(swara.talaBeats('Ektal'), 12);
      expect(swara.talaBeats('Jhaptal'), 10);
      expect(swara.talaBeats('Keherwa'), 8);
      expect(swara.talaBeats('Dadra'), 6);
      expect(swara.talaBeats('Rupak'), 7);
    });

    test('ignores case and a trailing tala/talam word', () {
      expect(swara.talaBeats('ADI'), 8);
      expect(swara.talaBeats('adi talam'), 8);
      expect(swara.talaBeats('Adi Tala'), 8);
      expect(swara.talaBeats('  misra chapu taalam  '), 7);
    });

    test('returns null for an unknown or empty tala', () {
      expect(swara.talaBeats('Nonsense'), isNull);
      expect(swara.talaBeats(''), isNull);
      expect(swara.talaBeats('tala'), isNull);
    });
  });

  group('full name with a variant digit', () {
    const swara = SwaraNotation();

    test('reads the same as the short letter form', () {
      for (final pair in const [
        ['Ma1', 'M1'],
        ['Ma2', 'M2'],
        ['Ri1', 'R1'],
        ['Ri2', 'R2'],
        ['Ri3', 'R3'],
        ['Re2', 'R2'],
        ['Ga1', 'G1'],
        ['Ga3', 'G3'],
        ['Dha2', 'D2'],
        ['Ni3', 'N3'],
      ]) {
        expect(
          swara.swaraPosition(pair[0]),
          swara.swaraPosition(pair[1]),
          reason: '${pair[0]} should equal ${pair[1]}',
        );
        expect(swara.swaraPosition(pair[0]), isNotNull, reason: pair[0]);
      }
    });

    test('is case-insensitive', () {
      expect(swara.swaraPosition('ma2'), 6);
      expect(swara.swaraPosition('MA2'), 6);
    });

    test('a bare full name is still the plain row', () {
      expect(swara.swaraPosition('Ma'), 5);
      expect(swara.swaraPosition('Ri'), 2);
      expect(swara.swaraPosition('Ga'), 4);
    });

    test('an unknown name with a digit is still unreadable', () {
      expect(swara.swaraPosition('Xy2'), isNull);
      expect(swara.swaraPosition('Ma9'), isNull);
    });
  });

  group('the Da spelling of Dha', () {
    const swara = SwaraNotation();

    test('Da places where Dha does', () {
      expect(swara.swaraPosition('Da'), 9);
      expect(swara.swaraPosition('Da'), swara.swaraPosition('Dha'));
    });

    test('Da2 means the same note as Dha2 and D2', () {
      expect(swara.swaraPosition('Da2'), 9);
      expect(swara.swaraPosition('Da2'), swara.swaraPosition('Dha2'));
      expect(swara.swaraPosition('Da2'), swara.swaraPosition('D2'));
    });

    test('Da1 and Da3 keep their variant', () {
      expect(swara.swaraPosition('Da1'), swara.swaraPosition('D1'));
      expect(swara.swaraPosition('Da3'), swara.swaraPosition('D3'));
    });

    test('Da is a swara token, with or without a digit', () {
      expect(swara.isSwaraToken('Da'), isTrue);
      expect(swara.isSwaraToken('Da2'), isTrue);
    });

    test('a swaram line written with Da is still recognised', () {
      expect(
        swara.isSwaramLine('Sa - Ri2 - Ga3 - Ma2 - Pa - Da2 - Ni3 - Sa -'),
        isTrue,
      );
    });

    test('the older spellings still work', () {
      expect(swara.swaraPosition('Dha2'), 9);
      expect(swara.swaraPosition('Dh'), 9);
      expect(swara.swaraPosition('D'), 9);
      expect(swara.isSwaraToken('Dha'), isTrue);
    });
  });
}
