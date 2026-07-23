# Change log: Performance controls moved to menu, pinch zoom added

**Plan:** `plans/20260722_043656_pinch-zoom-and-menu-controls.md`

## What changed

The performance screen used to have one big "Performance Controls" card
above the lyrics. When expanded, it covered most of the screen. Now:

- The card on screen holds **only Auto-scroll** (with the current key in
  its subtitle), so the lyrics get almost the whole screen.
- **Transpose** and **Show chords** moved to the top-bar dotted (⋮) menu.
  A new "Performance controls" item opens a bottom sheet with them. The
  sheet is live: the key read-out and the lyrics behind it update as you
  tap.
- The **Font size +/- buttons are gone**. You now pinch the lyrics with
  two fingers to zoom. Any pinch direction works (including a vertical
  pinch), the fingers can start anywhere on the sheet, and the zoom is
  smooth and continuous, clamped between 10 and 32. One finger still
  scrolls as before; while two fingers are down, scrolling pauses so the
  pinch is clean.

## Files changed

- `lib/providers/performance_provider.dart` — removed the step-button
  methods (`increaseFontSize`, `decreaseFontSize`, `fontSizeStep`); added
  `applyFontScale(startSize, factor)`, which scales from the size at
  pinch start (no compounding) and clamps to the min/max.
- `lib/widgets/performance_controls.dart` — slimmed to the Auto-scroll
  card only; title is now "Auto-scroll", subtitle keeps the live key.
- `lib/widgets/auto_scroll_controls.dart` — dropped its own
  "Auto-scroll" header row, which the new card title made redundant.
- `lib/widgets/transpose_sheet.dart` (new) — the bottom sheet with the
  Transpose row, the Show chords switch, and a small tip about pinching.
- `lib/screens/song_performance_screen.dart` — added the menu item; wrapped
  the lyric scroll view in a `Listener` + `GestureDetector`. The listener
  counts fingers and switches the scroll physics to
  `NeverScrollableScrollPhysics` while two or more are down; the scale
  gesture then sets the font size from the pinch.

## Tests

- `test/providers/performance_provider_test.dart` (new) — pinch scaling
  maths: scales from the start size, clamps at 10 and 32, `resetAll`.
- `test/screens/song_performance_screen_test.dart` — transpose, reset,
  and show-chords now tested through the menu + bottom sheet; two new
  pinch tests (vertical pinch out zooms in, pinch in zooms out); the
  auto-scroll tests expand the new "Auto-scroll" card.
- `test/screens/song_list_screen_test.dart` — the tablet dual-pane check
  now looks for "Auto-scroll" instead of "Performance Controls".

`flutter analyze` clean; all 201 tests pass; `dart format .` run.
