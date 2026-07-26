# Remove the three-dot (overflow) menu from the song list screen

**Status:** completed

## The issue

The song list app bar has a three-dot menu with three items:

1. **Import ChordPro file(s)** — the same action already lives in
   Settings → Import & Export.
2. **Export all songs (ChordPro)** — the same result is possible from
   selection mode: long-press a song, tap **Select all**, then tap
   **Export selected**.
3. **Select songs...** — not needed, because long-pressing any song
   already enters selection mode.

So the whole menu duplicates actions that exist elsewhere. The user asked
to remove it.

## Files to change

| File | Change |
|------|--------|
| `lib/screens/song_list_screen.dart` | Remove the `PopupMenuButton` from the app bar actions (keep the Settings icon). Remove the now-unused `_exportAllChordPro` helper. Remove any imports that become unused. |
| `test/screens/song_list_screen_test.dart` | Remove the test `overflow popup menu has options for import, export all, and select mode` (the menu no longer exists). |

## The fix

1. In `song_list_screen.dart`, delete the `PopupMenuButton<String>` block
   (lines ~92–141). The non-selection app bar then shows only the
   Settings icon.
2. Delete the private `_exportAllChordPro` method, which was only called
   from the menu. Keep `_exportSelectedChordPro` (used by selection
   mode).
3. Remove imports that are no longer used after step 2 (check
   `file_picker`, `chord_pro_service`, etc. — most are still used by the
   selected-export path, so only remove what the analyzer flags).
4. Delete the overflow-menu widget test.
5. Run `flutter analyze` and `flutter test` — both must be clean.
6. Run `dart format .`.

## Not changed

- Settings → Import & Export keeps the import and "export all" actions,
  so no capability is lost.
- Selection mode (long-press, select all, export selected, delete) stays
  exactly as it is.
