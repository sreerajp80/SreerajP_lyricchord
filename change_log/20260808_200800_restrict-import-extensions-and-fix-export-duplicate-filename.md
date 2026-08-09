# Restrict Import Extensions and Fix Export Duplicate Extension Appending

## Plan Reference
[plans/20260808_200600_restrict-import-extensions-and-fix-export-duplicate-filename.md](../plans/20260808_200600_restrict-import-extensions-and-fix-export-duplicate-filename.md)

## Summary of Changes
1. **Restricted File Import Extensions**:
   - In `ImportExportScreen._importChordPro`, configured `FilePicker.platform.pickFiles` with `type: FileType.custom` and `allowedExtensions: ['cho', 'pro', 'chordpro', 'txt']`.
   - Added a defensive validation filter in Dart logic on picked files so only `.cho`, `.pro`, `.chordpro`, and `.txt` files are allowed for import parsing.
2. **Fixed Export Duplicate File Extension Appending**:
   - Specified `type: FileType.custom` and `allowedExtensions: ['chordpro']` or `['pdf']` for all `FilePicker.platform.saveFile` calls across `ImportExportScreen`, `SongListScreen`, and `SongPerformanceScreen`.
   - Registered the target extensions explicitly with OS save dialogs so duplicate filenames append `(1)` before the extension (e.g. `song (1).chordpro`) rather than after it (e.g. `song.chordpro (1)`).

## Verification
- Ran `flutter analyze` — clean (0 issues).
- Ran `flutter test` — all 208 tests passed.
