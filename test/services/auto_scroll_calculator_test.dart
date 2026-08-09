import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/auto_scroll_calculator.dart';

void main() {
  const calc = AutoScrollCalculator();

  group('tempoDuration', () {
    test('turns measures and bpm into a length in 4/4', () {
      // 32 measures * 4 beats = 128 beats at 120 bpm = 64 seconds.
      expect(calc.tempoDuration(120, 32), const Duration(seconds: 64));
    });

    test('honours a different beats-per-measure', () {
      // 8 measures * 3 beats = 24 beats at 60 bpm = 24 seconds.
      expect(
        calc.tempoDuration(60, 8, beatsPerMeasure: 3),
        const Duration(seconds: 24),
      );
    });

    test('an Adi tala cycle is twice as long as a 4/4 measure', () {
      // Adi has 8 aksharas, not 4. Assuming common time made a classical song
      // scroll twice as fast as it should.
      final common = calc.tempoDuration(72, 16);
      final adi = calc.tempoDuration(72, 16, beatsPerMeasure: 8);

      // Compared with a tolerance: each duration is rounded to the nearest
      // microsecond on its own, so doubling one can differ by a microsecond.
      expect(adi.inMicroseconds, closeTo(common.inMicroseconds * 2, 2));
      // 16 cycles * 8 beats = 128 beats at 72 bpm.
      expect(adi.inMilliseconds, closeTo(128 * 60 / 72 * 1000, 1));
    });

    test('ends exactly at song end for an Adi tala song too', () {
      const contentExtent = 3210.0;
      final duration = calc.tempoDuration(68, 24, beatsPerMeasure: 8);
      final pxPerSec = calc.tempoPixelsPerSecond(contentExtent, duration);

      final seconds = duration.inMicroseconds / Duration.microsecondsPerSecond;
      expect(pxPerSec * seconds, closeTo(contentExtent, 0.001));
    });

    test('returns zero for inputs that make no real length', () {
      expect(calc.tempoDuration(0, 32), Duration.zero);
      expect(calc.tempoDuration(120, 0), Duration.zero);
      expect(calc.tempoDuration(-10, 32), Duration.zero);
      expect(calc.tempoDuration(120, 32, beatsPerMeasure: 0), Duration.zero);
    });
  });

  group('tempoPixelsPerSecond', () {
    test('spreads the content over the whole duration', () {
      // 1200 px over 60 s is 20 px/s.
      expect(calc.tempoPixelsPerSecond(1200, const Duration(seconds: 60)), 20);
    });

    test(
      'ends exactly at song end — px/s times seconds is the full length',
      () {
        const contentExtent = 4321.0;
        final duration = calc.tempoDuration(90, 48);
        final pxPerSec = calc.tempoPixelsPerSecond(contentExtent, duration);

        final seconds =
            duration.inMicroseconds / Duration.microsecondsPerSecond;
        final scrolled = pxPerSec * seconds;

        expect(scrolled, closeTo(contentExtent, 1e-6));
      },
    );

    test('returns zero when there is nothing or no time to scroll', () {
      expect(calc.tempoPixelsPerSecond(0, const Duration(seconds: 60)), 0);
      expect(calc.tempoPixelsPerSecond(1200, Duration.zero), 0);
    });
  });

  group('manualPixelsPerSecond', () {
    test('scales the base speed by the multiplier', () {
      const base = AutoScrollCalculator.baseManualPixelsPerSecond;
      expect(calc.manualPixelsPerSecond(1.0), base);
      expect(calc.manualPixelsPerSecond(0.5), base * 0.5);
      expect(calc.manualPixelsPerSecond(2.0), base * 2);
    });

    test('handles a fine step from the stepper', () {
      const base = AutoScrollCalculator.baseManualPixelsPerSecond;
      expect(calc.manualPixelsPerSecond(0.15), closeTo(base * 0.15, 1e-9));
      expect(calc.manualPixelsPerSecond(0.10), closeTo(base * 0.10, 1e-9));
    });

    test('returns zero for a non-positive multiplier', () {
      expect(calc.manualPixelsPerSecond(0), 0);
      expect(calc.manualPixelsPerSecond(-1), 0);
    });
  });
}
