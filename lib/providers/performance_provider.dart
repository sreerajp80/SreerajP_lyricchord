import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How the performance view is currently displayed.
///
/// This is view state, not song data: architecture §11 keeps transpose amount,
/// show-chords, and font size out of the database. Closing the song forgets
/// them, so every song opens in its own written key.
class PerformanceSettings {
  /// How far the sheet is transposed, in semitones. `0` means "as written".
  final int semitones;

  /// False hides the chord badges so only lyrics are left.
  final bool showChords;

  /// Lyric text size in logical pixels, always between [minFontSize] and
  /// [maxFontSize].
  final double fontSize;

  /// Smallest lyric size the controls allow.
  static const double minFontSize = 10;

  /// Largest lyric size the controls allow.
  static const double maxFontSize = 32;

  /// Size a song opens at.
  static const double defaultFontSize = 18;

  const PerformanceSettings({
    this.semitones = 0,
    this.showChords = true,
    this.fontSize = defaultFontSize,
  });

  /// True when nothing has been changed from the defaults.
  bool get isTransposed => semitones != 0;

  PerformanceSettings copyWith({
    int? semitones,
    bool? showChords,
    double? fontSize,
  }) {
    return PerformanceSettings(
      semitones: semitones ?? this.semitones,
      showChords: showChords ?? this.showChords,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PerformanceSettings &&
      other.semitones == semitones &&
      other.showChords == showChords &&
      other.fontSize == fontSize;

  @override
  int get hashCode => Object.hash(semitones, showChords, fontSize);

  @override
  String toString() =>
      'PerformanceSettings(semitones: $semitones, showChords: $showChords, '
      'fontSize: $fontSize)';
}

/// Drives the Performance Controls card.
class PerformanceSettingsNotifier extends Notifier<PerformanceSettings> {
  @override
  PerformanceSettings build() => const PerformanceSettings();

  /// Up one semitone. Stops at +11 so the sheet never wraps back to its own
  /// key, which would look like nothing happened.
  void transposeUp() {
    if (state.semitones >= 11) return;
    state = state.copyWith(semitones: state.semitones + 1);
  }

  /// Down one semitone, stopping at −11 for the same reason.
  void transposeDown() {
    if (state.semitones <= -11) return;
    state = state.copyWith(semitones: state.semitones - 1);
  }

  /// Back to the written key.
  void resetTranspose() => state = state.copyWith(semitones: 0);

  /// Shows or hides the chord badges.
  void toggleChords() => state = state.copyWith(showChords: !state.showChords);

  /// Pinch zoom: sets the size to [startSize] × [factor], clamped to
  /// [PerformanceSettings.minFontSize]–[PerformanceSettings.maxFontSize].
  ///
  /// [startSize] is the font size when the pinch began, so each gesture
  /// update scales from the same base and the zoom never compounds.
  void applyFontScale(double startSize, double factor) =>
      _setFontSize(startSize * factor);

  /// Clears everything — used when a swipe opens a different song.
  void resetAll() => state = const PerformanceSettings();

  void _setFontSize(double size) {
    final clamped = size.clamp(
      PerformanceSettings.minFontSize,
      PerformanceSettings.maxFontSize,
    );
    if (clamped == state.fontSize) return;
    state = state.copyWith(fontSize: clamped);
  }
}

/// The live performance-view settings.
final performanceSettingsProvider =
    NotifierProvider<PerformanceSettingsNotifier, PerformanceSettings>(
      PerformanceSettingsNotifier.new,
    );
