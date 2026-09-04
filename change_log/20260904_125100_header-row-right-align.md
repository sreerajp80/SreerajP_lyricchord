# Header read-out and icons moved to the right edge

Implements
[plans/20260904_124258_header-row-right-align.md](../plans/20260904_124258_header-row-right-align.md).

## What changed

The speed, the chords icon, the melody icon and the pitch button now sit hard
against the right edge of the header, as in the picture the user sent. Before
they bunched up next to the full screen button with a wide empty gap after them.

`lib/widgets/performance_controls.dart` — the `Wrap` that holds the row is now
inside `SizedBox(width: double.infinity, …)`. The `Column` around it has
`mainAxisSize: MainAxisSize.min`, so it was handing the `Wrap` only as much width
as its children needed; with no spare width, `alignment: spaceBetween` had
nothing to share out and the two groups ended up touching. Given the full width
the same `spaceBetween` puts M / T / full screen on the left and everything else
on the right, and the row still drops to a second line on a phone too narrow for
both.

## Tests

`test/widgets/performance_controls_test.dart`

- `pumpControls` gained a `hasMelody` argument, so the melody icon can be drawn.
- New test: the speed sits to the right of the mode buttons, the chords and
  melody icons are both there, the last icon ends within 20 px of the header's
  right edge, and it is all on one line.

The existing "controls row fits on a narrow phone" test still passes, so there is
no overflow at 360 dp with the metronome showing.

`flutter analyze` is clean and all 880 tests pass.
