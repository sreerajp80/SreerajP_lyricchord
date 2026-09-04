# Change log — Fix Missing Line Breaks When Importing Text Files

Implements plan: `plans/20260903_202800_fix_text_import_line_breaks.md`

## What changed

1. **`lib/core/utils/line_break_utils.dart`**
   - Created `normalizeLineBreaks(String content)` utility to normalize all line endings (`\r\n`, `\r`, `\u2028`, `\u2029`, `\u0085`, `\u000C`) into standard Unix newlines (`\n`, and `\n\n` for paragraph separators).
   - Automatically unescapes literal escaped `\n` or `\r\n` characters when text contains no raw newline characters.

2. **`lib/services/chord_pro_service.dart`**
   - Updated `parse`, `parseMultiple`, and `_withoutRagaAndTalaLines` to use `normalizeLineBreaks`.
   - Exposed `normalizeLineEndings` static method on `ChordProService` delegating to `normalizeLineBreaks`.

3. **`lib/services/chord_sheet_parser.dart`**
   - Updated `parseSheet` to normalize incoming lyric line breaks with `normalizeLineBreaks` before splitting into lines.

4. **`lib/screens/import_export_screen.dart`**
   - Added `decodeImportedBytes(Uint8List bytes)` helper to support UTF-8 (stripping UTF-8 BOM `\uFEFF`) and UTF-16 (little-endian and big-endian with BOM).
   - Added fallback to read `File(file.path!).readAsBytesSync()` if `file.bytes` is null on desktop platforms.

5. **`android/app/src/main/kotlin/in/sreerajp/lyricchord/MainActivity.kt`**
   - Explicitly specified `Charsets.UTF_8` in `InputStreamReader` when reading file intent streams.

6. **Tests**
   - Created `test/core/utils/line_break_utils_test.dart` testing `normalizeLineBreaks` across all line ending types and `decodeImportedBytes` across UTF-8 (with BOM) and UTF-16 (LE/BE).
   - Added `line break normalization` group in `test/services/chord_pro_service_test.dart`.
   - Added line break tests in `test/services/chord_sheet_parser_test.dart`.

## Verification

- `dart format .` — 190 files formatted (0 changed).
- `flutter analyze` — clean (No issues found).
- `flutter test` — all 852 tests passed.
