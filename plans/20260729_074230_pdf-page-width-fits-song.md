# Fix the shrunk PDF lines and size the page width to the song

**Status:** completed

Follow-up to [20260728_232348_pdf-fit-to-screen.md](20260728_232348_pdf-fit-to-screen.md),
after testing the export on a device.

## What the device test showed

The exported "Jingle Bells" sheet came out with lines at **very uneven sizes** —
most shrank all the way to the 9 pt floor — and the page still opened small in
the PDF viewer.

### Issue 1 — the auto-fit measured the wrong width (a bug)

`LcHtmlToPdf` attaches the off-screen web view with

```kotlin
val widthPx = ceil(widthPts * 96.0 / 72.0).toInt()   // 794
FrameLayout.LayoutParams(widthPx, heightPx)
```

`LayoutParams` are in **physical pixels**, but CSS pixels are physical pixels
divided by the screen density. On a 2.75x phone the page is 794 physical px =
about **289 CSS px** wide, when a real A4 page is **794 CSS px**.

`lcFitLines` used `line.clientWidth` as its limit, so it believed the page was
under half its true width and shrank almost every line to 9 pt. The printed PDF
is laid out at the real print width, so the result is small text with a lot of
empty space — exactly what the screenshot shows.

### Issue 2 — A4 is much wider than a song needs

A song line is short. On A4 a big part of the page width is empty, and the whole
page must shrink to fit a phone screen, so the lyrics look small no matter what
size they are.

The user chose: **set the page width from the longest line in the song**, keeping
the A4 page height.

## The plan

### Part 1 — measure against a real, fixed width, not the view

Stop depending on the web view's own width. The sheet's content gets an explicit
width in points, so every measurement is in page units and the device screen no
longer affects anything:

- CSS: `body { width: <content width>pt; }`, set from JavaScript.
- `@page` drops `size: A4` and uses `margin: 0`. The page size and margins now
  come only from the native `PrintAttributes`, so there is exactly one source
  for them and they cannot be applied twice.
- `HtmlPdfService` sends `marginPts: 20` (was 32) so the native margin matches
  what the layout was designed for.

Because the width is set as an inline style before printing, the layout the
script measured is exactly the layout that gets printed.

### Part 2 — page width follows the song

The page width can only be known after the text is measured, so the render
becomes two passes over the **same loaded page** (no reload, no extra work):

1. **Measure.** After the fonts load, `window.lcMeasure()` widens the body far
   past any real page (so no line can wrap), measures the true width of every
   `.line`, and returns the widest one in points.
2. **Decide.** Kotlin turns that into the page width:

   ```
   pageWidth = clamp(widest + 2 * margin, minWidthPts, maxWidthPts)
   ```

   with `minWidthPts = 300` (narrow enough for short songs, wide enough for the
   title and the "Key / BPM" line) and `maxWidthPts = 595.28` (A4 width — never
   wider than a sheet of paper). Page **height stays A4** (841.89 pt).
3. **Apply and print.** Kotlin calls `window.lcApplyWidth(<page width minus
   margins>)`, which sets the body width and then runs the same shrink pass as
   before — now only needed for a song so wide it hit the A4 limit. When that
   call finishes, Kotlin prints with the chosen media size.

A song with short lines therefore gets a narrow, tall page. Fitted to a phone
screen that page fills the width, so the lyrics look much bigger. A wide song
gets a page up to A4 and its longest lines shrink, as before.

Safety: the widest line is used with a 2% allowance so a rounding difference can
never push a line over the edge. If `lcMeasure` is missing or returns 0 (older
HTML, or a measuring error), Kotlin falls back to the full A4 width and prints
exactly as it does today.

### Part 3 — the JavaScript bridge

The bridge changes from "ready" to "measured":

- `onReady()` becomes `onMeasured(String widthPt)`. The value is passed as a
  string and parsed in Kotlin, so a bad value cannot crash the bridge — it just
  falls back to A4 width.
- The evaluated script becomes:

  ```js
  document.fonts.ready.then(function () {
    var w = window.lcMeasure ? window.lcMeasure() : 0;
    window.AndroidPdf.onMeasured(String(w));
  });
  ```

- The existing hard timeout still covers the whole two-pass sequence, so a stuck
  render can never hang.

## Files to change

| File | Change |
|------|--------|
| `lib/services/pdf_export_service.dart` | `@page` becomes `margin: 0` with no `size`; body width is set from script; replace `lcFitLines` with `lcMeasure()` (widest line, in points) and `lcApplyWidth(pt)` (set width, then shrink any line that still does not fit). |
| `android/app/src/main/kotlin/android/print/LcHtmlToPdf.kt` | Take `minWidthPts` as well; two-pass flow — measure, clamp the page width, `lcApplyWidth`, then print with the chosen media size; `onReady()` → `onMeasured(String)`. |
| `android/app/src/main/kotlin/in/sreerajp/lyricchord/MainActivity.kt` | Read and forward the new `minWidthPts` argument. |
| `lib/services/html_pdf_service.dart` | Send `minWidthPts: 300`, `marginPts: 20` (was 32); document that `widthPts` is now the **maximum** width. |
| `test/services/pdf_export_service_test.dart` | Update the script checks to `lcMeasure` / `lcApplyWidth`; check `@page { margin: 0 }`. |
| `test/services/html_pdf_service_test.dart` | Check the new `minWidthPts` argument is sent. |

The font sizes, the `/OpenAction [… /Fit]` hint, and all four export/share paths
stay exactly as they are.

## How to check it worked

1. `flutter analyze` clean, `flutter test` green.
2. On the device, export "Jingle Bells" again. Expect: all lines at the **same**
   15 pt size (no more mixed sizes), on a page clearly narrower than A4, and
   noticeably bigger text when the viewer fits the page to the screen.
3. Export a song with one very long line: that line should be the only smaller
   one, and it must not run off the page.
4. Export a Malayalam song — letters still shaped correctly.
5. Export several selected songs — the page is wide enough for the widest line
   of all of them, and each song still starts on its own page.

## Risks

- **A wider page for a wide song.** The page width is driven by the longest
  line, so one long line makes the whole song's page wider. This is the direct
  meaning of "fit the page width to the song".
- **Unusual page size.** Printing a narrow page on A4 paper leaves side margins
  or the printer scales it up. This is the accepted trade-off for on-screen
  reading.
- **Two-pass render.** One extra measure pass and one extra script call before
  printing; both are milliseconds, and the existing timeout still guards them.
