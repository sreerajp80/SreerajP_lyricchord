/// Turns a song title into a safe file name for exports (PDF / ChordPro).
///
/// Keeps Unicode letters and digits, so a Malayalam title survives and becomes
/// the file name. Only characters that are actually illegal in file names on
/// Android and iOS are removed: `\ / : * ? " < > |` and control characters.
/// Whitespace is collapsed to a single `_`. An empty result falls back to
/// `song`, so a stray title never breaks the export path.
String safeFileName(String title) {
  final cleaned = title
      .trim()
      // Drop file-system illegal characters and control characters. Everything
      // else (including Malayalam letters) is kept.
      .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '')
      .replaceAll(RegExp(r'\s+'), '_');
  return cleaned.isEmpty ? 'song' : cleaned;
}
