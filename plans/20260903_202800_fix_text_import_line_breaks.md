# Fix Missing Line Breaks When Importing Text Files

**Status:** complete

## Issue

When importing songs from text files or external sources, line breaks inside lyrics are not always recognized. This causes lines to run together into a single paragraph without breaks:
1. `ChordProService` and `ChordSheetParser` only normalize `\r\n` and `\r` into `\n`. They do not normalize Unicode line separators (`\u2028`), paragraph separators (`\u2029`), next-line characters (`\u0085`), or form feeds (`\u000C`). These characters are common when copying lyrics from web pages, iOS Notes, Google Docs, or Word.
2. If text was exported or transferred with escaped newlines (`\n` or `\r\n`) without actual newline characters, the parser treats the entire file as a single line.
3. In `ChordSheetView`, `Wrap` treats `\u2028` as regular whitespace (because `\s` in RegExp matches it), causing all words to flow together into a single continuous paragraph.
4. When picking files in `ImportExportScreen`, if a file is encoded in UTF-16 (common in Windows Notepad) or has a BOM (Byte Order Mark), `utf8.decode(bytes, allowMalformed: true)` leaves null characters (`\x00`), which breaks newline matching. Also, if `file.bytes` is null on desktop platforms, the file should be read safely from `file.path`.

## Files to change

1. `lib/services/chord_pro_service.dart`
   - Add a centralized `normalizeLineEndings(String text)` method that normalizes all line endings (`\r\n`, `\r`, `\u2028`, `\u2029`, `\u0085`, `\f`, and escaped `\n` if no real newlines exist) to standard `\n`.
   - Use `normalizeLineEndings` in `parse` and `parseMultiple`.
2. `lib/services/chord_sheet_parser.dart`
   - Normalize line endings with the same comprehensive line break rules in `parseSheet` before splitting into lines.
3. `lib/screens/import_export_screen.dart`
   - Add safe decoding that handles UTF-8 (with BOM stripping) and UTF-16 (LE and BE with BOM).
   - If `file.bytes` is null but `file.path` is available, read the file bytes from disk safely.
4. `android/app/src/main/kotlin/in/sreerajp/lyricchord/MainActivity.kt`
   - Explicitly specify `Charsets.UTF_8` when reading streams with `InputStreamReader`.
5. `test/services/chord_pro_service_test.dart`
   - Add tests verifying that files with `\u2028`, `\u2029`, `\u0085`, `\r\n`, `\r`, and escaped newlines preserve their lyric line breaks.
6. `test/services/chord_sheet_parser_test.dart`
   - Add tests verifying that `ChordSheetParser` parses sheets containing various line break styles into distinct `ChordLine`s.

## The plan for the fix

1. **Centralize line break normalization:**
   - In `ChordProService`, add `static String normalizeLineEndings(String text)`.
   - It replaces `\r\n`, `\r`, `\u2028`, `\u2029`, `\u0085`, and `\f` with `\n` (or `\n\n` for paragraph separators).
   - If the text contains no actual `\n` or `\r` but contains literal `\n` strings (such as from JSON/API dumps), unescape them into real `\n`.
   - Update `parse` and `parseMultiple` to use this method.
2. **Update ChordSheetParser:**
   - Update `parseSheet` in `lib/services/chord_sheet_parser.dart` to use the same normalization so that any sheet containing alternative line breaks splits cleanly into lines.
3. **Enhance file decoding in ImportExportScreen:**
   - Detect UTF-16 LE and UTF-16 BE BOMs and decode them into strings correctly.
   - If UTF-8 BOM (`\uFEFF`) is present, strip it.
   - Fall back to reading `File(file.path!).readAsBytesSync()` if `file.bytes` is null.
4. **Update Android file reading:**
   - In `MainActivity.kt`, use `InputStreamReader(inputStream, Charsets.UTF_8)`.
5. **Verify with automated tests:**
   - Run unit tests for `ChordProService` and `ChordSheetParser`.
   - Run `flutter analyze` and `flutter test`.

## After the change

- Format all touched files with `dart format .`.
- Ensure zero warnings from `flutter analyze`.
- Run all test suites with `flutter test`.
- Write change log to `change_log/20260903_202800_fix_text_import_line_breaks.md`.
