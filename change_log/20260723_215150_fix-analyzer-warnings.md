# Fix analyzer warnings (unused imports + deprecated `value`)

Implements plan: `plans/20260723_215150_fix-analyzer-warnings.md`

## What changed

1. `lib/screens/setlist_detail_screen.dart` — removed unused import of
   `models/song_note.dart`.
2. `lib/screens/setlist_list_screen.dart` — removed unused import of
   `models/setlist.dart`.
3. `lib/widgets/setlist_song_picker_sheet.dart` — removed unused import of
   `models/song_note.dart`.
4. `lib/widgets/song_meta_fields.dart` — changed the deprecated `value:`
   parameter to `initialValue:` on the setlist `DropdownButtonFormField`.
   Same behavior, new parameter name (deprecated after Flutter 3.33).

## Verification

- `flutter analyze` — no issues found.
- `flutter test` — all 253 tests passed.

No behavior change. No new dependencies.
