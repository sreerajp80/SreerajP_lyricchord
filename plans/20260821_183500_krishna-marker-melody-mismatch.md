# Krishna Nee Begane Baaro — swara markers do not match the melody line

**Status:** completed

Date: 2026-08-21
Revised: 2026-08-21 — added the full-name melody spelling, then the `Da2`
spelling, both asked for by the user. Then the pallavi G3 marker was moved onto
"nee" after a Carnatic-musicology review the user supplied.

---

## The issue

Three things, all about how the swaras are written in one song.

### 1. The markers disagree with the melody

The user spotted it on screen: the pallavi shows `Sa  Ma  Sa` above the words,
but the melody player row below shows `P , M2 G3 R2 S ,`. Two rows for the same
line, saying two different things.

Cause: in the 2026-08-21 change
([plans/20260821_172211_krishna-full-lyrics-and-melody.md](20260821_172211_krishna-full-lyrics-and-melody.md))
the words were rewritten and `{melody}` lines were added, but the inline
`[Sa] [Ma] [Sa]` markers were copied over unchanged from the old stub text
(`_krishnaNeeLyricsV9`). The markers were never checked against the new melody.

This affects **all ten lyric lines**, not just the pallavi.

Which row is right? The melody row. In Yamunakalyani this pallavi starts on Pa,
not Sa. The old `[Sa]` markers were part of the placeholder text and were never
musically checked.

### 2. The melody lines use short letters, the rest of the song uses full names

The markers say `Ga3`, the swaram block says `Ga3`, but the melody line says
`G3`. Same note, two spellings, in one song. The user wants the full name with
the digit everywhere: `Sa Ri2 Ga3 Ma2 Pa Da2 Ni3`.

### 3. The app does not know the spelling `Da`

The user wants the sixth swara written `Da2`, not `Dha2`. Today `SwaraNotation`
knows `Dha`, `Dh` and `D`, but **not** `Da`. So `Da2` reads as nothing: the
melody player would report "Could not read Da2" and draw the beat as unknown,
and a swaram line containing `Da2` would stop being recognised as a swaram line.

So unlike the earlier draft of this plan, this one **does** need a small code
change.

## The fix

### Fix 1 — teach the app the `Da` spelling (code)

Three one-line additions in
[lib/services/swara_notation_service.dart](../lib/services/swara_notation_service.dart):

| Place | Add | Why |
|---|---|---|
| `_swaraAliases` (line 38) | `Da` | so `isSwaraToken('Da2')` is true and swaram lines still parse |
| `_letterByName` (line 182) | `da` maps to `D` | so `Da2` folds to `D2` and means the same as `Dha2` |
| `_shuddhaByName` (line 207) | `da` maps to `9` | so a bare `Da` places at the right pitch |

`Da` clashes with nothing — Dha is the only swara starting with `d`. Both old
spellings keep working, so any song a user has already written with `Dha2` or
`D2` is unaffected.

### Fix 2 — correct the markers

Keep each line's three marker positions exactly where they are — they mark the
three Misra Chapu beat groups (3 + 2 + 2) — and change each marker to the note
the melody plays at the start of that group.

| Line | Beat groups | New markers |
|---|---|---|
| Pallavi 1 | `Pa , Ma2 / Ga3 Ri2 / Sa ,` | Pa, Ga3, Sa — see the note below on where Ga3 sits |
| Pallavi 2 | `Ga3 Ma2 Pa / Da2 Pa / Ma2 Ga3` | Ga3, Da2, Ga3 |
| Charanam 1.1 | `Pa , Da2 / Ni3 Da2 / Pa ,` | Pa, Ni3, Pa |
| Charanam 1.2 | `Sa' , Ni3 / Da2 Pa / Ma2 Ga3` | Sa', Da2, Ga3 |
| Charanam 2.1 | `Ga3 , Ma2 / Pa Da2 / Pa ,` | Ga3, Pa, Pa |
| Charanam 2.2 | `Ma2 Ga3 Ri2 / Sa .Ni3 / Sa ,` | Ma2, Sa, Sa |
| Charanam 3.1 | `Pa , Ma2 / Ga3 Ma1 / Ga3 Ri2` | Pa, Ga3, Ga3 |
| Charanam 3.2 | `Sa , Ri2 / Ga3 Ri2 / Sa ,` | Sa, Ga3, Sa |
| Charanam 4.1 | `Pa Da2 Ni3 / Sa' , / Ni3 Da2` | Pa, Sa', Ni3 |
| Charanam 4.2 | `Pa Ma2 Ga3 / Ri2 Sa / , ,` | Pa, Ri2, Sa |

(The `/` above stands for the bar line `|`, which a table cell cannot hold.)

### Fix 3 — full names in the melody lines, with `Da2`

Rewrite every `{melody}` line from short letters to full names. Same notes, same
beats, same bar lines — only the spelling changes.

Was, then becomes:

```
P , M2 | G3 R2 | S ,          ->  Pa , Ma2 | Ga3 Ri2 | Sa ,
G3 M2 P | D2 P | M2 G3        ->  Ga3 Ma2 Pa | Da2 Pa | Ma2 Ga3
P , D2 | N3 D2 | P ,          ->  Pa , Da2 | Ni3 Da2 | Pa ,
S' , N3 | D2 P | M2 G3        ->  Sa' , Ni3 | Da2 Pa | Ma2 Ga3
G3 , M2 | P D2 | P ,          ->  Ga3 , Ma2 | Pa Da2 | Pa ,
M2 G3 R2 | S .N3 | S ,        ->  Ma2 Ga3 Ri2 | Sa .Ni3 | Sa ,
P , M2 | G3 Ma | G3 R2        ->  Pa , Ma2 | Ga3 Ma1 | Ga3 Ri2
S , R2 | G3 R2 | S ,          ->  Sa , Ri2 | Ga3 Ri2 | Sa ,
P D2 N3 | S' , | N3 D2        ->  Pa Da2 Ni3 | Sa' , | Ni3 Da2
P M2 G3 | R2 S | , ,          ->  Pa Ma2 Ga3 | Ri2 Sa | , ,
```

The bare `Ma` in charanam 3.1 becomes `Ma1` — spelling out that it is the plain
(shuddha) Ma, not the tivra `Ma2` the rest of the raga uses.

### Fix 4 — the swaram block at the bottom

It currently says `Dha2`. Change both lines to `Da2` so the whole song agrees:

```
Sa - Ri2 - Ga3 - Ma2 - Pa - Da2 - Ni3 - Sa -
Sa - Ni3 - Da2 - Pa - Ma2 - Ga3 - Ri2 - Sa -
```

### All of it together — pallavi as an example

```
[Pa]Krishna [Ga3]nee be[Sa]gane baaro
{melody} Pa , Ma2 | Ga3 Ri2 | Sa ,
[Ga3]Begane baaro mukha[Da2]vannu tho[Ga3]ro
{melody} Ga3 Ma2 Pa | Da2 Pa | Ma2 Ga3
```

Every row now uses the same spelling: markers, melody, and the swaram block.

### Where the pallavi markers sit — checked by a musicologist

The user supplied a detailed Carnatic analysis of the pallavi. Its findings:

* Yamunakalyani is a janya of the 65th melakarta Mechakalyani. The notes used
  are S, R2 (chatushruti rishabham), G3 (antara gandharam), M2 (prati
  madhyamam), P. `P - M2 - G3 - R2 - S` is a **characteristic descending phrase**
  of the raga, so the melody line follows the raga's rules.
* The beat split `Pa , Ma2 | Ga3 Ri2 | Sa ,` is 3 + 2 + 2 = 7 and matches Misra
  Chapu exactly.
* **The one correction:** the words sit on the notes as
  `P , M2` = "Kri - shna", `G3` = "nee", `R2` = "be", `S ,` = "gane baaro".
  So Ga3 belongs on **"nee"**, not on "gane". The first draft of this plan wrote
  `be[Ga3]gane`, one word too late.

Verdict of that analysis: the melody notes, the swarasthanas and the 7 beats are
fully correct; only the Ga3 marker position needed moving. Pallavi line 1 is
therefore `[Pa]Krishna [Ga3]nee be[Sa]gane baaro`, which also happens to put
every marker on a word boundary.

**Scope of that check:** it covered pallavi line 1 only. The other nine lines are
still the approximate singable outline described in the earlier plan, and have
not been checked by anyone.

## Already checked

* `MelodyParser._readSwara`
  ([lib/services/melody_parser_service.dart:195](../lib/services/melody_parser_service.dart#L195))
  strips the octave marks first, then calls `SwaraNotation.swaraPosition`, which
  folds a full name with a digit down to its letter (`_foldFullName`). So once
  Fix 1 is in, `Ma2`, `Ga3`, `Da2`, `Sa'` and `.Ni3` all read correctly.
* `Ma1` folds to `M1`, which is already in `_carnaticPositions`. Valid today.
* `isSwaraToken` strips digits before matching, so the alias only has to be
  `Da`, not `Da2`.
* Inline `[...]` markers are carried as plain text, so `[Sa']` displays as
  written. The only place it is interpreted is `_sortedByPitch`
  ([lib/screens/song_performance_screen.dart:1106](../lib/screens/song_performance_screen.dart#L1106)),
  which reads it as Sa — the right swara, ignoring the octave. Fine for a sorted
  list of the swaras used.

## Files to change

| File | Change |
|---|---|
| `lib/services/swara_notation_service.dart` | Add the `Da` spelling in three maps/lists. |
| `lib/data/app_database.dart` | Rewrite `_krishnaNeeLyrics` (lines 686-722): ten marker sets, ten melody lines, two swaram lines. |
| `test/services/swara_notation_service_test.dart` | Add tests: `Da2` places the same as `Dha2` and `D2`; `Da` is a swara token; `Dha2` still works. |
| `test/services/melody_parser_service_test.dart` | Add a test that a full-name line parses with no problems and matches the short-letter line. |
| `test/repositories/song_repository_test.dart` | Update the v10 upgrade test if it asserts on any marker or melody text. |
| `change_log/…md` | Written after the change. |

## No schema bump needed

Schema version 10 and `_krishnaNeeLyrics` are **not committed yet** — they are in
the working tree only, from today's change. Nothing has shipped with the wrong
text, so this is a straight edit to the version 10 seed. No new version, no new
migration step.

Version 9 phones still upgrade correctly: `_rewriteKrishnaSample()` compares
against `_krishnaNeeLyricsV9`, which is not touched here.

## Risks

* **New alias, small false-positive risk.** `isSwaramLine` calls a line a swaram
  line when *every* token is a swara. After adding `Da`, a lyric line made only
  of the word "da" would be treated as a swaram line. This risk already exists
  for `Ma`, `Pa`, `Ni` and `Re`, so it is not new in kind, and such words are
  rare as whole lines. Judged acceptable.
* **Beat width.** `Da2` is three characters where `D2` was two, and `Ga3` is
  three where `G3` was two, so the beat boxes in the melody player get wider. If
  a line overflows on a phone, that is a layout fix in the melody row widget, and
  it will be reported rather than fixed silently under this plan.
* Otherwise low — the rest is constant song text.

## Checks after the change

* `flutter analyze` — clean.
* `flutter test` — all green.
* Open the sample song and confirm:
  * the marker above each line agrees with the first note of each melody beat
    group,
  * the melody player still plays every line (no "could not read" problems),
  * the wider beat boxes do not overflow.
