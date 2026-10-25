import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';

/// The value saved for "follow the phone's language".
const String systemLanguageValue = 'system';

/// The app languages the picker can offer: every language the app has strings
/// for (`AppLocalizations.supportedLocales`), template first. Malayalam and
/// Sanskrit appear here once their ARB files exist (Phase 10 of the guideline
/// plan).
List<String> get availableLanguageCodes => [
  for (final locale in AppLocalizations.supportedLocales) locale.languageCode,
];

/// The one place that holds the app language (engineering standard §8.4).
///
/// `null` means "follow the phone": `MaterialApp` then resolves the phone's
/// language against the supported ones. The choice is read from
/// `shared_preferences` (key `app_language`) before the first frame, because
/// the preferences are loaded during start-up.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final saved =
        ref
            .watch(sharedPreferencesProvider)
            .getString(AppConstants.prefAppLanguage) ??
        systemLanguageValue;
    return availableLanguageCodes.contains(saved) ? Locale(saved) : null;
  }

  /// [value] is [systemLanguageValue] or a language code. Saves it and applies
  /// it at once, app-wide, without a restart.
  Future<void> setLanguage(String value) async {
    final chosen = availableLanguageCodes.contains(value)
        ? value
        : systemLanguageValue;
    await ref
        .read(sharedPreferencesProvider)
        .setString(AppConstants.prefAppLanguage, chosen);
    state = chosen == systemLanguageValue ? null : Locale(chosen);
  }
}

/// The chosen app language, or `null` to follow the phone.
final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

/// Picks the app language for [deviceLocale]: the phone's language when the
/// app has it, otherwise the template language (English).
Locale resolveAppLocale(Locale? deviceLocale, Iterable<Locale> supported) {
  for (final locale in supported) {
    if (locale.languageCode == deviceLocale?.languageCode) return locale;
  }
  return supported.first;
}
