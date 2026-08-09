# Change Log: Correct swara markers, full swara names, no key on a raga song

**Plan Reference:** `plans/20260808_233943_swara-markers-full-names-hide-key.md`

## Why

Three things were wrong on an Indian song's page.

1. **The markers above the words did not match the song's own Swaram block.**
   On "Raghupati Raghava Raja Ram", line 2 told the singer to sing Pa on
   *Sita*, but the Swaram block says Ni. Two lines were also missing a marker.
2. **Two spellings on one screen.** Markers used one letter (`[S]`), the
   Swaram block used full names (`Sa`).
3. **A Western note letter was still showing.** The status line read
   `Sa = D`. The project rule is that Indian and Western notation stay apart.

A fourth problem came out while checking: the transposer was corrupting some
swaras. That one was already live.

## What changed

### The seeded classical songs (`lib/data/app_database.dart`)

"Raghupati Raghava Raja Ram" now reads:

```
[Sa]Raghupati [Pa]Raghava [Ma]Raja [Sa]Ram,
[Sa]Patita [Pa]Pavana [Ni]Sita [Sa]Ram.

[Sa]Sita [Pa]Ram [Ma]Sita [Sa]Ram,
[Sa]Bhaja [Pa]Pyare [Ni]Tukaram / [Sa]Sita Ram.
```

Every marker now agrees with the Swaram block below it. The two missing
markers are in, and the misplaced `[P]` moved from *Sita* to *Pavana* with
*Sita* corrected to `[Ni]`.

"Vathapi Ganapathim" and "Krishna Nee Begane Baro" changed spelling only —
`[S]`→`[Sa]`, `[G]`→`[Ga]`, `[P]`→`[Pa]`, `[N]`→`[Ni]`, `[M]`→`[Ma]`. Their
melodies are untouched.

Schema bumped to **v8**. The existing `_rewriteClassicalSongsInSwaraNotation()`
now runs for anyone below v8, so phones that already have these songs get the
corrected text. Nothing else in the migration needed to change — it reads the
same shared `_classicalSeedSongs()` list, so fixing the constants fixed first
run, seed-missing and upgrade all at once.

### The transposer no longer corrupts swaras (`lib/services/chord_transposer.dart`)

`_transposeToken()` reads only the **first letter** of a marker. So `[G]` (Ga)
and `[D]` (Dha) looked like Western chords and were transposed. `_vathapiLyrics`
contained `[G]sevitha`, so Vathapi's Ga was silently changed every time the
user transposed. Moving to full names would have widened it: `[Ga]` → `[Aa]`,
`[Dha]` → `[Eha]`.

`transposeLyrics()` and `chordsUsed()` now return an Indian sheet unchanged:

```dart
if (_parser.parseSheet(lyrics).isIndianNotation) return lyrics;
```

This is right musically, not just a patch. A swara is already named relative to
Sa — move Sa and every swara moves with it, so the written notation does not
change. There is nothing for a transpose to do.

Per-marker swara detection was rejected: a lone `[D]` in a Western song is a
real D chord, and nothing about that one token can tell the two apart. The song
decides, not the token.

The old doc comment claimed swaras were always left alone. That was wrong, and
it is corrected.

### No key on a raga song

- `lib/widgets/performance_controls.dart` — the status line drops the key
  entirely. It now reads `Auto-scroll · 84 BPM`, with
  `Raga Mishra Gara · Tala Keherwa` on the line below as before.
- `lib/widgets/stage_hud.dart` — new `raga`/`tala` parameters and a `_readOut`
  getter. Stage Mode shows `Title · Raga … · Tala … · 84 BPM` instead of
  `Title · Key D · 84 BPM`. It had no idea about ragas before.
- `lib/screens/song_performance_screen.dart` — passes `raga`/`tala` through to
  `StageHud`.
- `lib/services/pdf_export_service.dart` — an exported Indian sheet prints
  `BPM:` only. A Western one still prints `Key:`.

The `key` column still holds `'D'` in the database. Only the display changed,
so putting the pitch back is a one-line edit rather than another migration.

## One judgement call

**The plan said "hide the transpose action for a raga song".** Taken literally
that meant hiding the whole "Performance controls" menu item — but that sheet
also holds the **Show chords** switch, which a swara song still needs (to hide
the markers). So the menu item stays and only the transpose row inside the
sheet is hidden, via a new `showTranspose` flag on `showTransposeSheet()` and
`TransposeSheet`. This keeps the intent (no useless transpose buttons) without
taking away a control that still works.

## Verification

- `flutter analyze` — **No issues found.**
- `flutter test` — **394 tests, all passed.**
- `dart format lib test` — applied.

New and updated tests:

- `test/repositories/song_repository_test.dart` — the v8 migration writes full
  names, leaves no single-letter markers, and makes all four Raghupati lines
  match the Swaram block; a song of the user's own is untouched.
- `test/services/chord_transposer_test.dart` — `[Ga]`/`[Dha]` and `[G]`/`[D]`
  in a raga sheet survive a transpose; `chordsUsed` returns the swaras as
  written; a Western song with the same letters still transposes normally.
- `test/widgets/performance_controls_test.dart` — **new file.** A raga song
  shows no key but keeps its raga, tala and BPM; a Western song still shows
  `Key G`; an empty raga counts as Western.
- `test/widgets/stage_hud_test.dart` — a raga song shows raga and tala instead
  of a key, with or without a tala.
- `test/services/pdf_export_service_test.dart` — the old "reads as the tonic"
  test became "prints no key at all".
- `test/helpers/fake_song_repository.dart` — the three classical fixtures still
  held **Western chords** (`[E]Krishna nee be[A]gane baro`) despite a comment
  saying they matched the real database. Corrected to swaras.

## Still to check by hand

**Not done: looking at the song page in the running app.** `Dha` is three
characters where `D` was one, so two markers placed close together could
overlap in `chord_sheet_view.dart`. None of the three seeded songs place them
that close, and the tests pass, but the tests cannot see overlap. This needs
one look on a device.

## Noticed, not fixed

- **Chord Reference Guide on an Indian song.** It feeds the swaras (`Sa`, `Pa`)
  to the harmonium diagram, which can only draw Western chords. This was
  already the case before this change and is outside the approved plan.
- **Key chips in the song list, setlist, editor and import preview** still show
  `Key: D` for every song, including raga songs. Hiding them there means
  parsing each song's lyrics inside a list row — a bigger change, deliberately
  left out.
- **Seed-title matching is a substring.** A song the user renamed to
  "My Raghupati Notes" would still be overwritten by the migration. Recorded in
  a test comment rather than changed.
