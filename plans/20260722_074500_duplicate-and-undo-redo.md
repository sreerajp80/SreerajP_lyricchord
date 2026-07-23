# Plan: Duplicate song / "Save as copy" + Undo-redo in the lyrics editor

**Status:** completed

## What the user asked for

1. **Duplicate song / "Save as copy"** — let a musician make an arrangement
   variant of a song (a copy they can then change, e.g. a different key) without
   overwriting the original.
2. **Undo / redo in the lyrics editor** — let the user step their lyrics text
   back and forward, including chord insertions.

## The issue / why

- Today the only way to make a variant is to retype the whole song. There is no
  "copy this song" action anywhere.
- The lyrics field is a plain `TextField`. There are no visible undo/redo
  controls, so a mistaken edit or a wrong chord tap can only be fixed by hand.

## Design decisions (kept small and like-for-like)

### A. Duplicate / Save as copy — two entry points

- **Songbook list (quick duplicate):** add a "Duplicate" icon button to each
  song card. It inserts a copy titled `"<title> (Copy)"`, unstarred, with a
  fresh timestamp, and shows a `SnackBar`. On a tablet it selects the new copy.
- **Editor ("Save as copy" = arrangement variant):** when editing an existing
  song, an overflow (`⋮`) menu in the editor app bar offers **"Save as copy"**.
  It saves the *current* draft (with any key/lyrics changes the user just made)
  as a brand-new song titled `"<title> (Copy)"`, leaving the original
  untouched. Hidden for a brand-new (unsaved) song, where plain Save already
  creates a new song.

Both paths share one pure helper, `copiedTitle(String)`, so the "(Copy)"
suffix logic lives in one tested place.

### B. Undo / redo in the lyrics field

- Attach an `UndoHistoryController` to the lyrics `TextField` (`undoController:`).
- Add **Undo** and **Redo** icon buttons to the editor app bar (before Save),
  enabled/disabled live from the controller's `canUndo` / `canRedo`.
- Undo/redo covers both typed text and programmatic chord insertions (chord
  taps set the controller value, which the history records).
- After undo/redo, sync the draft (`setLyrics(controller.text)`) because a
  programmatic change does not fire `onChanged`; then return focus to the field.
- Clear the history right after the initial load, so "undo" can never wipe an
  existing song back to blank.

Scope: undo/redo applies to the **lyrics** field only (as requested), not the
title/artist/key/BPM meta fields.

## Files to change

**Source**

- `lib/core/utils/song_copy.dart` — **new.** Pure `copiedTitle(String)` helper.
- `lib/repositories/song_repository.dart` — add `Future<int> duplicate(SongNote)`
  (id 0, `copiedTitle` title, `favorite: false`, fresh timestamp, then insert).
- `lib/providers/song_editor_provider.dart` — add
  `Future<int> saveAsCopy()` to `SongEditorNotifier` (build a `SongNote` from the
  current draft with id 0 and `copiedTitle`, insert, return new id).
- `lib/widgets/song_card.dart` — add an `onDuplicate` callback and a
  `content_copy` icon button (between the star and delete buttons).
- `lib/screens/song_list_screen.dart` — wire `onDuplicate`: call
  `repository.duplicate`, select the copy, show a `SnackBar`, handle
  `AppException`.
- `lib/screens/song_editor_screen.dart` — add the `UndoHistoryController`, the
  Undo/Redo app-bar buttons, the sync-after-undo logic, the initial
  history-clear, and (when editing) the "Save as copy" overflow item; dispose the
  controller.

**Tests**

- `test/helpers/fake_song_repository.dart` — add a `duplicate` override so widget
  tests exercise the real copy behaviour.
- `test/core/utils/song_copy_test.dart` — **new.** Cover `copiedTitle` (normal
  title, empty title).
- `test/repositories/song_repository_test.dart` — add a `duplicate` test (new id,
  suffixed title, unstarred, original untouched, count grows).
- `test/widgets/song_card_test.dart` — add an `onDuplicate` fires test.
- `test/screens/song_list_screen_test.dart` — add a "duplicate adds a copy" test.
- `test/screens/song_editor_screen_test.dart` — add "Save as copy" creates a new
  song, and an undo reverts a lyrics edit test.

## Out of scope / non-goals

- No undo/redo for the meta fields.
- No new database columns or migrations (a copy is just another row).
- No new packages — `UndoHistoryController` is built into Flutter; everything
  else uses the existing drift/Riverpod stack. Stays fully offline.

## Verification

- `flutter analyze` clean.
- `flutter test` green (new + existing).
- Manual: duplicate from the list; edit a song, change key, "Save as copy",
  confirm the original is unchanged and the copy carries the new key; type and
  tap chords, then undo/redo.
