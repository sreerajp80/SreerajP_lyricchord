# Plan: PDF export should keep the Malayalam file name (use the Save dialog)

**Status:** approval_pending

## The issue

Exporting a Malayalam song to PDF produced a file whose name showed as
`%E0%B4%9F%E0%B5%86...pdf` (percent-encoded) in the Files app and in email apps.
The name is the correct Malayalam title, but PDF export shares it through
`Printing.sharePdf`, which hands the file over as a `content://` URI. URIs must
percent-encode non-ASCII characters, and the apps on the device display that
encoded form.

The existing **Export as ChordPro** uses the system "Save" dialog
(`FilePicker.saveFile`), which goes through Android's Storage Access Framework
and keeps the true Unicode name. Confirmed on device: a ChordPro export saved as
`ടെസ്റ്റ്.chordpro` (correct Malayalam).

## The fix

Make **Export as PDF** save through the same system "Save" dialog as ChordPro,
instead of the share sheet.

In `lib/screens/song_performance_screen.dart`, `_exportPdf`:

- Keep everything up to and including getting the PDF `bytes` (progress dialog,
  `HtmlPdfService`, timeout, error handling, empty-bytes guard).
- Replace the `Printing.sharePdf(...)` call with:
  `FilePicker.platform.saveFile(dialogTitle: 'Export as PDF',
  fileName: '${safeFileName(song.title)}.pdf', bytes: bytes)`.
- On a non-null returned path, show a `Exported "<title>"` SnackBar (mirrors the
  ChordPro export).
- Remove the now-unused `printing` import if nothing else in the file uses it.

This keeps the true Malayalam file name and makes it display correctly, matching
the ChordPro behaviour. Still fully offline (SAF is local, no network).

Note: PDF export becomes a "save to a folder" action instead of a share-sheet
action, exactly like ChordPro export. The Malayalam title also still appears
inside the PDF header.

## Files to change

- `lib/screens/song_performance_screen.dart` — `_exportPdf` uses
  `FilePicker.saveFile`; drop the unused `printing` import if applicable.

## Verification

- `flutter analyze` clean, `flutter test` green.
- On device: export a Malayalam song to PDF → the Save dialog is pre-filled with
  the Malayalam name; the saved file shows the real Malayalam name in Files; the
  PDF opens with correct Malayalam and selectable text.
