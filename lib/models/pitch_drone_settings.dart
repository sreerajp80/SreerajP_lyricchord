import 'package:flutter/foundation.dart';

import 'package:lyricchord/models/pitch_tradition.dart';

/// Supported 5-tier dynamic stage font scales.
const List<double> fontScaleTiers = [0.85, 0.95, 1.00, 1.15, 1.30];

/// Settings and state model for Pitch Pipe, Shruti Box Drone, and Dynamic Font Scale.
@immutable
class PitchDroneSettings {
  const PitchDroneSettings({
    this.selectedKey = 'C',
    this.saKey = 'C',
    this.pitchNaming = PitchTradition.carnatic,
    this.droneInterval = 'Pa',
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

  /// `Pa` for the fifth, `Ma` for the fourth.
  final String droneInterval;

  final double volume;
  final int fontScaleIndex;

  /// True only when the drone is really sounding.
  ///
  /// This used to be set the moment play was asked for, whether or not any
  /// sound followed, so the button read "Stop Drone" over silence.
  final bool dronePlaying;

  /// Why the last audio call failed, or `null` when all is well. The UI shows
  /// this once as a `SnackBar` rather than failing silently.
  final String? lastError;

  /// Returns current text scale factor (e.g. 1.00).
  double get fontScaleFactor =>
      fontScaleTiers[fontScaleIndex.clamp(0, fontScaleTiers.length - 1)];

  PitchDroneSettings copyWith({
    String? selectedKey,
    String? saKey,
    PitchTradition? pitchNaming,
    String? droneInterval,
    double? volume,
    int? fontScaleIndex,
    bool? dronePlaying,
    String? lastError,
    bool clearError = false,
  }) {
    return PitchDroneSettings(
      selectedKey: selectedKey ?? this.selectedKey,
      saKey: saKey ?? this.saKey,
      pitchNaming: pitchNaming ?? this.pitchNaming,
      droneInterval: droneInterval ?? this.droneInterval,
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
    volume,
    fontScaleIndex,
    dronePlaying,
    lastError,
  );
}
