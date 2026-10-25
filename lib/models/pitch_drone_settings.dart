import 'package:flutter/foundation.dart';

import 'package:lyricchord/models/pitch_tradition.dart';

/// Supported 5-tier dynamic stage font scales.
const List<double> fontScaleTiers = [0.85, 0.95, 1.00, 1.15, 1.30];

/// Which drone tradition to play: Classical Shruti drone or Western backing chord.
enum DroneMode {
  classical,
  western;

  // Screen names live in `lib/l10n/l10n_labels.dart` (no UI text in models).

  String get storageKey => name;

  static DroneMode fromStorage(
    String? value, {
    DroneMode fallback = DroneMode.classical,
  }) {
    for (final mode in DroneMode.values) {
      if (mode.storageKey == value) return mode;
    }
    return fallback;
  }
}

/// Western chord quality for chord drone playback.
enum ChordQuality {
  major,
  minor;

  // Screen names live in `lib/l10n/l10n_labels.dart` (no UI text in models).

  String get shortName => switch (this) {
    ChordQuality.major => 'maj',
    ChordQuality.minor => 'min',
  };

  String get storageKey => name;

  static ChordQuality fromStorage(
    String? value, {
    ChordQuality fallback = ChordQuality.major,
  }) {
    for (final quality in ChordQuality.values) {
      if (quality.storageKey == value) return quality;
    }
    return fallback;
  }
}

/// Why the last pitch pipe or drone sound failed. The screen turns this into
/// words (`lib/l10n/l10n_labels.dart`).
enum DroneError { chordCue, pitchCue, startDrone }

/// Settings and state model for Pitch Pipe, Shruti Box Drone, Western Chord Drone, and Dynamic Font Scale.
@immutable
class PitchDroneSettings {
  const PitchDroneSettings({
    this.selectedKey = 'C',
    this.saKey = 'C',
    this.pitchNaming = PitchTradition.carnatic,
    this.droneInterval = 'Pa',
    this.droneMode = DroneMode.classical,
    this.chordQuality = ChordQuality.major,
    this.volume = 0.8,
    this.fontScaleIndex = 2,
    this.dronePlaying = false,
    this.lastError,
  });

  /// The key the Western default tone uses.
  final String selectedKey;

  /// Where the singer's **Sa** sits, as a pitch (`G` = 5 kattai = safed 5).
  ///
  /// Separate from [selectedKey] on purpose. Sa is a property of the singer's
  /// voice and barely changes; a Western song's key changes with every song.
  /// Sharing one value would make each overwrite the other.
  final String saKey;

  /// Which naming to fall back to when a song's tradition cannot be worked out,
  /// and how the Settings screen itself is labelled.
  final PitchTradition pitchNaming;

  /// `Pa` for the fifth, `Ma` for the fourth (used in [DroneMode.classical]).
  final String droneInterval;

  /// Whether the drone sounds as Classical Shruti (Sa + Pa/Ma) or Western chords.
  final DroneMode droneMode;

  /// Chord quality when in [DroneMode.western] (Major or Minor).
  final ChordQuality chordQuality;

  final double volume;
  final int fontScaleIndex;

  /// True only when the drone is really sounding.
  ///
  /// This used to be set the moment play was asked for, whether or not any
  /// sound followed, so the button read "Stop Drone" over silence.
  final bool dronePlaying;

  /// Why the last audio call failed, or `null` when all is well. The UI shows
  /// this once as a `SnackBar` rather than failing silently.
  final DroneError? lastError;

  /// Returns current text scale factor (e.g. 1.00).
  double get fontScaleFactor =>
      fontScaleTiers[fontScaleIndex.clamp(0, fontScaleTiers.length - 1)];

  PitchDroneSettings copyWith({
    String? selectedKey,
    String? saKey,
    PitchTradition? pitchNaming,
    String? droneInterval,
    DroneMode? droneMode,
    ChordQuality? chordQuality,
    double? volume,
    int? fontScaleIndex,
    bool? dronePlaying,
    DroneError? lastError,
    bool clearError = false,
  }) {
    return PitchDroneSettings(
      selectedKey: selectedKey ?? this.selectedKey,
      saKey: saKey ?? this.saKey,
      pitchNaming: pitchNaming ?? this.pitchNaming,
      droneInterval: droneInterval ?? this.droneInterval,
      droneMode: droneMode ?? this.droneMode,
      chordQuality: chordQuality ?? this.chordQuality,
      volume: volume ?? this.volume,
      fontScaleIndex: fontScaleIndex ?? this.fontScaleIndex,
      dronePlaying: dronePlaying ?? this.dronePlaying,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PitchDroneSettings &&
          runtimeType == other.runtimeType &&
          selectedKey == other.selectedKey &&
          saKey == other.saKey &&
          pitchNaming == other.pitchNaming &&
          droneInterval == other.droneInterval &&
          droneMode == other.droneMode &&
          chordQuality == other.chordQuality &&
          volume == other.volume &&
          fontScaleIndex == other.fontScaleIndex &&
          dronePlaying == other.dronePlaying &&
          lastError == other.lastError;

  @override
  int get hashCode => Object.hash(
    selectedKey,
    saKey,
    pitchNaming,
    droneInterval,
    droneMode,
    chordQuality,
    volume,
    fontScaleIndex,
    dronePlaying,
    lastError,
  );
}
