# Krishna Nee Begane Baaro — the real Carnatic notation, transcribed

Date: 2026-08-22

Implements
[plans/20260821_210000_krishna-notation-transcription-findings.md](../plans/20260821_210000_krishna-notation-transcription-findings.md)
and completes
[plans/20260821_194500_krishna-madhyama-sruti-notation.md](../plans/20260821_194500_krishna-madhyama-sruti-notation.md).

---

## What changed

The sample song now carries the **published Carnatic notation** the user
supplied, replacing text that had been invented. `lib/data/app_database.dart`,
`_krishnaNeeLyrics`:

* **32 `{melody}` lines.** One lyric line spans four misra chapu avartas, so
  each line that has a melody carries four. All 32 parse clean at exactly seven
  beats, checked against the app's own `MelodyParser`.
* **Lyrics respelled** to the source's romanisation (`krishna nee bEganE baarO`,
  `kaalaalandhugE gejje nIlada baavuli`, …), which is what the notation's
  syllable alignment is written against.
* **First sangati only**, as agreed. The source gives three sangatis for the
  pallavi and five for the anupallavi.
* **caraNam 1 has words but no melody** — the source gives its lyrics and no
  notation. Chosen by the user over inventing one.
* **One marker per lyric line**, naming the first sounding swara of that line.
  The previous per-phrase markers were derived from the discarded
  absolute-scale reading and were dropped with it.

## How the notation was decoded

The duration rules were **fitted numerically** rather than read by eye: try
candidate values for each symbol, count how many of the 66 avartas come out as
misra chapu's 3 + 2 + 2.

```
rule                                       avartas at exactly 3+2+2
every symbol = 1 beat                             34 / 66
';' = 1 beat, ',' = karvai sharing a beat         37 / 66
';' = 1.0, ',' = 0.5, lowercase = 0.5             57 / 66
  + underline = one speed faster again            66 / 66
```

Final rule set:

| Symbol | Duration |
|---|---|
| uppercase note | 1.0 matra (first speed) |
| lowercase note | 0.5 matra (second speed) |
| underlined token (`dpP`, `mdpp`) | half again (third speed) |
| `;` | 1.0 matra |
| `,` | 0.5 matra |

Two of these differ from the user's summary table, which gave `;` = 2 matras and
`,` = 1. Those values fit almost no avartas; the user's own **worked examples**
used `;` = 1, and the data backs the examples.

The underline was the last piece. The nine remaining misfits were exactly the
tokens shown underlined in the supplied screenshots.

## Madhyamam selection

Yamunakalyani is a bhashanga raga: shuddha madhyamam (Ma1) is the anya svara and
belongs only to the descending `Ga3 → Ma1 → Ri2` vishesha prayoga. Everywhere
else the madhyamam is prati (Ma2). The user confirmed this rule.

The transcriber applies it mechanically — 6 occurrences become Ma1, the rest
Ma2 — and a test guards it so a careless edit cannot spread Ma1 through the song.

**This corrected an earlier mistake of mine.** I had concluded from the
avarohana that lowercase `m` was Ma1 and uppercase `M` was Ma2. The duration fit
disproved it: case marks speed, and if `m`/`M` were variants the 66/66 fit would
not hold.

## Tests

`test/repositories/song_repository_test.dart`:

* full-words test repointed at the new romanisation and `caraNam 4:`.
* new: every lyric line with a melody carries four avartas (32 melody lines).
* restored: every melody line is readable and fills one misra chapu cycle.
* new: Ma1 appears only beside Ga3, never in a Pa/Da2 neighbourhood.

`test/helpers/fake_song_repository.dart` — the fake song's line and melody
updated to the transcribed form.

## `docs/features.md`

Records that the sample song carries a real transcription in madhyama sruti,
four avartas per line, first sangati only. Also corrects the earlier "gaps"
note: `;` maps onto our `,` with no parser change, and the lowercase/komal
clash never fires because Classical songs here always use two-letter names.

## Known limits, carried deliberately

* **5 notes of 397 (1.3%) straddle a beat boundary** and were snapped to the
  beat. Our format treats a beat as atomic — notes can share a beat, but one
  cannot start halfway through and run into the next. Affects P1a.2, C3c.2
  (twice) and C4d.2.
* **Octaves are not marked in the source.** The user stated that lower octave
  takes a dot and the notation carries none, so everything was transcribed in
  the middle octave. Musically this is worth a second look: in an ascending run
  like `nsrgmp`, the leading `n` sits below `Sa` and would normally be mandra
  `.Ni3`. Left literal rather than guessed. **Raised with the user.**
* **Four stacked melody grids under one lyric line has not been seen on a
  phone.** The parser is happy; the layout is unverified.
* **No sruti representation.** The app cannot record that a song is in madhyama
  sruti, so the drone must be set by the player. Still open.

## Checks

* `flutter analyze` — clean, no issues.
* `flutter test` — all **703** tests pass.
* All 32 melody lines verified against `MelodyParser`: zero problems, every one
  exactly 7 beats.
* `dart format` — applied.
* Reproducible: `scratchpad/beats.py`, `beats2.py`, `beats3.py`, `convert.py`,
  `build_song.py` over `scratchpad/notation.txt`.
