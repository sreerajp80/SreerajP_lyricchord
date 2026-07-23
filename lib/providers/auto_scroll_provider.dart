import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which auto-scroll mode the performance view is in.
enum AutoScrollMode {
  /// Play/pause at a fixed 0.5x / 1x / 2x speed.
  manual,

  /// BPM + length in measures decide the speed, so the sheet ends at song end.
  tempo,
}

/// Live auto-scroll state for the performance view.
///
/// Like [PerformanceSettings], this is view state, not song data: it is not
/// stored, and swiping to another song forgets it (a fresh song is paused at
/// the top). [contentExtent] is reported by the scrolling widget so the
/// controls can show the Tempo-Auto duration and px/second.
class AutoScrollSettings {
  /// The current mode.
  final AutoScrollMode mode;

  /// Manual-mode speed multiplier — one of [speedChoices].
  final double speed;

  /// Tempo-mode length in measures, clamped to [minMeasures]–[maxMeasures].
  final int measures;

  /// True while the sheet is scrolling on its own.
  final bool isPlaying;

  /// How far the sheet can scroll, in logical pixels — reported by the widget
  /// once it has laid out. `0` before layout or when nothing overflows.
  final double contentExtent;

  /// The speeds Manual mode offers.
  static const List<double> speedChoices = [0.5, 1.0, 2.0];

  /// Smallest allowed measure count.
  static const int minMeasures = 1;

  /// Largest allowed measure count.
  static const int maxMeasures = 512;

  /// Measures a song opens at.
  static const int defaultMeasures = 32;

  /// One tap of the measures stepper.
  static const int measuresStep = 4;

  const AutoScrollSettings({
    this.mode = AutoScrollMode.manual,
    this.speed = 1.0,
    this.measures = defaultMeasures,
    this.isPlaying = false,
    this.contentExtent = 0,
  });

  AutoScrollSettings copyWith({
    AutoScrollMode? mode,
    double? speed,
    int? measures,
    bool? isPlaying,
    double? contentExtent,
  }) {
    return AutoScrollSettings(
      mode: mode ?? this.mode,
      speed: speed ?? this.speed,
      measures: measures ?? this.measures,
      isPlaying: isPlaying ?? this.isPlaying,
      contentExtent: contentExtent ?? this.contentExtent,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AutoScrollSettings &&
      other.mode == mode &&
      other.speed == speed &&
      other.measures == measures &&
      other.isPlaying == isPlaying &&
      other.contentExtent == contentExtent;

  @override
  int get hashCode =>
      Object.hash(mode, speed, measures, isPlaying, contentExtent);

  @override
  String toString() =>
      'AutoScrollSettings(mode: $mode, speed: $speed, measures: $measures, '
      'isPlaying: $isPlaying, contentExtent: $contentExtent)';
}

/// Drives the auto-scroll section of the Performance Controls card.
class AutoScrollNotifier extends Notifier<AutoScrollSettings> {
  @override
  AutoScrollSettings build() => const AutoScrollSettings();

  /// Switches mode. Switching pauses first, so the sheet never keeps moving at
  /// a speed the user did not just pick.
  void setMode(AutoScrollMode mode) {
    if (mode == state.mode) return;
    state = state.copyWith(mode: mode, isPlaying: false);
  }

  /// Picks a Manual-mode speed. Ignores anything not in
  /// [AutoScrollSettings.speedChoices].
  void setSpeed(double speed) {
    if (!AutoScrollSettings.speedChoices.contains(speed)) return;
    state = state.copyWith(speed: speed);
  }

  /// More Tempo-Auto measures, up to [AutoScrollSettings.maxMeasures].
  void increaseMeasures() =>
      _setMeasures(state.measures + AutoScrollSettings.measuresStep);

  /// Fewer Tempo-Auto measures, down to [AutoScrollSettings.minMeasures].
  void decreaseMeasures() =>
      _setMeasures(state.measures - AutoScrollSettings.measuresStep);

  /// Starts scrolling.
  void play() {
    if (state.isPlaying) return;
    state = state.copyWith(isPlaying: true);
  }

  /// Pauses scrolling, keeping the current offset.
  void pause() {
    if (!state.isPlaying) return;
    state = state.copyWith(isPlaying: false);
  }

  /// Play/pause in one tap.
  void togglePlay() => state.isPlaying ? pause() : play();

  /// Pauses — used when the sheet reaches the bottom (auto-stop). Kept as its
  /// own name so the intent reads clearly at the call site.
  void stop() => pause();

  /// The scrolling widget tells us its scroll length so the controls can show
  /// the Tempo-Auto duration and px/second.
  void reportContentExtent(double extent) {
    final clean = extent.isFinite && extent > 0 ? extent : 0.0;
    if (clean == state.contentExtent) return;
    state = state.copyWith(contentExtent: clean);
  }

  /// Clears everything — used when a swipe opens a different song.
  void resetAll() => state = const AutoScrollSettings();

  void _setMeasures(int measures) {
    final clamped = measures.clamp(
      AutoScrollSettings.minMeasures,
      AutoScrollSettings.maxMeasures,
    );
    if (clamped == state.measures) return;
    state = state.copyWith(measures: clamped);
  }
}

/// The live auto-scroll settings.
final autoScrollProvider =
    NotifierProvider<AutoScrollNotifier, AutoScrollSettings>(
      AutoScrollNotifier.new,
    );
