# Change Log: Song Performance Page Grouped Export & Share Menu

**Plan reference:** [plans/20260728_073014_song-page-export-share-menu.md](../plans/20260728_073014_song-page-export-share-menu.md)

## Summary

Grouped "Export as PDF" and "Export as ChordPro" into a single **Export** menu option on the song performance screen overflow menu, which presents a format selection dialog (ChordPro vs PDF) to export to a file. Also added a **Share** menu option to the song performance screen menu, allowing users to share the current song as ChordPro or PDF via the native OS share sheet.

## Changes Made

### `lib/screens/song_performance_screen.dart`

- Added import `package:printing/printing.dart`.
- Replaced separate `Export as PDF` and `Export as ChordPro` popup menu items in `_OverflowMenu` with:
  - **Export** (`Icons.output_rounded`): Opens `_showExportDialog`.
  - **Share** (`Icons.share_outlined`): Opens `_showShareDialog`.
- Implemented `_showExportDialog`:
  - Shows an `AlertDialog` titled `'Export song'` with `RadioGroup<String>` for selecting **ChordPro (`.chordpro`)** [default] or **PDF (`.pdf`)**.
  - On `'Export'`, triggers file picker save via `_exportChordPro` or `_exportPdf`.
- Implemented `_showShareDialog`:
  - Shows an `AlertDialog` titled `'Share song'` with `RadioGroup<String>` for selecting **ChordPro (`.chordpro`)** [default] or **PDF (`.pdf`)**.
  - On `'Share'`, formats content with live transpose/font settings and shares via `Printing.sharePdf(...)`.
- Implemented `_shareChordPro(...)` and `_sharePdf(...)` helper methods for single-song sharing.

## Verification

- `flutter analyze`: clean (0 issues).
- `flutter test`: all 280 unit & widget tests passed.
