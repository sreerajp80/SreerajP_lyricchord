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

  group('beatInBar', () {
    test('accents every fourth beat in 4/4', () {
      final pattern = [for (var i = 0; i < 9; i++) calc.beatInBar(i, 4)];
      expect(pattern, [0, 1, 2, 3, 0, 1, 2, 3, 0]);
    });

    test('accents every third beat in 3/4', () {
      final pattern = [for (var i = 0; i < 7; i++) calc.beatInBar(i, 3)];
      expect(pattern, [0, 1, 2, 0, 1, 2, 0]);
    });

    test('one beat per bar or less means every beat is the accent', () {
      expect(calc.beatInBar(0, 1), 0);
      expect(calc.beatInBar(5, 1), 0);
      expect(calc.beatInBar(5, 0), 0);
      expect(calc.beatInBar(5, -2), 0);
    });

    test('a negative beat index is treated as the bar start', () {
      expect(calc.beatInBar(-1, 4), 0);
    });
  });

  group('displayBeat', () {
    test('counts 1-based like a musician would', () {
      final counted = [for (var i = 0; i < 5; i++) calc.displayBeat(i, 4)];
      expect(counted, [1, 2, 3, 4, 1]);
    });
  });

  group('offsetOfBeat', () {
    test('beat 4 at 120 BPM lands at 2 seconds', () {
      expect(calc.offsetOfBeat(4, 120), const Duration(seconds: 2));
    });

    test('beat 0 is the very start', () {
      expect(calc.offsetOfBeat(0, 120), Duration.zero);
    });

    test('a bad tempo or index gives zero', () {
      expect(calc.offsetOfBeat(4, 0), Duration.zero);
      expect(calc.offsetOfBeat(-4, 120), Duration.zero);
    });

    test('never drifts: beat 600 at 100 BPM is exactly 6 minutes', () {
      // The whole point of measuring from the start instead of adding up beats.
      expect(calc.offsetOfBeat(600, 100), const Duration(minutes: 6));
    });
  });

  group('timeUntilBeat', () {
    test('gives the wait left to the next beat', () {
      // At 120 BPM beat 2 is due at 1000 ms; we are at 600 ms.
      expect(
        calc.timeUntilBeat(2, 120, const Duration(milliseconds: 600)),
        const Duration(milliseconds: 400),
      );
    });

    test('a late beat is due right now, never a negative wait', () {
      expect(
        calc.timeUntilBeat(2, 120, const Duration(milliseconds: 1500)),
        Duration.zero,
      );
    });

    test('a late beat does not push the following beat back', () {
      // Beat 1 fired 30 ms late, at 530 ms. Beat 2 is still due at 1000 ms, so
      // the next wait shortens to 470 ms instead of staying a full 500 ms.
      final wait = calc.timeUntilBeat(
        2,
        120,
        const Duration(milliseconds: 530),
      );
      expect(wait, const Duration(milliseconds: 470));
    });
  });

  group('bpmFromTaps', () {
    test('fewer than two taps has no tempo yet', () {
      expect(calc.bpmFromTaps([]), isNull);
      expect(calc.bpmFromTaps([Duration.zero]), isNull);
    });

    test('two taps half a second apart is 120 BPM', () {
      expect(
        calc.bpmFromTaps([Duration.zero, const Duration(milliseconds: 500)]),
        120,
      );
    });

    test('averages uneven taps', () {
      // Gaps of 500, 600 and 520 ms average 540 ms -> about 111 BPM.
      final taps = [
        Duration.zero,
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 1100),
        const Duration(milliseconds: 1620),
      ];
      expect(calc.bpmFromTaps(taps), 111);
    });

    test('ignores a repeated tap at the same moment', () {
      final taps = [
        Duration.zero,
        Duration.zero,
        const Duration(milliseconds: 500),
      ];
      expect(calc.bpmFromTaps(taps), 120);
    });

    test('all taps at the same moment gives no tempo, not a crash', () {
      expect(calc.bpmFromTaps([Duration.zero, Duration.zero]), isNull);
    });

    test('very fast or very slow tapping is clamped to the allowed range', () {
      // 10 ms apart would be 6000 BPM.
      expect(
        calc.bpmFromTaps([Duration.zero, const Duration(milliseconds: 10)]),
        MetronomeCalculator.maxBpm,
      );
      // 10 seconds apart would be 6 BPM.
      expect(
        calc.bpmFromTaps([Duration.zero, const Duration(seconds: 10)]),
        MetronomeCalculator.minBpm,
      );
    });
  });

  group('flashDuration', () {
    test('uses a share of the beat at a slow tempo', () {
      // 60 BPM: a 1000 ms beat, 18% is 180 ms — well over the minimum.
      expect(calc.flashDuration(60), const Duration(milliseconds: 180));
    });

    test('never drops below the minimum at a fast tempo', () {
      // 300 BPM: a 200 ms beat, 18% is only 36 ms — too quick to see.
      expect(calc.flashDuration(300), const Duration(milliseconds: 60));
    });

    test('never lasts longer than the beat itself', () {
      // A beat shorter than the 60 ms minimum must still go dark in time.
      final flash = calc.flashDuration(
        120,
        portion: 0.1,
        minFlash: const Duration(seconds: 5),
      );
      expect(flash, lessThanOrEqualTo(const Duration(milliseconds: 500)));
    });

    test('a bad tempo has no flash', () {
      expect(calc.flashDuration(0), Duration.zero);
    });
  });
}
