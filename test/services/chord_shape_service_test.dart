import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/chord_shape_service.dart';

void main() {
  const service = ChordShapeService();

  group('guitarShape — open chords', () {
    test('gives the well-known open shapes', () {
      expect(service.guitarShape('C')!.frets, [-1, 3, 2, 0, 1, 0]);
      expect(service.guitarShape('G')!.frets, [3, 2, 0, 0, 0, 3]);
      expect(service.guitarShape('Am')!.frets, [-1, 0, 2, 2, 1, 0]);
      expect(service.guitarShape('E7')!.frets, [0, 2, 0, 1, 0, 0]);
      expect(service.guitarShape('D')!.frets, [-1, -1, 0, 2, 3, 2]);
    });

    test('trims surrounding spaces', () {
      expect(service.guitarShape('  C  ')!.frets, [-1, 3, 2, 0, 1, 0]);
    });
  });

  group('guitarShape — barre fallback', () {
    test('builds a valid six-string shape for a root with no open chord', () {
      final fSharp = service.guitarShape('F#');
      expect(fSharp, isNotNull);
      expect(fSharp!.frets.length, 6);
      // Every value is a mute, an open string, or a real fret.
      for (final f in fSharp.frets) {
        expect(f >= -1, isTrue);
      }
      // F# major sits at the 2nd fret as an E-shape barre.
      expect(fSharp.frets, [2, 4, 4, 3, 2, 2]);
    });

    test('covers minor, 7, m7 and maj7 for barre roots', () {
      expect(service.guitarShape('Bbm'), isNotNull);
      expect(service.guitarShape('F#7'), isNotNull);
      expect(service.guitarShape('C#m7'), isNotNull);
      expect(service.guitarShape('Abmaj7'), isNotNull);
    });

    test('uses the root chord for a slash chord', () {
      // C/E draws the C shape (the bass note only matters on the keyboard).
      expect(
        service.guitarShape('C/E')!.frets,
        service.guitarShape('C')!.frets,
      );
    });
  });

  group('guitarShape — bad input', () {
    test('returns null for text that is not a chord', () {
      expect(service.guitarShape(''), isNull);
      expect(service.guitarShape('?'), isNull);
      expect(service.guitarShape('H9'), isNull);
    });
  });

  group('harmoniumShape — notes', () {
    test('major triad', () {
      final c = service.harmoniumShape('C');
      expect(c.notes, [0, 4, 7]);
      expect(c.root, 0);
      expect(c.bass, isNull);
    });

    test('minor triad', () {
      final am = service.harmoniumShape('Am');
      expect(am.root, 9);
      expect(am.notes.toSet(), {9, 0, 4});
    });

    test('dominant 7 adds the flat seventh', () {
      expect(service.harmoniumShape('C7').notes.toSet(), {0, 4, 7, 10});
    });

    test('major 7 adds the major seventh', () {
      expect(service.harmoniumShape('Cmaj7').notes.toSet(), {0, 4, 7, 11});
    });

    test('reads maj7 as major-seventh, not major plus 7', () {
      final g = service.harmoniumShape('Gmaj7');
      expect(g.root, 7);
      // G B D F# = 7 11 2 6
      expect(g.notes.toSet(), {7, 11, 2, 6});
    });

    test('sus and dim qualities', () {
      expect(service.harmoniumShape('Dsus4').notes.toSet(), {2, 7, 9});
      expect(service.harmoniumShape('Bdim').notes.toSet(), {11, 2, 5});
    });

    test('records the bass note of a slash chord', () {
      final shape = service.harmoniumShape('C/E');
      expect(shape.root, 0);
      expect(shape.bass, 4);
      expect(shape.notes.toSet(), {0, 4, 7});
    });
  });

  group('harmoniumShape — bad input', () {
    test('falls back to the major triad, never throwing', () {
      final shape = service.harmoniumShape('?');
      expect(shape.notes, [0, 4, 7]);
      expect(shape.root, 0);
    });

    test('unknown quality falls back to major triad on the right root', () {
      final shape = service.harmoniumShape('Fzzz');
      expect(shape.root, 5);
      expect(shape.notes.toSet(), {5, 9, 0});
    });
  });
}
