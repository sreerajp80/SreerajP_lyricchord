# Fix Malayalam PDF shaping and Malayalam export filename

**Status:** completed

## The issue

Two problems when exporting a song as PDF from the performance screen:

1. **Malayalam looks broken in the PDF.** Chillu letters, conjuncts
   (chandrakkala stacks like `സ്റ്റ`), and reordered vowel signs (the `െ` in
   `ടെസ്റ്റ്` that must move in front of `ട`) do not render correctly.
   Example: the user typed `ടെസ്റ്റ്` and `വക്കുന്നത്`, but the PDF showed
   `ടസെസ്റ്റ്റ്` and broken conjuncts.

   **Root cause:** the current export uses the `pdf` package's text widgets
   (`pw.Text`). That package maps each Unicode code point to one glyph, one to
   one. It ships only an Arabic shaper — it has **no** complex-script (Indic)
   shaping engine. So it cannot reorder Malayalam vowel signs, form conjuncts,
   or make chillu forms. There is no flag to fix this inside the `pdf` widget
   layer.

2. **A Malayalam title does not become the PDF file name.** `_safeFileName`
   uses `RegExp(r'[^\w\s-]')`. In Dart, `\w` matches only ASCII
   `[A-Za-z0-9_]` (no Unicode flag), so every Malayalam letter is stripped. A
   fully-Malayalam title becomes empty and the file falls back to `song.pdf`.

## The fix (approved direction: real, selectable text)

Render the sheet as **HTML** and convert it to PDF with the platform's native
web view via `Printing.convertHtml(...)` (the `printing` package, v5.14.3,
already a dependency). The native web view (Android WebView / iOS WKWebView)
does full complex-script shaping, so Malayalam renders exactly like the app
screen, and the text stays **real and selectable/copyable** in the PDF.

This stays fully offline: the HTML is an in-memory string with the fonts
embedded as base64 `@font-face` data URIs. No external URL is loaded, so no
network and no `INTERNET` permission are involved (CLAUDE.md hard rule 1).

### Design

- **`PdfExportService` becomes an HTML builder (pure, testable).**
  - New public method `Future<String> buildHtml(SongNote song, {int semitones,
    LyricFont font})` returns the full HTML document string.
  - It reuses the same pure services as today (`ChordTransposer`,
    `ChordSheetParser`, `ChordShapeService`) so the PDF matches the app.
  - Fonts: load the chosen font's regular + bold `.ttf` via `rootBundle`, plus
    always Noto Sans Malayalam as the fallback, and embed each as a base64
    `@font-face`. The CSS `font-family` list is `chosen, 'Noto Malayalam
    Fallback', sans-serif` so Malayalam prints even for the plain "System
    default" choice (same fallback behaviour as today).
  - The platform-channel call `Printing.convertHtml` is **not** put inside the
    service (keeps the service free of platform/UI). The screen does the
    conversion.
  - The old `buildPdf` (which used `pw.*`) and all `pdf`-widget code in this
    file are removed. The `pdf`/`pdf widgets` imports go; `printing` is used by
    the screen, not the service.

- **HTML layout (mirrors the current PDF):**
  - Header: title (22pt, accent purple `#6750A4`, bold), optional artist
    (12pt, grey), then `Key: … BPM: …` (11pt).
  - Guitar diagrams block: for each used chord, an **inline SVG** that
    reproduces today's diagram — fret grid, nut or start-fret number, purple
    finger dots, and `X`/`O` markers — from `ChordShapeService.guitarShape`.
    Vector, so it stays crisp. `no diagram` text when a shape is unknown.
  - A thin divider, then the lyric lines.
  - Lyric lines: reuse the existing word-piece split (`_wordPieces`) so long
    lines wrap between words. Each piece is a small stacked column (chord row
    above the lyric word) laid out with `display:flex; flex-wrap:wrap;
    align-items:flex-end`, matching the current `pw.Wrap`. Chord = 8pt bold
    accent; lyric = 11pt. Blank lines become vertical space.
  - All user text (`title`, `artist`, chords, lyrics) is HTML-escaped
    (`&`, `<`, `>`, `"`) so odd input can never break the markup
    (CLAUDE.md hard rule 4 — never crash on bad input).
  - Page: A4, 32pt margins, via `@page`/body CSS and the `format` argument.

- **Screen (`song_performance_screen.dart`) `_exportPdf`:**
  - `final html = await service.buildHtml(song, semitones: …, font: …);`
  - `final bytes = await Printing.convertHtml(html: html,
    format: PdfPageFormat.a4);`
  - `await Printing.sharePdf(bytes: bytes, filename: '<safe title>.pdf');`
  - Keep the existing try/catch → SnackBar on failure.

### File name fix (Malayalam title → file name)

- Extract the file-name cleaner into a small pure util so it is testable and
  shared: **new** `lib/core/utils/safe_file_name.dart` with
  `String safeFileName(String title)`.
  - Keep Unicode letters/digits (so Malayalam survives). Only remove characters
    that are actually illegal in file names on Android/iOS:
    `\ / : * ? " < > |` and control characters. Collapse whitespace to `_`,
    trim, and fall back to `song` when the result is empty.
- Replace the private `_safeFileName` in **both**
  `song_performance_screen.dart` and `song_list_screen.dart` with this shared
  util (same bug affects the ChordPro export file name too).

## Files to change

| File | Change |
|------|--------|
| `lib/services/pdf_export_service.dart` | Rewrite: build HTML (with embedded fonts + inline-SVG diagrams) instead of `pdf` widgets; expose `buildHtml`; drop `pdf`/`pdf/widgets` imports. |
| `lib/screens/song_performance_screen.dart` | `_exportPdf` uses `buildHtml` + `Printing.convertHtml`; use shared `safeFileName`; drop private `_safeFileName`. |
| `lib/screens/song_list_screen.dart` | Use shared `safeFileName`; drop private `_safeFileName`. |
| `lib/core/utils/safe_file_name.dart` | **New** pure util `safeFileName`. |
| `test/services/pdf_export_service_test.dart` | Update: assert on the returned HTML (contains the title/artist/chord/lyric text, an `@font-face`, and the SVG diagram) instead of `%PDF` bytes, because `convertHtml` needs a device/web view not available in unit tests. Keeps the Malayalam cases. |
| `test/core/utils/safe_file_name_test.dart` | **New**: Malayalam title kept, illegal chars removed, empty → `song`. |

## Trade-offs / notes

- `Printing.convertHtml` runs on a device/emulator (needs the platform web
  view). Unit tests therefore cover the **HTML building** and the **file-name
  util**, not the final PDF bytes. The PDF itself is verified by a manual run
  on device. This is why the service is split into a pure `buildHtml`.
- The guitar diagrams are re-implemented as SVG. I will match the current
  geometry (5 frets, 6 strings, nut, start-fret number, dot radius) as closely
  as practical.
- No new dependency is added; `printing` and its web-view conversion are
  already present. Still fully offline.

## Verification

- `flutter analyze` clean, `flutter test` green.
- Manual: export a song whose title and lyrics are Malayalam
  (`ടെസ്റ്റ്` / `വക്കുന്നത്`), confirm the PDF shows correct chillu/conjuncts
  and that the shared file name is the Malayalam title.
