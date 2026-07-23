/// Pure beat math for the metronome.
///
/// Like [AutoScrollCalculator], this has no Flutter imports: it only turns a
/// tempo and an elapsed time into beat numbers, so the "one beat per
/// 60/bpm seconds" rule can be unit-tested without a widget. The widget owns the
/// `Ticker`, the sound, and the flash; this owns the arithmetic.
class MetronomeCalculator {
  const MetronomeCalculator();

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
}
