# Restrict Import File Formats & Fix Export Duplicate File Name Extension

**Status:** Completed

## Issue
1. **Import File Restriction**: Currently, `FilePicker.platform.pickFiles` in `ImportExportScreen` allows picking any file without restricting file extension choices. The app should strictly restrict selection to ChordPro (`.cho`, `.pro`, `.chordpro`) and plain text (`.txt`) files.
2. **Export File Extension Collision**: When saving/exporting songs via `FilePicker.platform.saveFile`, if a file already exists in the target folder, the system appends `(1)` to the very end of the full file name (e.g., `song.chordpro (1)` instead of `song (1).chordpro`), because `saveFile` calls do not specify `type: FileType.custom` and `allowedExtensions`.

## Proposed Changes

### [lib/screens/import_export_screen.dart](../lib/screens/import_export_screen.dart)
- Update `_importChordPro` to configure `FilePicker.platform.pickFiles` with `type: FileType.custom` and `allowedExtensions: ['cho', 'pro', 'chordpro', 'txt']`.
- Add defensive Dart filter on picked files to ensure only files with `.cho`, `.pro`, `.chordpro`, or `.txt` extensions are parsed.
- Update `_exportAllChordPro` to specify `type: FileType.custom` and `allowedExtensions: ['chordpro']` in `FilePicker.platform.saveFile`.

### [lib/screens/song_list_screen.dart](../lib/screens/song_list_screen.dart)
- Update `_exportSelectedChordPro` to specify `type: FileType.custom` and `allowedExtensions: ['chordpro']` in `FilePicker.platform.saveFile`.

### [lib/screens/song_performance_screen.dart](../lib/screens/song_performance_screen.dart)
- Update `_exportPdf` to specify `type: FileType.custom` and `allowedExtensions: ['pdf']` in `FilePicker.platform.saveFile`.
- Update `_exportChordPro` to specify `type: FileType.custom` and `allowedExtensions: ['chordpro']` in `FilePicker.platform.saveFile`.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to verify zero warnings/errors.
- Run `flutter test` to ensure all existing test suites pass.
