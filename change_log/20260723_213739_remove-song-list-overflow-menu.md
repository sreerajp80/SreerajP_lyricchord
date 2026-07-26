# Removed the three-dot (overflow) menu from the song list screen

**Plan:** [plans/20260723_213739_remove-song-list-overflow-menu.md](../plans/20260723_213739_remove-song-list-overflow-menu.md)

## What changed

1. **`lib/screens/song_list_screen.dart`**
   - Removed the `PopupMenuButton` (three-dot menu) from the app bar.
     It held "Import ChordPro file(s)", "Export all songs (ChordPro)",
     and "Select songs...". The non-selection app bar now shows only the
     Settings icon.
   - Removed the private `_exportAllChordPro` method — it was only
     called from that menu. `_exportSelectedChordPro` (used by selection
     mode) stays.
   - No imports were removed; `file_picker` and `chord_pro_service` are
     still used by the selected-export path.

2. **`test/screens/song_list_screen_test.dart`**
   - Removed the test `overflow popup menu has options for import,
     export all, and select mode` — the menu no longer exists.

## Why

Every menu item existed elsewhere:
- Import lives in Settings → Import & Export.
- Export all = long-press a song → Select all → Export selected.
- Select songs = long-press already starts selection mode.

## Verification

- `flutter analyze` — no issues from this change (4 pre-existing
  findings in setlist screens and `song_meta_fields.dart`, untouched
  here).
- `flutter test` — all 253 tests pass.
- `dart format` — both changed files formatted.
