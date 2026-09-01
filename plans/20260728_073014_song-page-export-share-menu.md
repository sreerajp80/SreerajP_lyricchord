# Song Performance Page: Group Export & Add Share in Overflow Menu

**Status:** completed

## The issue

In the song performance screen overflow menu (`_OverflowMenu` in `song_performance_screen.dart`), "Export as PDF" and "Export as ChordPro" are listed as two separate menu items. Additionally, the **Share** feature (which allows sharing as ChordPro or PDF via the OS share sheet, as implemented on the song listing page) is missing from the song performance screen menu.

## Proposed Changes

### `lib/screens/song_performance_screen.dart`

1. **Import `package:printing/printing.dart`** for calling `Printing.sharePdf`.
2. **Update `_OverflowMenu`**:
   - Replace separate "Export as PDF" and "Export as ChordPro" popup menu items with a single **Export** menu item (`Icons.output_rounded`).
   - Add a new **Share** menu item (`Icons.share_outlined`).
3. **Implement `_showExportDialog(BuildContext context, SongNote song, int semitones, LyricFont font)`**:
   - Displays an `AlertDialog` titled `'Export song'` with `RadioGroup<String>` options:
     - **ChordPro (`.chordpro`)** *(Default option)*
     - **PDF (`.pdf`)**
   - Action buttons: `'Cancel'` and `'Export'`.
   - On tapping `'Export'`:
     - If **ChordPro** selected: call existing `_exportChordPro(context, song, semitones)`.
     - If **PDF** selected: call existing `_exportPdf(context, song, semitones, font)`.
4. **Implement `_showShareDialog(BuildContext context, SongNote song, int semitones, LyricFont font)`**:
   - Displays an `AlertDialog` titled `'Share song'` with `RadioGroup<String>` options:
     - **ChordPro (`.chordpro`)** *(Default option)*
     - **PDF (`.pdf`)**
   - Action buttons: `'Cancel'` and `'Share'`.
   - On tapping `'Share'`:
     - If **ChordPro** selected: format song as ChordPro text (with live transpose), encode UTF-8 bytes, and call `Printing.sharePdf(bytes: bytes, filename: '${safeFileName(song.title)}.chordpro')`.
     - If **PDF** selected: show progress dialog while generating PDF (with live transpose and selected font) via `PdfExportService` and `HtmlPdfService`, then call `Printing.sharePdf(bytes: bytes, filename: '${safeFileName(song.title)}.pdf')`.

### `test/screens/song_performance_screen_test.dart`

- Update widget tests for `song_performance_screen_test.dart` to account for the single "Export" menu item and new "Share" menu item in the overflow menu.

## Files to change

| File | Change |
|------|--------|
| `lib/screens/song_performance_screen.dart` | Update `_OverflowMenu` to group Export into a dialog, add Share option with dialog, add `package:printing` import |
| `test/screens/song_performance_screen_test.dart` | Update tests for overflow menu items |

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero static analysis warnings.
- Run `flutter test` to verify all unit and widget tests pass.

### Manual Verification
- Open any song performance screen.
- Tap the top-right overflow menu (`...`).
- Verify items: Performance controls, Chord Reference Guide, Export, Share, Settings.
- Tap **Export**: verify dialog opens with ChordPro selected by default; selecting ChordPro or PDF saves file via file picker.
- Tap **Share**: verify dialog opens with ChordPro selected by default; selecting ChordPro or PDF opens system share sheet.
