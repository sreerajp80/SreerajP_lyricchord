# Speed by tap gestures in the normal song view

Implements
[plans/20260904_114123_scroll-speed-gestures-normal-view.md](../plans/20260904_114123_scroll-speed-gestures-normal-view.md).

## What changed

The `−  0.40x  +` stepper is gone from the auto-scroll row in the normal song
view. The speed is now changed the same way as in full screen: double-tap the
upper half of the sheet to go faster, the lower half to go slower. In Tempo mode
the same double-taps add or remove bars. A two-finger tap plays or pauses. The
new value flashes big in the middle of the screen.

## Files

- **`lib/widgets/stage_gesture_layer.dart` → `lib/widgets/scroll_gesture_layer.dart`**
  (`StageGestureLayer` → `ScrollGestureLayer`). It is used by both views now, so
  the Stage-only name no longer fitted. New flag `singleTapTogglesHud`
  (default `true`): the normal view passes `false`, so a lone tap there does
  nothing — there is no control bar to show. All other gesture logic is
  untouched.
- **`lib/widgets/auto_scroll_controls.dart`** — the `_SpeedStepper` and
  `_MeasuresStepper` widgets are deleted. The row is now just the M / T toggle,
  play, and full screen, so a plain `Row` replaced the `Wrap` that existed only
  to stop the stepper overflowing. `formatSpeedLabel()` stays; the flash uses it.
- **`lib/screens/song_performance_screen.dart`** — the normal-view sheet is
  wrapped in `ScrollGestureLayer(singleTapTogglesHud: false, …)`. Stage Mode
  keeps its own layer with the flag at its default.
- **`lib/screens/help/help_content.dart`** — the Auto-scroll topic now lists the
  three gestures, says the value flashes, and says plainly that this speed is
  only used while auto-scroll is playing and never changes finger scrolling. The
  old "use the − and + buttons" and "change the count with the stepper" lines
  were corrected.

## Tests

- **`test/widgets/stage_gesture_layer_test.dart` → `test/widgets/scroll_gesture_layer_test.dart`** —
  renamed, plus one new case: with `singleTapTogglesHud: false` a single tap
  leaves the HUD alone while double-taps still change the speed.
- **`test/screens/song_performance_screen_test.dart`** — the speed, saving and
  Tempo tests now double-tap the sheet instead of tapping the removed
  `Faster` / `Slower` / `More measures` tooltips. Because the speed is no longer
  printed anywhere, they read the value from `autoScrollProvider` through
  `ProviderScope.containerOf` instead of looking for a `1.00x` label.

`flutter analyze` is clean and all 874 tests pass.

## Known effects

- The current speed is not shown on screen any more. It is only seen in the
  flash after a double-tap. This was the user's choice; adding it back as grey
  text on the status line is a one-line change if wanted later.
- Double-tapping a melody row's play button starts the tune *and* changes the
  speed, because the gesture layer listens without claiming the touch. A single
  tap — the normal way to use it — is unaffected.
- Nothing on screen hints that the gestures exist; only Help explains them. The
  one-time full-screen guide overlay is still full-screen only.
