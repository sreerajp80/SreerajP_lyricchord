import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:lyricchord/services/pcm_synth_service.dart';

/// What the metronome needs from its sound source.
///
/// An interface, not just a class, so a widget test can drop in a fake and
/// count beats without any real audio device.
abstract class MetronomeAudio {
  /// Builds and loads the two clicks. Safe to call more than once; the work only
  /// happens the first time. Call it before the first beat so the first click is
  /// not late.
  Future<void> prepare();

  /// Plays a normal beat. Fire-and-forget: never awaited on the beat path.
  void playNormal();

  /// Plays the accented beat 1 of a bar.
  void playAccent();

  /// Sets loudness, 0.0–1.0.
  Future<void> setVolume(double volume);

  /// Frees the players.
  Future<void> dispose();
}

/// Plays the metronome click through the device's **media** channel.
///
/// This replaces `SystemSound.play(SystemSoundType.click)`, which was the phone's
/// keyboard-tap sound: silent whenever the user has "Touch sounds" turned off
/// (the common case), tied to the system volume instead of the media volume, and
/// impossible to make louder, longer or higher-pitched from the app.
///
/// The clicks are synthesized by [PcmSynthService] and written to the temp
/// folder, the same approach the Shruti Box drone already uses — so no sound
/// asset ships with the app and no new package is needed.
///
/// Every call is wrapped: if audio fails for any reason the beat carries on
/// silently and the flash still works. A performance must never be interrupted
/// by a dead speaker (hard rule 4).
class MetronomeAudioService implements MetronomeAudio {
  MetronomeAudioService({this._synth = const PcmSynthService()});

  final PcmSynthService _synth;

  /// Pitch of a normal beat, in Hz.
  static const double normalFrequency = 1000.0;

  /// Pitch of the accented beat 1. Higher, so the bar start is obvious.
  static const double accentFrequency = 1500.0;

  AudioPlayer? _normalPlayer;
  AudioPlayer? _accentPlayer;

  double _volume = 0.8;
  bool _ready = false;
  Future<void>? _preparing;

  @override
  Future<void> prepare() {
    // Two beats arriving together must not build the files twice, so the first
    // call's future is shared.
    return _preparing ??= _prepare();
  }

  Future<void> _prepare() async {
    try {
      final tempDir = await getTemporaryDirectory();

      final normalFile = File('${tempDir.path}/metronome_click.wav');
      await normalFile.writeAsBytes(
        _synth.generateClickWav(frequency: normalFrequency, amplitude: 0.7),
      );

      final accentFile = File('${tempDir.path}/metronome_accent.wav');
      await accentFile.writeAsBytes(
        _synth.generateClickWav(frequency: accentFrequency, amplitude: 0.95),
      );

      _normalPlayer = await _loadPlayer(normalFile);
      _accentPlayer = await _loadPlayer(accentFile);
      _ready = true;
    } catch (error, stack) {
      // Leave _ready false; playNormal/playAccent then do nothing.
      _ready = false;
      if (kDebugMode) {
        debugPrint('MetronomeAudioService.prepare failed: $error\n$stack');
      }
    }
  }

  /// Creates a player already holding [file], in low-latency mode.
  ///
  /// Low-latency mode is meant for exactly this: one short sound fired again and
  /// again. Loading the source now means a beat only has to say "play".
  Future<AudioPlayer> _loadPlayer(File file) async {
    final player = AudioPlayer();
    await player.setPlayerMode(PlayerMode.lowLatency);
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setVolume(_volume);
    await player.setSource(DeviceFileSource(file.path));
    return player;
  }

  @override
  void playNormal() => _fire(_normalPlayer);

  @override
  void playAccent() => _fire(_accentPlayer ?? _normalPlayer);

  /// Restarts [player] from the beginning without waiting for it.
  ///
  /// A click is ~30 ms and the shortest beat gap is 200 ms (300 bpm), so one
  /// player per sound can never overlap itself.
  void _fire(AudioPlayer? player) {
    if (!_ready || player == null) return;
    player.stop().then((_) => player.resume()).catchError((Object error) {
      if (kDebugMode) debugPrint('Metronome click failed: $error');
    });
  }

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    try {
      await _normalPlayer?.setVolume(_volume);
      await _accentPlayer?.setVolume(_volume);
    } catch (error) {
      if (kDebugMode) debugPrint('Metronome setVolume failed: $error');
    }
  }

  @override
  Future<void> dispose() async {
    _ready = false;
    try {
      await _normalPlayer?.dispose();
      await _accentPlayer?.dispose();
    } catch (_) {
      // Nothing useful to do while tearing down.
    }
    _normalPlayer = null;
    _accentPlayer = null;
  }
}

/// The metronome's sound source.
///
/// Widget tests override this with a fake so no real audio is needed.
final metronomeAudioProvider = Provider<MetronomeAudio>((ref) {
  final service = MetronomeAudioService();
  ref.onDispose(service.dispose);
  return service;
});
