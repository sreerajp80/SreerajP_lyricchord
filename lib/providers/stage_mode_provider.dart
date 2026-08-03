import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';

/// Live state of Stage Mode — the full-screen performing view.
///
/// Like the other performance state this is view state, not song data: it is
/// not stored in the database. Unlike auto-scroll settings it is deliberately
/// **not** reset when the user moves to another song, because Stage Mode is a
/// way of working for the whole set, not a per-song setting.
class StageModeState {
  /// True when the lyrics fill the screen and the system bars are hidden.
  final bool enabled;

  /// True while the translucent control bar (the HUD) is on show. Meaningless
  /// when [enabled] is false.
  final bool hudVisible;

  /// How long the HUD stays up after the last touch before it slides away.
  static const Duration hudTimeout = Duration(seconds: 4);

  const StageModeState({this.enabled = false, this.hudVisible = false});

  StageModeState copyWith({bool? enabled, bool? hudVisible}) {
    return StageModeState(
      enabled: enabled ?? this.enabled,
      hudVisible: hudVisible ?? this.hudVisible,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StageModeState &&
      other.enabled == enabled &&
      other.hudVisible == hudVisible;

  @override
  int get hashCode => Object.hash(enabled, hudVisible);

  @override
  String toString() =>
      'StageModeState(enabled: $enabled, hudVisible: $hudVisible)';
}

/// Turns Stage Mode on and off and tracks whether the HUD is showing.
///
/// The screen owns the auto-hide `Timer` and the system-bar calls; this only
/// holds the flags, so it stays testable without a widget.
class StageModeNotifier extends Notifier<StageModeState> {
  @override
  StageModeState build() => const StageModeState();

  /// Goes full screen. The HUD starts visible so the way back out is on screen
  /// straight away — the app bar with its back arrow is gone by then.
  void enter() {
    if (state.enabled) return;
    state = const StageModeState(enabled: true, hudVisible: true);
  }

  /// Leaves full screen and forgets the HUD.
  void exit() {
    if (!state.enabled) return;
    state = const StageModeState();
  }

  /// Enter or leave in one call.
  void toggle() => state.enabled ? exit() : enter();

  /// Shows the control bar (a single tap, or any button press).
  void showHud() {
    if (!state.enabled || state.hudVisible) return;
    state = state.copyWith(hudVisible: true);
  }

  /// Hides the control bar (the auto-hide timer, or a second tap).
  void hideHud() {
    if (!state.hudVisible) return;
    state = state.copyWith(hudVisible: false);
  }

  /// What a single tap does: show the bar if it is away, hide it if it is up.
  void toggleHud() => state.hudVisible ? hideHud() : showHud();
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
