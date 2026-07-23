/// The title a duplicated song gets.
///
/// Appends `" (Copy)"` to the original title so a copy is easy to tell apart in
/// the songbook. A blank title falls back to `"Untitled Song (Copy)"` so a copy
/// never shows up with a leading space or nothing at all.
String copiedTitle(String title) {
  final clean = title.trim();
  final base = clean.isEmpty ? 'Untitled Song' : clean;
  return '$base (Copy)';
}
