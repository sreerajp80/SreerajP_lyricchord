# Speed by tap gestures in the normal song view

**Status:** completed

## What the user asked

In the normal (not full screen) song view, drop the `−  0.40x  +` stepper in the
auto-scroll row and change the speed the same way full screen does: double-tap
the upper half of the sheet to go faster, the lower half to go slower, with the
big value flash in the middle.

Answers already given by the user:

- The stepper is **removed completely** from the header.
- The gestures work in **both** modes — Manual changes speed, Tempo changes bars.
- **Two-finger tap** plays / pauses in the normal view too.

One point of language: this speed is the **Manual auto-scroll** speed (mode `M`
plus the play button). It does not change how fast the sheet moves when you drag
it with a finger.

## The issue

The gesture logic already exists, but only inside
`lib/widgets/stage_gesture_layer.dart`, which is only put on screen in Stage
Mode (`_stageBody`). The normal view has no gesture layer at all, so the only way
to change speed there is the stepper. Two different ways to do one thing is also
harder to teach in Help.

## The plan

### 1. Make the gesture layer usable outside Stage Mode

- Rename `lib/widgets/stage_gesture_layer.dart` →
  `lib/widgets/scroll_gesture_layer.dart`, and the class `StageGestureLayer` →
  `ScrollGestureLayer`. It is no longer a Stage-only widget, so the old name
  would mislead. Pure rename, no logic change.
- Add one named flag: `singleTapTogglesHud` (default `true`).
  - Stage Mode passes `true` — one tap shows / hides the HUD, as now.
  - The normal view passes `false` — there is no HUD there, so a single tap does
    nothing. The double-tap window still works exactly as before.
- Everything else stays: the double-tap halves, the two-finger tap, the flash,
  the pointer bookkeeping, and the `isLocked` check (in the normal view
  `isLocked` is always `false`, so it simply never blocks).

### 2. Take the steppers out of the header row

In `lib/widgets/auto_scroll_controls.dart`:

- Delete the private `_SpeedStepper` and `_MeasuresStepper` widgets and the code
  that picks between them.
- The row becomes just: `M` / `T` toggle, play button, full screen button.
- Keep `formatSpeedLabel()` — the flash uses it.
- Keep the `bpm` field and the "Tempo cannot play with no length" rule.

### 3. Put the layer over the normal sheet

In `lib/screens/song_performance_screen.dart`, wrap the normal-view sheet (the
`Expanded` child in the `Column`) in
`ScrollGestureLayer(singleTapTogglesHud: false, child: …)`. Stage Mode keeps its
own `ScrollGestureLayer(child: sheet)` with the flag left at its default.

### 4. Help text

In `lib/screens/help/help_content.dart`, add the same three gestures (double-tap
up = faster, double-tap down = slower, two-finger tap = play / pause) to the
normal song-view topic, and say that the speed is only used while auto-scroll is
playing. The Full screen topic keeps its own list, minus nothing.

### 5. Tests

- Rename `test/widgets/stage_gesture_layer_test.dart` →
  `test/widgets/scroll_gesture_layer_test.dart`; add one case: with
  `singleTapTogglesHud: false`, a single tap leaves the HUD state alone while
  double-tap still changes the speed.
- `test/screens/song_performance_screen_test.dart`: the three tests that tap the
  `Faster` / `Slower` tooltips and the one that looks for the `More measures` /
  `Fewer measures` tooltips now use double-taps on the sheet, and check the
  provider value instead of the removed `1.00x` label.

## Files to change

| File | Change |
|---|---|
| `lib/widgets/stage_gesture_layer.dart` → `lib/widgets/scroll_gesture_layer.dart` | Rename; add `singleTapTogglesHud` flag |
| `lib/widgets/auto_scroll_controls.dart` | Remove both steppers; keep `formatSpeedLabel` |
| `lib/screens/song_performance_screen.dart` | Wrap the normal sheet in the gesture layer; update import |
| `lib/screens/help/help_content.dart` | Gestures listed for the normal song view too |
| `test/widgets/stage_gesture_layer_test.dart` → `test/widgets/scroll_gesture_layer_test.dart` | Rename; new flag test |
| `test/screens/song_performance_screen_test.dart` | Speed / measures tests use gestures |

Not touched: `lib/providers/auto_scroll_provider.dart` (the increase / decrease
and saving logic is already right), and `lib/screens/scroll_settings_screen.dart`
(that stepper sets the *default* speed in Settings and stays a stepper).

## Things to know before approving

1. **The speed is not shown on screen any more.** With the stepper gone, the
   header shows no `0.40x`. You only see the value in the flash after a
   double-tap. If you want it visible, I can add it as plain grey text on the
   existing status line — `Auto-scroll · Key G · 68 BPM · 0.40x` — with no
   buttons. Say yes or no; the default in this plan is **not** to add it.
2. **Double-tapping a melody row's play button** will start the tune and also
   change the speed, because the gesture layer listens without claiming the
   touch. A single tap (the normal way to use it) is unaffected.
3. Discoverability drops: nothing on screen says the gestures exist. Help covers
   it; the one-time full-screen guide overlay is not shown in the normal view.

## Checks after the change

- `flutter analyze` clean.
- `flutter test` all green.
- Manual: speed up / slow down by double-tap in Manual mode, bars change in
  Tempo mode, two-finger tap plays and pauses, one-finger scroll and pinch-zoom
  still work, and Stage Mode behaves as before.
