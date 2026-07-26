import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/metronome_calculator.dart';

void main() {
  const calc = MetronomeCalculator();

  group('secondsPerBeat', () {
    test('60 BPM is one beat per second', () {
      expect(calc.secondsPerBeat(60), 1.0);
    });

    test('120 BPM is half a second per beat', () {
      expect(calc.secondsPerBeat(120), 0.5);
    });

    test('zero or negative BPM has no beat', () {
      expect(calc.secondsPerBeat(0), 0);
      expect(calc.secondsPerBeat(-30), 0);
    });
  });

  group('beatIndexAt', () {
    test('counts whole beats that have passed at 120 BPM', () {
      // Half a second per beat.
      expect(calc.beatIndexAt(Duration.zero, 120), 0);
      expect(calc.beatIndexAt(const Duration(milliseconds: 250), 120), 0);
      expect(calc.beatIndexAt(const Duration(milliseconds: 500), 120), 1);
      expect(calc.beatIndexAt(const Duration(milliseconds: 999), 120), 1);
      expect(calc.beatIndexAt(const Duration(seconds: 1), 120), 2);
      expect(calc.beatIndexAt(const Duration(seconds: 2), 120), 4);
    });

    test('returns 0 for a non-positive BPM', () {
      expect(calc.beatIndexAt(const Duration(seconds: 5), 0), 0);
      expect(calc.beatIndexAt(const Duration(seconds: 5), -60), 0);
    });

    test('returns 0 for non-positive elapsed time', () {
      expect(calc.beatIndexAt(Duration.zero, 120), 0);
      expect(calc.beatIndexAt(const Duration(seconds: -1), 120), 0);
    });
  });
}
