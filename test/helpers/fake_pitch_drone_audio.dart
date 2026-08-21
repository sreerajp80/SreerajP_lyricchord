import 'package:lyricchord/services/pitch_drone_audio_service.dart';

/// A [PitchDroneAudio] that records what it was asked to do and never touches
/// a real audio device.
///
/// Set [succeed] to false to act like a device that refuses to play — which is
/// exactly the situation the real bug produced, and the one the UI has to
/// report instead of silently claiming success.
class FakePitchDroneAudio implements PitchDroneAudio {
  FakePitchDroneAudio({this.succeed = true});

  /// Whether play calls report that sound started.
  bool succeed;

  /// Every cue pitch asked for, in order.
  final List<String> cueKeys = [];

  /// Every drone start asked for, in order, as `key/interval`.
  final List<String> droneStarts = [];

  int stopCount = 0;
  int disposeCount = 0;
  double? volume;

  /// The pitch the last successful drone start used.
  String? get lastDroneKey =>
      droneStarts.isEmpty ? null : droneStarts.last.split('/').first;

  @override
  Future<bool> playCue(String noteKey) async {
    cueKeys.add(noteKey);
    return succeed;
  }

  @override
  Future<bool> startDrone({
    required String noteKey,
    required String interval,
  }) async {
    droneStarts.add('$noteKey/$interval');
    return succeed;
  }

  @override
  Future<void> stopDrone() async => stopCount++;

  @override
  Future<void> setVolume(double value) async => volume = value;

  @override
  Future<void> dispose() async => disposeCount++;
}
