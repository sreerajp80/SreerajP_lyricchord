/// Pure timing math for the performance-view auto-scroll.
///
/// This service has no Flutter imports on purpose (architecture §4, layer
/// boundaries): it only turns tempo/length numbers into a duration and a
/// pixels-per-second speed, so the "ends exactly at song end" rule can be
/// unit-tested without a widget. The widget owns the scrolling; this owns the
/// arithmetic.
class AutoScrollCalculator {
  const AutoScrollCalculator();

  /// Speed of Manual mode at `1x`, in logical pixels per second. `0.5x` and
  /// `2x` are this scaled by the multiplier.
  static const double baseManualPixelsPerSecond = 40;

  /// Beats in one measure. The app assumes common time (4/4); the Android app
  /// did the same.
  static const int defaultBeatsPerMeasure = 4;

  /// How long a Tempo-Auto song lasts: `measures * beatsPerMeasure` beats at
  /// `bpm` beats per minute.
  ///
  /// Returns [Duration.zero] when the inputs cannot make a real length
  /// (non-positive bpm or measures), which the caller reads as "cannot
  /// auto-scroll yet".
  Duration tempoDuration(
    int bpm,
    int measures, {
    int beatsPerMeasure = defaultBeatsPerMeasure,
  }) {
    if (bpm <= 0 || measures <= 0 || beatsPerMeasure <= 0) {
      return Duration.zero;
    }
    final beats = measures * beatsPerMeasure;
    final seconds = beats * 60 / bpm;
    return Duration(
      microseconds: (seconds * Duration.microsecondsPerSecond).round(),
    );
  }

  /// Tempo-Auto speed: cover the whole [contentExtent] (logical pixels) in
  /// exactly [duration]. This is what guarantees the sheet ends at song end —
  /// `pixelsPerSecond * durationSeconds == contentExtent`.
  ///
  /// Returns `0` when there is nothing to scroll or no time to scroll in.
  double tempoPixelsPerSecond(double contentExtent, Duration duration) {
    if (contentExtent <= 0) return 0;
    final seconds = duration.inMicroseconds / Duration.microsecondsPerSecond;
    if (seconds <= 0) return 0;
    return contentExtent / seconds;
  }

  /// Manual-mode speed: the base speed scaled by the chosen multiplier
  /// (`0.5 / 1 / 2`).
  double manualPixelsPerSecond(double speedMultiplier) {
    if (speedMultiplier <= 0) return 0;
    return baseManualPixelsPerSecond * speedMultiplier;
  }
}
