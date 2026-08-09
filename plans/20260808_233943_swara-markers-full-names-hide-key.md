# Plan: Fix swara markers, use full swara names, hide the key for raga songs

**Status:** completed

## The issue

Three separate problems, all in the same area. They are in one plan because
fixing any one of them alone leaves the song half-right.

### 1. The markers above the words disagree with the Swaram block

In `_raghupatiLyrics` (`lib/data/app_database.dart`) the Swaram block is the
melody, written a note per beat:

```
Sa - Sa - Pa - Pa - | Ma - Ma - Sa - Sa -
Sa - Sa - Pa - Pa - | Ni - Ni - Sa - Sa -
```

Read against the words, one Keherwa cycle per line, that is:

| Line | word 1 | word 2 | word 3 | word 4 |
|------|--------|--------|--------|--------|
| 1 | Raghupati **Sa** | Raghava **Pa** | Raja **Ma** | Ram **Sa** |
| 2 | Patita **Sa** | Pavana **Pa** | Sita **Ni** | Ram **Sa** |

The markers stored on the lyric lines do not match:

| Line | Stored today | Wrong how |
|------|--------------|-----------|
| 1 | `[S]Raghupati Raghava [M]Raja [S]Ram,` | no marker on *Raghava* (missing Pa) |
| 2 | `[S]Patita Pavana [P]Sita [S]Ram.` | `[P]` sits on *Sita*; it belongs on *Pavana*, and *Sita* is Ni |
| 3 | `[S]Sita Ram [M]Sita [S]Ram,` | no marker on the second *Ram* (missing Pa) |
| 4 | `[S]Bhaja Pyare [P]Tukaram / [S]Sita Ram.` | `[P]` sits on *Tukaram*; it belongs on *Pyare*, and *Tukaram* is Ni |

Lines 3 and 4 repeat the tune of lines 1 and 2, so they take the same fix.
Line 2 is the worst: it tells the singer to sing Pa where the melody says Ni.

### 2. Single letters are hard to read

The markers use one letter (`[S]`, `[M]`, `[P]`), but the Swaram block uses
full names (`Sa`, `Ma`, `Pa`). Two spellings for the same thing on one screen.
Full names are clearer, and they match the Swaram block.

### 3. A raga song still shows a Western key

`performance_controls.dart` prints `Sa = D` and `stage_hud.dart` prints
`Key D`. `D` is a Western note letter. The project rule is that Indian and
Western notation stay apart (see
`change_log/20260808_154500_keep_indian_and_western_notation_separate.md`), so
a raga song should not show a Western letter at all.

**Decision (user's choice):** hide it. A raga song's status line reads
`Auto-scroll · Raga Mishra Gara · Tala Keherwa · 84 BPM` and nothing else.
The trade-off is accepted: the singer no longer gets a starting pitch from
this screen.

### 4. A hidden consequence — the transposer corrupts some swaras

`ChordTransposer._transposeToken()` only checks the **first letter** against
`A`–`G`. So a marker whose swara starts with G or D is treated as a chord:

| Marker | Today, +2 semitones | Should be |
|--------|---------------------|-----------|
| `[G]` (Ga) | `[A]` — corrupted | unchanged |
| `[D]` (Dha) | `[E]` — corrupted | unchanged |
| `[Ga]` (after fix 2) | `[Aa]` — nonsense | unchanged |
| `[Dha]` (after fix 2) | `[Eha]` — nonsense | unchanged |

`[S]`, `[Ma]`, `[Pa]`, `[Ni]`, `[Ri]` are safe, because S, M, P, N and R are
not Western note letters. This bug is live today — `_vathapiLyrics` contains
`[G]Charanam`, which is Ga. The doc comment on `transposeLyrics()` claims
swaras are always left alone; that claim is simply wrong.

Moving to full names does not create this bug, but it does widen it, so it
must be fixed in the same change.

---

## Files to change

### Source

| File | Change |
|------|--------|
| `lib/data/app_database.dart` | Fix the four Raghupati lines; rewrite all three classical songs' markers in full swara names; bump `schemaVersion` to **8**; extend the rewrite migration to run for `from < 8` |
| `lib/services/chord_transposer.dart` | `transposeLyrics()` and `chordsUsed()` return markers untouched when the sheet is Indian notation; correct the wrong doc comment |
| `lib/widgets/performance_controls.dart` | Drop the key from the status line when the song names a raga |
| `lib/widgets/stage_hud.dart` | Same, in stage mode — needs a `raga` (and `tala`) parameter, which it does not have today |
| `lib/screens/song_performance_screen.dart` | Pass `raga`/`tala` down to `StageHud`; hide the transpose action for a raga song |
| `lib/services/pdf_export_service.dart` | Drop the `Sa: D` header row for an Indian song (keep `Key:` for Western) |

### Tests

| File | Change |
|------|--------|
| `test/repositories/song_repository_test.dart` | Update the expected Raghupati text; add a v8 migration test |
| `test/helpers/fake_song_repository.dart` | Update the seeded fixture text |
| `test/screens/song_list_screen_test.dart` | Update any assertion on the old marker text |
| `test/services/chord_transposer_test.dart` | New: `[Ga]` and `[Dha]` in a raga sheet survive a transpose; a Western `[G]`/`[D]` still transposes normally |
| `test/services/pdf_export_service_test.dart` | Indian export has no key row; Western still has `Key:` |
| `test/widgets/performance_controls_test.dart` | Raga song shows no key; Western song still shows `Key G` |
| `test/services/swara_notation_service_test.dart` | Confirm `isSwaraToken` accepts every full name used in the seeds |

---

## The fix, in detail

### Step 1 — Raghupati, corrected and in full names

```
{raga: Mishra Gara}
{tala: Keherwa}

[Sa]Raghupati [Pa]Raghava [Ma]Raja [Sa]Ram,
[Sa]Patita [Pa]Pavana [Ni]Sita [Sa]Ram.

[Sa]Sita [Pa]Ram [Ma]Sita [Sa]Ram,
[Sa]Bhaja [Pa]Pyare [Ni]Tukaram / [Sa]Sita Ram.

Swaram:
Sa - Sa - Pa - Pa - | Ma - Ma - Sa - Sa -
Sa - Sa - Pa - Pa - | Ni - Ni - Sa - Sa -
```

Every marker now matches the Swaram block above it.

### Step 2 — the other two songs, full names only

No melody change, only the spelling of the markers:

- Vathapi: `[S]`→`[Sa]`, `[G]`→`[Ga]`, `[P]`→`[Pa]`, `[N]`→`[Ni]`
- Krishna Nee: `[S]`→`[Sa]`, `[M]`→`[Ma]`, `[P]`→`[Pa]`

### Step 3 — migration to v8

Follow the pattern already in the file. `_rewriteClassicalSongsInSwaraNotation()`
already replaces a seeded song's text by matching its **title**, so a song the
user renamed or wrote themselves is never touched. Change the guard from
`if (from < 7)` to `if (from < 8)` and bump `schemaVersion` to 8. Nothing else
about the migration needs to change — it reads the same shared
`_classicalSeedSongs()` list, so correcting the constants corrects every path
(first run, seed-missing, and upgrade) at once.

### Step 4 — transposer leaves an Indian sheet alone

In `transposeLyrics()` and `chordsUsed()`, parse the sheet first and return
early when it is Indian:

```dart
if (_parser.parseSheet(lyrics).isIndianNotation) return lyrics;
```

`ParsedSheet.isIndianNotation` already exists (`chord_sheet_parser.dart:113`),
so no new detection logic is needed.

This is the right rule musically, not just a workaround: a swara is already
named relative to Sa. Move Sa and every swara moves with it, so the written
notation does not change. There is nothing for a transpose to do.

Per-marker swara detection was considered and rejected: a lone `[D]` in a
Western song is a real D chord, and no amount of looking at that one token can
tell the two apart. The song has to decide, not the token.

### Step 5 — hide the key

`performance_controls.dart`, `_statusLine()`:

```dart
// An Indian song is written relative to Sa, so a Western key letter would be
// out of place. Raga and tala below already say what the song is.
final base = isIndian
    ? 'Auto-scroll  ·  $bpm BPM'
    : 'Auto-scroll  ·  $keyHint  ·  $bpm BPM';
```

The `Raga … · Tala …` line underneath is unchanged, so the screen reads:

```
Auto-scroll  ·  84 BPM
Raga Mishra Gara  ·  Tala Keherwa
```

`stage_hud.dart` gets `raga`/`tala` parameters and does the same for its
one-line header. `pdf_export_service.dart` drops the key row for an Indian
song. The transpose action on the performance screen is hidden for a raga
song, since after step 4 it would do nothing.

---

## Deliberately out of scope

- **Key chips in the song list, setlist and editor** (`song_card.dart`,
  `setlist_detail_screen.dart`, `import_preview_screen.dart`,
  `song_editor_screen.dart`). These show `Key: D` for every song. Hiding it
  there means parsing each song's lyrics in a list row, which is a bigger
  change and a performance question. Say so if you want it and it becomes its
  own plan.
- **The `key` column itself.** It stays `'D'` in the database. Only the
  display changes. This keeps the change reversible — if hiding the pitch turns
  out to be a mistake in practice, showing it again is a one-line edit rather
  than another migration.
- **Adding a Swaram block for lines 3 and 4.** They repeat the tune of lines 1
  and 2, which is how these sheets are normally written.

## Risk

The one real risk is the widened markers. `Dha` is three characters where `D`
was one, so two markers sitting close together could overlap in
`chord_sheet_view.dart`. None of the three seeded songs place markers that
close, but this must be checked by eye on the song page after the change, not
only by running the tests.

## Verification

- `flutter analyze` — must be clean.
- `flutter test` — all tests pass.
- `dart format lib test`.
- By eye on the song page: markers line up over the right words, no overlap,
  no key in the status line, raga and tala still shown.
- Upgrade check: open an install already on v7 and confirm the three songs are
  rewritten.
