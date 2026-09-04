# Speed read-out and toggles in the header, no play button, drag then carry on

**Status:** completed

Follows on from
[20260904_114123_scroll-speed-gestures-normal-view.md](20260904_114123_scroll-speed-gestures-normal-view.md).

## What the user asked

1. Use the empty space on the right of the auto-scroll row for the **speed**, a
   **show / hide chords** icon and a **show / hide melody** icon.
2. **Remove the round play button.** Play and pause is the two-finger tap.
3. While auto-scroll is playing, a **one-finger drag should scroll the page
   normally**, and auto-scroll should then carry on from that new position.

## The issues

- The speed is not shown anywhere since the stepper was removed. Show chords and
  show melody are buried in the top-bar menu → "Performance controls", which is
  three taps away mid-song. Meanwhile the header row has a wide empty gap.
- The play button is now one of three ways to do the same thing.
- Today the scroll ticker calls `jumpTo` every frame while it plays. A `jumpTo`
  cancels a drag that is in progress, so your finger and the ticker fight each
  other and the sheet will not go where you put it.

## The plan

### 1. Header row

`lib/widgets/auto_scroll_controls.dart`

- Remove the `_PlayButton` widget and its use. The row becomes `M` / `T` and the
  full screen button.
- Drop the now-unused `bpm` field and the `AutoScrollCalculator` import. The
  "Tempo cannot play before it has a length" guard goes with it; it is not lost,
  because the ticker already scrolls 0 px/sec when the length is zero, so play
  in Tempo mode with no BPM simply does nothing, as before.

`lib/widgets/performance_controls.dart`

- In the row, to the right of the auto-scroll controls and before the existing
  pitch button, add:
  - **Speed read-out** — plain text, e.g. `0.40x`, in Manual mode only. It is a
    read-out, not a button; a tooltip says "Scroll speed — double-tap the sheet
    to change". In Tempo mode nothing is drawn, because the status line under
    the row already reads "… · 32 bars · 1:04".
  - **Chords icon** — `music_note` when chords show, `music_off` when hidden;
    tap toggles `performanceSettingsProvider.toggleChords()`.
  - **Melody icon** — `piano` / `piano_off`, calling `toggleMelody()`. Only
    drawn for a song that has `{melody}` lines, matching the rule the menu
    already uses. This needs one new field on `PerformanceControls`
    (`hasMelody`), passed down from the performance screen, which already knows.
- The same toggles stay in the "Performance controls" sheet. Nothing is removed
  from there.

Resulting row: `M T ⛶ … 0.40x ♪ 🎹 ~ (metronome)`.

### 2. Play button

Removed, as above. Play and pause is the two-finger tap on the sheet, in both
views. Full screen keeps its own play button in the HUD (`stage_hud.dart`) —
that bar is hidden most of the time and is not part of this change.

### 3. Drag while playing

`lib/screens/song_performance_screen.dart`, in `_onTick`:

- After the elapsed time is recorded, return early while any finger is on the
  sheet (`_pointersDown > 0`). The clock still advances, so nothing jumps when
  the finger lifts.
- The sheet is then scrolled by the normal scroll physics — the thing your
  finger is dragging — and auto-scroll carries on from wherever you let go.
- Small effect worth knowing: a fling (a fast flick and release) stops as soon
  as the next tick lands, so the sheet carries on from the release point rather
  than coasting. That matches "carry on from where I put it".

### 4. Help

`lib/screens/help/help_content.dart` — say that the header shows the speed, that
the two icons hide chords and the melody rows, that play/pause is the two-finger
tap (no button any more), and that you can drag the sheet by hand at any time
and auto-scroll will carry on from there.

## Files to change

| File | Change |
|---|---|
| `lib/widgets/auto_scroll_controls.dart` | Remove the play button, the `bpm` field and the tempo guard |
| `lib/widgets/performance_controls.dart` | Speed read-out + chords and melody icons; new `hasMelody` field |
| `lib/screens/song_performance_screen.dart` | Pass `hasMelody`; `_onTick` steps aside while a finger is down |
| `lib/screens/help/help_content.dart` | Text for the new header and the drag behaviour |
| `test/screens/song_performance_screen_test.dart` | Play-button test replaced; new tests for the read-out, the icons and the drag |
| `test/widgets/performance_controls_test.dart` | Build with the new `hasMelody` field |

## Checks after the change

- `flutter analyze` clean, `flutter test` all green.
- Manual: speed read-out follows the double-taps; the two icons hide and show
  chords and melody; two-finger tap plays and pauses; while playing, a one-finger
  drag moves the sheet and auto-scroll carries on from there; the row still fits
  a 360 dp phone with the metronome on.
