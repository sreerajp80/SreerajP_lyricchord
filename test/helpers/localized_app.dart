import 'package:material_ui/material_ui.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/l10n/app_localizations_delegates.dart';

/// A bare [MaterialApp] with the app's localization delegates, so widgets
/// that call `AppLocalizations.of(context)` can be pumped on their own.
MaterialApp localizedApp(Widget home) {
  return MaterialApp(
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
