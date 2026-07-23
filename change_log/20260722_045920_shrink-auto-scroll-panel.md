# Shrink the Auto-scroll panel (slim header + one control row)

Implements plan `plans/20260722_045920_shrink-auto-scroll-panel.md`
(option B). Goal: give the lyrics more vertical space by making the
Auto-scroll card on the Performance screen shorter.

## What changed

### `lib/widgets/performance_controls.dart`
- Removed the leading icon from the `ExpansionTile`.
- Folded the key into the title (`Auto-scroll · Key G`, and
  `· Key G (+2)` when transposed) using `Text.rich`, so the tile no
  longer needs a subtitle line.
- Made the header dense: `dense: true`, `visualDensity: compact`, and a
  tighter `tilePadding`.

### `lib/widgets/auto_scroll_controls.dart`
- Replaced the stacked layout (full-width mode toggle, then the mode
  controls on a separate row) with a single `Row`:
  `[Manual|Tempo toggle] [mode controls]`.
- Added a compact `_ModeToggle` — a `SegmentedButton` with the segment
  icons dropped, `showSelectedIcon: false`, compact density, and
  shrink-wrapped tap targets, so it fits beside the controls.
- Tempo mode: made the stepper row narrow enough for the smaller space —
  dropped the "Measures" label and the `Spacer`, shrank the value box.
  The measures count now shows in the length read-out
  (`4 measures · 1:23 at 120 BPM`).
- No change to `autoScrollProvider`, the calculator, the play/pause
  ticker, or the scrolling behaviour — this is layout only.

### Tests
- `test/screens/song_performance_screen_test.dart` and
  `test/screens/song_list_screen_test.dart`: the header is now rich text,
  so the `find.text('Auto-scroll')` finders became
  `find.textContaining('Auto-scroll', findRichText: true)`.
- The Tempo test now checks for the stepper buttons
  (`find.byTooltip('More measures' / 'Fewer measures')`) instead of the
  removed standalone "Measures" label.

## Verification
- `flutter analyze` — no issues.
- `flutter test` — all 201 tests pass.
- `dart format` — clean.

## Result
The open Auto-scroll card drops from three stacked blocks to a slim
one-line header plus a single control row, freeing roughly 90–100 px for
the lyrics.
