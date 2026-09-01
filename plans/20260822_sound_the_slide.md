# Make the slide (`!`) actually sound

**Status:** completed

Date: 2026-08-22

---

## The issue

`!` (slide, jaru) and `~` (shake, kampita) are parsed, stored and drawn, but the
player hums plain notes. A slide is heard as a step.

`docs/carnatic_notation.md` §8 lists this as a known limit. This plan closes half
of it: **the slide**. The shake is deliberately left out — see below.

## Why it does not sound today

Not a missing capability. The melody is rendered to a WAV **in our own Dart
code, offline**, so there is no real-time budget to worry about. The blocker is
that the data has nowhere to put a changing pitch:

```dart
class PcmTone {
  final double frequency;        // one fixed pitch
  final double durationSeconds;
}
```

```dart
static double harmonicSample(int sampleIndex, double freq, int sampleRate) {
  final t = sampleIndex / sampleRate;
  return sin(2 * pi * freq * t) ...;   // frequency never varies
}
```

### The trap: it is about phase, not frequency

`freq` cannot simply be swapped for a varying value. `sin(2π · f · t)` computed
from absolute time gives an **instantaneous** pitch of `f(t) + t·f′(t)`, not
`f(t)`. A linear glide would sweep at roughly double the intended rate, and every
sample step would click.

The synth has to accumulate **phase** instead:

```dart
phase += 2 * pi * freqAtThisSample / sampleRate;
sample = sin(phase);
```

This is the real work. It is standard and small, but it changes how the
synthesiser fundamentally runs, and the drone and click share that code.

## The fix

### 1. Phase-accumulator synthesis

Add a phase-stepping path to `PcmSynthService` and use it in
`generateSequenceWav`. The existing time-based `harmonicSample` stays for the
callers that hold one pitch throughout (drone, click, pitch cue), so their sound
does not change at all — no risk of altering something that already works.

The harmonics ride the same accumulated phase, so a glide keeps its timbre.

### 2. A tone can carry a starting pitch

```dart
class PcmTone {
  final double frequency;        // where it lands
  final double? fromFrequency;   // where the glide starts, null for no glide
  final double durationSeconds;
}
```

Sweep **linearly in semitones**, not in Hz — a glide that is linear in Hz sounds
wrong at the low end, because pitch is logarithmic.

### 3. The scheduler works out the starting pitch

`MelodySpan` gains `fromFrequency`. `MelodyPlayerService` fills it in, because it
is the only place that knows both the note's `slideFrom` and the song's tonic:

* `M2!G3` — glide from Ma to Ga.
* `!G3` — a bare `!` has no written start, so it comes from just below.

### 4. The audio service passes it through

`MelodyAudioService` already maps spans to tones; it gains one field.

## Two judgement calls — please confirm

Neither is settled by the notation, so I would rather you chose than have me
pick quietly.

**a. How long is the glide?** Proposal: the first **30%** of the note, capped at
**120 ms**, so a long held note does not glide lazily for half a second. The
rest of the note holds the target pitch.

**b. Where does a bare `!` start?** Proposal: **one semitone below** the target
— the nearest neighbour, a short scoop into the note. Two semitones would be a
bigger, more obvious slide.

Both would be named constants, easy to change once you hear them.

## Why the shake (`~`) is not in this plan

A generic vibrato is not a gamaka. Kampita has a shape, width and speed that
depend on the raga, the note, and its place in the phrase. A fixed sine wobble is
what a keyboard does, and to a trained ear it would likely sound **worse than a
plain note** — wrong in a way a plain note is not.

The slide has no such problem: a glide between two pitches is well defined, and
roughly right already beats a step. So the slide is worth doing now and the shake
is not, until there is a real gamaka model behind it.

## Files to change

| File | Change |
|---|---|
| `lib/services/pcm_synth_service.dart` | Phase-accumulator path; `PcmTone.fromFrequency`; sweep in semitones. |
| `lib/services/melody_player_service.dart` | `MelodySpan.fromFrequency`, filled from `note.slideFrom` and the tonic. |
| `lib/services/melody_audio_service.dart` | Pass the new field into `PcmTone`. |
| `test/services/pcm_synth_service_test.dart` | The glide starts low and ends on pitch; no phase jump at the seam; a tone with no glide is unchanged. |
| `test/services/melody_player_service_test.dart` | `M2!G3` sets the start pitch; `!G3` starts a semitone below; a plain note sets none. |
| `docs/features.md`, `docs/carnatic_notation.md` | The slide sounds; the shake still does not. |

## How it will be tested

Sound is hard to assert, so the tests check the **samples**, not a feeling:

* A glide tone's early samples sit near the starting pitch and its late samples
  near the target — measured by counting zero crossings over a window, which
  gives the frequency without needing an FFT.
* **No phase jump at a tone boundary**: the step between the last sample of one
  tone and the first of the next stays small. This is the click the phase
  accumulator exists to prevent, so it is worth pinning.
* A tone with `fromFrequency == null` produces **byte-identical** output to
  today, which is what proves the drone and click are untouched.

## Risks

* **The synth is shared.** The drone, click and pitch cue use the same file. The
  byte-identical test above is the guard: if any of them changes, it fails.
* **A glide may sound wrong at first.** The two constants above are the dials.
  Judging them needs ears, so expect one round of adjustment after you hear it.
* **File size.** No change — the WAV is the same length, only its contents vary.

## Checks after the change

* `flutter analyze` clean, `flutter test` green.
* A tone with no glide is byte-identical to the current output.
* On a phone: play the sample song and hear the slides; the drone, metronome
  click and pitch cue sound exactly as before.
