# Header read-out and toggles, no play button, drag then carry on

Implements
[plans/20260904_121334_header-icons-and-drag-resume.md](../plans/20260904_121334_header-icons-and-drag-resume.md).

## What changed

### 1. The empty space in the auto-scroll row is now used

`lib/widgets/performance_controls.dart` — to the right of the M / T and full
screen buttons there are now:

- **The speed**, e.g. `0.40x`, in Manual mode only. It is a read-out, not a
  button; its tooltip says "Scroll speed — double-tap the sheet to change". In
  Tempo mode nothing is drawn there, because the status line under the row
  already reads `… · 32 bars · 1:04`.
- **A chords icon** — a music note, crossed out when chords are hidden. Tapping
  it hides or shows the chord line.
- **A melody icon** — a piano, crossed out when the melody rows are hidden. It
  is only drawn for a song that has `{melody}` lines. This needed one new field,
  `hasMelody`, which the performance screen fills in from the parsed sheet.

Both toggles are still in the "Performance controls" sheet as well; nothing was
taken away from there. The row is a `Wrap`, so on a narrow phone with the
metronome showing the right-hand group drops to a second line instead of
overflowing.

### 2. The play button is gone

`lib/widgets/auto_scroll_controls.dart` — the round play button is removed, and
with it the `bpm` field and the "Tempo has no length yet" guard (the ticker
already scrolls 0 px/sec in that case, so nothing changes in practice). The row
is now just M / T and full screen. Play and pause is the **two-finger tap** on
the sheet. Full screen keeps its own play button inside the HUD bar.

### 3. Dragging while auto-scroll plays

`lib/screens/song_performance_screen.dart`, in `_onTick` — the ticker now steps
aside while any finger is on the sheet. Before, it called `jumpTo` on every
frame, which cancelled the drag in progress, so the hand and the ticker fought
each other. Now the normal scroll physics move the sheet, and auto-scroll
carries on by itself from wherever the finger let go. The clock is still
advanced while the finger is down, so nothing jumps on release.

Side effect worth knowing: a fast flick stops where you lift your finger instead
of coasting on, because auto-scroll takes over again on the next frame.

### 4. Help

`lib/screens/help/help_content.dart` — three new sections under Auto-scroll: what
the row above the song shows, that play/pause is the two-finger tap with no
button on this screen, and that you can drag the sheet by hand at any time.

## Tests

`test/screens/song_performance_screen_test.dart`

- The old "tapping play" test is gone (there is no button); the two-finger tap is
  already covered in `test/widgets/scroll_gesture_layer_test.dart`.
- New: the header shows the speed and follows a double-tap; no speed in Tempo
  mode; the chords icon hides and shows the chords; a song with no tune has no
  melody icon; the melody icon hides the melody rows.
- New: a one-finger drag moves the sheet while auto-scroll plays — it checks
  that a held finger stops the ticker, that the drag really scrolls, and that
  auto-scroll carries on from the drop point. `pumpPerformance` gained a
  `viewSize` argument so this test can use a short window and a tall song.

`flutter analyze` is clean and all 879 tests pass.
