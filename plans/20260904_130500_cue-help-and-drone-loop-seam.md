# Pitch Cue help text + Shruti Drone loop gap fix

**Status:** completed

Date: 2026-09-04
Author: Claude (for Sreeraj P)

---

## Part A — The issue

### A1. Help does not explain the cue

The Help topic "Pitch Pipe & Shruti Box" has a short "Pitch cue" section. It only
says one line: *"Tap 'Pitch Cue' to hear a 2-second reference note."*

It does not tell the user:

- that the button is named **Chord Cue** in Western mode, and plays a whole
  chord (bass + root + third + fifth), not one note,
- why the length is fixed at 2 seconds and cannot be changed,
- how the cue differs from the drone (one short tone vs. a tone that never
  stops).

The user asked these exact questions, so the Help should answer them.

### A2. The Shruti Drone loop has an audible break

The drone is a 2-second WAV that the player loops. The user hears a "disconnect"
every time it loops. There are two separate causes.

**Cause 1 — a 10 ms hole punched at every seam.**
`droneEnvelope` in [lib/services/pcm_synth_service.dart:346](../lib/services/pcm_synth_service.dart#L346)
fades the sound in over the first 5 ms and out over the last 5 ms of the buffer:

```dart
final fade = math.min((sampleRate * 0.005).round(), totalSamples ~/ 2);
if (sampleIndex < fade) return sampleIndex / fade;             // fade in
final fromEnd = totalSamples - 1 - sampleIndex;
if (fromEnd < fade) return (fromEnd / fade).clamp(0.0, 1.0);   // fade out
```

That fade is correct for a sound that plays once. For a looped sound it is
wrong: the volume drops to zero and comes back every 2 seconds. That dip is the
"disconnect". This is the main cause.

**Cause 2 — the wave jumps at the seam.**
The tones are built with `harmonicSample(i, freq, sampleRate)`, which is
`sin(2 * pi * freq * t)` from absolute time. The buffer restarts at `t = 0`, so
the wave restarts at phase 0. That only joins up cleanly if the frequency fits a
**whole number of cycles** inside the buffer.

It does not. Example: C = 261.63 Hz over 2 s = 523.26 cycles. The leftover 0.26
of a cycle means the last sample and the first sample sit at different points of
the wave, so the loop point is a step in the waveform — heard as a faint click.
The detuned right channel (`freq * 1.004`) and the fifth/fourth are off the grid
too.

The comment above `generateShrutiDroneWav` claims the drone plays through
`SoundPool` and must stay under 1 MB. That is stale — the code now uses
`PlayerMode.mediaPlayer` for both drones
([lib/services/pitch_drone_audio_service.dart:124](../lib/services/pitch_drone_audio_service.dart#L124)),
which streams from the file and has no such cap.

**Cache note.** `_writeIfNeeded` reuses a temp file if it already exists, keyed
only on the file name. Devices that already ran the app hold the old, broken
WAVs. Fixing the maths alone would change nothing for them — the file names must
change too.

---

## Part B — Files to change

| File | Why |
|------|-----|
| `lib/screens/help/help_content.dart` | Rewrite the cue section, add a "cue vs. drone" section |
| `lib/services/pcm_synth_service.dart` | Add loop-grid frequency snapping; remove the fade from drones; fix the stale comment |
| `lib/services/pitch_drone_audio_service.dart` | Bump drone file names so old cached WAVs are not reused |
| `test/services/pcm_synth_service_test.dart` | New tests: seam continuity, no fade dip, snapping maths |
| `test/services/pitch_drone_audio_service_test.dart` | Update the expected drone file names |
| `change_log/…` | Log after the work |

No widget, provider, model, database, or permission changes. No new packages.

---

## Part C — The fix

### C1. Help text ([lib/screens/help/help_content.dart](../lib/screens/help/help_content.dart))

Replace the "Pitch cue" section inside the `pitch-pipe-drone` topic with a fuller
one, and add a short comparison section. Plain English, matching real behaviour:

**Section "Pitch Cue (called Chord Cue in Western)"**

- Tap "Pitch Cue" to hear a 2-second reference note. It is a digital pitch pipe:
  it sounds your Sa (or the chosen key) and then stops on its own.
- Use it to find your starting note before you begin singing.
- In Western mode the same button is named "Chord Cue" and plays the whole
  chord — bass, root, third and fifth — because Western players want the chord,
  not one note. Major or minor follows the quality you picked.
- The length is fixed at 2 seconds and there is no setting for it. That is long
  enough to hear the pitch clearly and short enough not to get in the way. The
  button label says "(2s)" so you know what you will get.
- If you want a tone that lasts longer, use the Shruti Drone instead. That is
  what it is for.

**Section "Cue or drone — which one?"**

- Cue: one short sound, stops by itself. For finding the note before you start.
- Drone: keeps sounding until you stop it. For singing against while you
  practise or perform.
- Both are built inside the app as you press the button. Nothing is downloaded
  and no sound files ship with the app.

### C2. Make the drone loop seamless ([lib/services/pcm_synth_service.dart](../lib/services/pcm_synth_service.dart))

**Step 1 — snap every drone partial onto the loop grid.**

A buffer `D` seconds long repeats `1/D` times a second. Any frequency that is a
whole multiple of `1/D` Hz completes whole cycles inside it, so the end joins the
start exactly. Add a small helper:

```dart
/// Nudges [freq] onto the nearest frequency that completes a whole number of
/// cycles in a [durationSeconds] buffer, so a looped buffer joins itself with
/// no step in the waveform.
static double snapToLoopGrid(double freq, double durationSeconds) {
  if (freq <= 0 || durationSeconds <= 0) return freq;
  final cycles = (freq * durationSeconds).round();
  if (cycles <= 0) return freq;
  return cycles / durationSeconds;
}
```

Apply it in `generateShrutiDroneWav` and `generateWesternChordDroneWav` to
**every** partial, including each detuned right-channel copy: root, second
(Pa/Ma), bass, third, fifth. The 2nd/3rd/4th harmonics inside `harmonicSample`
are whole multiples of a snapped fundamental, so they land on the grid for free.

The pitch shift this causes is tiny. With a 4-second buffer the grid is 0.25 Hz,
so the worst error is 0.125 Hz — about 1.7 cents at the lowest bass note and
under 1 cent at the root. The ear cannot hear that (the just-noticeable
difference is around 5 cents), and it is far smaller than the 0.4% (~7 cent)
stereo detune the drone already uses on purpose.

**Step 2 — stop fading the drone in and out.**

Drop `droneEnvelope` from both drone generators and use a flat gain. The fade is
no longer needed once step 1 is in place: every partial is a `sin()` starting at
phase 0, so the buffer already begins at zero amplitude — playback still starts
without a pop — and, being periodic, it ends exactly where it began.

`droneEnvelope` is used nowhere else, so remove it rather than leave dead code.

**Step 3 — lengthen the drone buffer from 2 s to 4 s.**

Two gains: the grid gets finer (0.25 Hz instead of 0.5 Hz, halving the snap
error) and there are half as many seams. The 1.5 Hz tremolo stays aligned — 6
whole cycles in 4 s, as it was 3 in 2 s. The file grows from ~350 KB to ~700 KB
in the temp folder, which is fine because the drone plays through
`PlayerMode.mediaPlayer`, streaming from the file, with no `SoundPool` size cap.

The cue generators keep their 2-second default. They are one-shot sounds, they
need their ADSR fade, and their label promises 2 seconds.

**Step 4 — correct the stale doc comment** above `generateShrutiDroneWav` that
still describes `SoundPool` and the 1 MB cap.

### C3. Do not reuse the old cached WAVs ([lib/services/pitch_drone_audio_service.dart](../lib/services/pitch_drone_audio_service.dart))

`_writeIfNeeded` keeps a file whose name already exists. Add a `_v2` marker to
the two drone file names so every device builds the fixed sound once:

- `shruti_drone_<key>_<interval>.wav` → `shruti_drone_v2_<key>_<interval>.wav`
- `western_chord_drone_<key>_<quality>.wav` → `western_chord_drone_v2_<key>_<quality>.wav`

Cue file names stay as they are — the cues are not changing. The old files sit in
the OS temp folder and are cleaned up by the system, so nothing needs deleting.

### C4. Tests

In `test/services/pcm_synth_service_test.dart`:

1. `snapToLoopGrid` returns a frequency that completes a whole number of cycles,
   and stays within a few cents of the asked-for pitch.
2. **No dip at the seam.** Build a drone, then check the peak level in the last
   5 ms is close to the peak in the middle. This fails on today's code, which
   fades to zero there.
3. **The loop joins up.** The step from the final sample back to the first must
   be no larger than the biggest step found inside the buffer — that is, the seam
   is no more of a jump than ordinary neighbouring samples.
4. The same two checks for `generateWesternChordDroneWav`.

In `test/services/pitch_drone_audio_service_test.dart`: update the four expected
drone file names to the `_v2` form.

Then run `flutter analyze`, `flutter test`, and `dart format .`.

---

## Part D — What this does not do

- Does **not** make the cue length a user setting. The user asked why it is
  fixed, not to make it changeable. If that is wanted later it is a separate
  plan (the `durationSeconds` parameter already exists; it would need a saved
  setting threaded from `PitchDroneSettings` through `playPitchCue`).
- Does not change the cue sound, the drone pitches the user picks, the UI, or
  any stored setting.

---

## Part E — How to check it by hand

1. Open Settings → Help → "Pitch Pipe & Shruti Box" and read the new sections.
2. Open a song, start the Shruti Drone, and let it run for a minute. The hum
   should be steady, with no pulse or click every couple of seconds.
3. Do the same in Western mode with the chord drone.
4. Tap Pitch Cue and Chord Cue — both should sound exactly as before.
