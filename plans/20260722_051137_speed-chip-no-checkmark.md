# Remove the checkmark from the selected speed chip

**Status:** completed

## The issue

In the Auto-scroll Manual controls, the selected speed chip (e.g. `1x`)
shows a checkmark. The user does not want the tick — the filled highlight
already shows which speed is selected, and this matches the mode toggle,
which no longer shows a selected-icon tick.

## Files to change

- `lib/widgets/auto_scroll_controls.dart` — the `ChoiceChip` for the speed
  choices.

## The plan for the fix

- Add `showCheckmark: false` to the `ChoiceChip` in `_ManualControls`.
- Nothing else changes — selection still works and is shown by the filled
  (selected) chip colour.

## Verification

- `flutter analyze` clean.
- `flutter test` (the speed chip test still finds `1x` by its label).
