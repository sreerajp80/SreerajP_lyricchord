# Melody grid: follow the playing beat, and wrap long lines

**Status:** completed

## The issue

When a `{melody}` line is played in the song view, the highlighted (playing) beat
box moves forward, but the view does not move with it. On a phone, a long line
runs off the right edge of the screen, so the user cannot see which swara is
sounding.

Why it happens:

- `MelodyBeatGrid` draws the whole line as one row inside its own sideways
  `SingleChildScrollView`.
- Nothing ever scrolls that view (or the page's up/down scroll) to the current
  beat. The highlight just changes colour, even when the box is off screen.

A long single line is **not wrong** — the parser accepts it and it plays
correctly. It is only hard to read on a narrow screen.

## Files to change

- `lib/widgets/melody_beat_grid.dart` — the fix.
- `test/widgets/melody_beat_grid_test.dart` — new tests.
- `docs/carnatic_notation.md` — one short note on how long lines are shown
  (only if it already describes the grid layout).

No ARB / translation changes. No new packages.

## The fix

1. **Wrap long lines at bar lines.** Replace the single sideways row with a
   `Wrap`. Each tala group (the beats between two `|`) stays together as one
   unit, so a group is never split in the middle. If one group alone is wider
   than the screen, that group itself wraps between beat boxes (never inside a
   box). Result: the whole line is visible on screen, on two or more rows, with
   no sideways scrolling.
2. **Follow the playing beat.** Turn `MelodyBeatGrid` into a `StatefulWidget`
   that keeps one `GlobalKey` per beat box. When `currentBeat` changes, after
   the frame is drawn, call `Scrollable.ensureVisible` on that box. This moves
   the page's up/down scroll only when the box is off screen (or near the edge),
   using a short animation, so it does not jump on every beat.
3. **Do not fight auto-scroll.** `ensureVisible` is only asked to make the box
   visible, not to centre it, so when the sheet's own auto-scroll is running it
   only nudges the view if the playing beat would leave the screen.
4. **Tests.**
   - A long line in a narrow screen lays out on more than one row with no
     overflow error.
   - A group is not split when it fits on a row.
   - Changing `currentBeat` to a box below the screen scrolls the page so the
     box is visible.

## Not in this plan

- No change to the parser, the player, or the audio.
- No change to the swara text line in `chord_sheet_view.dart` (the plain
  swara line still scrolls sideways).

## Checks after the change

`dart format .`, `flutter analyze`, `flutter test`.
