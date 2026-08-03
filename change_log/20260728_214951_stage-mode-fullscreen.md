# Stage Mode — full-screen lyrics with gesture speed control

Implements [plans/20260728_212934_stage-mode-fullscreen.md](../plans/20260728_212934_stage-mode-fullscreen.md).
Builds on the speed stepper from
[20260728_214951_manual-scroll-speed-stepper.md](20260728_214951_manual-scroll-speed-stepper.md),
whose `increaseSpeed` / `decreaseSpeed` the gestures call.

## Why

On stage a musician wants nothing on screen but the words, and wants to change
the scroll speed without hunting for a small button.

## What it does

A full-screen icon button in the auto-scroll row turns Stage Mode on. The app
bar and both phone system bars disappear and the lyrics fill the screen. The
song, key, text size and scroll position all carry over unchanged.

### Gestures

| Gesture | Does |
|---|---|
| Single tap | Show / hide the control bar |
| Double-tap, upper half | Faster (Manual) / more bars (Tempo) |
| Double-tap, lower half | Slower (Manual) / fewer bars (Tempo) |
| Two-finger tap | Play / pause |
| Pinch | Text size — unchanged |
| Drag | Scroll by hand — unchanged |
| Back | Leave Stage Mode |

Every change flashes big in the middle of the screen (`1.15x`, `36 bars`,
`Paused`) so it is readable from a metre away.

## Changes made to the original idea, and why

The idea as first described was: swipe the bottom-left corner to exit,
one-finger tap to slow down, two-finger tap to speed up. Three parts were
changed, with the user's approval:

1. **Corner swipe replaced by Back.** On Android 10 and later the left edge is
   the system Back gesture and the bottom edge is Home, so a bottom-left swipe
   sits on top of two system gestures. In immersive mode the OS also eats the
   first edge swipe to show the bars, so the app would never see it.
2. **Single tap now shows the controls, not "slower".** A single tap is what
   everyone tries first and everywhere means "show me the controls". Tied to
   speed, every accidental brush would drag the song slower mid-performance.
3. **Play/pause added.** It is the most-used control on stage and the original
   list had none.

Left/right halves were changed to **upper/lower** at the user's suggestion: up
for more matches volume and brightness, and it gives a squarer target
(about 420×420 dp instead of a 200×850 dp strip).

## Files added

| File | What it is |
|---|---|
| `lib/core/utils/system_ui.dart` | `enterImmersive()` / `exitImmersive()`, the only place `SystemChrome` is touched. |
| `lib/providers/stage_mode_provider.dart` | `stageModeProvider` (is it on, is the HUD showing) and `stageHelpSeenProvider` (the one-time guide flag, saved to `shared_preferences`). |
| `lib/widgets/stage_hud.dart` | The translucent control bar. |
| `lib/widgets/stage_gesture_layer.dart` | The taps, and the big value flash. |
| `lib/widgets/stage_help_overlay.dart` | The one-time gesture guide. |

## Files changed

- **`lib/screens/song_performance_screen.dart`** — no app bar in Stage Mode;
  `PopScope` makes Back leave Stage Mode rather than the song; the HUD auto-hide
  timer; the system bars are restored in `dispose` and on app pause and hidden
  again on resume, so they can never be left off; sideways song swiping is
  disabled in Stage Mode. The chord sheet was pulled out into a `_sheet` method
  shared by both layouts, with extra padding in Stage Mode so the HUD never
  covers the last lines.
- **`lib/widgets/auto_scroll_controls.dart`** — the full-screen button, with a
  `showFullScreenButton` flag.
- **`lib/widgets/performance_controls.dart`** — passes that flag through.
- **`lib/core/constants/app_constants.dart`** — new `prefStageHelpSeen` key.
- **`lib/screens/help/help_content.dart`** — a new "Full screen" help topic.

## Decisions taken without an answer from the user

These four were raised in the plan and left unanswered when implementation was
approved, so the plan's own recommendations were followed:

1. Sideways swiping does **not** change songs in Stage Mode — a stray swipe
   mid-song is the worst thing that can happen live.
2. The full-screen button is **hidden in the tablet split view**, where it would
   only fill the pane. Whole-screen tablet support is left for later.
3. Stage Mode **stays on** when moving to another song. Unlike the auto-scroll
   settings it is not reset by `resetAll` on a song change.
4. Back **exits Stage Mode first**; a second Back leaves the song.

## Tests

- `test/providers/stage_mode_provider_test.dart` — entering, leaving, the HUD
  flags, and the saved "guide seen" flag.
- `test/widgets/stage_gesture_layer_test.dart` — each gesture, both range ends,
  Tempo mode stepping bars, a double-tap not also toggling the HUD, and a drag
  changing nothing.
- `test/widgets/stage_hud_test.dart` — the read-out, exit, play, the stepper
  (and that it swaps to bars in Tempo mode), and that a hidden bar takes no
  taps.
- `test/screens/song_performance_screen_test.dart` — a `Stage Mode` group:
  the button hides the app bar and opens the HUD, exit brings it back, and the
  gesture guide appears once and is then remembered.

## Note on the gesture layer

The taps are worked out by hand from a passive `Listener` instead of using a
`GestureDetector`. The sheet already has a drag (scrolling) and a scale (pinch
zoom) competing for the same fingers; adding tap recognisers to that contest
makes both flaky. A `Listener` never claims a gesture, so scrolling and pinching
behave exactly as before.

## Checks

`flutter analyze` clean, `flutter test` all green (308 tests), `dart format .`
run. No new package was added — this uses `flutter/services`, already in the
app. No network calls and no permissions.

## Still to do

Not yet checked on a real device. Worth confirming by hand: both system bars go
away and come back, the two-finger tap does not fire during a pinch, and Back
behaves as described.
