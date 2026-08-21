# Melody line and melody player

**Status:** in_progress

Date: 2026-08-20
Slug: `melody-line-and-player`

## Progress

| Phase | State |
|---|---|
| 1 — read and play | **done** (2026-08-20) — [change log](../change_log/20260820_214500_melody-line-and-player-phase-1.md) |
| 2 — keypad entry | not started |
| 3 — gamaka and true-ratio tuning | not started |

One deviation worth noting: a trailing apostrophe means **upper octave** in a
melody line, never tivra Ma. The parser takes octave marks off before the pitch
lookup, so the existing tivra reading in `SwaraNotation` never sees them. This
follows the one naming rule — the raised Ma is always written `M2` / `Ma2`.

---

## 1. What the issue is

A song file in LyricChord holds **words** and **chords**. It does not hold the **tune**.

That is fine for someone who has heard the song before — the sheet is a reminder.
It is useless for someone who has not. They can read every word and see every
chord and still not know how the song goes.

The app already has the pieces around this gap:

* `SwaraNotation` (`lib/services/swara_notation_service.dart`) already turns a
  swara token into a semitone position, and already knows tala beat counts.
* `ChordSheetParser` already has a `ChordLineKind.swaram` for a line of bare
  swaras, drawn in a fixed grid.
* `PcmSynthService` already makes tones, and `PitchDroneAudioService` already
  plays a drone.

What is missing is the join: a way to write a tune **against the words and the
beat**, and a player that sings it back over the drone.

The existing `swaram` line is display only. It has no beats, no note lengths, no
octave, no playback, and no link to the lyric line above it.

---

## 2. What this adds

One new line type in the song text: `{melody}`, sitting under a lyric line.

```
{title: Krishna Nee Begane Baro}
{raga: Yamunakalyani}
{tala: misra chapu}
{tonic: 1 kattai}
{tempo: 68}

Pallavi:
[Sa]Krishna nee be[Ma]gane baro [Sa]
{melody} P ,  M2 | M2!G3~ ,  | R2 S
```

Nothing about the words or the chords changes. The melody line is optional —
every existing song keeps working untouched.

---

## 3. The format

### 3.1 Header directives

| Directive | Required for playback | Meaning |
|---|---|---|
| `{tonic: ...}` | **yes** | the real pitch of Sa (e.g. `1 kattai`). Without it nothing can be played. |
| `{tala: ...}` | for the grid | how many beats per cycle and where the bar lines fall. Read by the existing `SwaraNotation.talaBeats`. |
| `{tempo: N}` | yes | beats per minute. |
| `{raga: ...}` | no | **display label only.** Nothing parses it. No raga database. |

### 3.2 The melody line

Beats are separated by spaces. Five marks, nothing else:

| Mark | Written | Meaning |
|---|---|---|
| comma | `,` | hold the previous note for one more beat |
| bar | `\|` | bar line — where a new tala group starts |
| hyphen | `G3-R2` | the joined notes share one beat, split equally |
| bang | `M2!G3` or `!G3` | slide into a note. The note left of the bang says where the slide starts; leaving it out means a short slide in from just under the target. |
| tilde | `G3~` | shake the note (gamaka oscillation) |

Octave: a leading dot drops a note an octave (`.N3`), a trailing apostrophe
raises it (`S'`). Neither can be combined with the other.

### 3.2.1 Naming rule (decided)

**One rule, used everywhere — in chord brackets and in melody lines alike:**

> A bare swara name means the note as it sits in the plain
> **Sa Re Ga Ma Pa Dha Ni** row. A digit names an exact variant.

| Written | Semitones above Sa |
|---|---|
| `Sa` / `S` | 0 |
| `Ri` / `Re` / `R` | 2 |
| `Ga` / `G` | 4 |
| `Ma` / `M` | 5 |
| `Pa` / `P` | 7 |
| `Dha` / `D` | 9 |
| `Ni` / `N` | 11 |

So `Ma` on its own is **Ma1**. The raised Ma must be written `Ma2` (or `M2`).
There is no case where the raga silently changes what a name means.

This is already how `SwaraNotation.swaraPosition` behaves — `_shuddhaByName`
maps `ma` to 5, and `_carnaticPositions` already holds the full variant table
(`R1 R2 R3`, `G1 G2 G3`, `M1 M2`, `D1 D2 D3`, `N1 N2 N3`). No behaviour change
is needed, only the gap in 3.2.2.

### 3.2.2 Gap to fix in the existing service

Full name plus digit does **not** parse today. `swaraPosition('Ma2')` returns
`null`, because `_carnaticPositions` is keyed on the single-letter forms
(`M2`) and `_shuddhaByName` has no entry for `ma2`.

Since the chord layer uses full names (`[Ma]`, `[Pa]`), `[Ma2]` must work.
Fix: fold a full name down to its letter before the variant lookup, so
`Ma2` = `M2`, `Ri2` = `R2`, `Dha2` = `D2`, `Ni3` = `N3`, and so on.

### 3.2.3 Variants

Variants are written into the note itself — `R1 R2 R3`, `G1 G2 G3`, `M1 M2`,
`D1 D2 D3`, `N1 N2 N3`. `S` and `P` never take a digit. Both the letter form
(`M2`) and the full-name form (`Ma2`) mean the same thing.

Convention in practice: full names inside chord brackets (`[Ma2]`), short
letters in melody lines (`M2`). Both are accepted in both places — the
difference is only what reads better.

### 3.3 Grammar

```
line   = beat ( SPACE+ beat )*
beat   = note ( "-" note )*  |  ","  |  "|"
note   = [ from "!" ] target [ "~" ]
from   = swara
target = swara
swara  = [ "." ] LETTER [ DIGIT ] [ "'" ]
```

A comma may also appear inside a hyphen group, where it extends the sub-beat
before it.

### 3.4 Why no raga lookup

Every variant is written into the note. The player resolves `M2` straight to a
semitone. It never needs to know what Yamunakalyani is, so there is no raga
table to build, ship, or maintain. `{raga:}` stays as a label for the reader.

---

## 4. Scope

### In

* Parsing `{melody}` lines, defensively — bad input never throws (hard rule 4).
* Playing a melody line back over the existing drone, at full and half speed,
  with looping and a moving cursor.
* Drawing the beat grid, grouped by the tala.
* Tapping notes in on a keypad instead of typing them.
* Import/export round-trip keeps melody lines intact.

### Out (explicitly not building)

* Any raga or melakarta database.
* Gamaka beyond the two marks above.
* Exercises, drills, scale practice, raga reference charts — anything that works
  with no song open belongs in a different app.
* Automatic melody detection from audio.

---

## 5. Files

### New

| File | Purpose |
|---|---|
| `lib/models/melody_note.dart` | one note: semitone position, octave, optional slide source, shake flag |
| `lib/models/melody_beat.dart` | one beat: the notes sharing it, or a hold, or a bar line |
| `lib/models/melody_line.dart` | a parsed line: beats, tala grouping, beat count |
| `lib/services/melody_parser_service.dart` | text to `MelodyLine`. Never throws. Reports problems as a result, not an exception. |
| `lib/services/melody_player_service.dart` | `MelodyLine` + tonic + tempo to scheduled tones |
| `lib/providers/melody_player_provider.dart` | play / stop / loop / half speed / cursor position |
| `lib/widgets/melody_beat_grid.dart` | the grid with tala grouping and the moving cursor |
| `lib/widgets/melody_keypad.dart` | tap entry (phase 3) |

### Modified

| File | Change |
|---|---|
| `lib/services/chord_sheet_parser.dart` | add `ChordLineKind.melody`; recognise a `{melody}` line and attach it to the lyric line above |
| `lib/services/chord_pro_service.dart` | read the new header directives; keep `{melody}` lines through import and export unchanged |
| `lib/services/swara_notation_service.dart` | make full name + digit parse (`Ma2` = `M2`, `Ri2` = `R2`, `Dha2` = `D2`) — see 3.2.2. Everything else stays as it is. |
| `lib/services/pcm_synth_service.dart` | add a pitch ramp (for the bang mark) and a pitch wobble (for the tilde mark) to tone generation |
| `lib/screens/song_performance_screen.dart` | show melody lines; play / loop / half-speed control |
| `lib/screens/song_editor_screen.dart` | melody keypad and live beat-count check |
| `lib/screens/help/help_content.dart` | document the five marks and the header directives |
| `docs/architecture.md`, `docs/features.md` | record the new layer pieces and the feature |

### Tests (mirroring `lib/`)

* `test/services/melody_parser_service_test.dart` — every mark, every
  combination, and a pile of broken input that must not throw
* `test/services/melody_player_service_test.dart` — note timings add up to the
  right total; half speed doubles every duration; the hyphen splits a beat evenly
* `test/widgets/melody_beat_grid_test.dart` — tala grouping draws the right boxes
* `test/services/chord_pro_service_test.dart` — melody lines survive an
  import/export round trip

---

## 6. Phases

Ordered by what unblocks the next thing, not by what is most interesting.

**Phase 1 — read and play (the shippable core).**
Parser, models, player, beat grid, playback over the drone with loop and half
speed. The parser accepts the bang and tilde marks from day one and stores them,
but the player ignores them — so files written now stay correct later. No editor
changes; melodies are typed into the existing text field.

**Phase 2 — make it enterable.**
The keypad: swara buttons, hold, bar, share-beat, slide, shake, octave up/down.
Live beat count against the tala, so a wrong-length line is caught as it is
typed.

**Phase 3 — make it sound like music.**
Implement the bang and tilde marks in the synth. Switch the tone table from
equal steps to true ratios against the drone.

### Why entry comes before sound

An earlier draft had these the other way round. That was wrong.

Phase 3 makes melodies that **already exist** sound better. Phase 2 decides
whether melodies exist at all. If nobody can enter a tune without carefully
typing spaces and commas into a plain text box, there is nothing for phase 3 to
improve.

So the polish waits. Phases 1 and 2 together are the real feature; phase 3 is
what you do once people are using it.

---

## 7. Risks

**Data entry is the real risk, not the code.** Every song needs a person who
knows the tune to sit down and enter it. If that is slow or fiddly, the feature
sits empty. Phase 1 exists partly to measure this cheaply before building the
keypad.

**It will not sound like a singer.** Even with the two gamaka marks, the shaping
of a note changes by phrase and by singer, and no notation captures it. The help
screen must say plainly: *the melody player shows you where the notes go; listen
to a singer for how to shape them.*

**Scope creep toward classical pedagogy.** The test for any follow-up feature:
if it needs a song from the user's book to make sense, it belongs here. If it
works with no song at all, it is a different app.

---

## 8. Decisions taken

1. **What does `Ma` mean?** One rule everywhere: a bare name is the note from
   the plain Sa Re Ga Ma Pa Dha Ni row, so `Ma` is Ma1. A digit names the exact
   variant, so the raised Ma is written `Ma2` / `M2`. The raga never silently
   changes what a name means. See 3.2.1.

   This also means the sample song is already correct as written — `[Ma]` is the
   right chord for the accompanist, and the melody's `M2` is the right note for
   the singer. Two different notes, two different spellings, no ambiguity.

2. **Where do melody lines live?** Inline in the existing song content text. No
   schema change, no new database fields, no change to import or export
   plumbing.

3. **Phase order.** 1, then 2, then 3 — with entry (the keypad) ahead of sound
   polish. See "Why entry comes before sound" in section 6.

Nothing is left open. Ready to implement on approval.

---

## 9. Definition of done (phase 1)

* A song with `{melody}` lines parses, draws a beat grid, and plays back over
  the drone at full and half speed, with looping.
* A song with no melody lines behaves exactly as it does today.
* Broken melody text never throws and never corrupts the song.
* Import and export keep melody lines byte-identical.
* `flutter analyze` clean, `flutter test` green.
* Change log written to `change_log/`.
