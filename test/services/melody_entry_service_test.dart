import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/melody_entry_service.dart';
import 'package:lyricchord/services/melody_parser_service.dart';

void main() {
  const parser = MelodyParser();

  group('building a line', () {
    test('a note becomes its own beat', () {
      final entry = MelodyEntry.empty.addNote('Sa').addNote('Ga3');
      expect(entry.text, 'Sa Ga3');
    });

    test('the note keeps the spelling it was given', () {
      expect(MelodyEntry.empty.addNote('Ma2').text, 'Ma2');
      expect(MelodyEntry.empty.addNote('M2').text, 'M2');
    });

    test('hold and bar line are beats of their own', () {
      final entry = MelodyEntry.empty
          .addNote('Sa')
          .hold()
          .barLine()
          .addNote('Ri2');
      expect(entry.text, 'Sa , | Ri2');
    });

    test('share puts the next note in the same beat', () {
      final entry = MelodyEntry.empty
          .addNote('Ga3')
          .share()
          .addNote('Ma1')
          .addNote('Ri2');
      expect(entry.text, 'Ga3-Ma1 Ri2');
    });

    test('share can be used twice for three notes in one beat', () {
      final entry = MelodyEntry.empty
          .addNote('Ga3')
          .share()
          .addNote('Ri2')
          .share()
          .addNote('Sa');
      expect(entry.text, 'Ga3-Ri2-Sa');
    });

    test('a tie lets a note start part-way through a beat', () {
      final entry = MelodyEntry.empty.tie().addNote('Ri2');
      expect(entry.text, ',-Ri2');
    });

    test('silence stops a sound inside a beat', () {
      final entry = MelodyEntry.empty.addNote('Ri2').share().silence();
      expect(entry.text, 'Ri2-x');
    });

    test('nothing can share into a bar line', () {
      final entry = MelodyEntry.empty.addNote('Sa').barLine();
      expect(entry.canShare, isFalse);
      expect(entry.share().addNote('Ri2').text, 'Sa | Ri2');
    });

    test('sharing with nothing entered just starts a beat', () {
      expect(MelodyEntry.empty.share().addNote('Sa').text, 'Sa');
    });

    test('the line carries the melody directive', () {
      expect(MelodyEntry.empty.addNote('Sa').line, '{melody} Sa');
    });
  });

  group('marks on the last note', () {
    test('octave up and down are toggles', () {
      var entry = MelodyEntry.empty.addNote('Sa');

      entry = entry.toggle(MelodyMark.octaveUp);
      expect(entry.text, "Sa'");
      expect(entry.markActive(MelodyMark.octaveUp), isTrue);

      entry = entry.toggle(MelodyMark.octaveUp);
      expect(entry.text, 'Sa');
      expect(entry.markActive(MelodyMark.octaveUp), isFalse);

      entry = entry.toggle(MelodyMark.octaveDown);
      expect(entry.text, '.Sa');
      expect(entry.markActive(MelodyMark.octaveDown), isTrue);
    });

    test('the two octave marks cannot both be on', () {
      final entry = MelodyEntry.empty
          .addNote('Ni3')
          .toggle(MelodyMark.octaveDown)
          .toggle(MelodyMark.octaveUp);
      expect(entry.text, "Ni3'");
    });

    test('slide and shake sit outside the octave marks', () {
      final entry = MelodyEntry.empty
          .addNote('Ga3')
          .toggle(MelodyMark.octaveDown)
          .toggle(MelodyMark.slide)
          .toggle(MelodyMark.shake);
      expect(entry.text, '!.Ga3~');
    });

    test('shake comes off again', () {
      final entry = MelodyEntry.empty
          .addNote('Ga3')
          .toggle(MelodyMark.shake)
          .toggle(MelodyMark.shake);
      expect(entry.text, 'Ga3');
    });

    test('a mark lands on the shared note, not the whole beat', () {
      final entry = MelodyEntry.empty
          .addNote('Ga3')
          .share()
          .addNote('Ma1')
          .toggle(MelodyMark.octaveUp);
      expect(entry.text, "Ga3-Ma1'");
    });

    test('there is nothing to mark after a hold or a bar line', () {
      expect(MelodyEntry.empty.hold().canMarkLastNote, isFalse);
      expect(
        MelodyEntry.empty.addNote('Sa').barLine().canMarkLastNote,
        isFalse,
      );
      expect(MelodyEntry.empty.canMarkLastNote, isFalse);
    });

    test('marking when there is no note changes nothing', () {
      final entry = MelodyEntry.empty.hold();
      expect(entry.toggle(MelodyMark.shake).text, ',');
    });
  });

  group('backspace and clear', () {
    test('backspace drops an armed share first', () {
      final entry = MelodyEntry.empty.addNote('Sa').share().backspace();
      expect(entry.shareArmed, isFalse);
      expect(entry.text, 'Sa');
    });

    test('backspace drops one shared slot before the whole beat', () {
      var entry = MelodyEntry.empty.addNote('Ga3').share().addNote('Ma1');

      entry = entry.backspace();
      expect(entry.text, 'Ga3');

      entry = entry.backspace();
      expect(entry.text, '');
      expect(entry.isEmpty, isTrue);
    });

    test('backspace on an empty entry is safe', () {
      expect(MelodyEntry.empty.backspace().isEmpty, isTrue);
    });

    test('clear empties everything', () {
      final entry = MelodyEntry.empty.addNote('Sa').hold().clear();
      expect(entry.isEmpty, isTrue);
    });
  });

  group('reading a line back in', () {
    test('a written line loads with its tokens intact', () {
      final entry = MelodyEntry.fromLine('{melody} , , Sa | Ga3 Ma1 | Ri2 ,');
      expect(entry.tokens.length, 9);
      expect(entry.text, ', , Sa | Ga3 Ma1 | Ri2 ,');
    });

    test('the prefix is optional', () {
      expect(MelodyEntry.fromLine('Sa Ri2').text, 'Sa Ri2');
    });

    test('an empty line loads as empty', () {
      expect(MelodyEntry.fromLine('{melody}').isEmpty, isTrue);
      expect(MelodyEntry.fromLine('   ').isEmpty, isTrue);
    });

    test('a loaded line can be added to', () {
      final entry = MelodyEntry.fromLine('{melody} Sa').addNote('Ri2');
      expect(entry.text, 'Sa Ri2');
    });
  });

  group('everything the keypad writes can be played', () {
    test('a full line parses with no problems', () {
      final entry = MelodyEntry.empty
          .tie()
          .addNote('Sa')
          .hold()
          .barLine()
          .addNote('Ga3')
          .toggle(MelodyMark.slide)
          .share()
          .addNote('Ma1')
          .toggle(MelodyMark.octaveUp)
          .barLine()
          .addNote('Ri2')
          .toggle(MelodyMark.shake)
          .share()
          .silence();

      final line = parser.parse(entry.line);
      expect(line.problems, isEmpty);
      // Four beats: the tie beat, the hold, the shared Ga3-Ma1, and Ri2-x.
      // Bar lines take no time.
      expect(line.beatCount, 4);
    });

    test('every swara on the pad parses', () {
      const swaras = [
        'S',
        'R1',
        'R2',
        'R3',
        'G1',
        'G2',
        'G3',
        'M1',
        'M2',
        'P',
        'D1',
        'D2',
        'D3',
        'N1',
        'N2',
        'N3',
      ];

      for (final swara in swaras) {
        for (final mark in MelodyMark.values) {
          final entry = MelodyEntry.empty.addNote(swara).toggle(mark);
          final line = parser.parse(entry.line);
          expect(
            line.problems,
            isEmpty,
            reason: '"${entry.text}" should be readable',
          );
          expect(line.beatCount, 1, reason: '"${entry.text}" is one beat');
        }
      }
    });

    test('an octave mark actually moves the note', () {
      final up = parser.parse(
        MelodyEntry.empty.addNote('Sa').toggle(MelodyMark.octaveUp).line,
      );
      final down = parser.parse(
        MelodyEntry.empty.addNote('Sa').toggle(MelodyMark.octaveDown).line,
      );

      expect(up.beats.first.notes.first.semitonesFromSa, 12);
      expect(down.beats.first.notes.first.semitonesFromSa, -12);
    });

    test('the slide and shake marks reach the note', () {
      final line = parser.parse(
        MelodyEntry.empty
            .addNote('Ga3')
            .toggle(MelodyMark.slide)
            .toggle(MelodyMark.shake)
            .line,
      );

      final note = line.beats.first.notes.first;
      expect(note.slide, isTrue);
      expect(note.shake, isTrue);
    });
  });
}
