# Change log: fix Malayalam PDF shaping and Malayalam export file name

Implements plan
`plans/20260724_200822_pdf-malayalam-shaping-and-filename.md`.

## What was wrong

1. Exported PDFs rendered Malayalam incorrectly — chillu letters, conjuncts
   (chandrakkala stacks), and reordered vowel signs were broken (e.g. the user
   typed `ടെസ്റ്റ്` but the PDF showed `ടസെസ്റ്റ്റ്`). Cause: the export used
   the `pdf` package's text widgets, which map each Unicode code point to one
   glyph and do no complex-script (Indic) shaping.
2. A Malayalam song title did not become the export file name. `_safeFileName`
   used `RegExp(r'[^\w\s-]')`; Dart's `\w` is ASCII-only, so it stripped every
   Malayalam letter and the file fell back to `song`.

## What changed

- **`lib/services/pdf_export_service.dart` — rewritten.** It no longer uses the
  `pdf` widget layer. New method `buildHtml(song, {semitones, font})` returns a
  self-contained HTML song sheet:
  - Chosen font (regular + bold) and the Noto Sans Malayalam fallback are
    embedded as base64 `@font-face` data URIs — no external URL is loaded, so
    the app stays fully offline.
  - Header, a divider, and chord-over-lyric lines are built as HTML. Lyric
    lines reuse the existing per-word split so long lines wrap between words.
  - Guitar diagrams are drawn as inline SVG (fret grid, nut / start-fret
    number, purple finger dots, X/O markers), matching the previous geometry.
  - All user text (title, artist, chords, lyrics) is HTML-escaped.
- **`lib/screens/song_performance_screen.dart` — `_exportPdf`** now calls
  `buildHtml`, converts it with `Printing.convertHtml(...)` (the native web
  view shapes Malayalam and keeps the text selectable), then shares the bytes.
  `convertHtml` is soft-deprecated in `printing` but is the only API that
  shapes complex scripts, so its lint is suppressed with a documented reason.
- **`lib/core/utils/safe_file_name.dart` — new.** `safeFileName(title)` keeps
  Unicode letters/digits (so Malayalam survives), removes only characters that
  are illegal in file names (`\ / : * ? " < > |` and control chars), collapses
  whitespace to `_`, and falls back to `song` when empty.
- **`lib/screens/song_performance_screen.dart` and
  `lib/screens/song_list_screen.dart`** now use the shared `safeFileName` and
  their private `_safeFileName` copies were removed. This fixes the file name
  for both the PDF and ChordPro exports.

## Tests

- **`test/core/utils/safe_file_name_test.dart` — new.** Covers Malayalam kept,
  mixed titles, illegal-char removal, whitespace collapse, and empty fallback.
- **`test/services/pdf_export_service_test.dart` — updated.** Asserts on the
  returned HTML (self-contained, embedded fonts, correct text, HTML-escaping,
  Malayalam kept, chosen font embedded) instead of `%PDF` bytes, because
  `Printing.convertHtml` needs a device/web view not available in unit tests.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 262 tests pass.
- Manual on-device check (not automatable in unit tests): export a song with a
  Malayalam title and lyrics, confirm the PDF shows correct chillu/conjuncts,
  that the text is selectable, and that the file name is the Malayalam title.

## Caveat

`Printing.convertHtml` is marked deprecated in `printing` 5.14.3 (it may be
removed in a future major version). It still works today and is the only
package API that shapes complex scripts. If it is removed later, the export
would need a different native HTML→PDF path.
