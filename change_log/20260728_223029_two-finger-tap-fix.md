# Fix: the two-finger tap never fired

Implements [plans/20260728_222256_two-finger-tap-fix.md](../plans/20260728_222256_two-finger-tap-fix.md).

Reported by the user: in Stage Mode, tapping with two fingers did nothing. The
widget tests passed the whole time, which is the real failure — they drove the
pointers in a way no hand ever does.

## The bugs

### 1. Each finger was measured from the first finger's starting point

`_onPointerMove` compared every pointer against one shared origin, taken from
the first finger. Two fingers sit 100–200 px apart, so the moment the second
finger moved even slightly its "travel" read about 150 px — far past the 18 px
slop — and the touch was thrown out as a drag. Real fingers always send a few
move events, so this fired every single time.

The tests missed it because `tester.startGesture(...)` then `up()` sends **no
move events at all**, leaving travel at 0.

### 2. 300 ms was too short for two fingers

The limit ran from the first finger going down to the last finger coming up. A
person takes 400–600 ms over a two-finger tap.

### 3. (found while fixing) the timeout could not be tested at all

The code used `DateTime.now()` — the real wall clock — while widget tests run on
a fake clock that `tester.pump` advances. A test could never make the timeout
expire, so bug 2 was invisible to tests by construction. This was not in the
plan; it was found when the new "slow tap" test passed against the broken code.

## What changed

All in [lib/widgets/stage_gesture_layer.dart](../lib/widgets/stage_gesture_layer.dart):

- `_touchOrigin` (one `Offset`) replaced by `_origins`, a map of pointer id to
  where that finger went down. Each move is measured against its own origin.
  `_maxTravel` keeps its meaning: the furthest any one finger strayed.
- Added `_multiTapTimeout` of **600 ms**, used when two or more fingers were
  involved. One-finger taps keep the 300 ms limit, because the double-tap
  window hangs off it and needs to stay snappy.
- `_tapSlop` raised from 18 to **24** px — two fingers landing together roll and
  settle more than one does.
- Timing now reads `event.timeStamp` instead of `DateTime.now()`. That is the
  clock the framework and the test binding both control, so the timeout behaves
  the same in a test as on a phone. This is what makes the fix testable.
- The origins map is cleared when a touch starts, ends, or is cancelled.

## Tests

In [test/widgets/stage_gesture_layer_test.dart](../test/widgets/stage_gesture_layer_test.dart).
The first two were written before the fix and confirmed failing against the
broken code:

- **"still plays when the fingers wobble"** — both pointers move a few pixels
  before lifting. Failed before the fix; this is bug 1.
- **"still plays when it is slow"** — 400 ms between down and up, set on the
  events themselves. Fails if the multi-finger timeout is not honoured.
- **"a long two-finger hold is not a tap"** — 2 seconds; must not toggle play.
- **"a two-finger drag does not play"** — 200 px of movement, proving the travel
  check still works and was not simply switched off.
- **"a pinch does not play"** — fingers moving apart, which is how the font size
  is changed, must never toggle play.

## Checks

`flutter analyze` clean, `flutter test` all green (314 tests), `dart format .`
run.

## Still to do, and one thing to watch

- **Needs a real device.** The bug only showed on hardware, so the fix has to be
  confirmed there: two-finger tap plays and pauses, a pinch still only changes
  the text size, one-finger scrolling is unaffected.
- **The single tap still has a 300 ms limit.** It was left alone because it was
  not part of the report and the double-tap window depends on it. But the same
  reasoning applies: a deliberate, slightly slow single tap may not show the
  control bar. If that turns out to be a nuisance on the device, raising it to
  about 500 ms is the fix — there is no long-press gesture here to clash with.
- If the two-finger tap now feels twitchy, the lever is lowering
  `_multiTapTimeout` from 600 ms.
