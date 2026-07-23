# Shorten mode toggle to M/T, stop chip wrap, trim header

**Status:** completed

## The issue

1. The Manual / Tempo toggle is wide. Its width pushes the `2x` speed chip
   onto a second line in Manual mode.
2. The user wants the toggle shortened to single letters **M** and **T** to
   save space — but each letter must still be a comfortable tap target
   (the whole segment tappable, not shrunk to the letter's width).
3. The header could be a little shorter still.

## Files to change

- `lib/widgets/auto_scroll_controls.dart` — the `_ModeToggle`.
- `lib/widgets/performance_controls.dart` — the `ExpansionTile` header.
- `test/screens/song_performance_screen_test.dart` — the toggle labels are
  now `M` / `T` instead of `Manual` / `Tempo`.

## The plan for the fix

### 1. M / T toggle (`auto_scroll_controls.dart`)
- Change the segment labels from `Manual` / `Tempo` to `M` / `T`.
- Keep each segment easy to tap: give the button style a `minimumSize`
  (about 44 x 40) so the tap area stays large even though the label is one
  letter. Keep a little horizontal padding.
- Add a `tooltip` to each segment (`Manual`, `Tempo`) so the meaning is
  still discoverable on long-press and for accessibility.

### 2. Stop the chip wrap (Manual mode)
- The narrower M / T toggle frees enough width that the three chips
  (`0.5x 1x 2x`) fit on one line again. The `Wrap` stays (so on a very
  small screen it can still fall back to a second line instead of
  overflowing), it just will not need to wrap at normal widths.

### 3. Trim the header (`performance_controls.dart`)
- Add `minTileHeight` (about 40) to the `ExpansionTile` so the header row
  is shorter.
- Make the `Auto-scroll` title use a slightly smaller text style
  (`titleSmall`) so the header reads a touch smaller.

## Verification
- `flutter analyze` clean.
- `flutter test` — update the two toggle assertions/taps to `M` / `T`
  (or their tooltips); everything else stays green. Tests will also catch
  any row overflow.
