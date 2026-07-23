import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyriccord/core/constants/app_constants.dart';
import 'package:lyriccord/models/lyric_font.dart';
import 'package:lyriccord/providers/theme_mode_provider.dart';

/// Holds the chosen lyric font and saves changes to `shared_preferences`.
///
/// Mirrors [ThemeModeNotifier]: the value is loaded once at build and every
/// change is written back so it survives a restart.
class LyricFontNotifier extends Notifier<LyricFont> {
  @override
  LyricFont build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return LyricFont.fromId(prefs.getString(AppConstants.prefLyricFont));
  }

  /// Changes the lyric font and saves it for next launch.
  Future<void> setFont(LyricFont font) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.prefLyricFont, font.id);
    state = font;
  }
}

/// The current lyric font, backed by [LyricFontNotifier].
final lyricFontProvider = NotifierProvider<LyricFontNotifier, LyricFont>(
  LyricFontNotifier.new,
);
