import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';

/// Holds the manual auto-scroll speed a song starts at, saved in
/// `shared_preferences`.
///
/// This is only the starting point. A song that has had its speed set opens at
/// its own speed and ignores this — see `SongNote.scrollSpeedSet`.
class DefaultScrollSpeedNotifier extends Notifier<double> {
  @override
  double build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getDouble(AppConstants.prefDefaultScrollSpeed);
    if (saved == null) return AutoScrollSettings.defaultSpeed;
    return snap(saved);
  }

  /// Saves [speed], clamped and snapped to the stepper grid first.
  Future<void> setSpeed(double speed) async {
    final value = snap(speed);
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(AppConstants.prefDefaultScrollSpeed, value);
  }

  /// One step faster.
  Future<void> increase() => setSpeed(state + AutoScrollSettings.speedStep);

  /// One step slower.
  Future<void> decrease() => setSpeed(state - AutoScrollSettings.speedStep);

  /// Back to 1.00x.
  Future<void> reset() => setSpeed(AutoScrollSettings.defaultSpeed);

  /// Puts [speed] inside the allowed range and on the step grid.
  ///
  /// The same rule the performance stepper uses, done in whole hundredths so
  /// repeated steps can never drift off the grid. A saved value that is not a
  /// real number falls back to the plain default.
  static double snap(double speed) {
    if (!speed.isFinite) return AutoScrollSettings.defaultSpeed;

    final step = (AutoScrollSettings.speedStep * 100).round();
    final min = (AutoScrollSettings.minSpeed * 100).round();
    final max = (AutoScrollSettings.maxSpeed * 100).round();
    final hundredths = (speed * 100).round().clamp(min, max);
    final snapped = (hundredths / step).round() * step;

    return snapped.clamp(min, max) / 100;
  }
}

/// The speed a song starts scrolling at when it has none of its own.
final defaultScrollSpeedProvider =
    NotifierProvider<DefaultScrollSpeedNotifier, double>(
      DefaultScrollSpeedNotifier.new,
    );
