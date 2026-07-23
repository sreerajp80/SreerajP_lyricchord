# Change log — Remove the Export entry from the Settings Import screen

Implements plan `plans/20260722_072458_remove-export-from-settings.md`.

## Why

The Settings → "Import / Export" screen had an "Export a song" list tile that was
not a real action. It only told the user to use a song's share menu. Export
already works from the song screen (Export as ChordPro / Export as PDF), so the
tile was dead, confusing text. With export gone from this screen, the
"Import / Export" name no longer fit, so the labels were renamed to "Import".

## What changed

1. `lib/screens/import_export_screen.dart`
   - Removed the `Divider` and the "Export a song" `ListTile`. The screen now
     shows only the "Import ChordPro file" action.
   - AppBar title changed from "Import / Export" to "Import".
   - Updated the class doc comment.

2. `lib/screens/settings_screen.dart`
   - Settings card title changed from "Import / Export" to "Import".
   - Card subtitle changed to "Bring in ChordPro files as songs".
   - Updated the class doc comment.

3. `test/screens/settings_screen_test.dart`
   - Updated the two assertions that looked for "Import / Export" to "Import".

The internal route path `import-export` was left unchanged (not user-facing), so
`app_router.dart` needed no edit.

## Verification

- `flutter analyze` — no issues.
- `flutter test test/screens/settings_screen_test.dart` — all 7 tests passed.
