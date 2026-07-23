# Compact performance-view header (M/T · play · speed · status line)

Implements plan
`plans/20260722_055349_compact-performance-header.md`.

## What changed

The performance view's auto-scroll controls were in a collapsible `Card`
(`ExpansionTile`). They are now a compact, always-visible header that matches the
supplied mockup.

### `lib/widgets/auto_scroll_controls.dart`
- Rebuilt as one compact row:
  `[ M / T toggle ] [ play ] … [ mode control ]`, the mode control right-aligned.
- **M / T toggle** is now two round buttons (`_CircleToggle`): the selected mode
  is a filled primary circle, the other an outlined circle. Each stays a ~40 dp
  tap target and keeps its `Manual` / `Tempo` tooltip.
- **Play** is a round filled button (`IconButton.filled`, primary fill). In Tempo
  mode it stays disabled until there is a real length, as before.
- **Manual mode** shows the `0.5x 1x 2x` speed chips (unchanged).
- **Tempo mode** shows only the compact `− count +` measures stepper; the old
  multi-line duration/px read-out was removed from the row.

### `lib/widgets/performance_controls.dart`
- Dropped the `Card` + `ExpansionTile`; the header is now a slim always-visible
  `Column`: the controls row plus one muted status line.
- Status line reads `Auto-scroll · Key G · 120 BPM` (with `(+n)` after the key
  when transposed). In Tempo mode it appends ` · {measures} bars · {m:ss}`, so
  the "ends at song end" length the old read-out showed is not lost.

### `test/screens/song_performance_screen_test.dart`
- Removed the "expand first" taps in the three tests that opened the old
  `ExpansionTile`. Renamed the expand test to
  "the auto-scroll controls are visible without tapping" and assert M / T / 1x
  show immediately.

## Not changed
- `autoScrollProvider`, `PerformanceSettings`, and `AutoScrollCalculator` — all
  play / speed / measures / tempo logic is untouched. This was a UI-layout change
  only.

## Verification
- `flutter analyze` — no issues.
- `flutter test` — all 201 tests pass.
- `dart format .` — clean.
