# Bigger full screen button, and a controls row that cannot overflow

Implements [plans/20260728_220601_full-screen-button-size.md](../plans/20260728_220601_full-screen-button-size.md).

## Why

The full screen button looked small and weak. Its neighbours (`M`, `T`, play)
are all 40 dp circles with a background; it was a bare icon at
`VisualDensity.compact`, about 32 dp with no background, and the smallest tap
target in the row.

## What changed

### The button — as planned

In [lib/widgets/auto_scroll_controls.dart](../lib/widgets/auto_scroll_controls.dart):

- Dropped `VisualDensity.compact`.
- Now an `IconButton.filledTonal`, so it has a background circle. Tonal rather
  than filled on purpose — going full screen is a normal action, and the strong
  primary fill stays with play.
- Sized 40×40, sharing the `_CircleToggle.size` constant with `M` and `T` so all
  four line up. That constant was renamed from `_size` to `size` so it could be
  shared.
- An 8 dp gap before it, which it did not have.

### The overflow — extra work, not in the plan

The plan warned the row was tight and said I would check it at a narrow width.
It did not just get tight, it broke: at **360 dp with the metronome switched on
the row overflowed by 46 pixels**.

This was **not new**. Checking against the previous version, the old `0.5x / 1x
/ 2x` chips were wider than the stepper that replaced them, so the row already
overflowed by roughly 20 px before any of today's work; the bigger button added
about 16 px more. It was never caught because no test ran at a narrow width with
the metronome on.

Trimming sizes was not enough — shaving every gap and label saved about 26 px of
the 46 needed. So the outer `Row` is now a `Wrap`:

- On a normal phone nothing changes: both groups sit on one line with the
  stepper pushed to the right, exactly as before (`WrapAlignment.spaceBetween`
  does what the old `Spacer` did).
- When there is genuinely not enough width, the stepper drops to a second line
  instead of spilling off the edge.

Wrapping beats shrinking here: these are already 40 dp targets and a musician
taps them mid-song, so making them smaller is the wrong trade.

## Tests

`test/screens/song_performance_screen_test.dart` — new test, "the controls row
fits on a narrow phone": builds the screen at 360×800 with the metronome
switched on (the widest the row ever gets) and asserts no layout exception, with
the full screen button and the speed label both present. This is the test that
caught the overflow.

## Checks

`flutter analyze` clean, `flutter test` all green (309 tests), `dart format .`
run.

## Still to do

Not checked on a real device. Worth a look at how the two-line layout reads on a
small phone with the metronome on — it is correct, but whether it is the layout
we want there is a design call.
