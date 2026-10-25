# Melody grid: follow the playing beat, and wrap long lines

Implements plan: `plans/20261025_175816_melody-grid-follow-playing-beat.md`

## What was wrong

A `{melody}` line was drawn as one long row that scrolled sideways. During
playback the highlighted beat moved off the right edge of a phone screen, and
nothing scrolled to it, so the user could not see what was playing.

## What changed

- `lib/widgets/melody_beat_grid.dart`
  - The line now wraps onto more rows instead of scrolling sideways. Each tala
    group (the beats between bar lines) is one `Wrap`, so a group moves down to
    the next row as a whole. Only a group wider than the row by itself breaks,
    and then between boxes. The bar-line gap is now the outer `Wrap`'s spacing
    (14 px, same as before).
  - The widget is now a `StatefulWidget` with one `GlobalKey` per beat box.
    When the playing beat changes, it calls `Scrollable.ensureVisible` after the
    frame. It uses `keepVisibleAtEnd` when moving forward and
    `keepVisibleAtStart` when the beat jumps back (a loop starting again), so
    the page only moves when the box would be off screen. This does not pull
    the sheet's own auto-scroll around on every beat.
- `test/widgets/melody_beat_grid_test.dart`
  - Updated the tala-group test and the long-line test for the new layout.
  - New tests: a group that fits is not split; a group wider than the row does
    not overflow; the sheet scrolls to a playing beat below the screen; the
    sheet does not move when the playing beat is already visible.
- `test/widgets/melody_keypad_sheet_test.dart`
  - The `tapKey` helper found keypad keys as "text inside a `Wrap`". The grid
    preview now also uses a `Wrap`, so the helper now leaves out text inside
    `MelodyBeatGrid`.

## Not changed

- `docs/carnatic_notation.md` does not describe the grid layout, so no doc
  change was needed.
- No parser, player, audio, or translation changes.

## Checks

- `dart format .` — clean.
- `flutter analyze` — no issues.
- `flutter test` — all 1274 tests pass.
- Not yet checked by hand on a device.
