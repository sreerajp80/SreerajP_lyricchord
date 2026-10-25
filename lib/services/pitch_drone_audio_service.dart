import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:lyricchord/core/logging/app_logger.dart';
import 'package:lyricchord/services/pcm_synth_service.dart';

/// What the pitch pipe and shruti drone need from their sound source.
///
/// An interface, not just a class, so a widget test can drop in a fake and
/// check what was asked for without any real audio device.
///
/// Every method reports whether the sound really started. The old code assumed
/// success, which is how a completely silent feature managed to look like it
/// was working.
abstract class PitchDroneAudio {
  /// Plays a one-off reference tone for [noteKey]. Returns false if it failed.
  Future<bool> playCue(String noteKey);

  /// Starts the looping drone on [noteKey] with [interval] (`Pa` or `Ma`).
  /// Returns false if it failed, so the caller must not claim it is playing.
  Future<bool> startDrone({required String noteKey, required String interval});

  /// Starts the looping Western chord drone on [noteKey] with [isMinor].
  /// Returns false if it failed.
  Future<bool> startChordDrone({
    required String noteKey,
    required bool isMinor,
  });

  /// Plays a one-off Western chord cue for [noteKey] with [isMinor].
  Future<bool> playChordCue({required String noteKey, required bool isMinor});

  /// Stops the drone. Safe to call when nothing is playing.
  Future<void> stopDrone();

  /// Sets loudness for both sounds, 0.0–1.0.
  Future<void> setVolume(double volume);

  /// Frees the players.
  Future<void> dispose();
}

/// Plays the synthesized pitch cue and shruti drone.
///
/// **Audio player modes:**
/// * Cues use [PlayerMode.mediaPlayer] or low-latency playback for short one-shot
///   tones.
/// * Continuous drones (Shruti and Western chords) use [PlayerMode.mediaPlayer]
///   with [ReleaseMode.loop]. SoundPool (`lowLatency`) has a 1 MB uncompressed buffer
///   cap and low-priority stream handling on Android which can cause continuous loops
///   to drop out after 2 seconds. MediaPlayer streams from file and loops seamlessly.
///
/// Every method reports whether the sound really started. A failure returns
/// false and, in debug builds only, logs the error. Song content is never logged.
class PitchDroneAudioService implements PitchDroneAudio {
  PitchDroneAudioService({this._synth = const PcmSynthService()});

  final PcmSynthService _synth;

  AudioPlayer? _cuePlayer;
  AudioPlayer? _dronePlayer;

  double _volume = 0.8;

  @override
  Future<bool> playCue(String noteKey) async {
    try {
      final file = await _writeIfNeeded(
        name: 'pitch_cue_${_slug(noteKey)}.wav',
        build: () => _synth.generatePitchCueWav(noteKey: noteKey),
      );

      final player = _cuePlayer ??= AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(_volume);
      await player.setSource(DeviceFileSource(file.path));
      await player.resume();
      return true;
    } catch (error, stack) {
      _report('playCue', error, stack);
      return false;
    }
  }

  @override
  Future<bool> playChordCue({
    required String noteKey,
    required bool isMinor,
  }) async {
    try {
      final quality = isMinor ? 'minor' : 'major';
      final file = await _writeIfNeeded(
        name: 'western_chord_cue_${_slug(noteKey)}_$quality.wav',
        build: () => _synth.generateWesternChordCueWav(
          noteKey: noteKey,
          isMinor: isMinor,
        ),
      );

      final player = _cuePlayer ??= AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(_volume);
      await player.setSource(DeviceFileSource(file.path));
      await player.resume();
      return true;
    } catch (error, stack) {
      _report('playChordCue', error, stack);
      return false;
    }
  }

  @override
  Future<bool> startDrone({
    required String noteKey,
    required String interval,
  }) async {
    try {
      final file = await _writeIfNeeded(
        name: 'shruti_drone_v2_${_slug(noteKey)}_${_slug(interval)}.wav',
        build: () =>
            _synth.generateShrutiDroneWav(noteKey: noteKey, interval: interval),
      );

      final player = _dronePlayer ??= AudioPlayer();
      await player.stop();
      await player.setPlayerMode(PlayerMode.mediaPlayer);
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(_volume);
      await player.setSource(DeviceFileSource(file.path));
      await player.resume();
      return true;
    } catch (error, stack) {
      _report('startDrone', error, stack);
      return false;
    }
  }

  @override
  Future<bool> startChordDrone({
    required String noteKey,
    required bool isMinor,
  }) async {
    try {
      final quality = isMinor ? 'minor' : 'major';
      final file = await _writeIfNeeded(
        name: 'western_chord_drone_v2_${_slug(noteKey)}_$quality.wav',
        build: () => _synth.generateWesternChordDroneWav(
          noteKey: noteKey,
          isMinor: isMinor,
        ),
      );

      final player = _dronePlayer ??= AudioPlayer();
      await player.stop();
      await player.setPlayerMode(PlayerMode.mediaPlayer);
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(_volume);
      await player.setSource(DeviceFileSource(file.path));
      await player.resume();
      return true;
    } catch (error, stack) {
      _report('startChordDrone', error, stack);
      return false;
    }
  }

  @override
  Future<void> stopDrone() async {
    try {
      await _dronePlayer?.stop();
      await _dronePlayer?.release();
    } catch (error, stack) {
      _report('stopDrone', error, stack);
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    try {
      await _cuePlayer?.setVolume(_volume);
      await _dronePlayer?.setVolume(_volume);
    } catch (error, stack) {
      _report('setVolume', error, stack);
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _cuePlayer?.dispose();
      await _dronePlayer?.dispose();
    } catch (_) {
      // Nothing useful to do while tearing down.
    }
    _cuePlayer = null;
    _dronePlayer = null;
  }

  /// Writes [name] into the temp folder unless it is already there.
  ///
  /// The synth is deterministic — the same key and interval always produce the
  /// same bytes — so a file that exists is already correct and rebuilding it
  /// would only cost time on the button press.
  ///
  /// The flip side: nothing here notices that the synth itself changed. A device
  /// that already played a drone holds the old sound for good. So the drone
  /// names carry a `_v2` marker — bump it whenever a generator's output changes,
  /// or the fix never reaches anyone who already ran the app.
  Future<File> _writeIfNeeded({
    required String name,
    required List<int> Function() build,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    if (!file.existsSync() || file.lengthSync() == 0) {
      await file.writeAsBytes(build());
    }
    return file;
  }

  /// Makes a key safe for a file name — `C#` would be fine but `G/B` would not.
  String _slug(String value) =>
      value.replaceAll('#', 'sharp').replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');

  /// Logs a failed audio call. Never song content, only which call failed.
  void _report(String where, Object error, StackTrace stack) {
    AppLogger.error(
      'PitchDroneAudioService.$where failed',
      error: error,
      stackTrace: stack,
    );
  }
}

/// The pitch pipe and drone sound source.
///
/// Widget tests override this with a fake so no real audio is needed.
final pitchDroneAudioProvider = Provider<PitchDroneAudio>((ref) {
  final service = PitchDroneAudioService();
  ref.onDispose(service.dispose);
  return service;
});
