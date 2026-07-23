# Change log — Phase 7: Import / export

**Date:** 2026-07-21

**Implements:** [../plans/20260721_103433_phase-7-import-export.md](../plans/20260721_103433_phase-7-import-export.md)

Phase 7 of [../docs/implementation_plan.md](../docs/implementation_plan.md):
ChordPro import, ChordPro export, and PDF export.

---

## What changed

### New services (pure — no UI, no IO)

- **`lib/services/chord_pro_service.dart`** — `ChordProService`.
  - `parse(String content)` reads ChordPro text into a `SongNote` (id `0`,
    timestamp `0`; the caller stamps the real time). It understands
    `{title|t}`, `{artist|a}`, `{key|k}`, `{bpm|tempo}`, and `{comment|c}`
    (a comment becomes a plain lyric line). Chorus/verse markers
    (`soc`/`eoc`/`sov`/`eov`) and any other directive are dropped; everything
    else is a lyric line, kept verbatim. Leading/trailing blank lines are
    trimmed so a round-trip is exact. It never throws — a broken or empty file
    still returns a usable "Untitled Song" with safe defaults (CLAUDE.md hard
    rule 4).
  - `format(SongNote song, {int semitones = 0})` writes the four metadata
    directives, a blank line, then the lyrics, applying the live transpose to
    both the `{key}` and the chords when `semitones != 0`.

- **`lib/services/pdf_export_service.dart`** — `PdfExportService`.
  - `buildPdf(SongNote song, {int semitones = 0})` builds an A4 `MultiPage`
    document: a header (title/artist/`Key • BPM`), a wrapped row of guitar
    diagrams for the chords used (drawn with `pw.CustomPaint` from the existing
    `ChordShapeService` shapes), and the chorded lyrics laid out the same way as
    the on-screen `ChordSheetView`. It reuses `ChordTransposer`,
    `ChordSheetParser`, and `ChordShapeService` so the PDF matches the app.

### Wired into the screens (IO stays at the edge)

- **`lib/screens/song_list_screen.dart`** — the **Import ChordPro** overflow item
  is now enabled. It picks a file with `file_picker`, decodes the bytes as UTF-8,
  parses them with `ChordProService`, saves the song through
  `songRepositoryProvider`, shows a success `SnackBar`, and opens the new song. A
  read failure surfaces as a `SnackBar`; a bad parse never reaches the database.

- **`lib/screens/song_performance_screen.dart`** — **Export as PDF** and
  **Export as ChordPro** are now enabled (disabled only when no song is on
  screen). PDF export builds the bytes and opens the system share sheet via
  `Printing.sharePdf`. ChordPro export writes the text through
  `FilePicker.platform.saveFile`. Both apply the live transpose; failures show a
  `SnackBar`. A helper makes the song title safe to use as a file name.

### Tests

- **`test/services/chord_pro_service_test.dart`** — directive parsing and short
  aliases, comment-to-lyric-line, dropped chorus/unknown directives, bad-tempo
  fallback, empty-file defaults, chords preserved, blank-line trimming; export
  directive output and transpose; and export→import round-trip (a simple song and
  one with slash chords + blank-line spacing).
- **`test/services/pdf_export_service_test.dart`** — `buildPdf` returns valid PDF
  bytes (`%PDF` magic) for a normal song, a song with no chords, a transposed
  song, and an empty song.

### Docs

- **`docs/implementation_progress.md`** — Phase 7 marked done; current status moved
  to Phase 8.

---

## Notes / decisions

- **No new packages.** Only the already-approved `file_picker`, `pdf`, and
  `printing` are used. The app stays fully offline; no storage permission is
  requested (scoped storage via the picker / share sheet).
- **`{comment}` imports as a plain lyric line** because `SongNote` has a single
  lyrics body. This keeps the export→import round-trip exact (export writes no
  comment directives, so nothing is lost).
- The PDF uses the built-in Helvetica font. The test run prints a harmless
  "Helvetica has no Unicode support" notice; the ASCII chord/lyric content renders
  fine. A custom Unicode font can be added later if non-Latin lyrics are needed.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 170 tests pass (17 new).
- `dart format .` applied to the changed files.
- A manual run on a device is still pending across phases.
