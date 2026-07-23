# Remove the Export entry from the Settings Import/Export screen

**Status:** completed

## The issue

The Settings → "Import / Export" screen shows an "Export a song" list tile. It is
not a real action — it only tells the user to go to a song's share menu. Export
already works fully from the song screen (Export as ChordPro / Export as PDF).
The settings tile is dead, confusing text, so it should go.

Once the export tile is gone, the screen and its Settings card only do import.
Keeping the "Import / Export" name would be misleading, so the user-facing labels
should say "Import".

## Files to change

1. `lib/screens/import_export_screen.dart`
   - Remove the `Divider` and the "Export a song" `ListTile`
     (lines 34-43).
   - Change the AppBar title from `'Import / Export'` to `'Import'`.
   - Update the class doc comment to match (no longer mentions export here).

2. `lib/screens/settings_screen.dart`
   - Change the settings card `title` from `'Import / Export'` to `'Import'`
     (line 20).
   - Update the doc comment wording on line 6.

3. `test/screens/settings_screen_test.dart`
   - Update the two assertions that look for `'Import / Export'`
     (lines 61 and 71) to `'Import'`.

Note: the internal route path `import-export` stays the same (it is not shown to
the user), so `app_router.dart` needs no change.

## The plan for the fix

- Delete the export `ListTile` + `Divider` so the screen has only the "Import
  ChordPro file" action.
- Rename the user-facing "Import / Export" labels to "Import" in the screen
  AppBar and the settings card.
- Fix the widget test text expectations.
- Run `flutter analyze` and `flutter test` — both must be clean.

## Open question

If you would rather keep the name "Import / Export" as-is and only delete the
export tile, tell me and I will drop the rename part.
