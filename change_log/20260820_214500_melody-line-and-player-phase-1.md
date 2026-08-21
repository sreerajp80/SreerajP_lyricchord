# Melody line and melody player — Phase 1

Date: 2026-08-20
Implements: [plans/20260820_212252_melody-line-and-player.md](../plans/20260820_212252_melody-line-and-player.md)
Covers: **Phase 1 only** (read and play). Phases 2 and 3 are not started.

---

## What changed

A song can now carry its **tune**, not just its words and chords. A `{melody}`
line written under a lyric line is parsed into beats, drawn as a beat grid, and
hummed back over the drone.

Songs with no melody lines are untouched and behave exactly as before.

## The format

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

Five marks, nothing else:

| Mark | Written | Meaning |
|---|---|---|
| comma | `,` | hold the note before it one more beat |
| bar | `\|` | bar line — takes no time, shows a tala group |
| hyphen | `G3-R2` | the joined notes share one beat |
| bang | `M2!G3`, `!G3` | slide into a note, optionally from a named one |
| tilde | `G3~` | shake the note |

A leading `.` drops an octave (`.N3`); a trailing `'` or `^` raises it (`S'`).

**One naming rule, used everywhere:** a bare name is the note from the plain
Sa Re Ga Ma Pa Dha Ni row, so `Ma` is Ma1. A digit names the exact variant, so
the raised Ma is `Ma2` / `M2`. The raga never changes what a name means — which
is why no raga or melakarta table was needed anywhere.

## New files

| File | What it does |
|---|---|
| `lib/models/melody_note.dart` | one note: pitch, octave, slide, shake |
| `lib/models/melody_beat.dart` | one beat: the notes sharing it and their slot weights, or a hold, bar line, or unreadable token |
| `lib/models/melody_line.dart` | a parsed line: beats, beat count, problems, `fitsTala` |
| `lib/services/melody_parser_service.dart` | melody text into beats. Never throws. |
| `lib/services/melody_player_service.dart` | beats plus tonic and tempo into timed spans |
| `lib/services/melody_audio_service.dart` | renders a line as one WAV and plays it |
| `lib/providers/melody_player_provider.dart` | play / stop / loop / half speed / cursor |
| `lib/widgets/melody_beat_grid.dart` | the beat boxes, grouped by tala |
| `lib/widgets/melody_line_row.dart` | play button, grid, and the loop / half-speed chips |

## Changed files

| File | Change |
|---|---|
| `lib/services/swara_notation_service.dart` | `Ma2` now reads the same as `M2`. Full names carrying a variant digit are folded to their letter form before the lookup (`Ri2`→`R2`, `Dha2`→`D2`). Nothing else changed. |
| `lib/services/chord_sheet_parser.dart` | new `ChordLineKind.melody` and a `melody` field on `ChordLine`. A `{melody}` line is recognised **before** the directive test, or `{melody: ...}` would have been swallowed as a header and the tune lost. |
| `lib/services/chord_pro_service.dart` | `{melody}` and `{tonic}` are kept inside the lyrics on import instead of being dropped as unknown directives — in both the single-song and multi-song paths. |
| `lib/services/pitch_naming_service.dart` | new `noteForTonic()`: reads `1 kattai`, `5½ kattai`, `5.5`, `5 1/2` or a Western key back into a note. |
| `lib/services/pcm_synth_service.dart` | new `PcmTone` and `generateSequenceWav()`, which renders a run of tones back to back as one file. |
| `lib/widgets/chord_sheet_view.dart` | draws melody lines; takes optional `melodyTonicHz` and `melodyTempoBpm`. |
| `lib/screens/song_performance_screen.dart` | resolves the song's Sa and tempo and passes them down. |
| `lib/screens/help/help_content.dart` | new "Melody Lines" help topic. |
| `docs/architecture.md`, `docs/features.md` | record the new services, models and the feature. |

## Decisions made while building

**The tonic and the melody live inside the song text, not in new columns.** No
database change, no migration, and import, export and transposition carry both
through untouched. `ChordSheetParser` reads the tonic back out of
`ParsedSheet.directives`.

**The whole line is rendered as one WAV, not one sound per note.** Starting a
sound per note on a timer drifts on a real device and every start carries its
own latency, so the tune would come out uneven — which is exactly what a learner
would copy. Timing is now decided in arithmetic. The cursor timer only moves the
highlight; it never decides when a note sounds, so the cursor can lag a frame
without the tune lagging at all.

**An apostrophe means upper octave in a melody line, not tivra Ma.**
`SwaraNotation.swaraPosition` reads a trailing apostrophe on Ma as tivra. The
melody parser strips octave marks *before* the pitch lookup, so `M'` is upper
Ma1. This is consistent with the one naming rule: the raised Ma is always `M2`.
The plan said "trailing apostrophe raises an octave" and this is how that was
made to work alongside the existing service.

**An unreadable token keeps its beat.** It becomes a marked beat drawn in the
error colour and played as silence. Dropping it would pull every later note
earlier and quietly break the rest of the line.

**A comma inside a shared beat weights the split** rather than adding a note, so
`G3-,-R2` is two thirds Ga and one third Ri. `MelodyBeat` carries a `slots` list
for this.

**Sa moves with the transpose.** Transposing the chords up two semitones moves
the tonic too, or the tune would be hummed in the old key while the chords
showed the new one. Swaras themselves never transpose — they are relative to Sa
already.

**No tonic means no playback, not a guessed one.** The grid still draws and
reads correctly; the play button is disabled with a tooltip saying what to add.

## What is deliberately not done yet

* **The slide and shake marks are parsed and stored but not sounded.** Every
  span comes out as a steady tone. Files written now stay correct when phase 3
  implements them.
* **Equal steps, not true ratios.** Pitch comes from one line in
  `MelodyPlayerService.frequencyOf`, so swapping to ratios against the drone is
  a contained change (phase 3).
* **No keypad.** Melodies are typed into the existing text field. The keypad is
  phase 2, and it is the part that decides whether anyone actually fills a
  melody in.

## Verification

* `flutter analyze` — clean, no issues.
* `flutter test` — **675 tests, all passing** (up from 666).
* `dart format .` — applied.

New tests:

* `test/services/melody_parser_service_test.dart` — 42 tests: every mark, every
  combination, and sixteen kinds of rubbish input that must not throw.
* `test/services/melody_player_service_test.dart` — 17 tests: beats add up
  exactly, bar lines take no time, half speed doubles every duration without
  changing pitch, odd splits total exactly one beat.
* `test/widgets/melody_beat_grid_test.dart` — 9 tests: tala grouping, the
  writer's own spelling, cursor highlight, a wide line scrolling.
* `test/widgets/melody_line_row_test.dart` — 9 tests, with a fake audio source:
  play, stop, loop, half speed, disabled without a tonic, and a SnackBar when
  the sound will not start.

Added to existing files:

* `test/services/chord_pro_service_test.dart` — 6 tests: melody and tonic
  survive import, export, a round trip, transposition, and a multi-song bundle.
* `test/services/swara_notation_service_test.dart` — 4 tests for `Ma2`.
* `test/services/pitch_naming_service_test.dart` — 5 tests for `noteForTonic`.

## Open question carried forward

The chord `[Ma]` and the melody `M2` are now unambiguous under the one naming
rule, so the sample song is correct as written. Worth confirming on a real
device that the Ma chord an accompanist expects is the Ma1-rooted one.
