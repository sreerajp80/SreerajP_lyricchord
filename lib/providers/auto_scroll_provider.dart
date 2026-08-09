import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/providers/database_provider.dart';

/// Which auto-scroll mode the performance view is in.
enum AutoScrollMode {
  /// Play/pause at a speed the user steps up or down (0.10x – 2.00x).
  manual,

  /// BPM + length in measures decide the speed, so the sheet ends at song end.
  tempo,
}

/// Live auto-scroll state for the performance view.
///
/// [speed] and [measures] belong to the song in [songId]: they are saved to the
/// database soon after the user changes them, and a song opens again at the
/// values it was last performed at. [mode], [isPlaying] and [contentExtent] stay
/// view-only — a fresh song is always paused at the top.
/// [contentExtent] is reported by the scrolling widget so the controls can show
/// the Tempo-Auto duration and px/second.
class AutoScrollSettings {
  /// The song these settings belong to, or `null` when no song is loaded.
  final int? songId;

  /// The current mode.
  final AutoScrollMode mode;

  /// Manual-mode speed multiplier, clamped to [minSpeed]–[maxSpeed] and always
  /// sitting on the [speedStep] grid.
  final double speed;

  /// Tempo-mode length in measures, clamped to [minMeasures]–[maxMeasures].
  final int measures;

  /// Beats in one measure, for the Tempo-Auto length.
  ///
  /// 4 for ordinary Western songs. An Indian song takes the beat count of its
  /// tala instead — Adi is 8 — so Tempo-Auto times the cycle correctly rather
  /// than assuming common time.
  final int beatsPerMeasure;

  /// True while the sheet is scrolling on its own.
  final bool isPlaying;

  /// How far the sheet can scroll, in logical pixels — reported by the widget
  /// once it has laid out. `0` before layout or when nothing overflows.
  final double contentExtent;

  /// Slowest Manual speed.
  static const double minSpeed = 0.10;

  /// Fastest Manual speed.
  static const double maxSpeed = 2.00;

  /// One tap of the speed stepper.
  static const double speedStep = 0.05;

  /// Speed a song opens at.
  static const double defaultSpeed = 1.00;

  /// Smallest allowed measure count.
  static const int minMeasures = 1;

  /// Largest allowed measure count.
  static const int maxMeasures = 512;

  /// Measures a song opens at.
  static const int defaultMeasures = 32;

  /// One tap of the measures stepper.
  static const int measuresStep = 4;

  /// Beats per measure when the song does not name a tala — common time.
  static const int defaultBeatsPerMeasure = 4;

  const AutoScrollSettings({
    this.songId,
    this.mode = AutoScrollMode.manual,
    this.speed = defaultSpeed,
    this.measures = defaultMeasures,
    this.beatsPerMeasure = defaultBeatsPerMeasure,
    this.isPlaying = false,
    this.contentExtent = 0,
  });

  AutoScrollSettings copyWith({
    int? songId,
    AutoScrollMode? mode,
    double? speed,
    int? measures,
    int? beatsPerMeasure,
    bool? isPlaying,
    double? contentExtent,
  }) {
    return AutoScrollSettings(
      songId: songId ?? this.songId,
      mode: mode ?? this.mode,
      speed: speed ?? this.speed,
      measures: measures ?? this.measures,
      beatsPerMeasure: beatsPerMeasure ?? this.beatsPerMeasure,
      isPlaying: isPlaying ?? this.isPlaying,
      contentExtent: contentExtent ?? this.contentExtent,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AutoScrollSettings &&
      other.songId == songId &&
      other.mode == mode &&
      other.speed == speed &&
      other.measures == measures &&
      other.beatsPerMeasure == beatsPerMeasure &&
      other.isPlaying == isPlaying &&
      other.contentExtent == contentExtent;

  @override
  int get hashCode => Object.hash(
    songId,
    mode,
    speed,
    measures,
    beatsPerMeasure,
    isPlaying,
    contentExtent,
  );

  @override
  String toString() =>
      'AutoScrollSettings(songId: $songId, mode: $mode, speed: $speed, '
      'measures: $measures, beatsPerMeasure: $beatsPerMeasure, '
      'isPlaying: $isPlaying, '
      'contentExtent: $contentExtent)';
}

/// Drives the auto-scroll section of the Performance Controls card.
class AutoScrollNotifier extends Notifier<AutoScrollSettings> {
  /// How long the user must stop tapping before the speed is written.
  ///
  /// The stepper and the Stage Mode tap zones can fire many times a second, so
  /// one write per tap would hit the database far too often.
  static const Duration saveDebounce = Duration(milliseconds: 600);

  Timer? _saveTimer;

  /// True when the speed or measures changed and are not yet written.
  bool _savePending = false;

  @override
  AutoScrollSettings build() {
    ref.onDispose(() {
      _saveTimer?.cancel();
      _saveTimer = null;
    });
    return const AutoScrollSettings();
  }

  /// Loads the values saved for [songId] and points later saves at that song.
  ///
  /// Does nothing when the same song is already loaded, so a database rebuild
  /// (the song stream emits again after our own write) can never undo a change
  /// the user just made. Mode goes back to Manual, paused, at the top.
  ///
  /// The one exception is [beatsPerMeasure]: it comes from the song's `{tala}`
  /// line, not from the user's controls, so editing the tala must re-time the
  /// scroll straight away rather than waiting for the song to be reopened.
  void loadForSong(
    int songId, {
    required double speed,
    required int measures,
    int beatsPerMeasure = AutoScrollSettings.defaultBeatsPerMeasure,
  }) {
    final beats = beatsPerMeasure < 1
        ? AutoScrollSettings.defaultBeatsPerMeasure
        : beatsPerMeasure;

    if (state.songId == songId) {
      if (state.beatsPerMeasure != beats) {
        state = state.copyWith(beatsPerMeasure: beats);
      }
      return;
    }
    _saveTimer?.cancel();
    _saveTimer = null;
    _savePending = false;
    state = AutoScrollSettings(
      songId: songId,
      speed: _snapSpeed(speed),
      measures: measures.clamp(
        AutoScrollSettings.minMeasures,
        AutoScrollSettings.maxMeasures,
      ),
      beatsPerMeasure: beats,
    );
  }

  /// Switches mode. Switching pauses first, so the sheet never keeps moving at
  /// a speed the user did not just pick.
  void setMode(AutoScrollMode mode) {
    if (mode == state.mode) return;
    state = state.copyWith(mode: mode, isPlaying: false);
  }

  /// Sets the Manual-mode speed. The value is clamped to the allowed range and
  /// snapped to the nearest [AutoScrollSettings.speedStep], so the stepper can
  /// never drift off the grid and a bad value can never reach the ticker.
  void setSpeed(double speed) {
    if (!speed.isFinite) return;
    final snapped = _snapSpeed(speed);
    if (snapped == state.speed) return;
    state = state.copyWith(speed: snapped);
    _scheduleSave();
  }

  /// One step faster, up to [AutoScrollSettings.maxSpeed].
  void increaseSpeed() => setSpeed(state.speed + AutoScrollSettings.speedStep);

  /// One step slower, down to [AutoScrollSettings.minSpeed].
  void decreaseSpeed() => setSpeed(state.speed - AutoScrollSettings.speedStep);

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

  /// Clears everything, including the loaded song.
  void resetAll() {
    _saveTimer?.cancel();
    _saveTimer = null;
    _savePending = false;
    state = const AutoScrollSettings();
  }

  /// Writes any pending change right now.
  ///
  /// Called when the song changes, the performance screen closes, or the app
  /// goes to the background, so the last value is never lost to the debounce.
  Future<void> flushSave() {
    _saveTimer?.cancel();
    _saveTimer = null;
    return _writeNow();
  }

  /// Starts (or restarts) the debounce timer after a speed/measures change.
  void _scheduleSave() {
    if (state.songId == null) return;
    _savePending = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDebounce, () {
      _saveTimer = null;
      _writeNow();
    });
  }

  /// Saves the current speed and measures for the loaded song.
  ///
  /// A failed save is swallowed on purpose: losing a scroll speed is a small
  /// problem, and an error thrown mid-performance would be a big one.
  Future<void> _writeNow() async {
    if (!_savePending) return;
    _savePending = false;
    final songId = state.songId;
    if (songId == null) return;
    try {
      await ref
          .read(songRepositoryProvider)
          .saveScrollSettings(
            songId,
            speed: state.speed,
            measures: state.measures,
          );
    } catch (_) {
      // Ignored — see the doc comment above.
    }
  }

  /// Puts [speed] on the step grid and inside the allowed range.
  ///
  /// The work is done in whole hundredths of an `x` on purpose. Adding `0.05`
  /// to a `double` again and again drifts (`0.1 + 0.05 + 0.05` is not exactly
  /// `0.2`), which would slowly push the value off the grid and show labels
  /// like `1.1500000000000001x`. Integers cannot drift.
  double _snapSpeed(double speed) {
    final stepHundredths = (AutoScrollSettings.speedStep * 100).round();
    final minHundredths = (AutoScrollSettings.minSpeed * 100).round();
    final maxHundredths = (AutoScrollSettings.maxSpeed * 100).round();

    final steps = (speed * 100 / stepHundredths).round();
    final hundredths = (steps * stepHundredths).clamp(
      minHundredths,
      maxHundredths,
    );
    return hundredths / 100;
  }

  void _setMeasures(int measures) {
    final clamped = measures.clamp(
      AutoScrollSettings.minMeasures,
      AutoScrollSettings.maxMeasures,
    );
    if (clamped == state.measures) return;
    state = state.copyWith(measures: clamped);
    _scheduleSave();
  }
}

/// The live auto-scroll settings.
final autoScrollProvider =
    NotifierProvider<AutoScrollNotifier, AutoScrollSettings>(
      AutoScrollNotifier.new,
    );
