# Plan: Remove guitar chord diagrams from the PDF export

**Status:** completed

## The issue

The exported PDF draws a grid of guitar fret diagrams (one per chord used, e.g.
Dm, G, F, Am) near the top. The user does not want these in the PDF. The PDF
should show only the header (title, artist, key, BPM) and the chord-over-lyric
sheet.

## The fix

In `lib/services/pdf_export_service.dart`:

- In `buildHtml`, stop writing the diagrams block. The body becomes: header →
  divider (`<hr class="rule">`) → lyrics. Keep the divider so the header is still
  separated from the lyrics.
- Remove the now-unused code:
  - the `chords` variable and the `_transposer.chordsUsed(...)` call,
  - `_diagramsBlock`, `_guitarSvg`, `_line`, `_marker`,
  - the `_shapes` field and the `ChordShapeService` import,
  - the `.diagrams`, `.diagram`, `.nodiagram` CSS rules (and the unused
    `_grey600` constant if nothing else uses it).

This does not touch the on-screen Chord Reference Guide or anything else — only
the PDF output.

## Files to change

- `lib/services/pdf_export_service.dart` — remove the diagrams block and its
  helpers/CSS.
- `test/services/pdf_export_service_test.dart` — the "normal song with chords"
  test asserts an `<svg>` diagram is present; change it to assert there is **no**
  `<svg>` and no `class="diagrams"`. The other tests already expect no diagrams.

## Verification

- `flutter analyze` clean, `flutter test` green.
- On device: export a song with chords → PDF has the header and lyrics only, no
  fret diagrams.
