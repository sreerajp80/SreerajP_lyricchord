import 'package:lyricchord/models/song_title_words.dart';

/// The title a duplicated song gets.
///
/// Wraps the original title with [SongTitleWords.copyOf] (`"<title> (Copy)"` in
/// English) so a copy is easy to tell apart in the songbook. A blank title
/// falls back to [SongTitleWords.untitled] first, so a copy never shows up with
/// a leading space or nothing at all. Screens pass the user's language in
/// [words].
String copiedTitle(
  String title, [
  SongTitleWords words = SongTitleWords.english,
]) {
  final clean = title.trim();
  final base = clean.isEmpty ? words.untitled : clean;
  return words.copyOf(base);
}
