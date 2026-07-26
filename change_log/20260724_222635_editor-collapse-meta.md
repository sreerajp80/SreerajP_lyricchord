# Change log: Collapse meta fields while editing lyrics

Implements plan `plans/20260724_214702_editor-collapse-meta.md`.

## Why

On a phone, opening the keyboard in the Song Editor squeezed the lyrics field
down to a single visible line, because the meta fields (Title, Artist, Key,
Tempo, Setlist) kept their full height at the top. It looked like the lyrics
could not be edited.

## What changed

`lib/screens/song_editor_screen.dart`

- Added a `bool _metaCollapsed` state field.
- Added a focus listener on the lyrics `FocusNode` (`_onLyricsFocusChange`):
  when the lyrics field gains focus the meta section collapses; when it loses
  focus the section expands again. The listener is added in `initState` and
  removed in `dispose`.
- Wrapped the meta section in an `AnimatedSize` that swaps between:
  - the full `SongMetaFields` (expanded), and
  - a new compact `_MetaSummary` one-line row (collapsed) showing
    `Title · Key · BPM`, with a chevron. Tapping it re-opens the full fields
    without dropping the keyboard.
- Added the private `_MetaSummary` widget at the end of the file. It reads
  straight from the editor's controllers, so the summary always shows the
  latest values.

`test/screens/song_editor_screen_test.dart`

- Added a widget test: focusing the lyrics field hides the Title field and
  shows the summary chevron; tapping the summary brings the fields back.

## Notes

- Used `AnimatedSize` (a single conditional child) rather than
  `AnimatedCrossFade`. `AnimatedCrossFade` keeps both subtrees alive, so the
  hidden Title field stayed in the widget tree; `AnimatedSize` genuinely removes
  the collapsed-away fields, which is cleaner and lets the test assert they are
  gone.
- No changes to providers, services, repositories, models, or the database.
  Layout/UX only.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 267 tests pass (was 266; +1 new test).
