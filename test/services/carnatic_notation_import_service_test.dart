import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/models/carnatic_import_result.dart';
import 'package:lyricchord/services/carnatic_notation_import_service.dart';
import 'package:lyricchord/services/melody_parser_service.dart';

/// The published notation for the sample song, first sangati of each section.
///
/// Underlined runs are written `_like_this_`, since an underline does not
/// survive a copy into plain text. See `docs/carnatic_notation.md` section 4.
const _pallavi =
    '; ; S | G , m | R ; || snrs nd | ; N | , R , ||\n'
    '; ; g m | R ; | S ; || dnrds , | ; ; | ; ; ||';

const _anupallavi =
    '; ; G | G R | G M || P ; ; | gm P | P ; ||\n'
    '; ; mp | D ; | D P || P ; , n | _dpP_ ; | mdpm ||';

void main() {
  const importer = CarnaticNotationImporter();
  const parser = MelodyParser();

  group('reading the pallavi', () {
    test('every cycle lands on misra chapu', () {
      final result = importer.convert(_pallavi, tala: 'Misra Chapu');

      expect(result.chosen.isPerfect, isTrue);
      expect(result.chosen.fitting, 4);
      expect(result.problems, isEmpty);
    });

    test('the opening avarta reads as the source says it should', () {
      // From the beat table in docs/carnatic_notation.md section 9:
      // two beats of rest, Sa on beat 3, Ga with its karvai on 4, Ma on 5,
      // Ri held across 6 and 7.
      final result = importer.convert(
        _pallavi,
        tala: 'Misra Chapu',
        applyAnyaSvaraRule: true,
      );

      expect(result.melodyLines.first, '{melody} , , Sa | Ga3 ,-Ma1 | Ri2 ,');
    });

    test('every line it produces is one our own parser accepts', () {
      final result = importer.convert(_pallavi, tala: 'Misra Chapu');

      expect(result.melodyLines, hasLength(4));
      for (final line in result.melodyLines) {
        final parsed = parser.parse(line);
        expect(parsed.problems, isEmpty, reason: line);
        expect(parsed.beatCount, 7, reason: line);
      }
    });
  });

  group('choosing between the two case conventions', () {
    test('krithi notation is read as durations, and says so', () {
      final result = importer.convert(_pallavi, tala: 'Misra Chapu');

      expect(result.chosen.reading, CarnaticCaseReading.duration);
      expect(result.chosen.isPerfect, isTrue);
      // The rejected reading is kept so a caller can show the evidence.
      expect(result.rejected!.reading, CarnaticCaseReading.octave);
      expect(result.rejected!.fitting, lessThan(result.chosen.fitting));
      expect(result.isAmbiguous, isFalse);
    });

    test('a beginner exercise in adi tala is read as octaves', () {
      // The sarali varisai convention: one akshara per letter, case marking the
      // octave. Under the duration reading these cycles do not add up.
      const sarali = 's r g m | p d | n S ||\nS n d p | m g | r s ||';

      final result = importer.convert(sarali, tala: 'Adi');

      expect(result.chosen.reading, CarnaticCaseReading.octave);
      expect(result.chosen.isPerfect, isTrue);
    });

    test('a tie is reported rather than presented as settled', () {
      // Every note uppercase, where the two readings happen to give the same
      // length. The arithmetic cannot separate them, so neither may be claimed.
      final result = importer.convert('S S S S S S S ||', tala: 'Misra Chapu');

      expect(result.isAmbiguous, isTrue);
      expect(result.problems.whereType<CarnaticReadingsTie>(), hasLength(1));
    });
  });

  group('the symbols', () {
    List<String> lines(String notation, {String tala = 'Misra Chapu'}) =>
        importer.convert(notation, tala: tala).melodyLines;

    test('a semicolon is a whole beat of rest', () {
      expect(lines('; ; S | G R | S ; ||').first, startsWith('{melody} , , '));
    });

    test('a comma lengthens the note before it, it does not add a beat', () {
      // `G , m` is three symbols filling two beats: Ga takes the first with its
      // karvai, Ma the second.
      final line = importer
          .convert('; ; S | G , m | R ; ||', tala: 'Misra Chapu')
          .melodyLines
          .first;
      expect(line, contains('| Ga3 ,-Ma2 |'));
    });

    test('letters written together share one beat', () {
      final line = lines('snrs nd | ; N | , R , ||').first;
      expect(line, startsWith('{melody} Sa-Ni3 Ri2-Sa Ni3-Da2'));
    });

    test('an underlined run is packed faster still', () {
      final result = importer.convert(_anupallavi, tala: 'Misra Chapu');
      expect(result.chosen.isPerfect, isTrue);
      expect(result.melodyLines.last, contains('Da2-Pa-Pa-,'));
    });

    test('a pause mark and an anya svara mark take no time', () {
      final withMarks = lines('; ; -S | G , m* | R ; ||');
      final without = lines('; ; S | G , m | R ; ||');
      expect(withMarks, equals(without));
    });
  });

  group('notes that cross a beat line', () {
    test('a note carried over is tied, not moved to the next beat', () {
      // `, R ,` puts Ri half a beat in and holds it across the bar. Before
      // slots existed this was snapped to the beat and lost half a beat.
      final result = importer.convert(_pallavi, tala: 'Misra Chapu');

      expect(result.melodyLines[1], contains(',-Ri2'));
      expect(result.chosen.isPerfect, isTrue);
      expect(result.problems, isEmpty);
    });

    test('nothing is reported as snapped any more', () {
      // Snapping a note to the beat used to be reported as a problem. There is
      // no such problem now, so a carried-over note reports nothing at all.
      final result = importer.convert(_pallavi, tala: 'Misra Chapu');

      expect(result.problems, isEmpty);
    });

    test('a note held over a bar keeps its full length', () {
      // `G , m` is Ga for a beat and a half, then Ma: Ga fills its own beat and
      // ties into half of the next.
      final result = importer.convert(
        _pallavi,
        tala: 'Misra Chapu',
        applyAnyaSvaraRule: true,
      );

      expect(result.melodyLines.first, '{melody} , , Sa | Ga3 ,-Ma1 | Ri2 ,');
    });
  });

  group('the anya svara rule', () {
    test('is off by default — the madhyamam is not guessed', () {
      final result = importer.convert(_pallavi, tala: 'Misra Chapu');

      expect(result.melodyLines.first, contains('Ma2'));
      expect(result.melodyLines.first, isNot(contains('Ma1')));
    });

    test('reports where the phrase appears even when off', () {
      final result = importer.convert(_pallavi, tala: 'Misra Chapu');

      expect(result.anyaSvaraHints, isNotEmpty);
    });

    test('switched on, shuddha madhyamam only inside Ga to Ma to Ri', () {
      final result = importer.convert(
        _pallavi,
        tala: 'Misra Chapu',
        applyAnyaSvaraRule: true,
      );
      // `G , m | R` is the descent, so that madhyamam is shuddha.
      expect(result.melodyLines.first, contains('Ma1'));
      // No line carries a shuddha madhyamam without the gandharam that licenses
      // it, so the borrowed note never drifts into a Pa/Da2 phrase.
      for (final line in result.melodyLines) {
        if (line.contains('Ma1')) {
          expect(line, contains('Ga3'), reason: line);
        }
      }
    });
  });

  group('bad input never throws', () {
    test('an unknown tala comes back as a problem', () {
      final result = importer.convert(_pallavi, tala: 'Nonsense');

      expect(result.hasLines, isFalse);
      final problem = result.problems.single;
      expect(problem, isA<CarnaticUnknownTala>());
      expect((problem as CarnaticUnknownTala).tala, 'Nonsense');
    });

    test('empty and junk input are handled', () {
      for (final junk in ['', '   ', '||', '\n\n', 'xyz qrs', '@@@ ###']) {
        final result = importer.convert(junk, tala: 'Misra Chapu');
        expect(result.problems, isNotEmpty, reason: 'for "$junk"');
      }
    });

    test('a cycle of the wrong length is reported, not silently accepted', () {
      final result = importer.convert('S S ||', tala: 'Misra Chapu');

      expect(result.chosen.isPerfect, isFalse);
      final wrong = result.problems.whereType<CarnaticWrongLength>().first;
      expect(wrong.cycle, 1);
      expect(wrong.wanted, 14);
    });
  });
}
