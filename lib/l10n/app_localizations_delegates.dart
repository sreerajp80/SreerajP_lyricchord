import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/fallback_localizations.dart';

/// The localization delegates for the app's root `MaterialApp`, and for tests
/// that build a screen on its own.
///
/// The generated `AppLocalizations.localizationsDelegates` list names the
/// Flutter SDK's Material delegates. The app uses `material_ui`, which ships
/// its own; its `delegates` list also holds the Cupertino and Widgets ones.
///
/// The fallback delegates come first so they win for Sanskrit, which Flutter
/// has no framework strings for (`fallback_localizations.dart`).
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  FallbackMaterialLocalizationsDelegate(),
  FallbackCupertinoLocalizationsDelegate(),
  FallbackWidgetsLocalizationsDelegate(),
  ...GlobalMaterialLocalizations.delegates,
];
