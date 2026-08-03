# Manual auto-scroll speed: stepper instead of three fixed chips

**Status:** completed

> Approved and implemented on 2026-07-28, together with the Stage Mode plan
> ([20260728_212934_stage-mode-fullscreen.md](20260728_212934_stage-mode-fullscreen.md)).
> Change log:
> [change_log/20260728_214951_manual-scroll-speed-stepper.md](../change_log/20260728_214951_manual-scroll-speed-stepper.md).

## The issue

In the performance screen, Manual auto-scroll only offers three fixed speeds:
`0.5x`, `1x`, `2x` (`AutoScrollSettings.speedChoices`). Users say even the
lowest of these is too fast, and there is no way to fine-tune.

Today the speed is `40 px/s × multiplier`
([lib/services/auto_scroll_calculator.dart:13](../lib/services/auto_scroll_calculator.dart#L13)),
so the only choices are 20, 40 and 80 logical pixels per second.

## The fix (in short)

Replace the three chips with a `−  1.00x  +` stepper, exactly like the Tempo
mode measures stepper that already sits in the same spot.

- Range: **0.10x to 2.00x**
- Step: **0.05x** per tap
- Default on open: **1.00x** (unchanged)

At the current base of 40 px/s this gives 4 px/s at the slowest and 80 px/s at
the fastest, in 39 stops.

Note on rounding: the multiplier is a `double`, and repeatedly adding `0.05`
drifts (0.1 + 0.05 + 0.05 ≠ 0.2 exactly). To keep values clean the notifier
will hold the speed as **hundredths of an x** internally when stepping — that
is, compute in integer steps and convert back to a `double` rounded to two
decimals. This keeps `0.05x` steps exact and makes the label easy.

## Files to change

| File | Change |
|---|---|
| [lib/providers/auto_scroll_provider.dart](../lib/providers/auto_scroll_provider.dart) | Replace `speedChoices` with `minSpeed` (0.10), `maxSpeed` (2.00), `speedStep` (0.05), `defaultSpeed` (1.00). Add `increaseSpeed()` / `decreaseSpeed()`. Change `setSpeed(double)` to clamp and round to the step grid instead of rejecting anything not in a list. |
| [lib/widgets/auto_scroll_controls.dart](../lib/widgets/auto_scroll_controls.dart) | Replace `_SpeedChips` with `_SpeedStepper` (`−` button, value text, `+` button), reusing the look of `_MeasuresStepper`. Buttons disable at the ends of the range. Label reads `1.00x`, `0.85x`, `0.10x`. |
| [lib/services/auto_scroll_calculator.dart](../lib/services/auto_scroll_calculator.dart) | Doc comment only — it says "`0.5x` and `2x`". The maths (`base × multiplier`) does not change. |
| [lib/screens/help/help_content.dart](../lib/screens/help/help_content.dart#L134) | Update the help line "Manual scrolls at a fixed speed you pick: 0.5x, 1x, or 2x." to describe the new range and step. |
| [test/providers/auto_scroll_provider_test.dart](../test/providers/auto_scroll_provider_test.dart) | Update the existing `setSpeed` tests (they currently assert `1.7` is rejected). Add tests for increase/decrease, clamping at both ends, and no float drift after many steps. |
| [test/services/auto_scroll_calculator_test.dart](../test/services/auto_scroll_calculator_test.dart) | Add a case for a fine multiplier (e.g. `0.15`); existing cases still pass. |

No database, model or migration change — auto-scroll speed is view state only
and is not saved.

## Detail of the changes

### 1. Provider

```dart
/// Slowest Manual speed.
static const double minSpeed = 0.10;
/// Fastest Manual speed.
static const double maxSpeed = 2.00;
/// One tap of the speed stepper.
static const double speedStep = 0.05;
/// Speed a song opens at.
static const double defaultSpeed = 1.00;
```

`setSpeed(double speed)` becomes: clamp to `minSpeed`..`maxSpeed`, snap to the
nearest `speedStep`, round to 2 decimals, then set state (no-op if unchanged).

`increaseSpeed()` / `decreaseSpeed()` call `setSpeed(state.speed ± speedStep)`,
so clamping and rounding live in one place.

### 2. Widget

`_SpeedStepper` mirrors `_MeasuresStepper`:

```
[ − ]  1.00x  [ + ]
```

- `−` is disabled at `0.10x`, `+` is disabled at `2.00x`.
- The value box needs to be a little wider than the measures one (about 52 dp)
  because `1.00x` is 5 characters.
- Tooltips: "Slower" and "Faster".

The rest of the row (M / T toggle, play button) is untouched.

### 3. Speed label

Always two decimals plus `x` — `0.10x`, `1.00x`, `2.00x`. Fixed width reads
better in a stepper than the current "drop the trailing .0" rule, and it stops
the row jumping as the number changes.

## Things I am assuming — tell me if any is wrong

1. "increment of 5" means **0.05x** per tap (so 0.10 → 0.15 → 0.20 …). If you
   meant 0.5x steps, say so and I will change the step only.
2. The stepper **replaces** the chips; there is no preset row left.
3. The base speed constant stays at 40 px/s. Users who find 1x fast can now
   step down to 0.10x, so I would not change the base as well — but I can lower
   it if you prefer 1x itself to be slower.
4. Plain tap-to-step is enough; no press-and-hold repeat and no slider. With 39
   stops, walking from 1.00x to 0.20x is 16 taps. If that feels long I can add
   hold-to-repeat as a follow-up.

## Checks after implementing

- `flutter analyze` clean.
- `flutter test` all green.
- `dart format .`
- Manual check: open a song, Manual mode, step down to 0.10x and play — the
  sheet should crawl; step to 2.00x and play — same speed as the old `2x`.

## Change log

On completion, write `change_log/<timestamp>_manual-scroll-speed-stepper.md`
referencing this plan.
