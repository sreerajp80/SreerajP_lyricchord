# Fix analyzer warnings (unused imports + deprecated `value`)

**Status:** completed

## The issue

`flutter analyze` / the IDE shows four warnings:

1. [lib/screens/setlist_detail_screen.dart:7](../lib/screens/setlist_detail_screen.dart#L7) — unused import of `models/song_note.dart`.
2. [lib/screens/setlist_list_screen.dart:6](../lib/screens/setlist_list_screen.dart#L6) — unused import of `models/setlist.dart`.
3. [lib/widgets/setlist_song_picker_sheet.dart:3](../lib/widgets/setlist_song_picker_sheet.dart#L3) — unused import of `models/song_note.dart`.
4. [lib/widgets/song_meta_fields.dart:107](../lib/widgets/song_meta_fields.dart#L107) — `DropdownButtonFormField.value` is deprecated; Flutter says to use `initialValue` instead.

The project rule says `flutter analyze` must be clean.

## Files to change

- `lib/screens/setlist_detail_screen.dart`
- `lib/screens/setlist_list_screen.dart`
- `lib/widgets/setlist_song_picker_sheet.dart`
- `lib/widgets/song_meta_fields.dart`

## The fix

1. Remove the three unused import lines.
2. In `song_meta_fields.dart`, rename the `value:` parameter of the
   `DropdownButtonFormField<int?>` to `initialValue:`. The behavior is the
   same — it sets the starting selection of the dropdown.
3. Run `flutter analyze` and `flutter test` to confirm everything is clean.
4. Write a change log in `change_log/`.

No behavior change is expected. No new dependencies.
