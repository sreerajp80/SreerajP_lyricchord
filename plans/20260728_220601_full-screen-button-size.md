# Make the full screen button bigger

**Status:** completed

> Done on 2026-07-28. The space check found a real overflow (46 px at 360 dp
> with the metronome on), so the outer `Row` became a `Wrap` as well — more than
> this plan described. Change log:
> [change_log/20260728_221200_full-screen-button-size.md](../change_log/20260728_221200_full-screen-button-size.md).

## The issue

The full screen button in the auto-scroll row looks small and weak next to its
neighbours. Everything around it — the `M`, the `T` and the play button — is a
40 dp circle with a filled or outlined background. The full screen button is a
bare icon at `VisualDensity.compact`, so it draws about 32 dp with no background
at all. It reads as an afterthought, and it is the smallest tap target in the
row.

Current code: [lib/widgets/auto_scroll_controls.dart:51-57](../lib/widgets/auto_scroll_controls.dart#L51-L57).

## The fix

Give it the same shape and weight as the mode buttons beside it:

- Drop `VisualDensity.compact`.
- Use `IconButton.filledTonal` so it has a visible background circle, like the
  `−` / `+` steppers, but not the strong primary fill of the play button — full
  screen is a normal action, not the main one.
- Wrap it in a `SizedBox` of 40×40, the same size as `_CircleToggle` uses for
  `M` and `T`, so all four controls line up.
- Add a small gap (`SizedBox(width: 8)`) before it, since it currently sits hard
  against the play button.

The icon, the tooltip and what it does all stay the same.

## Files to change

| File | Change |
|---|---|
| [lib/widgets/auto_scroll_controls.dart](../lib/widgets/auto_scroll_controls.dart) | The full screen button only — size, background and spacing. |

No provider, no logic, no test change. The existing test finds the button by its
`Full screen` tooltip, which is unchanged, so it keeps passing.

## Space check

The row currently holds, on a 360 dp phone: `M`+`T` (86) + gap (12) + play (48)
+ full screen (32) + stepper (about 140). That is roughly 318 dp inside a 336 dp
usable width. Growing the button to 40 and adding an 8 dp gap adds 16 dp, which
takes it to about 334 dp — it still fits, but only just, and the `Spacer` will
be squeezed to nothing.

So I will check this by running the app at a narrow width. If it is too tight I
will drop the gap back to 4 dp and report that.

## Checks after implementing

- `flutter analyze` clean, `flutter test` green, `dart format .`
- Look at the row on a narrow phone width and confirm nothing overflows.

## Change log

On completion, write `change_log/<timestamp>_full-screen-button-size.md`
referencing this plan.
