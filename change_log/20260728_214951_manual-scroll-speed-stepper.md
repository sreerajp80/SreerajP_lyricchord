# Manual auto-scroll speed: stepper instead of three fixed chips

Implements [plans/20260728_212325_manual-scroll-speed-stepper.md](../plans/20260728_212325_manual-scroll-speed-stepper.md).

## Why

Manual auto-scroll only offered `0.5x`, `1x` and `2x`. Users said even the
slowest was too fast, and there was no way to fine-tune.

## What changed

Manual mode now has a `− 1.00x +` stepper in place of the three chips.

- Range **0.10x to 2.00x**, one tap changes it by **0.05x**.
- Songs still open at **1.00x**.
- At the unchanged base of 40 logical pixels per second that is 4 px/s at the
  slowest and 80 px/s at the fastest — 39 stops in all.

### `lib/providers/auto_scroll_provider.dart`

- Removed `speedChoices`. Added `minSpeed` (0.10), `maxSpeed` (2.00),
  `speedStep` (0.05) and `defaultSpeed` (1.00).
- `setSpeed` used to ignore anything not in the old list. It now clamps to the
  range and snaps to the nearest step, so a bad value can never reach the
  ticker.
- Added `increaseSpeed()` and `decreaseSpeed()`.
- Added the private `_snapSpeed`, which does its work in whole hundredths of an
  `x`. Adding `0.05` to a `double` over and over drifts (`0.1 + 0.05 + 0.05` is
  not exactly `0.2`), which would have slid the value off the grid and shown
  labels like `1.1500000000000001x`. Integers cannot drift.

### `lib/widgets/auto_scroll_controls.dart`

- `_SpeedChips` replaced by `_SpeedStepper`, built to match the existing
  measures stepper so the two modes look like one control swapping its middle
  value.
- The `−` and `+` buttons switch off at the ends of the range rather than
  silently doing nothing.
- Added the public `formatSpeedLabel`, which always shows two decimals plus an
  `x` (`0.10x`, `1.00x`). Fixed width stops the row jumping as the number
  changes. Stage Mode reuses it.
- Both steppers now use `VisualDensity.compact`, so the row still fits on a
  narrow phone with the metronome beat showing.

### Other

- `lib/services/auto_scroll_calculator.dart` — doc comments only. The maths
  (`base × multiplier`) is unchanged.
- `lib/screens/help/help_content.dart` — the help line now describes the range
  and the step.

## Tests

- `test/providers/auto_scroll_provider_test.dart` — replaced the old
  "only accepts one of the offered speeds" test with three: snapping and
  clamping, stepping to both ends, and a drift check that walks 30 steps and
  asserts every value stays an exact multiple of the step.
- `test/services/auto_scroll_calculator_test.dart` — added a fine-multiplier
  case (`0.15`, `0.10`).
- `test/screens/song_performance_screen_test.dart` — the old test looked for the
  `1x` chip; it now expects `1.00x`, plus a new test that steps the speed up and
  down through the buttons.

## Checks

`flutter analyze` clean, `flutter test` all green (308 tests), `dart format .`
run.
