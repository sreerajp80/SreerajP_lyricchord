# Change log: fix "Export as PDF" doing nothing

Implements plan `plans/20260724_211711_fix-pdf-export-hang.md`.

## What was wrong

Tapping **Export as PDF** did nothing — no PDF, no share sheet, no error.

Root cause (confirmed on a moto g54, Android 15, debug build): the export used
`Printing.convertHtml`, which renders HTML in a **hidden WebView that is never
attached to the window**. On this device the print callback never fires, so the
`await` hung forever. Because it hung (instead of throwing), the old `catch (_)`
never ran — so nothing at all happened. A diagnostic build proved even a tiny
plain-text page (no fonts) hung, so it was the WebView path itself, not our HTML.

## What changed

- **`lib/screens/song_performance_screen.dart` — `_exportPdf` rewritten.**
  - Shows a "Generating PDF…" progress dialog.
  - Renders through the new `HtmlPdfService` instead of `Printing.convertHtml`.
  - Wraps the render in a 30 s backstop timeout and handles `TimeoutException`
    and other errors with a visible SnackBar; logs the real error under
    `kDebugMode` only. Guards empty output. Removed the blind `catch (_)`.
  - Still shares the bytes with `Printing.sharePdf` (offline system share sheet).
  - Removed the now-unused `pdf` / `PdfPageFormat` import.
- **`lib/services/html_pdf_service.dart` — new.** A thin wrapper over a method
  channel `in.sreerajp.lyricchord/html_pdf`. Sends the HTML plus A4 size and
  margin, returns PDF bytes, and throws a clear `HtmlPdfException` on failure or
  when no native implementation exists (iOS today).
- **`android/app/src/main/kotlin/android/print/LcHtmlToPdf.kt` — new.** Renders
  the HTML in a real WebView that **is attached** to the activity window (pushed
  off-screen so it never shows), waits for the embedded fonts via
  `document.fonts.ready`, then prints to a temp PDF and returns the bytes. It
  lives in package `android.print` so it can subclass the print callbacks. Fully
  offline: `blockNetworkLoads = true`, `allowFileAccess = false`, only local HTML
  is loaded. Has its own hard timeout so it can never hang.
- **`android/app/src/main/kotlin/in/sreerajp/lyricchord/MainActivity.kt`** — now
  registers the `html_pdf` method channel and calls `LcHtmlToPdf`.

## Why this keeps Malayalam correct and offline

Proper Malayalam shaping (chillu, conjuncts, reordered vowel signs) needs a real
text engine. The `pdf` package draws Unicode but does no complex-script shaping.
The system WebView shapes correctly — but only when attached to a window, which
is exactly what the new native code does. No network is used at any point, and
the release manifest has no INTERNET permission.

## Platform note

Android only. On iOS the channel is absent, so export shows a clear
"not available on this device" message until a WKWebView version is added.

## Tests

- **`test/services/html_pdf_service_test.dart` — new.** Verifies the channel
  call and args, and that failures / empty results / missing implementation all
  throw `HtmlPdfException`.
- `test/services/pdf_export_service_test.dart` unchanged (HTML building is the
  same).

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 266 tests pass.
- On device: exported a Malayalam song → PDF generated in a few seconds, opened
  in the share sheet, Malayalam shaped correctly, text selectable. No hang.
