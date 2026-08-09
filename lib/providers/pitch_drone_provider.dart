import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/models/pitch_drone_settings.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/services/pcm_synth_service.dart';

/// Riverpod notifier managing Pitch Pipe audio cues, Shruti Box drone state,
/// dynamic 5-tier font scale, and persisting settings to `shared_preferences`.
class PitchDroneNotifier extends Notifier<PitchDroneSettings> {
  static const PcmSynthService _synth = PcmSynthService();
  AudioPlayer? _cuePlayer;
  AudioPlayer? _dronePlayer;

  @override
  PitchDroneSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    const defaults = PitchDroneSettings();

    ref.onDispose(() {
      _cuePlayer?.dispose();
      _dronePlayer?.dispose();
    });

    return PitchDroneSettings(
      selectedKey:
          prefs.getString(AppConstants.prefPitchDroneKey) ??
          defaults.selectedKey,
      droneInterval:
          prefs.getString(AppConstants.prefPitchDroneInterval) ??
          defaults.droneInterval,
      volume:
          prefs.getDouble(AppConstants.prefPitchDroneVolume) ?? defaults.volume,
      fontScaleIndex:
          prefs.getInt(AppConstants.prefFontScaleIndex) ??
          defaults.fontScaleIndex,
      dronePlaying: false,
    );
  }

  /// Sets active root key (e.g. 'C', 'G').
  Future<void> setSelectedKey(String key) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.prefPitchDroneKey, key);
    state = state.copyWith(selectedKey: key);

    // If drone is currently running, restart with the new key
    if (state.dronePlaying) {
      await _startDrone();
    }
  }

  /// Sets drone interval ('Pa' for 5th or 'Ma' for 4th).
  Future<void> setDroneInterval(String interval) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.prefPitchDroneInterval, interval);
    state = state.copyWith(droneInterval: interval);

    if (state.dronePlaying) {
      await _startDrone();
    }
  }

  /// Sets audio volume [0.0, 1.0].
  Future<void> setVolume(double volume) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(AppConstants.prefPitchDroneVolume, volume);
    state = state.copyWith(volume: volume);

    _cuePlayer?.setVolume(volume);
    _dronePlayer?.setVolume(volume);
  }

  /// Sets 5-tier stage font scale index (0 to 4).
  Future<void> setFontScaleIndex(int index) async {
    final clamped = index.clamp(0, fontScaleTiers.length - 1);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(AppConstants.prefFontScaleIndex, clamped);
    state = state.copyWith(fontScaleIndex: clamped);
  }

  /// Cycles to the next font scale tier (0.85x -> 0.95x -> 1.00x -> 1.15x -> 1.30x -> 0.85x).
  Future<void> cycleFontScale() async {
    final nextIndex = (state.fontScaleIndex + 1) % fontScaleTiers.length;
    await setFontScaleIndex(nextIndex);
  }

  /// Plays a synthesized 2-second reference pitch cue tone for [key].
  Future<void> playPitchCue({String? key}) async {
    final targetKey = key ?? state.selectedKey;
    final wavBytes = _synth.generatePitchCueWav(noteKey: targetKey);

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/pitch_cue.wav');
    await tempFile.writeAsBytes(wavBytes);

    _cuePlayer ??= AudioPlayer();
    await _cuePlayer!.stop();
    await _cuePlayer!.setVolume(state.volume);
    await _cuePlayer!.play(DeviceFileSource(tempFile.path));
  }

  /// Toggles continuous Shruti Box drone on or off.
  Future<void> toggleDrone({String? key}) async {
    if (state.dronePlaying) {
      await stopDrone();
    } else {
      if (key != null && key != state.selectedKey) {
        final prefs = ref.read(sharedPreferencesProvider);
        await prefs.setString(AppConstants.prefPitchDroneKey, key);
        state = state.copyWith(selectedKey: key);
      }
      await _startDrone();
    }
  }

  /// Starts continuous Shruti Box drone playback.
  Future<void> _startDrone() async {
    final wavBytes = _synth.generateShrutiDroneWav(
      noteKey: state.selectedKey,
      interval: state.droneInterval,
    );

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/shruti_drone.wav');
    await tempFile.writeAsBytes(wavBytes);

    _dronePlayer ??= AudioPlayer();
    await _dronePlayer!.stop();
    await _dronePlayer!.setReleaseMode(ReleaseMode.loop);
    await _dronePlayer!.setVolume(state.volume);
    await _dronePlayer!.play(DeviceFileSource(tempFile.path));

    state = state.copyWith(dronePlaying: true);
  }

  /// Stops continuous Shruti Box drone playback.
  Future<void> stopDrone() async {
    if (_dronePlayer != null) {
      await _dronePlayer!.stop();
    }
    state = state.copyWith(dronePlaying: false);
  }
}

/// Riverpod provider for Pitch Pipe, Shruti Box drone, and 5-Tier Font Scale.
final pitchDroneProvider =
    NotifierProvider<PitchDroneNotifier, PitchDroneSettings>(
      PitchDroneNotifier.new,
    );
