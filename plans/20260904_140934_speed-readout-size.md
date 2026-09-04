# Make the auto-scroll speed read-out bigger

**Status:** completed

## Issue

On the performance screen, the Manual-mode speed read-out (for example
`0.20x`) in the control row is small and hard to read on stage. The user
asked for it to be a little bigger.

## Files to change

- `lib/widgets/performance_controls.dart` — the `_SpeedReadout` widget.

## Plan for the fix

1. In `_SpeedReadout.build`, change the text style from
   `theme.textTheme.titleSmall` (14 sp) to `theme.textTheme.titleMedium`
   (16 sp), keeping the same colour and tabular figures.
2. Keep everything else the same: same tooltip, same padding, same
   position in the row. The row already has room, so no layout change is
   needed.
3. Run `flutter analyze` and `flutter test` to confirm nothing breaks.

## Notes

- The same helper `formatSpeedLabel` is used by the gesture flash and the
  stage HUD. Those are not touched, so their sizes stay as they are.
