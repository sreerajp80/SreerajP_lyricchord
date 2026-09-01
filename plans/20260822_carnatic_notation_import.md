# Make the app comply with docs/carnatic_notation.md

**Status:** completed

Date: 2026-08-22

---

## The issue

[docs/carnatic_notation.md](../docs/carnatic_notation.md) describes how published
Carnatic notation works and how it maps onto our `{melody}` format. **The app
implements almost none of it.**

The seeded *Krishna Nee Begane Baaro* has a correct melody only because it was
converted **by hand, outside the product**, using throwaway Python scripts in a
session scratch folder. Those scripts are not in the repository and the folder is
temporary. Nothing in `lib/` knows how to do the conversion.

Verified against the real parser today:

```
OK    our converted form      , , Sa | Ga3 Ma1 | Ri2 ,
OK    beat sharing, octave dots, gamaka marks
FAIL  source semicolon        ; ; Sa | Ga3 , Ma1 | Ri2 ;
FAIL  source anya svara       Ga3*
FAIL  raw paste from a page   ; ; S | G , m | R ;
```

So a musician who copies notation from a published page and pastes it in gets an
error. The app contains **one converted song, not the ability to convert.**

## What "comply" means, in order of value

| # | Gap | Doc section |
|---|---|---|
| 1 | Cannot read published notation at all | §4, §4a, §7 |
| 2 | No way to say a song is in madhyama sruti | §5 |
| 3 | No sangati support | §6 |
| 4 | A beat is atomic — notes cannot straddle | §8 |
| 5 | `!` and `~` parsed but not sounded | §8 |

This plan covers **1 and 2**. Items 3–5 are separate features and stay in §8 of
the document as known limits.

## The fix — phase 1: a notation import service

**New file:** `lib/services/carnatic_notation_import_service.dart`
**Layer:** service. It knows notation, not UI and not storage — it takes text and
returns text, matching the rules already stated in the document.

### What it does

Input: a block of published notation plus the tala.
Output: `{melody}` lines in our format, plus a list of problems.

Applying the documented rules (§4):

| Source | Duration | Becomes |
|---|---|---|
| uppercase note `S` | 2 aksharakalas | `Sa` — one beat |
| lowercase note `s` | 1 aksharakala | half a beat; pairs join with `-` |
| `;` | 2 aksharakalas | `,` |
| `,` | 1 aksharakala | extends the note before it |
| underlined group | packed, faster | one beat, hyphen-joined |
| letters written together `snrs` | share the beat | `Sa-Ni3 Ri2-Sa` |
| `\|` | end of an anga | `\|` |
| `\|\|` | end of an avarta | ends the `{melody}` line |
| `-` | pause/split marker | dropped, carries no duration |
| `*` | anya svara | dropped from the note, recorded as a hint |
| dot below / above | octave | `.Ni3` / `Sa'` |

### The case question — asked, not guessed

§4a is explicit that letter case means **duration** on some pages and **octave**
on others, and that only the page's own legend or the tala arithmetic can tell
them apart. The service therefore:

1. Converts under **both** readings.
2. Counts, for each, how many avartas land exactly on the tala.
3. Returns the better one, **with the score**, so the caller can say
   "read as duration — 66 of 66 cycles fit" or flag an ambiguous result.

This is the §4a procedure turned into code, and it is the part that makes the
feature trustworthy rather than a guess.

### Not in scope for the service

Choosing between Ma1 and Ma2. That is raga grammar (§5), varies per raga, and the
notation does not mark it. The service emits `Ma` positions using the raga's
default madhyamam and reports where a `G → M → R` descent was seen, so the user
can decide. **It will not silently apply a raga rule.**

## Phase 1b: let the parser accept `;`

`MelodyParser` should treat `;` as a synonym for `,`. In the source convention
`;` is two aksharakalas, which is exactly one beat — the same as our `,`. This is
a two-line change and it stops a pasted line from hard-failing.

Also accept and ignore a trailing `*` on a note, so an anya-svara mark does not
make the note unreadable.

## Phase 2: `{sruti: madhyama}`

A header directive recording that a song is sung in madhyama sruti, so the drone
and the melody player agree on where Sa sits. Without it the played melody can
sit at the wrong absolute pitch against the drone — the exact bug that made the
first transcription of the sample song wrong.

## Files to change

| File | Change |
|---|---|
| `lib/services/carnatic_notation_import_service.dart` | **New.** The converter described above. |
| `lib/services/melody_parser_service.dart` | Accept `;` as a synonym for `,`; ignore a trailing `*`. |
| `lib/models/…` | A small result type: converted lines, the chosen reading, the fit score, problems. |
| `test/services/carnatic_notation_import_service_test.dart` | **New.** See below. |
| `test/services/melody_parser_service_test.dart` | Cover `;` and `*`. |
| `docs/features.md` | Record the import feature. |
| `docs/carnatic_notation.md` | Update §8 — items 1 and 2 stop being limits. |

## Tests

The strongest test available is one already have the answer to: **the sample
song.** Feed the service the published notation for *Krishna Nee Begane Baaro*
and assert it produces the 32 melody lines now in `app_database.dart`, character
for character. That is a real end-to-end check against a known-good result, and
it locks the hand conversion into the product.

Plus: each symbol in isolation; the case-detection scoring on both a
duration-convention and an octave-convention sample; malformed input never
throwing (hard rule 4).

## What is NOT decided, and needs your answer

**Where does the user reach this?** Options:

1. A button in the **song editor** — "Paste Carnatic notation", opens a sheet,
   converts, inserts the `{melody}` lines. Most direct.
2. Part of the **import screen**, alongside ChordPro import.
3. Service only for now, no UI, used to regenerate seeded songs.

I would pick **1**, because the feature's value is exactly at the moment someone
is typing a song in. But it is a UI decision and it is yours.

## Risks

* **Scope.** The converter is the largest single piece of logic added to this
  app so far. It is well specified by the document, which lowers the risk, but it
  is not a small change.
* **The `-` collision.** `-` means "pause/split" in the source and "share a
  beat" in our format. The converter must not pass it through. Called out here
  because a straight paste would silently misread it — which is the main argument
  for a converter over a more permissive parser.
* **Ambiguous pages.** Where both readings score equally, the service must say
  so rather than pick. Covered by returning the score.

## Checks after the change

* `flutter analyze` clean, `flutter test` green.
* The round-trip test: published notation in, the exact current 32 melody lines
  out.
* Paste a page of notation into the app by hand and confirm it converts.
