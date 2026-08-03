# PDF export: fixed the shrunk lines, and the page width now follows the song

Implements [plans/20260729_074230_pdf-page-width-fits-song.md](../plans/20260729_074230_pdf-page-width-fits-song.md).
Follow-up to [20260728_232348_pdf-fit-to-screen.md](20260728_232348_pdf-fit-to-screen.md)
after testing that export on a device.

## Why

The device test showed two problems:

1. **Lines came out at very uneven sizes**, most shrunk to the 9 pt floor. The
   auto-fit script used the off-screen web view's own width as its limit, but
   that view is sized in **physical pixels** while CSS pixels are physical
   pixels divided by the screen density. On a 2.75x phone the script saw a page
   about 289 CSS px wide instead of the real 794, so it believed almost every
   line was too long and shrank it.
2. **A4 is far wider than a song needs.** The unused side space is what makes
   the whole page — and so the lyrics — look small on a phone.

## What changed

### 1. Measuring no longer depends on the screen

`lib/services/pdf_export_service.dart`:

- The sheet now sets its own width **in points** (`document.body.style.width`),
  so all measuring is in page units and the device screen cannot affect it. The
  layout that gets measured is exactly the layout that gets printed, because
  the width is an inline style applied before the print pass.
- `@page` no longer sets `size: A4` and now uses `margin: 0`. The page size and
  margins come only from the native print attributes, so there is one source
  for them and they cannot be applied twice.
- `lib/services/html_pdf_service.dart` sends `marginPts: 20` (was 32) so the
  native margin matches the layout the CSS was designed for.

### 2. The page width follows the song

The width is only knowable after the text is measured, so the render is now two
passes over the **same loaded page** — no reload:

- `window.lcMeasure()` widens the sheet to 5000 pt so no line can wrap,
  measures the true width of every `.line`, and returns the widest in points
  (with a 2% allowance so rounding can never push a line over the edge). It
  returns `0` if nothing could be measured.
- `LcHtmlToPdf` turns that into the page width:
  `clamp(widest + 2 * margin, minWidthPts, maxWidthPts)`, with
  **min 300 pt** (room for the title and the Key/BPM line) and **max 595.28 pt**
  (A4 width — never wider than paper). The height stays A4 (841.89 pt).
- `window.lcApplyWidth(pt)` then sets the sheet to the chosen content width and
  runs the shrink pass, which now only matters for a song wide enough to hit
  the A4 cap. Printing starts from the `evaluateJavascript` callback, so the new
  width is always in place first.

A song with short lines now gets a narrow, tall page. Fitted to a phone screen
that page fills the width, so the lyrics look much bigger.

### 3. The JavaScript bridge

`android/app/src/main/kotlin/android/print/LcHtmlToPdf.kt`:

- `onReady()` became `onMeasured(String widestLinePt)`. The value crosses as a
  string and is parsed with `toDoubleOrNull()`, so a bad value cannot break the
  bridge — it falls back to a full-width page.
- A `measured` flag makes the callback run once only.
- `convert(...)` takes `maxWidthPts` and `minWidthPts` instead of a fixed
  `widthPts`.
- If `lcMeasure` / `lcApplyWidth` are missing (older HTML), the guards make it
  print full width exactly as before.
- The existing hard timeout still covers the whole two-pass sequence.

`android/app/src/main/kotlin/in/sreerajp/lyricchord/MainActivity.kt` reads and
forwards the new `minWidthPts` argument, and its `marginPts` default is now 20.

### 4. Unchanged

Font sizes (15 pt lyrics, ~11 pt chords), the no-wrap behaviour, the
`/OpenAction [… /Fit]` hint, and all four export/share paths are as before.

## Tests

- `test/services/pdf_export_service_test.dart` — the script checks now look for
  `lcMeasure` and `lcApplyWidth`, and the page check is `@page { margin: 0; }`
  with no `size: A4`.
- `test/services/html_pdf_service_test.dart` — checks `minWidthPts` is sent and
  is smaller than the maximum `widthPts`.

`flutter analyze` — clean. `flutter test` — 322 tests, all passing.
`gradlew :app:compileDevDebugKotlin` — compiles clean.

## Still to check on a device

The measure/fit passes only run inside the real web view, so please confirm:

1. "Jingle Bells" exports with **all lines the same 15 pt size** (no more mixed
   sizes), on a page clearly narrower than A4.
2. A song with one very long line: only that line is smaller, and it does not
   run off the page.
3. Malayalam still shapes correctly.
4. A multi-song export: the page is wide enough for the widest line across all
   the songs, and each song still starts on its own page.

## Known trade-offs

- One long line makes that whole song's page wider — that is what fitting the
  page width to the song means.
- A narrow page printed on A4 paper gets side margins, or the printer scales it
  up. Accepted, because the sheet is mainly read on a screen.
