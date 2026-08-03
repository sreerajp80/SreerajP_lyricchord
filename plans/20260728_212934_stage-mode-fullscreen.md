# Stage Mode — full-screen lyrics with gesture speed control

**Status:** completed

> Approved and implemented on 2026-07-28. The four open questions below were not
> answered, so the recommendations in each were followed. Change log:
> [change_log/20260728_214951_stage-mode-fullscreen.md](../change_log/20260728_214951_stage-mode-fullscreen.md).

> Depends on the speed-stepper plan
> ([20260728_212325_manual-scroll-speed-stepper.md](20260728_212325_manual-scroll-speed-stepper.md)),
> which is approved and on hold. That one should be built first, because the
> gestures here step the speed by `AutoScrollSettings.speedStep`.

## The idea (what you asked for)

A full-screen lyrics view for performing:

- Hides the app bar and the phone's system bars.
- Swipe from the bottom-left corner to go back.
- Two-finger tap = faster, one-finger tap = slower (Manual mode).

## What I would keep, and what I would change

Your core idea is right: on stage the musician wants nothing on screen but the
words, and wants to change speed without hunting for a small button. I would
keep that whole shape. Three details I think will cause trouble in real use,
with what I suggest instead.

### 1. Bottom-left corner swipe → use the normal Back gesture instead

On Android 10 and later, a swipe in from the left or right edge **is** the
system Back gesture. The bottom edge is the Home gesture. So a bottom-left
corner swipe sits on top of two system gestures at once. Worse, in full-screen
(immersive) mode the *first* edge swipe is eaten by the OS to bring the system
bars back — the app never sees it. iOS has the same problem with the home
indicator strip.

**Instead:** the normal Back button / Back swipe leaves Stage Mode and returns
to this screen (it does not leave the song). Plus a clear **Exit** button in the
on-screen controls. This is what video players and reader apps do, so it needs
no teaching.

### 2. One-finger tap = slower → use it for "show the controls"

A single tap is the one gesture every user tries first, and in every media app
it means *show me the controls*. If it silently makes the song slower, then
every accidental brush — a hand steadying the phone, a knuckle on the stand —
drags the speed down mid-song with no way to notice.

It is also lopsided: one finger down, two fingers up is hard to remember under
stage pressure, and there is no matching gesture for play/pause.

**Instead:** single tap shows or hides a translucent control bar (auto-hides
after 4 seconds). For fast speed changes without the bar:

- **Double-tap on the upper half → one step faster**
- **Double-tap on the lower half → one step slower**

Up for more, down for less is the same direction as volume and brightness on
every phone, so it needs no teaching. It also gives a squarer, more forgiving
target than a left/right split (about 420×420 dp on a phone instead of a narrow
200×850 dp strip), and it still works in landscape and on tablets.

Slower being on the **lower** half also matters in practice: with the phone
propped on a stand, the bottom of the screen is the nearest reach, and slowing
down is the more urgent correction mid-song.

Each change flashes the new value big in the middle of the screen (`1.15x`) so
you can see it from a metre away.

### 3. Nothing was said about play/pause, Tempo mode, or seeing the speed

On stage the most used control is play/pause, not speed. Stage Mode needs it.

**Instead:** two-finger tap = play / pause. Two fingers make it hard to trigger
by accident, and pinch (font zoom) still works because a pinch involves
movement while a tap does not.

Tempo mode gets the same treatment: the double-tap steps the **measures** count
up and down, because that is what changes speed in that mode. The flash then
shows `36 bars`.

## The design I propose

**Name:** Stage Mode.

**Entering:** a full-screen icon button in the auto-scroll controls row, plus an
item in the top-bar overflow menu. Nothing else changes — the same song, the
same scroll position, the same transpose and font size carry straight over.

**On screen in Stage Mode:** only the lyrics, edge to edge, on the app's dark
surface. No app bar, no system status bar, no navigation bar
(`SystemUiMode.immersiveSticky`). The screen already stays awake in this screen
(`WakelockPlus`), so that keeps working.

**The control bar (the HUD):** a translucent bar that slides in on a single tap
and slides away after 4 seconds of no touch. It holds, left to right:

```
[ Exit ]  [ M | T ]  [ ▶/⏸ ]  [ − 1.00x + ]   Jingle Bells · Key G · 120 BPM
```

Every gesture has a button here too. That is the professional part: gestures are
shortcuts for people who learn them, never the only way to do something.

**Full gesture list in Stage Mode:**

| Gesture | Does |
|---|---|
| Single tap | Show / hide the control bar |
| Double-tap, upper half | One step faster (Manual) / more measures (Tempo) |
| Double-tap, lower half | One step slower (Manual) / fewer measures (Tempo) |
| Two-finger tap | Play / pause |
| Pinch | Font size — unchanged |
| Drag up / down | Scroll by hand — unchanged (pauses auto-scroll, see below) |
| Back button / Back swipe | Leave Stage Mode |

**Touch-to-pause:** while auto-scroll is playing, a hand-drag scrolls as normal
and auto-scroll keeps running from the new position. I suggest we keep the
current behaviour and not add a pause-on-touch rule, so this stays a small
change. Say if you want it.

**First time only:** a short one-time overlay listing the gestures, dismissed by
a tap, remembered in `shared_preferences`. Without it nobody discovers the
double-tap.

## Files to change

### New files

| File | What it is |
|---|---|
| `lib/providers/stage_mode_provider.dart` | `stageModeProvider` — is Stage Mode on, is the HUD showing. Holds the auto-hide timer state; the widget owns the actual `Timer`. |
| `lib/widgets/stage_hud.dart` | The translucent control bar and its slide in/out animation. |
| `lib/widgets/stage_gesture_layer.dart` | The tap / double-tap / two-finger-tap detector plus the big value flash. Kept separate so the performance screen does not grow another 200 lines. |
| `lib/widgets/stage_help_overlay.dart` | The one-time gesture guide. |
| `lib/core/utils/system_ui.dart` | Two small helpers: `enterImmersive()` and `exitImmersive()` wrapping `SystemChrome`. Keeps `SystemChrome` calls in one place so we can restore them reliably. |

### Changed files

| File | Change |
|---|---|
| [lib/screens/song_performance_screen.dart](../lib/screens/song_performance_screen.dart) | Hide the `AppBar` when Stage Mode is on (build the `Scaffold` with `appBar: null`). Wrap the body in the gesture layer + HUD. Add `PopScope` so Back leaves Stage Mode instead of the screen. Call `exitImmersive()` in `dispose` and on app pause, `enterImmersive()` on resume — the bars must never be left hidden. Disable the left/right song swipe while in Stage Mode (see open question 2). |
| [lib/widgets/auto_scroll_controls.dart](../lib/widgets/auto_scroll_controls.dart) | Add the "Full screen" icon button that turns Stage Mode on. |
| [lib/providers/auto_scroll_provider.dart](../lib/providers/auto_scroll_provider.dart) | No new logic — reuses `increaseSpeed` / `decreaseSpeed` / `increaseMeasures` / `decreaseMeasures`. Listed only because Stage Mode reads it. |
| [lib/screens/help/help_content.dart](../lib/screens/help/help_content.dart) | New help section: what Stage Mode is and the gesture table. |
| [lib/providers/settings_provider.dart] *(or wherever the prefs live — I will check)* | One new flag: has the gesture guide been shown. |

### Tests

| File | Covers |
|---|---|
| `test/providers/stage_mode_provider_test.dart` | Toggling Stage Mode, HUD show/hide, reset when the song changes. |
| `test/widgets/stage_gesture_layer_test.dart` | Double-tap left lowers the speed one step, double-tap right raises it, both clamp at the ends; two-finger tap toggles play; single tap shows the HUD. |
| `test/widgets/stage_hud_test.dart` | The HUD auto-hides after 4 seconds and its buttons hit the right notifier methods. |

Nothing touches the database, the models, or the parser.

## Risks I want to call out

1. **The bars must always come back.** If the app is killed or backgrounded
   while immersive, Android normally restores the bars, but we will also restore
   them in `dispose` and on `AppLifecycleState.paused` so there is no way to get
   stuck in a bar-less app.
2. **Double-tap adds a delay to the single tap.** Flutter must wait ~300 ms to
   know a tap is not a double-tap, so the control bar will appear a moment after
   the tap. This is normal and video players do the same, but it is a real
   trade-off of having both gestures.
3. **Two-finger tap vs pinch.** Both start with two fingers. The tap only fires
   if the fingers lift quickly without moving, so a real pinch will not toggle
   play. I will test this by hand on a device.
5. **The HUD sits in the lower half.** When the control bar is showing, a
   double-tap must not both press a HUD button and count as "slower". The
   gesture layer will ignore touches inside the HUD's area while it is visible.
4. **Tablet split view.** In the embedded tablet pane, Stage Mode should take
   the whole window, not just the pane. Simplest answer: hide the Stage Mode
   button when `embedded` is true, and add it properly later. See question 3.

## Open questions — please answer these

1. **Do you accept my three changes** (Back instead of corner swipe, single tap
   = show controls, double-tap upper/lower = faster/slower, two-finger tap =
   play/pause)? Or do you want your original mapping kept as-is? I can build
   either — I just think the original will misfire on stage.
2. **In Stage Mode, should a left/right swipe still change to the next song?**
   My advice: no — an accidental sideways swipe mid-song is the worst thing that
   can happen live. Use the HUD or Back out. Tell me if you want it kept.
3. **Tablets:** hide the Stage Mode button in the split view for now, or make it
   cover the whole tablet screen? Hiding is much less work.
4. **Should Stage Mode stay on when you swipe or move to another song?** My
   advice: yes, stay in Stage Mode; it is a way of working, not a per-song
   setting.

## Checks after implementing

- `flutter analyze` clean, `flutter test` green, `dart format .`
- On a real Android phone: enter Stage Mode, confirm both system bars are gone,
  confirm Back returns to the normal view with the scroll position kept, confirm
  the bars come back, confirm the gestures do what the table says.
- Confirm no new package is added — everything here uses `flutter/services`,
  which is already in the app. No network, no permissions.

## Change log

On completion, write `change_log/<timestamp>_stage-mode-fullscreen.md`
referencing this plan.
