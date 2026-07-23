# Change log: Duplicate / "Save as copy" + Undo-redo in the lyrics editor

Implements plan
[plans/20260722_074500_duplicate-and-undo-redo.md](../plans/20260722_114500_duplicate-and-undo-redo.md).

## What changed

### 1. Duplicate a song / "Save as copy" (arrangement variant)

- **New pure helper** `lib/core/utils/song_copy.dart` — `copiedTitle(String)`
  builds the copy's title (`"<title> (Copy)"`, or `"Untitled Song (Copy)"` for a
  blank title). Shared by every copy path so the naming lives in one place.
- **`lib/repositories/song_repository.dart`** — added
  `Future<int> duplicate(SongNote)`: inserts a new row that copies the song,
  titled by `copiedTitle`, unstarred, with a fresh timestamp; the original is
  untouched.
- **`lib/providers/song_editor_provider.dart`** — added
  `SongEditorNotifier.saveAsCopy()`: saves the *current* draft (with any key or
  lyric changes made this session) as a brand-new song, without overwriting the
  song being edited.
- **`lib/widgets/song_card.dart`** — added an `onDuplicate` callback and a
  "Duplicate song" icon (`content_copy_outlined`) between the star and delete
  buttons.
- **`lib/screens/song_list_screen.dart`** — wired the card's duplicate action:
  calls `duplicate`, selects the new copy (for the tablet pane), shows a
  `Copied "<title>."` SnackBar, and reports storage errors as a SnackBar.
- **`lib/screens/song_editor_screen.dart`** — added a "Save as copy" item in a
  new overflow (`⋮`) menu, shown only when editing an existing song (a new song's
  plain Save already creates a new song).

### 2. Undo / redo in the lyrics editor

- **`lib/screens/song_editor_screen.dart`**
  - Added an `UndoHistoryController` wired to the lyrics `TextField`
    (`undoController:`), so undo/redo covers both typing and chord insertions.
  - Added **Undo** and **Redo** icon buttons in the app bar, enabled live from
    the controller's `canUndo` / `canRedo` via a `ValueListenableBuilder`.
  - After undo/redo the draft is synced by hand (`setLyrics`) — a programmatic
    text change does not fire `onChanged` — and focus returns to the field.
  - The undo history is cleared right after the song loads, so the first Undo can
    never wipe an existing song back to empty.
  - The controller is disposed with the others.

## Tests

- **New** `test/core/utils/song_copy_test.dart` — `copiedTitle` (normal, trimmed,
  blank).
- **New** `duplicate` test in `test/repositories/song_repository_test.dart` — the
  copy has a new id, the suffixed title, is unstarred, carries the other fields,
  and leaves the original untouched.
- `test/helpers/fake_song_repository.dart` — added a `duplicate` override so
  widget tests exercise real copy behaviour.
- `test/widgets/song_card_test.dart` — the duplicate icon fires its callback.
- `test/screens/song_list_screen_test.dart` — duplicating from the list adds a
  `"<title> (Copy)"` card and keeps the original.
- `test/screens/song_editor_screen_test.dart` — "Save as copy" stores a new song
  (with a changed key) and keeps the original; the menu is hidden for a new song;
  Undo reverts a lyrics edit.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 209 tests pass.
- `dart format .` — applied.

## Notes

- No new packages (`UndoHistoryController` is built into Flutter), no database
  migration, no network use — stays fully offline and within the hard rules.
- Undo/redo covers the lyrics field only, as requested (not the meta fields).
- Testing note: an unfocused empty `TextField` has an invalid selection, so
  Flutter's undo history does not push an empty baseline until the field is
  focused. The undo test focuses the field first (as a real user does) so the
  baseline commits before typing.
