/// Pure beat math for the metronome.
///
/// Like [AutoScrollCalculator], this has no Flutter imports: it only turns a
/// tempo and an elapsed time into beat numbers, so the "one beat per
/// 60/bpm seconds" rule can be unit-tested without a widget. The widget owns the
/// `Ticker`, the sound, and the flash; this owns the arithmetic.
class MetronomeCalculator {
  const MetronomeCalculator();

  /// Slowest and fastest tempo the metronome accepts.
  static const int minBpm = 30;
  static const int maxBpm = 300;

  /// How long one beat lasts at [bpm] beats per minute, in seconds.
  ///
  /// Returns `0` when [bpm] is not positive, which the caller reads as "no
  /// valid beat" (the start button is disabled).
  double secondsPerBeat(int bpm) {
    if (bpm <= 0) return 0;
    return 60 / bpm;
  }

  /// How many whole beats have passed after [elapsed] time at [bpm].
  ///
  /// Beat 0 is the instant the metronome starts; the first tick fires when the
  /// count crosses to 1. Returns `0` for a non-positive bpm or elapsed time, so
  /// a bad tempo never fires a beat.
  int beatIndexAt(Duration elapsed, int bpm) {
    final perBeat = secondsPerBeat(bpm);
    if (perBeat <= 0) return 0;
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    if (seconds <= 0) return 0;
    return seconds ~/ perBeat;
  }

  /// Where [beatIndex] sits inside its bar, counting from 0.
  ///
  /// 0 means the accented beat 1 of the bar. With [beatsPerBar] of 4 the run of
  /// beats 0,1,2,3,4,5 gives 0,1,2,3,0,1 — so the accent lands on every fourth
  /// beat. A [beatsPerBar] of 1 or less means "no bars", so everything is 0.
  int beatInBar(int beatIndex, int beatsPerBar) {
    if (beatsPerBar <= 1) return 0;
    if (beatIndex <= 0) return 0;
    return beatIndex % beatsPerBar;
  }

  /// The beat number a musician would count out loud for [beatIndex]: 1-based.
  ///
  /// With [beatsPerBar] of 4 this counts 1,2,3,4,1,2,3,4 …
  int displayBeat(int beatIndex, int beatsPerBar) =>
      beatInBar(beatIndex, beatsPerBar) + 1;

  /// How long after the start [beatIndex] falls.
  ///
  /// Always measured from the start, never by adding one beat to the last one,
  /// so small errors cannot pile up over a long song. Returns
  /// [Duration.zero] for a bad tempo or a negative index.
  Duration offsetOfBeat(int beatIndex, int bpm) {
    final perBeat = secondsPerBeat(bpm);
    if (perBeat <= 0 || beatIndex <= 0) return Duration.zero;
    final micros = beatIndex * perBeat * Duration.microsecondsPerSecond;
    return Duration(microseconds: micros.round());
  }

  /// How long to wait, from [elapsed], until beat number [beatIndex] is due.
  ///
  /// Used to arm a timer for the *next* beat instead of waiting for a screen
  /// frame to notice the beat already went past. Never negative: a beat that is
  /// already late is due right now ([Duration.zero]).
  Duration timeUntilBeat(int beatIndex, int bpm, Duration elapsed) {
    final target = offsetOfBeat(beatIndex, bpm);
    final remaining = target - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Works out a tempo from the gaps between tap-tempo taps.
  ///
  /// [taps] are the moments the user tapped, oldest first. Two taps give one
  /// gap, so anything shorter than two taps has no tempo yet and returns `null`.
  /// The gaps are averaged, which steadies an uneven hand, and the result is
  /// clamped to [minBpm]–[maxBpm]. Gaps of zero (a double-registered tap) are
  /// skipped rather than dividing by zero.
  int? bpmFromTaps(List<Duration> taps) {
    if (taps.length < 2) return null;

    var total = 0;
    var count = 0;
    for (var i = 1; i < taps.length; i++) {
      final gap = (taps[i] - taps[i - 1]).inMicroseconds;
      if (gap <= 0) continue;
      total += gap;
      count++;
    }
    if (count == 0) return null;

    final averageSeconds = (total / count) / Duration.microsecondsPerSecond;
    final bpm = (60 / averageSeconds).round();
    return bpm.clamp(minBpm, maxBpm);
  }

  /// How long the flash should stay lit for one beat at [bpm].
  ///
  /// A fixed share of the beat becomes only two or three screen frames at a fast
  /// tempo — easy to miss — so the pulse never drops below [minFlash], while
  /// still never running past the beat itself.
  Duration flashDuration(
    int bpm, {
    double portion = 0.18,
    Duration minFlash = const Duration(milliseconds: 60),
  }) {
    final perBeat = secondsPerBeat(bpm);
    if (perBeat <= 0) return Duration.zero;

    final beat = Duration(
      microseconds: (perBeat * Duration.microsecondsPerSecond).round(),
    );
    final share = Duration(
      microseconds: (perBeat * portion * Duration.microsecondsPerSecond)
          .round(),
    );
    if (share >= minFlash) return share;
    // Never light longer than the beat, or the flash would never go dark.
    return minFlash < beat ? minFlash : beat;
  }
}
