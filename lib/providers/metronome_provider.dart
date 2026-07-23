import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyriccord/core/constants/app_constants.dart';
import 'package:lyriccord/models/metronome_settings.dart';
import 'package:lyriccord/providers/theme_mode_provider.dart';

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
    return MetronomeSettings(
      enabled:
          prefs.getBool(AppConstants.prefMetronomeEnabled) ?? defaults.enabled,
      flash: prefs.getBool(AppConstants.prefMetronomeFlash) ?? defaults.flash,
      click: prefs.getBool(AppConstants.prefMetronomeClick) ?? defaults.click,
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
}

/// The current metronome settings, backed by [MetronomeSettingsNotifier].
final metronomeSettingsProvider =
    NotifierProvider<MetronomeSettingsNotifier, MetronomeSettings>(
      MetronomeSettingsNotifier.new,
    );
