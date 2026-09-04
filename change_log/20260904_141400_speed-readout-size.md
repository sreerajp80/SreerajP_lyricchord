# Bigger auto-scroll speed read-out

Implements [plans/20260904_140934_speed-readout-size.md](../plans/20260904_140934_speed-readout-size.md).

## What changed

- `lib/widgets/performance_controls.dart` — in `_SpeedReadout`, the text
  style for the `0.20x` speed read-out changed from `titleSmall` (14 sp)
  to `titleMedium` (16 sp). Colour, tabular figures, tooltip, padding and
  position are unchanged.

## Checks

- `flutter analyze` — no issues.
- `flutter test` — all 886 tests passed.
