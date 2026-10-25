import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';

/// How the tablet split view is laid out: the song list's width and whether
/// it is hidden.
class SplitViewLayout {
  /// The song list's share of the available width (0.0–1.0) while it is open.
  final double listFraction;

  /// True when the song list is hidden and the song fills the width.
  final bool listCollapsed;

  const SplitViewLayout({
    this.listFraction = AppConstants.splitDefaultListFraction,
    this.listCollapsed = false,
  });

  SplitViewLayout copyWith({double? listFraction, bool? listCollapsed}) {
    return SplitViewLayout(
      listFraction: listFraction ?? this.listFraction,
      listCollapsed: listCollapsed ?? this.listCollapsed,
    );
  }
}

/// Holds the tablet split-view layout and saves changes to
/// `shared_preferences`, so the list keeps its width across restarts.
class SplitViewNotifier extends Notifier<SplitViewLayout> {
  @override
  SplitViewLayout build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return SplitViewLayout(
      listFraction: _validFraction(
        prefs.getDouble(AppConstants.prefSplitListFraction),
      ),
      listCollapsed:
          prefs.getBool(AppConstants.prefSplitListCollapsed) ?? false,
    );
  }

  /// Saves a new list width (as a share of the width) and opens the list.
  Future<void> setListFraction(double fraction) async {
    final valid = _validFraction(fraction);
    state = state.copyWith(listFraction: valid, listCollapsed: false);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(AppConstants.prefSplitListFraction, valid);
    await prefs.setBool(AppConstants.prefSplitListCollapsed, false);
  }

  /// Hides or shows the song list.
  Future<void> setListCollapsed(bool collapsed) async {
    state = state.copyWith(listCollapsed: collapsed);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.prefSplitListCollapsed, collapsed);
  }

  /// A saved fraction outside (0, max] — or a missing or broken one — falls
  /// back to the default.
  static double _validFraction(double? value) {
    if (value == null ||
        value.isNaN ||
        value <= 0 ||
        value > AppConstants.splitMaxListFraction) {
      return AppConstants.splitDefaultListFraction;
    }
    return value;
  }
}

/// The tablet split-view layout, backed by [SplitViewNotifier].
final splitViewProvider = NotifierProvider<SplitViewNotifier, SplitViewLayout>(
  SplitViewNotifier.new,
);
