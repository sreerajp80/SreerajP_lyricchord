# The slide is sung now, not stepped

Date: 2026-08-22

Implements [plans/20260822_sound_the_slide.md](../plans/20260822_sound_the_slide.md).

---

## Why

`!` (slide, jaru) was parsed, stored and drawn, but the player hummed a plain
note — a glide was heard as a step. Nothing blocked it technically; the melody is
rendered to a WAV in our own Dart code, offline, so there is no real-time budget
to work around. The blocker was that a tone had nowhere to put a changing pitch.

## The real difficulty: phase, not frequency

`freq` could not simply be swapped for a varying value. `harmonicSample`
computes `sin(2 * pi * freq * t)` from absolute time. If `freq` changes with `t`,
the pitch actually heard is `freq + t * dFreq/dt` — a linear glide would sweep at
roughly **twice** the rate asked for, and every step would click.

So a gliding tone now steps its own angle instead:

```dart
sample = harmonicSampleAtPhase(phase);
phase += 2 * math.pi * freq / sampleRate;
```

The harmonics are multiples of the same angle, so the timbre holds through the
glide.

## What changed

### `lib/services/pcm_synth_service.dart`

* `PcmTone.fromFrequency` — where a glide starts, `null` for a steady tone.
* `harmonicSampleAtPhase` — the same four harmonics read off a caller-advanced
  angle.
* `slideFrequency` — interpolates **in semitones**, not hertz. Pitch is
  logarithmic, so a glide straight in hertz drags at the bottom and rushes at the
  top.
* `slidePortion` 0.30 and `slideMaxSeconds` 0.12 — the glide takes the first 30%
  of the note, capped at 120 ms, then settles.

**The steady path is untouched.** A tone with no glide still goes through the
original time-based `harmonicSample`, so the drone, metronome click and pitch cue
produce exactly the bytes they did before.

### `lib/services/melody_player_service.dart`

`MelodySpan.fromFrequency`, filled by `slideFromHz()`. This is the only place
that knows both the note's `slideFrom` and the song's tonic.

* `Ma2!Ga3` glides from the written note.
* A bare `!Ga3` scoops in from `bareSlideSemitones` (1) below — enough to hear as
  a slide, not so much that it sounds like a different note sung first.

Holds and ties carry the glide with them, or a slide would lose its scoop the
moment it was held.

### `lib/services/melody_audio_service.dart`

One field passed through to `PcmTone`.

## Tests — measuring samples, not feelings

* **The glide is real.** Frequency measured by counting zero crossings (enough to
  tell 220 Hz from 440 Hz without an FFT): early samples are still climbing, and
  by mid-note the pitch has settled on the target. Checked gliding up and down.
* **The glide is short.** On a two-second note the pitch is on target well before
  halfway, proving the 120 ms cap works.
* **No clicks.** The largest step between neighbouring samples through an
  880 Hz-from-220 Hz glide stays far below full scale. This is the click the
  phase accumulator exists to prevent.
* **Byte-identical for steady tones.** A non-gliding run is compared sample by
  sample against the original time-based formula. This is the guard that the
  drone, click and pitch cue did not change, since they share this file.
* **Semitone interpolation.** Halfway from 220 to 880 is 440, not the 550 a
  straight line in hertz would give.
* **The scheduler.** A written start pitch is used; a bare `!` starts a semitone
  below; a plain note has no glide; a held slide keeps it.

## Checks

* `flutter analyze` — clean, no issues.
* `flutter test` — all **753** pass (was 742).
* `dart format` — applied.

## Not done, on purpose

**The shake `~` is still silent.** A fixed sine wobble is not a gamaka —
kampita's shape, width and speed depend on the raga, the note and its place in
the phrase. Done naively it would likely sound *worse* than a plain note, wrong
in a way a plain note is not. It waits for a real gamaka model.

## Worth hearing before it is called finished

The two constants are judgement calls, not facts: 30% of the note capped at
120 ms, and one semitone for a bare `!`. They are named constants and easy to
change. They have not been listened to on a device yet — that needs ears.
