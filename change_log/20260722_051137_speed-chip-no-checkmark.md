# Remove the checkmark from the selected speed chip

Implements plan `plans/20260722_051137_speed-chip-no-checkmark.md`.

## What changed

### `lib/widgets/auto_scroll_controls.dart`
- Added `showCheckmark: false` to the speed `ChoiceChip` in
  `_ManualControls`. The selected speed (e.g. `1x`) now shows only its
  filled highlight, with no tick — matching the mode toggle, which also
  has no selected-icon tick.
- No behaviour change: tapping a chip still sets the speed.

## Verification
- `flutter analyze` — no issues.
- `flutter test` (performance screen) — all pass; the `1x` chip is still
  found by its label.
