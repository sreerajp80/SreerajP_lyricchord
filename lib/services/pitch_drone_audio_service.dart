import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

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

  /// Stops the drone. Safe to call when nothing is playing.
  Future<void> stopDrone();

  /// Sets loudness for both sounds, 0.0–1.0.
  Future<void> setVolume(double volume);

  /// Frees the players.
  Future<void> dispose();
}

/// Plays the synthesized pitch cue and shruti drone.
///
/// **Why this exists.** The drone used to be played straight from the provider
/// with a single `play()` call on a default `AudioPlayer`. On a real device that
/// created a `MediaPlayer` which loaded the file, looped over it, and never once
/// reached the started state — `dumpsys audio` showed the format being re-read
/// every four seconds but no `event:started`, so nothing was ever heard.
///
/// The metronome had already solved this. It uses [PlayerMode.lowLatency] and
/// starts the sound with `setSource()` then `resume()`, and on the same device
/// that logs a real start for every beat. This service copies that sequence.
///
/// Two other things the old code got wrong are fixed here:
///
/// * **Unique file names.** `audioplayers` caches a source by its path, so
///   always writing to `shruti_drone.wav` meant a changed key could keep
///   sounding the old note. Each key and interval now gets its own file.
/// * **Nothing is silent about failing.** Every call is wrapped. A failure
///   returns false and, in debug builds only, says why. Song content is never
///   logged.
class PitchDroneAudioService implements PitchDroneAudio {
  PitchDroneAudioService({this._synth = const PcmSynthService()});

  final PcmSynthService _synth;

  AudioPlayer? _cuePlayer;
  AudioPlayer? _dronePlayer;

  double _volume = 0.8;

  /// The drone source currently loaded, so re-pressing the same key does not
  /// rebuild a 700 KB file for nothing.
  String? _loadedDronePath;

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
  Future<bool> startDrone({
    required String noteKey,
    required String interval,
  }) async {
    try {
      final file = await _writeIfNeeded(
        name: 'shruti_drone_${_slug(noteKey)}_${_slug(interval)}.wav',
        build: () =>
            _synth.generateShrutiDroneWav(noteKey: noteKey, interval: interval),
      );

      final player = _dronePlayer ??= AudioPlayer();
      await player.stop();
      // Low latency, i.e. SoundPool — the same path the metronome uses.
      //
      // The obvious choice for a long pad is the default media player, and that
      // is what this used to do. On a real device it never worked: the player
      // loaded the file, looped over it, and never once reached the started
      // state, so nothing came out. The pitch cue on SoundPool played fine from
      // the same process at the same moment, which is what pinned it down.
      //
      // SoundPool caps a sample at roughly 1 MB, which is why the drone buffer
      // is two seconds rather than four.
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(_volume);

      // Only reload when the sound actually changed. Re-setting the same source
      // is what used to leave the player sitting idle.
      if (_loadedDronePath != file.path) {
        await player.setSource(DeviceFileSource(file.path));
        _loadedDronePath = file.path;
      } else {
        await player.seek(Duration.zero);
      }

      await player.resume();
      return true;
    } catch (error, stack) {
      _report('startDrone', error, stack);
      _loadedDronePath = null;
      return false;
    }
  }

  @override
  Future<void> stopDrone() async {
    try {
      await _dronePlayer?.stop();
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
    _loadedDronePath = null;
  }

  /// Writes [name] into the temp folder unless it is already there.
  ///
  /// The synth is deterministic — the same key and interval always produce the
  /// same bytes — so a file that exists is already correct and rebuilding it
  /// would only cost time on the button press.
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

  /// Debug-only failure note. Never logs song content, only the audio call.
  void _report(String where, Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('PitchDroneAudioService.$where failed: $error\n$stack');
    }
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
