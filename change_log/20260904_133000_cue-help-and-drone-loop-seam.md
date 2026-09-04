# Pitch Cue help text + Shruti Drone loop gap fix

Date: 2026-09-04
Implements: [plans/20260904_130500_cue-help-and-drone-loop-seam.md](../plans/20260904_130500_cue-help-and-drone-loop-seam.md)

---

## Why

Two things, both raised by the user.

1. Help did not explain the Pitch Cue. It did not say the button is called
   "Chord Cue" in Western mode, did not say what that chord contains, and did
   not say why the length is fixed at 2 seconds.
2. The Shruti Drone had an audible break every time the loop came round. The
   user heard it as a "disconnect" in a sound that is supposed to be steady.

## What changed

### 1. Help — Settings → Help → "Pitch Pipe & Shruti Box"

[lib/screens/help/help_content.dart](../lib/screens/help/help_content.dart)

The one-line "Pitch cue" section became a full section,
**"Pitch Cue (called Chord Cue in Western)"**, covering: what the cue is and
that it stops on its own; what to use it for; the Western name change and the
fact it plays bass + root + third + fifth, major or minor; that 2 seconds is
fixed on purpose and why; and to use the drone instead for a longer tone.

A second section, **"Cue or drone — which one?"**, was added so the difference
between the two buttons is stated plainly in one place.

No behaviour changed here — text only.

### 2. The drone loop break — two causes, both fixed

[lib/services/pcm_synth_service.dart](../lib/services/pcm_synth_service.dart)

**Cause 1: the code faded the drone to silence at every loop.**
`droneEnvelope` faded the buffer in over the first 5 ms and out over the last
5 ms. That is right for a sound that plays once and wrong for one that loops —
it punched a 10 ms hole of silence into the hum on every pass. That was the
main thing the user was hearing.

Both drone generators now use a flat gain and `droneEnvelope` was removed (it
had no other caller). Nothing pops when the drone starts, because every partial
is a `sin()` beginning at phase 0, so the buffer already opens at zero.

**Cause 2: the waveform did not join up at the seam.**
Tones are built from absolute time, so each loop restarts the wave at phase 0.
That is only silent if the tone fits a whole number of cycles in the buffer. It
did not: C over 2 seconds is 523.26 cycles, and that leftover 0.26 of a cycle is
a step in the waveform — a faint click on every loop.

Added `snapToLoopGrid(freq, durationSeconds)`, which rounds a frequency to the
nearest whole multiple of `1 / durationSeconds` Hz. Both drone generators now
snap every voice through it — root, second (Pa/Ma), bass, third, fifth — and
each detuned right-channel copy separately, since otherwise that channel alone
would still click. The 2nd/3rd/4th harmonics are whole multiples of a snapped
fundamental, so they land on the grid for free.

The pitch moves by at most 0.125 Hz — under 2 cents, which no ear can hear, and
far less than the 0.4% (~7 cent) stereo detune the drone already uses on purpose.

**The drone buffer went from 2 seconds to 4 seconds.** This makes the loop grid
finer (0.25 Hz instead of 0.5 Hz, halving the snap error) and halves the number
of seams. The 1.5 Hz tremolo still lines up — 6 whole cycles in 4 s, where it
was 3 in 2 s. The file grows from ~350 KB to ~700 KB in the temp folder, which
does not matter because the drone plays through `PlayerMode.mediaPlayer` and
streams from the file.

The cue generators are unchanged: still 2 seconds, still with their ADSR fade.
They play once, so the fade is correct there, and the button promises 2 seconds.

A stale doc comment claiming the drone runs through `SoundPool` under a 1 MB cap
was corrected — the code has used `mediaPlayer` for the drones for some time.

### 3. Old cached sounds are no longer reused

[lib/services/pitch_drone_audio_service.dart](../lib/services/pitch_drone_audio_service.dart)

`_writeIfNeeded` keeps any temp file whose name already exists and never checks
whether the synth itself changed. A device that had already played a drone would
have kept the old, broken WAV for good, so the fix would have reached nobody who
had already run the app.

The two drone file names now carry a `_v2` marker, so every device builds the
fixed sound once:

- `shruti_drone_<key>_<interval>.wav` → `shruti_drone_v2_<key>_<interval>.wav`
- `western_chord_drone_<key>_<quality>.wav` → `western_chord_drone_v2_<key>_<quality>.wav`

Cue names are unchanged — the cues did not change. The old files sit in the OS
temp folder and the system clears them. A note was added on `_writeIfNeeded`
explaining that this marker must be bumped whenever a generator's output changes.

## Tests

[test/services/pcm_synth_service_test.dart](../test/services/pcm_synth_service_test.dart) — new group, "a looping drone":

- `snapToLoopGrid` lands on a whole number of cycles, and moves the pitch by
  less than 3 cents.
- `snapToLoopGrid` leaves zero, negative, and zero-duration input alone.
- The Shruti drone does not fade out at the seam: the peak level in the last
  5 ms and the first 5 ms is compared against the peak in the middle. This test
  fails on the old code, which faded to silence there.
- The Shruti drone joins its own start with no step: the jump from the last
  sample back to the first must be no bigger than the largest ordinary step
  inside the buffer.
- The same two checks for the Western chord drone.
- The default drone length is a whole number of tremolo cycles.

[test/services/pitch_drone_audio_service_test.dart](../test/services/pitch_drone_audio_service_test.dart) — the expected drone
file names updated to the `_v2` form.

## Checks run

- `dart format` — clean.
- `flutter analyze` — **No issues found**.
- `flutter test` — **all 886 tests pass**.

Not verified by me: how it actually sounds on a device. Worth starting the drone
and letting it run for a minute, in both Classical and Western mode.

## Not done

The cue length was **not** made adjustable. The user asked why it is fixed, not
to change it. If it is wanted later, `durationSeconds` already exists as a
parameter on both cue generators; it would need a saved setting threaded from
`PitchDroneSettings` through `playPitchCue`. That is a separate plan.
