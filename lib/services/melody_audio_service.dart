import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:lyricchord/services/melody_player_service.dart';
import 'package:lyricchord/services/pcm_synth_service.dart';

/// What the melody player needs from its sound source.
///
/// An interface so a widget test can drop in a fake and check what was asked
/// for, without any real audio device — the same reason `PitchDroneAudio` is
/// one.
abstract class MelodyAudio {
  /// Renders [schedule] and starts it. Returns false if it failed, so the
  /// caller must not claim it is playing.
  ///
  /// When [loop] is true the line repeats until [stop] is called.
  Future<bool> play(MelodySchedule schedule, {bool loop = false});

  /// Stops playback. Safe to call when nothing is playing.
  Future<void> stop();

  /// Sets loudness, 0.0–1.0.
  Future<void> setVolume(double volume);

  /// Frees the player.
  Future<void> dispose();
}

/// Plays a melody line as one synthesized WAV.
///
/// **Why the whole line becomes a single file.** The obvious approach is to
/// start a sound per note on a timer. On a real device that timer drifts and
/// every note start carries its own latency, so a tune comes out uneven — which
/// is exactly the thing a learner would copy. Rendering the line once means the
/// timing is decided in arithmetic, not by the scheduler, and what comes out is
/// what `MelodyPlayerService` worked out.
///
/// Uses `PlayerMode.mediaPlayer` with `setSource` then `resume`, and a unique
/// file name per rendered line so `audioplayers` never replays a cached older
/// version. Media player mode avoids the 1 MB buffer limit of Android's
/// `SoundPool` so long melody lines play completely.
class MelodyAudioService implements MelodyAudio {
  MelodyAudioService({this._synth = const PcmSynthService()});

  final PcmSynthService _synth;

  AudioPlayer? _player;

  double _volume = 0.9;

  /// The file currently loaded, so replaying the same line does not rebuild it.
  String? _loadedPath;

  /// How many rendered lines to keep before reusing names.
  ///
  /// A melody line at half speed can be a few hundred kilobytes. Naming files
  /// by a rolling counter rather than by content keeps the temp folder from
  /// growing without bound while still giving each render a fresh path.
  static const int _fileSlots = 4;
  int _slot = 0;

  @override
  Future<bool> play(MelodySchedule schedule, {bool loop = false}) async {
    if (schedule.isEmpty) return false;

    try {
      final tones = schedule.spans
          .map(
            (span) => PcmTone(
              frequency: span.frequency,
              fromFrequency: span.fromFrequency,
              shakeHz: span.shakeHz,
              shakeDepthSemitones: span.shakeDepthSemitones,
              durationSeconds: span.duration.inMicroseconds / 1000000,
            ),
          )
          .toList(growable: false);

      _slot = (_slot + 1) % _fileSlots;
      final file = await _write(
        name: 'melody_line_$_slot.wav',
        bytes: _synth.generateSequenceWav(tones: tones),
      );

      final player = _player ??= AudioPlayer();
      await player.stop();
      await player.setPlayerMode(PlayerMode.mediaPlayer);
      await player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
      await player.setVolume(_volume);

      if (_loadedPath != file.path) {
        await player.setSource(DeviceFileSource(file.path));
        _loadedPath = file.path;
      } else {
        await player.seek(Duration.zero);
      }

      await player.resume();
      return true;
    } catch (error, stack) {
      _report('play', error, stack);
      _loadedPath = null;
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (error, stack) {
      _report('stop', error, stack);
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    try {
      await _player?.setVolume(_volume);
    } catch (error, stack) {
      _report('setVolume', error, stack);
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _player?.dispose();
    } catch (_) {
      // Nothing useful to do while tearing down.
    }
    _player = null;
    _loadedPath = null;
  }

  /// Writes [bytes] into the temp folder under [name], replacing what is there.
  ///
  /// Unlike the drone, this always rewrites: the same slot name is reused for a
  /// different tune, so a file that exists is not necessarily the right one.
  Future<File> _write({required String name, required List<int> bytes}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Debug-only failure note. Never logs song content, only the audio call.
  void _report(String where, Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('MelodyAudioService.$where failed: $error\n$stack');
    }
  }
}

/// The melody player's sound source.
final melodyAudioProvider = Provider<MelodyAudio>((ref) {
  final audio = MelodyAudioService();
  ref.onDispose(audio.dispose);
  return audio;
});
