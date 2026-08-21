import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/models/pitch_drone_settings.dart';
import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/services/pitch_drone_audio_service.dart';

/// Riverpod notifier managing Pitch Pipe audio cues, Shruti Box drone state,
/// dynamic 5-tier font scale, and persisting settings to `shared_preferences`.
///
/// The audio itself lives in [PitchDroneAudio]. This notifier only decides
/// *what* should sound and records *whether it did* — it never touches an
/// `AudioPlayer`, so a widget test can run the whole flow with a fake.
class PitchDroneNotifier extends Notifier<PitchDroneSettings> {
  PitchDroneAudio get _audio => ref.read(pitchDroneAudioProvider);

  /// The pitch the drone is sounding right now.
  ///
  /// Not the same as [PitchDroneSettings.selectedKey]: a song sheet can start
  /// the drone on the song's own key without changing the saved default, and a
  /// later interval change must stay on that key rather than jumping back.
  String? _soundingKey;

  @override
  PitchDroneSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    const defaults = PitchDroneSettings();

    return PitchDroneSettings(
      selectedKey:
          prefs.getString(AppConstants.prefPitchDroneKey) ??
          defaults.selectedKey,
      saKey: prefs.getString(AppConstants.prefSaKey) ?? defaults.saKey,
      pitchNaming: PitchTradition.fromStorage(
        prefs.getString(AppConstants.prefPitchNaming),
        fallback: defaults.pitchNaming,
      ),
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
      await _startDrone(key);
    }
  }

  /// Sets where the singer's Sa sits, as a pitch name.
  Future<void> setSaKey(String key) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.prefSaKey, key);
    state = state.copyWith(saKey: key);
  }

  /// Sets how pitches are named when a song's tradition is unclear.
  Future<void> setPitchNaming(PitchTradition tradition) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.prefPitchNaming, tradition.storageKey);
    state = state.copyWith(pitchNaming: tradition);
  }

  /// Sets drone interval ('Pa' for the fifth or 'Ma' for the fourth).
  Future<void> setDroneInterval(String interval) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.prefPitchDroneInterval, interval);
    state = state.copyWith(droneInterval: interval);

    if (state.dronePlaying) {
      await _startDrone(_soundingKey ?? state.selectedKey);
    }
  }

  /// Sets audio volume [0.0, 1.0].
  Future<void> setVolume(double volume) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(AppConstants.prefPitchDroneVolume, volume);
    state = state.copyWith(volume: volume);
    await _audio.setVolume(volume);
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

  /// Plays a synthesized reference pitch cue for [key].
  ///
  /// [key] is the pitch to sound and does **not** become the saved default —
  /// a song opening on its own key must not overwrite the user's setting.
  /// Returns false when no sound was produced, so the caller can say so.
  Future<bool> playPitchCue({String? key}) async {
    await _audio.setVolume(state.volume);
    final played = await _audio.playCue(key ?? state.selectedKey);
    state = played
        ? state.copyWith(clearError: true)
        : state.copyWith(lastError: 'Could not play the pitch cue.');
    return played;
  }

  /// Toggles the continuous Shruti Box drone. Returns false if starting failed.
  Future<bool> toggleDrone({String? key}) async {
    if (state.dronePlaying) {
      await stopDrone();
      return true;
    }
    return _startDrone(key ?? state.selectedKey);
  }

  /// Starts the drone on [key]. Only reports playing when sound really began.
  Future<bool> _startDrone(String key) async {
    await _audio.setVolume(state.volume);
    final started = await _audio.startDrone(
      noteKey: key,
      interval: state.droneInterval,
    );

    _soundingKey = started ? key : null;
    state = started
        ? state.copyWith(dronePlaying: true, clearError: true)
        : state.copyWith(
            dronePlaying: false,
            lastError: 'Could not start the drone.',
          );
    return started;
  }

  /// Stops continuous Shruti Box drone playback.
  Future<void> stopDrone() async {
    await _audio.stopDrone();
    _soundingKey = null;
    state = state.copyWith(dronePlaying: false);
  }

  /// Clears [PitchDroneSettings.lastError] once the UI has shown it.
  void clearError() {
    if (state.lastError != null) state = state.copyWith(clearError: true);
  }
}

/// Riverpod provider for Pitch Pipe, Shruti Box drone, and 5-Tier Font Scale.
final pitchDroneProvider =
    NotifierProvider<PitchDroneNotifier, PitchDroneSettings>(
      PitchDroneNotifier.new,
    );
