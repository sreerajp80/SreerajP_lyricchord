# Plan — Phase 7: Import / export

**Status:** completed

**Date:** 2026-07-21

Implements Phase 7 of [../docs/implementation_plan.md](../docs/implementation_plan.md):
ChordPro import, ChordPro export, and PDF export.

---

## 1. What we are building

From the plan's Phase 7 and [../docs/lyriccord_idea.md](../docs/lyriccord_idea.md) §7:

- **ChordPro import** — pick a `.chordpro`/`.txt` file, read the directives
  (`{title|t}`, `{artist|a}`, `{key|k}`, `{bpm|tempo}`, `{comment|c}`, and
  chorus/verse markers), turn it into a new song, and save it.
- **ChordPro export** — write the current song back out as ChordPro text, applying
  the live transpose if one is active.
- **PDF export** — an A4 sheet with title/artist/key/BPM, guitar diagrams for the
  chords used, and the chorded lyrics; multi-page aware.

Hard rules that shape this work:
- **Never crash on bad input** (CLAUDE.md rule 4). The imported file is the one
  untrusted input. Parsing never throws; a bad file surfaces as a `SnackBar`.
- **Fully offline** (rule 1). We only use packages already in `pubspec.yaml`
  (`file_picker`, `pdf`, `printing`). No new dependency, no network.
- **Scoped storage only** (rule 5). Import uses the system file picker; export uses
  the share sheet / save dialog. No storage permission is requested.
- **Layer boundaries.** The parsing/formatting and PDF drawing live in pure
  services. The file picking, sharing, DB writes, navigation, and `SnackBar`s stay
  at the screen edge, where the app already does its IO.

---

## 2. Files to change

### New source files

1. **`lib/services/chord_pro_service.dart`** — `ChordProService` (pure).
   - `SongNote parse(String content)` — reads ChordPro text into a `SongNote`
     (id `0`, `timestamp` `0`; the caller stamps the real time on save). Never
     throws. An empty/garbled file still returns a usable song ("Untitled Song").
     - `{title|t: ...}` → `title` (falls back to `'Untitled Song'` if none).
     - `{artist|a: ...}` → `artist`.
     - `{key|k: ...}` → `key` (falls back to `'C'`).
     - `{bpm|tempo: ...}` → `bpm` (integer; keeps `120` if not a number).
     - `{comment|c: ...}` → kept as a plain lyric line (its text).
     - `{start_of_chorus|soc}`, `{end_of_chorus|eoc}`, `{start_of_verse|sov}`,
       `{end_of_verse|eov}` and any other `{directive}` → skipped, but blank-line
       spacing between sections is preserved.
     - Every non-directive line → a lyric line, kept verbatim (chords intact).
     - Leading/trailing blank lyric lines are trimmed so a round-trip is exact.
   - `String format(SongNote song, {int semitones = 0})` — writes
     `{title: ...}`, `{artist: ...}` (only when non-empty), `{key: ...}`,
     `{tempo: ...}`, a blank line, then the lyrics. When `semitones != 0` the
     lyrics and the `{key}` are transposed with the existing `ChordTransposer`, so
     export matches what the performer sees.

2. **`lib/services/pdf_export_service.dart`** — `PdfExportService`.
   - `Future<Uint8List> buildPdf(SongNote song, {int semitones = 0})`.
   - Uses `ChordTransposer` (transpose lyrics + key), `ChordSheetParser` (lines and
     `chordsUsed`), and `ChordShapeService` (guitar shape per chord).
   - Layout on an A4 `pw.MultiPage`:
     - Header: title (bold), artist, and a `Key: X • BPM: N` line.
     - A wrapped row of small guitar chord diagrams for the chords used, drawn with
       `pw.CustomPaint` from each `GuitarChordShape` (dots, open `O`/muted `X`, and
       the base-fret label) — the same data the on-screen diagram uses.
     - The chorded lyrics: each line as a `pw.Wrap` of small columns (chord on top,
       lyric below), mirroring `ChordSheetView`; blank lines become vertical gaps.
   - `MultiPage` handles pagination automatically.

### New test files

3. **`test/services/chord_pro_service_test.dart`**
   - Import: parses each directive and its short alias; unknown directives and
     chorus/verse markers are dropped; `{comment}` becomes a lyric line; a bad
     `{bpm}` keeps the default; an empty file gives "Untitled Song"; chords in
     lyric lines survive untouched.
   - Export: writes the four directives + lyrics; omits artist when empty;
     transposes lyrics and key when `semitones != 0`.
   - **Round-trip:** `parse(format(song)) == song` (ignoring id/timestamp) for a
     seeded song, and for a song with slash chords and blank-line spacing.

4. **`test/services/pdf_export_service_test.dart`**
   - `buildPdf` returns non-empty bytes that start with `%PDF` for a seeded song,
     for a song with no chords, and with a non-zero transpose (no throw).

### Edited source files

5. **`lib/screens/song_list_screen.dart`** — enable the **Import ChordPro** menu
   item. Handler: pick a file with `FilePicker`, read its bytes as text, `parse`
   it, `insert` via `songRepositoryProvider` (stamping `timestamp`), then open the
   new song and show a success `SnackBar`. Any failure → an `ImportException`
   caught at the edge and shown as a `SnackBar`; the DB is never touched on a bad
   parse.

6. **`lib/screens/song_performance_screen.dart`** — enable **Export as PDF** and
   **Export as ChordPro** in `_OverflowMenu`.
   - Export as PDF: `buildPdf` then `Printing.sharePdf(bytes:, filename:)` (share
     sheet — offline).
   - Export as ChordPro: `format` then `FilePicker.platform.saveFile` writing the
     text bytes (scoped save dialog). Both apply the live transpose. Errors →
     `ExportException` → `SnackBar`.
   - Both items are disabled when there is no song on screen.

### Edited test files (keep the suite green)

7. **`test/screens/song_list_screen_test.dart`** and
   **`test/screens/song_performance_screen_test.dart`** — update the expectations
   that assert those menu items are disabled / say "Coming soon", since they are
   now enabled. (File IO itself is not driven from widget tests; the pure services
   carry the logic coverage.)

### Docs (after implementation)

8. **`docs/implementation_progress.md`** — mark Phase 7 done with a change-log
   link.

---

## 3. Approach notes / decisions

- **Where IO lives.** `ChordProService` and `PdfExportService` stay pure and
  testable. The file picker, share sheet, database write, navigation, and
  `SnackBar`s stay in the screen handlers — the same edge the app already uses for
  its side effects. This keeps the "widgets don't know ChordPro syntax / services
  don't know navigation" boundary.
- **`{comment}` on import** becomes a plain lyric line rather than a special block,
  because `SongNote` has only a single `lyrics` field. This is faithful to the
  Android app's single-body model and keeps the round-trip exact (export writes no
  comment directives, so nothing is lost on the way back).
- **Round-trip definition.** The tests treat round-trip as `export → import`
  producing an equal song (ignoring id/timestamp), which is what the Phase 7
  Definition of Done asks for.
- **No new packages.** Everything uses `file_picker`, `pdf`, and `printing`, all
  already approved in `pubspec.yaml`.

---

## 4. Verification

- `flutter analyze` — zero warnings.
- `flutter test` — full suite green, including the new ChordPro round-trip and PDF
  tests.
- `dart format .`.
- Manual device run is still pending across phases (noted in progress doc); this
  plan does not change that.

---

## 5. Out of scope

- No changes to the data schema, theme, or navigation structure.
- No printing of the harmonium diagram in the PDF (idea §7 asks for guitar diagrams
  in the PDF only; the harmonium diagram stays in the on-screen Chord Reference).
