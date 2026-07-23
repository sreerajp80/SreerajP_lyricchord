# Plan: Move Performance Controls to the menu, add pinch zoom

**Status:** completed

## The issue

On the performance screen, the Performance Controls card sits above the
lyrics. When it is expanded (which it must be to reach Auto-scroll), it
eats most of the screen and very little lyric text is visible.

Requested changes:

1. Keep **Auto-scroll** visible on the screen (it is used live while
   performing).
2. Move the rest of the Performance Controls (**Transpose**, **Show
   chords**) into the top-bar dotted (overflow) menu.
3. Remove the **Font size** +/- buttons. Instead, the lyric text is
   resized by **pinch zoom** directly on the sheet:
   - Pinching in any direction works, including a vertical pinch.
   - The two fingers do NOT need to start at the same spot — they can be
     anywhere on the sheet (this is how Flutter's scale gesture already
     works, so no special handling is needed for that part).

## Files to change

| File | Change |
|------|--------|
| `lib/widgets/performance_controls.dart` | Strip the card down to only the Auto-scroll section. Remove transpose, show-chords, and font-size rows. The card stays collapsible but is much smaller; its subtitle keeps showing the current key. |
| `lib/widgets/transpose_sheet.dart` (new) | A modal bottom sheet with the Transpose row (−, key, +, Reset) and the Show chords switch. Opened from the overflow menu. It watches `performanceSettingsProvider` so it updates live while open. |
| `lib/screens/song_performance_screen.dart` | 1) Add a "Performance controls" item at the top of the overflow menu that opens the new bottom sheet. 2) Wrap the lyric scroll area in a pinch-zoom handler (details below). |
| `lib/providers/performance_provider.dart` | Add `beginFontScale()` / `applyFontScale(double factor)` (scales from the size at gesture start, clamped 10–32). Keep `increaseFontSize` / `decreaseFontSize` removed or kept unused — plan: **remove** them and the `fontSizeStep` constant, since no button uses them any more. |
| `test/...` | Update/add tests: provider test for the pinch scaling maths (clamping at 10 and 32); widget test that the overflow menu opens the transpose sheet and transpose still works; keep existing auto-scroll tests passing. |

## How pinch zoom will work

- A `GestureDetector` with `onScaleStart` / `onScaleUpdate` wraps the
  `SingleChildScrollView` that holds the sheet.
- On scale start we remember the current font size. On each update the
  new size = start size × gesture scale, clamped to 10–32. So zoom is
  smooth and continuous, not in 2-pt steps. The number shown nowhere —
  the text itself is the feedback.
- Flutter's scale gesture measures the distance between the two fingers
  wherever they are, in any direction — so a vertical pinch and fingers
  starting far apart both work naturally.
- Conflict with scrolling: one finger must still scroll the lyrics. A
  `Listener` counts touching pointers; while 2 or more fingers are down
  the scroll view's physics switch to `NeverScrollableScrollPhysics`, so
  the pinch wins and the sheet does not scroll-jitter during a zoom.
  With one finger, scrolling behaves exactly as before.
- Auto-scroll keeps working: font size changes re-report the content
  extent (already handled by `_reportExtentAfterFrame`).

## What does not change

- Auto-scroll UI and behaviour (Manual / Tempo, play, speeds).
- Transpose and show-chords logic — only where the buttons live.
- Reset-on-swipe (new song still opens at default size and key).
- No new packages; no permissions; fully offline.

## Steps

1. Add font-scale methods to `performance_provider.dart`; remove the
   step-button methods.
2. Slim `performance_controls.dart` to Auto-scroll only.
3. Create `transpose_sheet.dart` bottom sheet widget.
4. Wire the overflow menu item and the pinch handler in
   `song_performance_screen.dart`.
5. Update tests; run `flutter analyze` and `flutter test`; `dart format .`.
6. Write the change log.
