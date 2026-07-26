# Change log: PDF export no longer puts each word on its own line

**Plan:** `plans/20260723_213221_pdf-one-word-per-line.md`

## What changed

- `lib/services/pdf_export_service.dart` — in `_segment`, the chord slot above
  each word was an empty `pw.Container(height: 11)` when the word had no
  chord. In the `pdf` package, an empty container with an open width expands
  to fill the whole page, so every chordless word became page-wide and the
  `Wrap` could fit only one word per line.
  - No chord: now uses `pw.SizedBox(width: 0, height: 11)` — fully tight, so
    it stays 0 wide and only reserves the chord row's height.
  - With a chord: unchanged (`Container` with the chord `Text` child, which
    sizes to the text).

## Checks

- `flutter analyze`: no new issues (4 pre-existing warnings in unrelated
  setlist/meta-field files remain).
- `flutter test`: all 254 tests passed.
- Manual: re-export a song PDF to confirm lyrics flow and wrap normally.
