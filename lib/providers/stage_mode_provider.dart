import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';

import 'package:lyricchord/services/stage_quiet_mode_service.dart';
import 'package:lyricchord/services/stage_security_service.dart';

/// Live state of Stage Mode — the full-screen performing view.
class StageModeState {
  /// True when the lyrics fill the screen and the system bars are hidden.
  final bool enabled;

  /// True while the translucent control bar (the HUD) is on show.
  final bool hudVisible;

  /// True when touch inputs and navigation are locked to prevent accidental touches.
  final bool isLocked;

  /// True when incoming call ringers and notifications are muted automatically.
  final bool isQuietMode;

  /// How long the HUD stays up after the last touch before it slides away.
  static const Duration hudTimeout = Duration(seconds: 4);

  const StageModeState({
    this.enabled = false,
    this.hudVisible = false,
    this.isLocked = false,
    this.isQuietMode = false,
  });

  StageModeState copyWith({
    bool? enabled,
    bool? hudVisible,
    bool? isLocked,
    bool? isQuietMode,
  }) {
    return StageModeState(
      enabled: enabled ?? this.enabled,
      hudVisible: hudVisible ?? this.hudVisible,
      isLocked: isLocked ?? this.isLocked,
      isQuietMode: isQuietMode ?? this.isQuietMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StageModeState &&
      other.enabled == enabled &&
      other.hudVisible == hudVisible &&
      other.isLocked == isLocked &&
      other.isQuietMode == isQuietMode;

  @override
  int get hashCode => Object.hash(enabled, hudVisible, isLocked, isQuietMode);

  @override
  String toString() =>
      'StageModeState(enabled: $enabled, hudVisible: $hudVisible, isLocked: $isLocked, isQuietMode: $isQuietMode)';
}

/// Turns Stage Mode on and off, tracks HUD visibility, Stage Lock, and Stage Quiet Mode.
class StageModeNotifier extends Notifier<StageModeState> {
  @override
  StageModeState build() => const StageModeState();

  /// Goes full screen.
  void enter() {
    if (state.enabled) return;
    state = const StageModeState(enabled: true, hudVisible: true);
    if (state.isQuietMode) {
      ref.read(stageQuietModeServiceProvider).enableQuietMode();
    }
  }

  /// Leaves full screen and restores system states.
  void exit() {
    if (!state.enabled) return;
    if (state.isQuietMode) {
      ref.read(stageQuietModeServiceProvider).disableQuietMode();
    }
    state = const StageModeState();
  }

  /// Enter or leave in one call.
  void toggle() => state.enabled ? exit() : enter();

  /// Lock Stage view to prevent accidental screen touches.
  void lockStage() {
    state = state.copyWith(isLocked: true, hudVisible: false);
  }

  /// Authenticates using biometric/PIN to unlock Stage view.
  Future<bool> unlockStageWithAuth({
    String reason = 'Authenticate to unlock Stage View',
  }) async {
    final security = ref.read(stageSecurityServiceProvider);
    final isAvailable = await security.isSecurityAvailable();
    if (!isAvailable) {
      // Fallback: unlock directly if no hardware lock is set up
      state = state.copyWith(isLocked: false, hudVisible: true);
      return true;
    }

    final result = await security.authenticate(reason: reason);
    if (result.isSuccess) {
      state = state.copyWith(isLocked: false, hudVisible: true);
      return true;
    }
    return false;
  }

  /// Toggles Stage Quiet Mode on/off.
  Future<void> toggleQuietMode() async {
    final newQuiet = !state.isQuietMode;
    state = state.copyWith(isQuietMode: newQuiet);
    final quietService = ref.read(stageQuietModeServiceProvider);
    if (state.enabled) {
      if (newQuiet) {
        await quietService.enableQuietMode();
      } else {
        await quietService.disableQuietMode();
      }
    }
  }

  /// Shows the control bar.
  void showHud() {
    if (!state.enabled || state.hudVisible || state.isLocked) return;
    state = state.copyWith(hudVisible: true);
  }

  /// Hides the control bar.
  void hideHud() {
    if (!state.hudVisible) return;
    state = state.copyWith(hudVisible: false);
  }

  /// What a single tap does: show the bar if it is away, hide it if it is up.
  void toggleHud() {
    if (state.isLocked) return;
    state.hudVisible ? hideHud() : showHud();
  }
}

/// The live Stage Mode state.
final stageModeProvider = NotifierProvider<StageModeNotifier, StageModeState>(
  StageModeNotifier.new,
);

/// Whether the one-time Stage Mode gesture guide has already been shown.
///
/// Saved to `shared_preferences` so it appears once and never again. Without it
/// nobody discovers the double-tap and two-finger gestures.
class StageHelpSeenNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(AppConstants.prefStageHelpSeen) ?? false;
  }

  /// Remembers that the guide has been shown.
  Future<void> markSeen() async {
    if (state) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.prefStageHelpSeen, true);
    state = true;
  }
}

/// Has the Stage Mode gesture guide been seen yet?
final stageHelpSeenProvider = NotifierProvider<StageHelpSeenNotifier, bool>(
  StageHelpSeenNotifier.new,
);
