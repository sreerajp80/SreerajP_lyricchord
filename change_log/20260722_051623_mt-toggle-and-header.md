# Shorten mode toggle to M/T, stop chip wrap, trim header

Implements plan `plans/20260722_051623_mt-toggle-and-header.md`.

## What changed

### `lib/widgets/auto_scroll_controls.dart` (`_ModeToggle`)
- Changed the segment labels from `Manual` / `Tempo` to single letters
  `M` / `T` to save width.
- Kept each segment easy to tap: the button style now sets a
  `minimumSize` of `Size(44, 40)` with 10 px horizontal padding, so the
  tap area stays large even though the label is one letter.
- Added a `tooltip` to each segment (`Manual`, `Tempo`) so the meaning is
  still discoverable on long-press and for accessibility.
- Effect: the narrower toggle frees enough width that the speed chips
  (`0.5x 1x 2x`) fit on one line again instead of wrapping. The `Wrap`
  stays as a fallback for very small screens.

### `lib/widgets/performance_controls.dart` (header)
- Added `minTileHeight: 40` to the `ExpansionTile` so the header row is
  shorter.
- Gave the `Auto-scroll` title a slightly smaller style (`titleSmall`) so
  the header reads a touch smaller.

### `test/screens/song_performance_screen_test.dart`
- Updated the toggle assertions and tap from `Manual` / `Tempo` to
  `M` / `T`.

## Verification
- `flutter analyze` — no issues.
- `flutter test` (performance + list screens) — all pass; no row overflow.
- `dart format` — clean.
