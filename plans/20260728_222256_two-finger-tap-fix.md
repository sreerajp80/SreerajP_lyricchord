# Fix: the two-finger tap never fires

**Status:** completed

> Done on 2026-07-28. A third bug turned up while fixing: the code timed the
> touch with `DateTime.now()`, which a widget test's fake clock cannot move, so
> the timeout was untestable by construction. It now reads `event.timeStamp`.
> Change log:
> [change_log/20260728_223029_two-finger-tap-fix.md](../change_log/20260728_223029_two-finger-tap-fix.md).

## The issue

In Stage Mode, tapping with two fingers is meant to play or pause. On a real
phone it does nothing. My widget tests passed, which is why this shipped — the
tests drove the pointers in a way a real hand never does.

There are two separate bugs, and either one on its own is enough to break it.

### Bug 1 — the second finger is measured from the first finger's position

[stage_gesture_layer.dart:92-97](../lib/widgets/stage_gesture_layer.dart#L92-L97):

```dart
void _onPointerMove(PointerMoveEvent event) {
  final origin = _touchOrigin;          // where the FIRST finger went down
  if (origin == null) return;
  final travel = (event.localPosition - origin).distance;
  if (travel > _maxTravel) _maxTravel = travel;
}
```

There is one origin for the whole touch, taken from the first finger. When the
second finger moves even a hair, its distance is measured from *the first
finger's* starting point — and two fingers are naturally 100–200 px apart. So
`travel` immediately jumps to about 150, way past the 18 px slop, and the touch
is judged "not a tap".

A real finger always emits a few move events. This is why it never fires.

The tests missed it because `tester.startGesture(...)` followed by `up()` sends
**no move events at all**, so `_maxTravel` stayed 0.

### Bug 2 — 300 ms is too short for two fingers

`_tapTimeout` is 300 ms, measured from the first finger going down to the last
finger coming up. A person putting two fingers down and lifting them takes
longer than that — 400 to 600 ms is normal, and more if you are holding an
instrument. The test does it in microseconds.

## The fix

### 1. Measure each finger from its own starting point

Replace the single `_touchOrigin` / `_maxTravel` pair with a map of pointer id
to that pointer's own down position, and check each move against its own origin:

```dart
final Map<int, Offset> _origins = {};   // pointer id -> where it went down

void _onPointerMove(PointerMoveEvent event) {
  final origin = _origins[event.pointer];
  if (origin == null) return;
  final travel = (event.localPosition - origin).distance;
  if (travel > _maxTravel) _maxTravel = travel;
}
```

`_maxTravel` stays as "the furthest any one finger strayed from where it
started", which is the right test for a tap.

### 2. Give a two-finger tap longer

Keep 300 ms for a one-finger tap (it needs to stay snappy, since the
double-tap window hangs off it), and allow **600 ms** when two or more fingers
were involved. Two-finger taps are slower to make and have nothing racing them.

### 3. Loosen the slop a little

Raise `_tapSlop` from 18 to **24** logical pixels. Two fingers landing together
roll and settle more than one, and 24 px is still far below any real drag.

## Files to change

| File | Change |
|---|---|
| [lib/widgets/stage_gesture_layer.dart](../lib/widgets/stage_gesture_layer.dart) | Per-pointer origins; a longer timeout for multi-finger taps; slop 18 → 24. Also clear the map on cancel and when the touch ends. |
| [test/widgets/stage_gesture_layer_test.dart](../test/widgets/stage_gesture_layer_test.dart) | New tests that reproduce both bugs (see below). |

No provider, screen or HUD change. Nothing else uses this widget.

## Tests — the important part

The existing tests passed while the feature was broken, so the fix is only
believable with tests that fail against the current code:

1. **A two-finger tap with small finger movement still plays.** Drive both
   pointers with a `moveBy` of a few pixels before lifting. This fails today
   (bug 1) and passes after.
2. **A slow two-finger tap still plays.** Put 400 ms between the fingers going
   down and coming up. This fails today (bug 2) and passes after.
3. **A two-finger drag still does not play.** Move one finger 200 px and check
   nothing toggles — proof the fix has not simply disabled the travel check.
4. **A pinch still does not play.** Move the two fingers apart, which is what
   zooming the font does, and check play is untouched.

I will run tests 1 and 2 against the unfixed code first and confirm they fail,
so we know they are really testing the bug.

## Risk

The looser limits make it slightly easier to trigger play/pause by accident —
for example, resting two fingers on the screen briefly. Tests 3 and 4 guard the
line between a tap and a drag or pinch. If it still feels twitchy on the device,
the next lever is to lower the multi-finger timeout from 600 ms.

## Checks after implementing

- `flutter analyze` clean, `flutter test` green, `dart format .`
- **On a real phone:** two-finger tap plays and pauses; a pinch still only
  changes the text size and never toggles play; a one-finger scroll is
  unaffected.

## Change log

On completion, write `change_log/<timestamp>_two-finger-tap-fix.md` referencing
this plan.
