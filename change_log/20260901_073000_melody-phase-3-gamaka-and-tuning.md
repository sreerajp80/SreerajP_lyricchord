# Melody phase 3 — the shake, and true-ratio tuning

Date: 2026-09-01
Implements [../plans/20260901_070119_melody-phase-3-gamaka-and-tuning.md](../plans/20260901_070119_melody-phase-3-gamaka-and-tuning.md),
the last phase of
[../plans/20260820_212252_melody-line-and-player.md](../plans/20260820_212252_melody-line-and-player.md),
which is now closed.

---

## What changed

Two things, both in how a melody **sounds**. Nothing about how it is written,
stored, imported or exported changed at all — a song saved before this plays the
same notes, tuned differently and shaken where it says to shake.

### 1. Swaras are tuned to the drone, not to a piano

`MelodyPlayerService.frequencyOf` was one line of equal temperament. It now
reads `justRatios`, a twelve-key just-intonation table, and multiplies by a
plain octave doubling.

The point of it: the shruti drone sounds Pa at exactly `1.5 x Sa` and Ma at
exactly `4/3`. An equal-tempered Pa is about two cents flat of that, so a held Pa
used to beat slowly against the very drone it should lock into. Now it does not.

Ma 2 is the one with no clean answer — `45/32` was chosen over `64/45` because it
is reachable from the notes around it (`5/4 x 9/8`), so a Ga3-Ma2 phrase stays in
tune with itself. This is the twelve-key scheme the app already documents in
`docs/carnatic_notation.md` §2, not the 22-sruti one: a position carrying two
names gets one tuning.

### 2. The shake is sounded

`~` was parsed, stored, drawn and silent. It now moves the pitch:

- **up from the written note and back**, never around it, so the written pitch
  stays what the ear anchors on;
- **one key deep**;
- **two swings per beat**, clamped to 3-8 Hz, so it moves with the tala rather
  than at a fixed vibrato speed — and a line played at half speed shakes half as
  fast;
- after a **plain onset** (15% of the note, capped at 60 ms) and **ramping in**
  over the first swing;
- **not at all on a note under 180 ms**, because half a swing is a wobble, not a
  gamaka.

A note can now **slide and shake at once** — `M2!G3~` has always been writable
and nothing could render it until now.

## Changed files

- **`lib/services/melody_player_service.dart`** — `justRatios` and the new
  `frequencyOf`; the shake constants and `shakeHzFor`; `MelodySpan` gains
  `shakeHz`, `shakeDepthSemitones` and a `shakes` getter; a new `_withShake`
  pass. That pass runs **after** the schedule is built, on purpose: a hold or a
  tie stretches the span before it, so `Ga3~ ,` is one long note and judging its
  length from the first beat alone would wrongly call it too short.

- **`lib/services/pcm_synth_service.dart`** — `PcmTone` gains `shakeHz`,
  `shakeDepthSemitones`, `shakes` and `pitchMoves`; the new pure `shakeFactor`
  and its two onset constants; `generateSequenceWav` renders any tone whose
  pitch moves through the phase-accumulator path the slide added, with the shake
  riding on top of the glide.

- **`lib/services/melody_audio_service.dart`** — passes the two new span fields
  into the tone.

- **`test/services/melody_player_service_test.dart`** — the `frequencyOf` group
  is rewritten for the ratios: Pa and Ma1 land exactly on the drone, every key
  matches its ratio, the ratios hold in every octave, and one test states
  plainly that this is *not* equal temperament. A new shake group covers the
  rate following the tempo, both clamps, half speed halving the swing, the
  short-note rule, the held-note case, slide-and-shake together, and silence
  never shaking.

- **`test/services/pcm_synth_service_test.dart`** — a shaken-tone group:
  `shakeFactor` holds the plain note through the onset, never dips below the
  written note, reaches the full depth and returns, and ramps in over the first
  swing; the rendered pitch moves while staying inside the note-to-next-key
  band; the wave stays continuous (no clicks); a tone can slide and shake; and a
  steady tone still matches the time-based path sample for sample, which is what
  protects the drone, the click and the pitch cue.

- **`docs/carnatic_notation.md`** — §8: the shake moves into *Built*, with the
  tuning beside it. Its entry under *Still cannot express* is rewritten rather
  than deleted (see below).

- **`docs/features.md`** — §2.8 gains the tuning and the two gamaka marks, and
  drops the phase number from its heading now that all three are done.

- **`plans/20260820_212252_melody-line-and-player.md`** — phase 3 done; the
  plan is `completed`.

## The honest caveat, kept in the docs

The notation doc used to say the shake was left silent *on purpose*, because a
generic wobble is not a gamaka and might sound worse than a plain note. That
entry was **not** deleted. It was rewritten to say what is now true: the shake is
sounded, but it is one fixed shape standing in for every kampita, and it is not
raga-aware — the app holds no raga grammar, by a decision made in phase 1 that
still stands. A musician should read it as "there is a gamaka here", not as a
rendering of that gamaka.

If it turns out to sound worse than a plain note on real songs, the follow-up is
a setting to turn gamakas off, or taking the shake back out. That was not built
now because it would be guessing at a problem that may not appear.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — 824 tests pass (23 more than before).
- `dart format .` — run.
