# Melody phase 3 — the shake, and true-ratio tuning

**Status:** completed

Date: 2026-09-01
Slug: `melody-phase-3-gamaka-and-tuning`

Implements **phase 3** of
[20260820_212252_melody-line-and-player.md](20260820_212252_melody-line-and-player.md),
the last one. Phase 2 is
[20260901_064116_melody-keypad-phase-2.md](20260901_064116_melody-keypad-phase-2.md).

---

## 1. What is left

The parent plan's phase 3 is "make it sound like music", and named two jobs:

1. **The gamaka marks in the synth.** Half of this is already done — the slide
   `!` was sounded in
   [20260822_sound_the_slide.md](20260822_sound_the_slide.md). What remains is
   the **shake `~`** (kampita), which is parsed, stored, drawn on the grid, and
   silent.
2. **True ratios instead of equal steps.** `MelodyPlayerService.frequencyOf` is
   one line of equal temperament. Every swara is played at a Western piano's
   pitch, over a drone tuned to whole-number ratios. The fifth is the audible
   case: the drone's Pa is exactly `1.5 x Sa`, and the melody's Pa is
   `2^(7/12) x Sa` — about **2 cents flat of the drone**, so a held Pa beats
   slowly against the thing it is supposed to lock into.

---

## 2. A concern to state before building it

`docs/carnatic_notation.md` §8 currently says the shake is left silent **on
purpose**:

> The shake is left alone on purpose. A fixed sine wobble is not a gamaka —
> kampita's shape, width and speed depend on the raga, the note and the phrase,
> and a generic vibrato would likely sound *worse* than a plain note. It waits
> for a real gamaka model.

That reasoning has not stopped being true, and this plan does not pretend to
deliver a raga-aware gamaka model — the app holds no raga grammar and phase 1
decided it never would (parent plan §3.4). What this plan builds is a **plain
approximation**, designed to be as unembarrassing as possible:

- it swings **up from the written note and back**, never around it, so the note
  the reader sees stays the pitch the ear anchors on;
- it is **metrical** — tied to the beat, not a fixed vibrato speed — because
  gamakas move with the tala;
- it **holds the plain note first** and ramps the depth in, so the pitch is
  established before anything moves;
- it **does not shake a short note at all**, because half a swing sounds like a
  wobble, not a gamaka.

The doc will be rewritten to say exactly this: sounded, approximate, and not a
raga-aware model. If it turns out to sound worse than a plain note on real
songs, the honest fix is to make it optional or take it back out — I would
rather record that risk here than discover it quietly.

The tuning change carries no such doubt. It is unambiguously more correct.

---

## 3. True-ratio tuning

### The change

`frequencyOf(semitones, tonicHz)` stops computing `2^(n/12)` and reads a ratio
table instead:

```dart
double frequencyOf(int semitonesFromSa, double tonicHz) {
  final octave = (semitonesFromSa / 12).floor();
  final position = semitonesFromSa - octave * 12;   // always 0..11
  return tonicHz * math.pow(2, octave) * justRatios[position];
}
```

### The table

| Position | Swara | Ratio | Cents | Equal temp | Difference |
|---|---|---|---|---|---|
| 0 | Sa | 1/1 | 0 | 0 | 0 |
| 1 | Ri 1 | 16/15 | 112 | 100 | +12 |
| 2 | Ri 2 | 9/8 | 204 | 200 | +4 |
| 3 | Ri 3 / Ga 2 | 6/5 | 316 | 300 | +16 |
| 4 | Ga 3 | 5/4 | 386 | 400 | −14 |
| 5 | Ma 1 | 4/3 | 498 | 500 | −2 |
| 6 | Ma 2 | 45/32 | 590 | 600 | −10 |
| 7 | Pa | 3/2 | 702 | 700 | +2 |
| 8 | Dha 1 | 8/5 | 814 | 800 | +14 |
| 9 | Dha 2 / Ni 1 | 5/3 | 884 | 900 | −16 |
| 10 | Dha 3 / Ni 2 | 16/9 | 996 | 1000 | −4 |
| 11 | Ni 3 | 15/8 | 1088 | 1100 | −12 |

Two of these are worth defending:

- **Pa = 3/2** is the point of the whole change. The drone's fifth is
  `rootFreq * 1.5` in `PcmSynthService.generateShrutiBoxWav`, so this makes the
  melody's Pa land exactly on the drone's, with no beating.
- **Ma 2 = 45/32.** The tritone has no clean answer; 45/32 and 64/45 are both
  defensible. 45/32 is chosen because it is the one reachable from the notes
  around it (`5/4 x 9/8`), so a Ga3-Ma2 phrase stays in tune with itself.

**This is a 12-key just-intonation table, not the 22-sruti scheme.**
`docs/carnatic_notation.md` §2 already records that the app models the twelve
svarasthanas and does not do microtonal shading; that stays true. Positions that
carry two names (3, 9, 10) get one tuning, because our model has one key there.

### What it touches

Nothing else. `frequencyOf` is the only place a pitch is decided — the slide's
start pitch and the keypad both go through it — which is exactly what the phase
1 comment predicted.

---

## 4. The shake

### How it is shaped

A shaken note's pitch over time:

```
f(t) = note * 2^( depth(t) * (1 - cos(2*pi*rate*t')) / 2 / 12 )
```

- `(1 - cos(...)) / 2` runs **0 → 1 → 0**, so the pitch leaves the note, rises
  to `depth` semitones above, and comes back. It never dips below the written
  note.
- `t'` is time measured from the end of the onset hold, so the swing starts from
  the note rather than mid-air.
- `depth(t)` ramps from 0 to the full depth over the first swing, so the shake
  grows in rather than switching on.

### The numbers, and why

| Setting | Value | Why |
|---|---|---|
| Depth | **1 semitone** | The neighbouring key. Without raga grammar, a wider swing would land on a note that may not be in the raga at all. |
| Rate | **2 swings per beat**, clamped to 3–8 Hz | Metrical, so it moves with the tala. The clamp keeps a very slow or very fast tempo from producing a lazy scoop or a buzz. |
| Onset hold | **15% of the note, capped at 60 ms** | Establishes the pitch first. Mirrors how the slide is capped. |
| Minimum note | **0.18 s** | Below this there is no room for a full swing, so the note plays plain. |

The rate is worked out by the **player**, not the synth, because the player is
the layer that knows the tempo — the same division of labour the slide already
uses, where the player computes `fromFrequency` because only it knows the tonic.

### Where the code goes

`PcmTone` gains two fields, `shakeHz` and `shakeDepthSemitones`, next to the
`fromFrequency` the slide added. `generateSequenceWav` already has a
phase-accumulator path for gliding tones — a shaken tone uses that same path,
because a changing pitch cannot be computed from absolute time (that is the
phase trap the slide plan documented). The condition widens from "slides" to
"slides or shakes", and the per-sample frequency becomes:

```
base  = in the glide ? slideFrequency(...) : tone.frequency
freq  = base * shakeFactor(sampleIndex)
```

so **a note can slide and shake at once**, which the parser has always allowed
(`M2!G3~`) and which nothing has been able to render until now.

---

## 5. Files

### Modified

| File | Change |
|---|---|
| `lib/services/melody_player_service.dart` | `frequencyOf` reads the ratio table; new `justRatios` constant; `shakeHzFor(duration)` works out the metrical rate; `MelodySpan` gains `shakeHz` and `shakeDepthSemitones`, filled in for a note carrying `~` that is long enough. |
| `lib/services/pcm_synth_service.dart` | `PcmTone` gains `shakeHz` / `shakeDepthSemitones` and a `shakes` getter; new `shakeFactor` (pure, testable) and the constants above; `generateSequenceWav` renders shake through the phase path, combined with the glide. |
| `lib/services/melody_audio_service.dart` | Passes the two new span fields into `PcmTone`. |
| `test/services/melody_player_service_test.dart` | The `frequencyOf` group is rewritten for just ratios — Pa lands on the drone's `1.5`, the octave still doubles, and a comparison against equal temperament documents the sizes. New tests for the shake rate and the short-note rule. |
| `test/services/pcm_synth_service_test.dart` | `shakeFactor` shape: starts at 1.0, peaks at the depth, returns, never goes below the note; a shaken tone renders a valid WAV of the right length; a tone that both slides and shakes is rendered. |
| `test/services/melody_audio_service_test.dart` (if present, else the melody audio coverage in place) | The shake reaches the tone. |
| `docs/carnatic_notation.md` | §8: the shake moves from "still cannot express" to "built", written honestly as an approximation. A new note records the tuning. |
| `docs/features.md` | §2.8: swaras are tuned in whole-number ratios against the drone; the shake is sounded. |
| `plans/20260820_212252_melody-line-and-player.md` | Progress table: phase 3 done. |

No new file, no new package, no schema change, no stored-format change. A song
written before this plays the same notes — only their tuning and their shake
change.

---

## 6. Risks

1. **The shake may sound worse than a plain note.** Stated in §2. Mitigated by
   the conservative shaping; if it is bad on real songs, the follow-up is to
   make it optional.
2. **Existing pitch tests will fail, and should.** Every equal-tempered
   expectation in the player tests is now wrong by design. They are being
   rewritten, not loosened — the new values are asserted against the ratios, not
   against whatever the code produces.
3. **A shaken note is more expensive to render.** It moves that tone onto the
   phase path, which costs a few more operations per sample. The line is
   rendered once, offline, before playback starts, so this is not a real-time
   budget — the same argument the slide plan made.
4. **Just intonation only makes sense against a fixed Sa.** It does: the whole
   melody format is relative to the song's Sa, and the drone holds it. There is
   no key change to drift against.

---

## 7. Out of scope

- **A raga-aware gamaka model** — needs raga grammar the app does not have and
  phase 1 decided against.
- **The other gamakas** (jaru variants, sphuritam, and the rest). Only the two
  marks the format has, `!` and `~`, are sounded.
- **A setting to turn gamakas off.** Worth having if the shake disappoints, but
  it is a settings-screen change, not a synth one, and guessing now would be
  building for a problem that may not appear.
- **The 22-sruti scheme.** The app models twelve keys, as §2 of the notation doc
  records.

---

## 8. Definition of done

- A held Pa does not beat against the drone.
- `Ga3~` on a slow line is audibly shaken, and the shake stays on the written
  note as its anchor.
- `M2!G3~` both slides and shakes.
- A very short note plays plain.
- `flutter analyze` clean, `flutter test` green, `dart format .` run.
- Docs updated honestly, change log written, parent plan closed.
