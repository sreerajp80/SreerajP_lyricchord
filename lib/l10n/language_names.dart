/// Each declared language's name in its own script (its endonym), as the
/// language picker lists it (engineering standard §8.4, language pack §3).
///
/// These are never translated: a reader who cannot read the current language
/// must still find their own. Keep in step with `docs/PROJECT_PROFILE.md` §4.
const Map<String, String> languageEndonyms = {
  'en': 'English',
  'ml': 'മലയാളം',
  'sa': 'संस्कृतम्',
};

/// The endonym for [languageCode], or the code itself if it is not declared.
String languageEndonym(String languageCode) =>
    languageEndonyms[languageCode] ?? languageCode;
