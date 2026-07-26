# Plan: Fix "Export as PDF" doing nothing (offline)

**Status:** completed

## The issue

Tapping **Export as PDF** on a song does nothing — no PDF, no share sheet, no
error message.

Confirmed on device (moto g54, Android 15) with a debug build:

- Tapping the item reaches `_exportPdf` in
  `lib/screens/song_performance_screen.dart`, which calls
  `Printing.convertHtml(...)`.
- `convertHtml` opens a hidden, off-screen WebView. The log shows it start
  (`WebViewFactory: Loading ... webview`, chromium native library loaded) but it
  **never finishes** — no PDF bytes, no error, forever.
- Root of the hang (from reading the plugin source
  `printing-5.14.3/.../PrintingJob.java` `convertHtml` and
  `android/print/PdfConvert.java`):
  1. The WebView is **never attached to the screen** and there is **no timeout**.
     If any step stalls, the Dart `await` waits forever.
  2. Today's rewrite (`change_log/20260724_200822`) **embeds the Malayalam font
     as a large base64 `@font-face` blob** inside the HTML. An off-screen WebView
     that is never drawn commonly never finishes loading such a font, so the
     "page finished / ready to print" step never completes. Before the rewrite
     there were no embedded fonts, so this never happened.
- Second bug: `_exportPdf` uses `catch (_)`, which hides the real failure and
  only shows a SnackBar if still mounted — so a hang shows nothing at all.

**Offline rule stays intact:** the WebView renders local, app-built HTML; the
font is a local bundled asset; the PDF is shared through the system share sheet.
No network is used at any point. "baseUrl" in the fix means a local `file://`
path only — never a website.

## Important finding: local font files will NOT help

The plugin uses a bare `WebView` with no `allowFileAccessFromFileURLs`. A
`file://` HTML document therefore **cannot** load a separate `file://` font
(blocked by same-origin file rules). Serving the font from a temp file would
render the PDF **without** Malayalam — worse, not better. So base64 embedding is
the correct self-contained approach and must stay.

This means the stall is **not** simply "base64 font." We need the exact failure
before changing the rendering path.

## Step 1 — precise diagnosis + stop the silent hang (this cycle)

Change only `_exportPdf` in `song_performance_screen.dart`:

1. Show a "Generating PDF…" progress dialog.
2. Wrap `Printing.convertHtml` in `.timeout(...)` so it can never hang forever.
3. Replace `catch (_)` with real handling: on `TimeoutException` and any other
   error, close the dialog and show a clear SnackBar; `debugPrint` the full
   error + stack under `kDebugMode` so the device log shows the real cause.
4. Guard empty bytes.

Rebuild once, export a Malayalam song, and read the flutter-run log:
- PDF works → done (the release build may have been the earlier problem).
- Times out → `convertHtml` genuinely hangs on this content; escalate to Step 2.
- Specific error (e.g. "No page created") → fix that precisely.

**Step 1 result (confirmed on device):** even a tiny plain-text page (no fonts,
no SVG) times out. So `Printing.convertHtml` is fundamentally broken on this
device — its hidden WebView is **never attached to a window**, so on Android 15 /
WebView 150 the print callback never fires. No HTML change can fix it.

## Step 2 — attached-WebView HTML→PDF (chosen approach)

Why: proper Malayalam shaping needs a real text engine. The `pdf` package draws
Unicode but does **no complex-script shaping**, so it renders Malayalam wrong.
The system WebView shapes correctly **when it is attached to the window**. We
add a tiny Android method channel that renders the same HTML in an **attached**
WebView and prints it to PDF. Fully offline: the WebView loads only local HTML
(data-URI fonts), JavaScript is local, and network loading is blocked at the
WebView (`blockNetworkLoads = true`); no INTERNET permission is added.

### New native code (Android / Kotlin)

- `MainActivity.kt` — in `configureFlutterEngine`, register a `MethodChannel`
  `in.sreerajp.lyricchord/html_pdf` with one method `convertHtml`
  (args: `html`, `widthPts`, `heightPts`, `marginPts`).
- New `HtmlToPdf.kt` — the converter:
  1. Create `WebView(activity)` and **add it to the activity content view**
     (pushed off-screen via a large translationX so nothing flashes).
  2. `settings.javaScriptEnabled = true`, `settings.blockNetworkLoads = true`
     (enforces offline), `loadDataWithBaseURL(null, html, "text/html", "UTF-8",
     null)`.
  3. On `onPageFinished`, wait for fonts via
     `document.fonts.ready` (a small `@JavascriptInterface` callback), then
     `createPrintDocumentAdapter(...)` and run `onLayout` → `onWrite` to a temp
     file (same technique as the plugin, but on an attached WebView so the
     callbacks actually fire). Read bytes, delete the temp file, remove the
     WebView, return bytes.
  4. A safety timeout (e.g. 20 s) that cleans up and returns an error, so it can
     never hang even in a future edge case.

### Dart changes

- New `lib/services/html_pdf_service.dart` — thin wrapper over the method
  channel: `Future<Uint8List> convert({html, widthPts, heightPts, marginPts})`.
  On a platform without the channel (iOS today) it throws a clear, caught error.
- `lib/screens/song_performance_screen.dart` — `_exportPdf` uses
  `HtmlPdfService` instead of `Printing.convertHtml`, keeping the Step-1 progress
  dialog, timeout, error SnackBar and empty-bytes guard. Still shares via
  `Printing.sharePdf` (offline system share sheet).
- `lib/services/pdf_export_service.dart` — unchanged (`buildHtml` still builds
  the self-contained HTML with base64 fonts; base64 is correct for a
  self-contained document).

### iOS

Out of scope for this change (Android-only, agreed). iOS export will show a
clear "not available yet" message until a WKWebView equivalent is added on a Mac.

### Tests

- `buildHtml` tests unchanged.
- Method-channel converter can't run in unit tests; add a small test that
  `HtmlPdfService` sends the right method and args over a mocked channel.

## Files to change

Step 1 (done):
- `lib/screens/song_performance_screen.dart` — timeout, progress, error handling.

Step 2:
- `android/app/src/main/kotlin/in/sreerajp/lyricchord/MainActivity.kt`
- `android/app/src/main/kotlin/in/sreerajp/lyricchord/HtmlToPdf.kt` (new)
- `lib/services/html_pdf_service.dart` (new)
- `lib/screens/song_performance_screen.dart` (switch to `HtmlPdfService`)
- `test/services/html_pdf_service_test.dart` (new, mocked channel)

## Verification

- `flutter analyze` clean, `flutter test` green.
- On device: export a Malayalam song → PDF generates within a few seconds,
  shows correct chillu/conjuncts, text is selectable, file name is the Malayalam
  title.
- `aapt2 dump permissions` on the release APK shows **no INTERNET** permission.

## Verification

- `flutter analyze` clean, `flutter test` green.
- On device: export a Malayalam song → PDF generates, shows correct
  chillu/conjuncts, text is selectable, file name is the Malayalam title.
- Confirm the built APK still has no INTERNET permission.
