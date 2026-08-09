import 'package:flutter/foundation.dart';

/// Supported 5-tier dynamic stage font scales.
const List<double> fontScaleTiers = [0.85, 0.95, 1.00, 1.15, 1.30];

/// Settings and state model for Pitch Pipe, Shruti Box Drone, and Dynamic Font Scale.
@immutable
class PitchDroneSettings {
  const PitchDroneSettings({
    this.selectedKey = 'C',
    this.droneInterval = 'Pa',
    this.volume = 0.8,
    this.fontScaleIndex = 2,
    this.dronePlaying = false,
  });

  final String selectedKey;
  final String droneInterval;
  final double volume;
  final int fontScaleIndex;
  final bool dronePlaying;

  /// Returns current text scale factor (e.g. 1.00).
  double get fontScaleFactor =>
      fontScaleTiers[fontScaleIndex.clamp(0, fontScaleTiers.length - 1)];

  PitchDroneSettings copyWith({
    String? selectedKey,
    String? droneInterval,
    double? volume,
    int? fontScaleIndex,
    bool? dronePlaying,
  }) {
    return PitchDroneSettings(
      selectedKey: selectedKey ?? this.selectedKey,
      droneInterval: droneInterval ?? this.droneInterval,
      volume: volume ?? this.volume,
      fontScaleIndex: fontScaleIndex ?? this.fontScaleIndex,
      dronePlaying: dronePlaying ?? this.dronePlaying,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PitchDroneSettings &&
          runtimeType == other.runtimeType &&
          selectedKey == other.selectedKey &&
          droneInterval == other.droneInterval &&
          volume == other.volume &&
          fontScaleIndex == other.fontScaleIndex &&
          dronePlaying == other.dronePlaying;

  @override
  int get hashCode => Object.hash(
    selectedKey,
    droneInterval,
    volume,
    fontScaleIndex,
    dronePlaying,
  );
}
