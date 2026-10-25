import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';

/// Declared languages that Flutter has no framework translation for
/// (engineering standard §8.3.1; language pack §1.1). Keep in step with
/// `docs/PROJECT_PROFILE.md` §4.
const Set<String> kFrameworkFallbackLanguages = {'sa'};

/// The language framework strings fall back to: the template language,
/// English — never Hindi, so no Hindi text can appear in a Sanskrit screen.
const Locale kFrameworkFallbackLocale = Locale('en');

/// Material strings (date picker, dialog buttons, text menus) for a fallback
/// language come from English. The app's own strings stay in that language.
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      kFrameworkFallbackLanguages.contains(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(kFrameworkFallbackLocale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<dynamic> old) => false;
}

/// Cupertino strings for a fallback language come from English.
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      kFrameworkFallbackLanguages.contains(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(kFrameworkFallbackLocale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<dynamic> old) => false;
}

/// Widgets strings (text direction and similar) for a fallback language come
/// from English.
class FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      kFrameworkFallbackLanguages.contains(locale.languageCode);

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(kFrameworkFallbackLocale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<dynamic> old) => false;
}
