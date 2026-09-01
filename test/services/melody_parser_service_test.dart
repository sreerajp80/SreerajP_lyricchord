import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/models/melody_beat.dart';
import 'package:lyricchord/services/melody_player_service.dart';
import 'package:lyricchord/services/melody_parser_service.dart';

void main() {
  const parser = MelodyParser();

  group('isMelodyLine', () {
    test('recognises the directive', () {
      expect(parser.isMelodyLine('{melody} S R G'), isTrue);
      expect(parser.isMelodyLine('  {Melody} S R G'), isTrue);
      expect(parser.isMelodyLine('{melody: S R G}'), isTrue);
    });

    test('leaves ordinary lines alone', () {
      expect(parser.isMelodyLine('[Sa]Krishna nee begane baro'), isFalse);
      expect(parser.isMelodyLine('{raga: Yamunakalyani}'), isFalse);
      expect(parser.isMelodyLine('Pallavi:'), isFalse);
      expect(parser.isMelodyLine(''), isFalse);
    });
  });

  group('stripPrefix', () {
    test('takes off both spellings', () {
      expect(parser.stripPrefix('{melody} S R G'), 'S R G');
      expect(parser.stripPrefix('{melody: S R G}'), 'S R G');
    });

    test('returns a non-melody line untouched', () {
      expect(parser.stripPrefix('Pallavi:'), 'Pallavi:');
    });
  });

  group('beats', () {
    test('reads plain swaras, one per beat', () {
      final line = parser.parse('{melody} S R G M P');
      expect(line.beatCount, 5);
      expect(line.problems, isEmpty);
      expect(line.beats.first.notes.single.position, 0);
      expect(line.beats[1].notes.single.position, 2); // Ri from the plain row
      expect(line.beats[2].notes.single.position, 4); // Ga from the plain row
      expect(line.beats[3].notes.single.position, 5); // Ma alone is Ma1
      expect(line.beats[4].notes.single.position, 7);
    });

    test('a comma holds and takes a beat', () {
      final line = parser.parse('{melody} S , R G');
      expect(line.beatCount, 4);
      expect(line.beats[1].kind, MelodyBeatKind.hold);
    });

    test('a bar line takes no time', () {
      final line = parser.parse('{melody} P , M | G , | R S');
      expect(line.beats.length, 9);
      expect(line.beatCount, 7);
      expect(
        line.beats.where((b) => b.kind == MelodyBeatKind.barLine).length,
        2,
      );
    });
  });

  group('variants', () {
    test('digits name the exact note', () {
      final line = parser.parse('{melody} R1 R2 R3 G3 M1 M2 D2 N3');
      final positions = line.beats.map((b) => b.notes.single.position).toList();
      expect(positions, [1, 2, 3, 4, 5, 6, 9, 11]);
    });

    test('a full name with a digit means the same as the letter', () {
      final full = parser.parse('{melody} Ma2 Ri2 Dha2 Ni3');
      final short = parser.parse('{melody} M2 R2 D2 N3');
      expect(
        full.beats.map((b) => b.notes.single.position).toList(),
        short.beats.map((b) => b.notes.single.position).toList(),
      );
    });

    test('a bare name is the plain row, so Ma is Ma1', () {
      expect(parser.parse('{melody} Ma').beats.single.notes.single.position, 5);
      expect(parser.parse('{melody} M').beats.single.notes.single.position, 5);
    });
  });

  group('octaves', () {
    test('a leading dot drops an octave', () {
      final note = parser.parse('{melody} .N3').beats.single.notes.single;
      expect(note.octave, -1);
      expect(note.position, 11);
      expect(note.semitonesFromSa, -1);
    });

    test('a trailing mark raises an octave', () {
      for (final written in ["S'", 'S^']) {
        final note = parser
            .parse('{melody} $written')
            .beats
            .single
            .notes
            .single;
        expect(note.octave, 1, reason: written);
        expect(note.semitonesFromSa, 12, reason: written);
      }
    });

    test("M' is upper Ma1, not tivra Ma", () {
      final note = parser.parse("{melody} M'").beats.single.notes.single;
      expect(note.position, 5);
      expect(note.octave, 1);
    });
  });

  group('shared beats', () {
    test('a hyphen splits the beat evenly', () {
      final beat = parser.parse('{melody} G3-R2').beats.single;
      expect(beat.notes.length, 2);
      expect(beat.totalSlots, 2);
      expect(beat.slotsAt(0), 1);
      expect(beat.slotsAt(1), 1);
    });

    test('four notes in one beat still count as one beat', () {
      final line = parser.parse('{melody} M2-G3-R2-S');
      expect(line.beatCount, 1);
      expect(line.beats.single.totalSlots, 4);
    });

    test('a comma inside a group extends the note before it', () {
      final beat = parser.parse('{melody} G3-,-R2').beats.single;
      expect(beat.notes.length, 2);
      expect(beat.slotsAt(0), 2);
      expect(beat.slotsAt(1), 1);
      expect(beat.totalSlots, 3);
    });
  });

  group('gamaka marks', () {
    test('a tilde shakes the note', () {
      final note = parser.parse('{melody} G3~').beats.single.notes.single;
      expect(note.shake, isTrue);
      expect(note.position, 4);
    });

    test('a bare bang slides in with no named start', () {
      final note = parser.parse('{melody} !G3').beats.single.notes.single;
      expect(note.slide, isTrue);
      expect(note.slideFrom, isNull);
    });

    test('a named start is kept, with its own octave', () {
      final note = parser.parse('{melody} M2!G3').beats.single.notes.single;
      expect(note.slide, isTrue);
      expect(note.slideFrom!.position, 6);
      expect(note.position, 4);
    });

    test('slide and shake combine', () {
      final note = parser.parse('{melody} M2!G3~').beats.single.notes.single;
      expect(note.slide, isTrue);
      expect(note.slideFrom!.position, 6);
      expect(note.shake, isTrue);
      expect(note.position, 4);
    });

    test('marks work inside a shared beat', () {
      final beat = parser.parse('{melody} !G3~-R2').beats.single;
      expect(beat.notes.length, 2);
      expect(beat.notes.first.slide, isTrue);
      expect(beat.notes.first.shake, isTrue);
      expect(beat.notes.last.position, 2);
    });
  });

  group('bad input never throws', () {
    const rubbish = [
      '{melody} X Y Z',
      '{melody} ---',
      '{melody} !!!',
      '{melody} S!!R',
      '{melody} ~',
      '{melody} !',
      '{melody} ,,,',
      '{melody} |||',
      '{melody} S- -R',
      '{melody} R9 G7 M5',
      '{melody} .....',
      "{melody} '''",
      '{melody} S R [C] G',
      '{melody}',
      '{melody} \t\t  ',
      '{melody} Krishna nee begane baro',
    ];

    for (final line in rubbish) {
      test('survives "$line"', () {
        expect(() => parser.parse(line), returnsNormally);
      });
    }

    test('an unreadable token keeps its place in the line', () {
      final line = parser.parse('{melody} S Q G');
      expect(line.beats.length, 3);
      expect(line.beats[1].kind, MelodyBeatKind.unknown);
      expect(line.beats[2].notes.single.position, 4);
      expect(line.hasProblems, isTrue);
    });

    test('an empty line has nothing to play', () {
      final line = parser.parse('{melody}');
      expect(line.isEmpty, isTrue);
      expect(line.beatCount, 0);
    });
  });

  group('fitsTala', () {
    test('catches a line that is the wrong length', () {
      expect(parser.parse('{melody} P , M | G , | R S').fitsTala(7), isTrue);
      expect(parser.parse('{melody} P , M | G , | R S ,').fitsTala(7), isFalse);
      expect(parser.parse('{melody} S , R G | M , | , ,').fitsTala(8), isTrue);
    });

    test('stays quiet when the tala is unknown', () {
      expect(parser.parse('{melody} S R G').fitsTala(null), isNull);
      expect(parser.parse('{melody} S R G').fitsTala(0), isNull);
    });

    test('a line covering two cycles still fits', () {
      expect(parser.parse('{melody} S R G M P D N S').fitsTala(4), isTrue);
    });
  });

  group('notes that start or stop inside a beat', () {
    const parser = MelodyParser();

    test('a leading comma ties the beat to what came before', () {
      // `,-Ri2` is half a beat carrying the previous sound on, then Ri.
      final beat = parser.parse('{melody} Sa ,-Ri2').beats.last;

      expect(beat.parts, hasLength(2));
      expect(beat.parts.first.kind, MelodySlotKind.tie);
      expect(beat.parts.last.kind, MelodySlotKind.note);
      expect(beat.parts.last.note!.text, 'Ri2');
      expect(beat.totalSlots, 2);
    });

    test('a tie does not strike the note again', () {
      const player = MelodyPlayerService();
      final schedule = player.schedule(
        parser.parse('{melody} Sa ,-Ri2'),
        tonicHz: 240,
        tempoBpm: 60,
      );

      // Sa, then Ri — two sounds, not three. The tie lengthens Sa instead of
      // adding a strike of its own.
      final struck = schedule.spans.where((s) => !s.isSilence).length;
      expect(struck, 2);
      // Sa runs a beat and a half: its own beat plus the tied half.
      expect(schedule.spans.first.duration.inMilliseconds, closeTo(1500, 50));
    });

    test('x is a silent slot and stops the sound', () {
      final beat = parser.parse('{melody} Ri2-x').beats.single;

      expect(beat.parts, hasLength(2));
      expect(beat.parts.first.kind, MelodySlotKind.note);
      expect(beat.parts.last.kind, MelodySlotKind.silence);
    });

    test('a silent slot takes its share of the beat', () {
      const player = MelodyPlayerService();
      final schedule = player.schedule(
        parser.parse('{melody} Ri2-x'),
        tonicHz: 240,
        tempoBpm: 60,
      );

      expect(schedule.spans, hasLength(2));
      expect(schedule.spans.first.isSilence, isFalse);
      expect(schedule.spans.last.isSilence, isTrue);
      expect(schedule.spans.first.duration.inMilliseconds, closeTo(500, 50));
      expect(schedule.spans.last.duration.inMilliseconds, closeTo(500, 50));
    });

    test('X reads the same as x, while keeping the writer spelling', () {
      final upper = parser.parse('{melody} Ri2-X').beats.single;
      final lower = parser.parse('{melody} Ri2-x').beats.single;

      expect(upper.parts, lower.parts);
      // The beat still shows what was typed, so the grid draws it back.
      expect(upper.text, 'Ri2-X');
      expect(lower.text, 'Ri2-x');
    });

    test('a comma after a note still extends it, as it always did', () {
      final beat = parser.parse('{melody} Ga3-,-Ri2').beats.single;

      expect(beat.notes.map((n) => n.text), ['Ga3', 'Ri2']);
      expect(beat.slots, [2, 1]);
      expect(beat.totalSlots, 3);
    });
  });

  group('symbols from published notation', () {
    const parser = MelodyParser();

    test('a semicolon holds a beat, the same as a comma', () {
      final withSemis = parser.parse('{melody} ; ; Sa | Ga3 Ma1 | Ri2 ;');
      final withCommas = parser.parse('{melody} , , Sa | Ga3 Ma1 | Ri2 ,');

      expect(withSemis.problems, isEmpty);
      expect(withSemis.beatCount, 7);
      expect(
        withSemis.beats.map((b) => b.notes.map((n) => n.position).toList()),
        withCommas.beats.map((b) => b.notes.map((n) => n.position).toList()),
      );
    });

    test('an anya svara star does not make the note unreadable', () {
      final marked = parser.parse('{melody} , , Sa | Ga3 Ma1* | Ri2 ,');
      final plain = parser.parse('{melody} , , Sa | Ga3 Ma1 | Ri2 ,');

      expect(marked.problems, isEmpty);
      expect(marked.beatCount, 7);
      expect(
        marked.beats.map((b) => b.notes.map((n) => n.position).toList()),
        plain.beats.map((b) => b.notes.map((n) => n.position).toList()),
      );
    });

    test('a star on its own is still unreadable', () {
      expect(parser.parse('{melody} * , Sa').problems, isNotEmpty);
    });
  });

  group('full swara names', () {
    const parser = MelodyParser();

    test('a full-name line reads the same as the short-letter line', () {
      final full = parser.parse('{melody} Pa , Ma2 | Ga3 Ri2 | Sa ,');
      final short = parser.parse('{melody} P , M2 | G3 R2 | S ,');

      expect(full.problems, isEmpty);
      expect(full.beatCount, short.beatCount);
      expect(
        full.beats.map((b) => b.notes.map((n) => n.position).toList()),
        short.beats.map((b) => b.notes.map((n) => n.position).toList()),
      );
    });

    test('Da2 reads as the same note as D2', () {
      final withDa = parser.parse('{melody} Ga3 Ma2 Pa | Da2 Pa | Ma2 Ga3');
      final withD = parser.parse('{melody} G3 M2 P | D2 P | M2 G3');

      expect(withDa.problems, isEmpty);
      expect(
        withDa.beats.map((b) => b.notes.map((n) => n.position).toList()),
        withD.beats.map((b) => b.notes.map((n) => n.position).toList()),
      );
    });

    test('full names carry their octave marks', () {
      final line = parser.parse("{melody} Pa Da2 Ni3 | Sa' , | Ni3 Da2");

      expect(line.problems, isEmpty);
      expect(line.beatCount, 7);
      // The fourth beat is upper Sa.
      final upper = line.beats.firstWhere(
        (b) => b.notes.isNotEmpty && b.notes.first.octave == 1,
      );
      expect(upper.notes.first.position, 0);
    });
  });
}
