/// The words the app puts into a song's saved title on its own: the name for a
/// song with no title, and the name for a copy.
///
/// These titles are saved in the database, so they must be in the user's
/// language. Models and services must not hold UI text, so the screen builds
/// this from its localizations (`songTitleWords` in `lib/l10n/l10n_labels.dart`)
/// and passes it down. [english] is only the fallback for tests and for code
/// that runs without a screen.
class SongTitleWords {
  const SongTitleWords({required this.untitled, required this.copyOf});

  /// The English name for a song with no title.
  static const String englishUntitled = 'Untitled Song';

  /// English words, used when no localized words are passed.
  static const SongTitleWords english = SongTitleWords(
    untitled: englishUntitled,
    copyOf: _englishCopyOf,
  );

  /// The title for a song saved without one, e.g. "Untitled Song".
  final String untitled;

  /// The title for a copy of a song titled `title`, e.g. "<title> (Copy)".
  final String Function(String title) copyOf;

  static String _englishCopyOf(String title) => '$title (Copy)';
}
