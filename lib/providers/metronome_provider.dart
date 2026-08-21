import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/models/metronome_settings.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/services/metronome_audio_service.dart';

/// Holds the saved [MetronomeSettings] and saves changes to
/// `shared_preferences`.
///
/// Mirrors [ThemeModeNotifier]: the value is loaded once at build and every
/// change is written back so it survives a restart.
class MetronomeSettingsNotifier extends Notifier<MetronomeSettings> {
  @override
  MetronomeSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    const defaults = MetronomeSettings();

    final savedBeats = prefs.getInt(AppConstants.prefMetronomeBeatsPerBar);
    return MetronomeSettings(
      enabled:
          prefs.getBool(AppConstants.prefMetronomeEnabled) ?? defaults.enabled,
      flash: prefs.getBool(AppConstants.prefMetronomeFlash) ?? defaults.flash,
      click: prefs.getBool(AppConstants.prefMetronomeClick) ?? defaults.click,
      volume:
          prefs.getDouble(AppConstants.prefMetronomeVolume) ?? defaults.volume,
      // Ignore a saved value that is not one of the offered time signatures, so
      // an edited or stale preference cannot leave the picker with no selection.
      beatsPerBar: MetronomeSettings.beatsPerBarChoices.contains(savedBeats)
          ? savedBeats!
          : defaults.beatsPerBar,
      accent:
          prefs.getBool(AppConstants.prefMetronomeAccent) ?? defaults.accent,
    );
  }

  /// Turns the whole metronome on or off.
  Future<void> setEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.prefMetronomeEnabled, enabled);
    state = state.copyWith(enabled: enabled);
  }

  /// Turns the visual flash on or off.
  Future<void> setFlash(bool flash) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.prefMetronomeFlash, flash);
    state = state.copyWith(flash: flash);
  }

  /// Turns the click sound on or off.
  Future<void> setClick(bool click) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.prefMetronomeClick, click);
    state = state.copyWith(click: click);
  }

  /// Sets the click loudness (0.0–1.0) and applies it to the live players.
  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(
      MetronomeSettings.minVolume,
      MetronomeSettings.maxVolume,
    );
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(AppConstants.prefMetronomeVolume, clamped);
    state = state.copyWith(volume: clamped);
    await ref.read(metronomeAudioProvider).setVolume(clamped);
  }

  /// Sets how many beats make one bar. Values outside
  /// [MetronomeSettings.beatsPerBarChoices] are ignored.
  Future<void> setBeatsPerBar(int beatsPerBar) async {
    if (!MetronomeSettings.beatsPerBarChoices.contains(beatsPerBar)) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(AppConstants.prefMetronomeBeatsPerBar, beatsPerBar);
    state = state.copyWith(beatsPerBar: beatsPerBar);
  }

  /// Turns the louder beat 1 on or off.
  Future<void> setAccent(bool accent) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.prefMetronomeAccent, accent);
    state = state.copyWith(accent: accent);
  }
}

/// The current metronome settings, backed by [MetronomeSettingsNotifier].
final metronomeSettingsProvider =
    NotifierProvider<MetronomeSettingsNotifier, MetronomeSettings>(
      MetronomeSettingsNotifier.new,
    );
