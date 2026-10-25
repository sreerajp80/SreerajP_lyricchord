import 'package:intl/intl.dart';

/// The locale to hand to `intl` for dates and numbers (engineering standard
/// §8.3.2). A language with no `intl` data (Sanskrit, `sa`) is formatted with
/// English patterns, never Hindi, while the words around it stay translated.
///
/// [localeName] is an app locale such as `en`, `ml` or `sa` — for example
/// `AppLocalizations.of(context).localeName`.
String formattingLocale(String localeName) {
  final canonical = Intl.canonicalizedLocale(localeName);
  return NumberFormat.localeExists(canonical) ? canonical : 'en';
}

/// [value] with exactly [fractionDigits] decimals, in the conventions of
/// [localeName] (see [formattingLocale]). Use this for every number shown to
/// the user instead of `toStringAsFixed`.
String formatFixed(num value, int fractionDigits, String localeName) {
  final format = NumberFormat.decimalPattern(formattingLocale(localeName))
    ..minimumFractionDigits = fractionDigits
    ..maximumFractionDigits = fractionDigits;
  // Grouping (1,234) is not wanted for the small values the app shows.
  format.turnOffGrouping();
  return format.format(value);
}
