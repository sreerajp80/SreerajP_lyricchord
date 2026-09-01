# Krishna Nee Begane Baaro — adopt the authentic madhyama sruti notation

**Status:** completed

Date: 2026-08-21

---

## The issue

The song text shipped earlier today
([change_log/20260821_190500](../change_log/20260821_190500_krishna-marker-melody-mismatch.md))
uses melody lines like `Pa , Ma2 | Ga3 Ri2 | Sa ,`. The user has established
that this is a **simplified absolute-scale reading**, not the form Carnatic
tradition uses.

Yamunakalyani is a **madhyama sruti** raga. The tambura's Pa string is dropped
to shuddha madhyamam (M1), and that M1 is taken as the base Sa. So the krithi is
notated **starting on S**, not on P. The authoritative notation
([shivkumar.org](https://www.shivkumar.org/music/krishnaneebegane.htm)) opens:

```
ta ki ta  |  ta ka  |  ta ka
;  ;  S   |  G , m  |  R ;
Kri -     |  shna nee | bE -
```

Our current form is what you would play reading one line on a keyboard without
changing the sruti. It is not wrong to the ear in isolation, which is why an
earlier check passed it, but it is not the form taught in the gurukula
sampradaya or sung in kacheri.

Sources the user cites: *Sangita Sampradaya Pradarsini* (Subbarama Dikshitar),
*South Indian Music Book IV* (P. Sambamoorthy), and the shivkumar.org archive.

## Three problems this creates in the app

These are the reason this is a plan and not a quick edit.

### 1. One melody line per lyric line no longer fits

Our format assumes **one 7-beat melody line under each lyric line**. The
authentic pallavi spreads "Krishna nee begane baaro" over **three avartas** of
misra chapu — 21 beats:

```
;  ;  S      |  G , m  |  R ;        Kri- / shna nee / bE-
s n r s n d  |  ;  N   |  , R ,      (gamaka) / ga / nE
;  ;  g m    |  R ;    |  S ;        baa / rO / -
```

So one lyric line needs three `{melody}` lines, not one. The parser handles each
`{melody}` line on its own, so **stacking three is already possible** with no
code change. But:

* `test/repositories/song_repository_test.dart` asserts
  `melodyLines == lyricLines`. That assertion becomes wrong and must change.
* The melody row widget draws one grid per melody line. Three stacked grids
  under one lyric line has never been looked at on screen. It may well be fine;
  it has to be checked.

### 2. The lowercase letters would be read wrong — this one is a real bug

shivkumar.org writes fast gamaka notes in lowercase: `s n r s n d`. In that
convention lowercase marks the **lower octave (mandra sthayi)**.

Our parser reads lowercase as **komal** — see
[swara_notation_service.dart](../lib/services/swara_notation_service.dart),
"A single letter: case carries komal/shuddha". So:

| Written | We read it as | Yamunakalyani wants | Result |
|---|---|---|---|
| `n` | N2 (10) | N3 (11) | **wrong** |
| `d` | D1 (8) | D2 (9) | **wrong** |
| `r` | R1 (1) | R2 (2) | **wrong** |
| `m` | M1 (5) | M1 (5) | right, by luck |
| `s` | S (0) | S (0) | right |

Three of the five would sound the wrong note. So the source notation **cannot be
pasted in as-is**. Either it is rewritten in our own spelling with explicit
octave dots (`.Ni3`, `.Da2`, `.Ri2`), or the parser learns a second convention —
and teaching it that lowercase means lower octave would contradict the
Hindustani komal rule it already implements for other songs. **Rewriting the
notation is the safe path; changing the parser is not.**

### 3. The tonic and the drone

The melody player hums over the drone using `{tonic:}`. If the song is notated
in madhyama sruti, its Sa is not the same pitch as a panchama-sruti song's Sa.
The page states *Sruti: Madhyamam*. The song text should say so, or the played
melody will sit at the wrong absolute pitch against the drone.

Needs deciding: add a `{sruti: madhyama}` header, or set `{tonic:}` to the
madhyama pitch, or leave it and document that the user sets their own drone.

## What I cannot do, and what I need from you

**I could not read the notation off the page.** The fetch tool declines to
reproduce it (copyright), and two attempts returned answers that contradicted
each other — one said M1 appears in the avarohana, the other said it never
appears. Its reading of the pallavi swaras came back garbled. I will not
transcribe a classical notation from a source I could not read reliably.

**So this plan is blocked on the notation itself.** Please paste the notation
text for the sections you want, or confirm the blocks you already gave are
complete and correct, and I will transcribe exactly those.

What you have already given, and what I would use as-is:

```
Pallavi, line 1 — "Krishna nee begane baaro"
;  ;  S      |  G , m  |  R ;
s n r s n d  |  ;  N   |  , R ,
;  ;  g m    |  R ;    |  S ;
```

Still needed: the Anupallavi ("Begane baaro mukhavannu thoro") and Charanams
1-4.

## Files to change

| File | Change |
|---|---|
| `lib/data/app_database.dart` | Rewrite `_krishnaNeeLyrics` in the madhyama sruti notation; split the Anupallavi out of the Pallavi; stack the melody lines per avarta. No schema bump (see below). |
| `test/repositories/song_repository_test.dart` | Drop the `melodyLines == lyricLines` assertion; keep the 7-beats-per-melody-line check, which still holds per avarta. Update the pinned marker text. |
| `test/helpers/fake_song_repository.dart` | Update the fake song's line to the new notation. |
| `docs/features.md` | Note that the sample song is in madhyama sruti and carries one melody line per avarta. |
| `change_log/…md` | Written after the change. |

## Also in scope: the Anupallavi

shivkumar.org treats "Begane baaro mukhavannu thoro" as a separate
**Anupallavi**, not the pallavi's second line. Our text has it under `Pallavi:`.
This plan relabels it. This was flagged as open in the last change log.

## No schema bump needed

Schema version 10 is still uncommitted working-tree work, so nothing has shipped
with the current text. This edits the version 10 seed. Version 9 devices still
upgrade correctly — `_rewriteKrishnaSample()` matches on `_krishnaNeeLyricsV9`,
which is not touched.

## Risks

* **The melody becomes a real transcription, not my outline.** That is the point
  of the change, and it is better. But it means the text must match the source
  exactly, so it must come from you rather than from me.
* **Three stacked melody grids per lyric line is an untested layout.** Must be
  looked at on a phone.
* **Octave dots get heavy.** Written in our spelling the gamaka run becomes
  something like `Sa .Ni3 .Ri2 Sa .Ni3 .Da2`, which is wide. The beat grid
  scrolls sideways, so it should cope, but it needs checking.

## Checks after the change

* `flutter analyze` — clean.
* `flutter test` — all green.
* On a phone: every melody line plays, the stacked grids read clearly, and the
  drone sits right against the notated Sa.
