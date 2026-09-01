# Share selected song(s) as ChordPro or PDF

**Status:** completed

## The issue

When selecting one or multiple songs on the song list page (`SongListScreen`), the app bar only provides an export button (save to file as ChordPro), select all, and delete. Users cannot share the selected songs directly via Android/iOS share sheet, nor can they share selected songs as PDF format.

## Proposed Changes

### 1. `lib/services/pdf_export_service.dart`

- Add `buildHtmlForMultiple(List<SongNote> songs, {LyricFont font = LyricFont.fallback})` to generate a single self-contained HTML document containing all selected songs, separated by CSS paged-media page breaks (`page-break-after: always`).

### 2. `lib/screens/song_list_screen.dart`

- Add a Share action button (`Icons.share_outlined`, tooltip: `'Share selected'`) to the AppBar `actions` when `isSelectionMode` is active (between Export and Select All).
- Implement `_shareSelected(BuildContext context, WidgetRef ref, List<SongNote> allVisibleSongs)`:
  - Open an `AlertDialog` allowing the user to select the export format:
    - **ChordPro** (`.chordpro`) — selected by default
    - **PDF** (`.pdf`)
  - Format selection dialog contains "Cancel" and "Share" buttons.
  - When "Share" is tapped:
    - If **ChordPro** is selected:
      - Format selected songs using `ChordProService().formatMultiple(selectedSongs)`.
      - Filename: `${safeFileName(selectedSongs.first.title)}.chordpro` if 1 song, or `selected_songs.chordpro` if multiple.
      - Trigger OS share sheet via `Printing.sharePdf(bytes: bytes, filename: filename)`.
      - Clear selection mode.
    - If **PDF** is selected:
      - Show progress dialog while building HTML and rendering PDF via `HtmlPdfService().convert(...)`.
      - Filename: `${safeFileName(selectedSongs.first.title)}.pdf` if 1 song, or `selected_songs.pdf` if multiple.
      - Trigger OS share sheet via `Printing.sharePdf(bytes: bytes, filename: filename)`.
      - Clear selection mode.

### 3. `test/services/pdf_export_service_test.dart`

- Add unit test `builds HTML for multiple songs with page breaks` to verify `buildHtmlForMultiple`.

## Files to change

| File | Change |
|------|--------|
| `lib/services/pdf_export_service.dart` | Add `buildHtmlForMultiple(List<SongNote> songs, {LyricFont font})` |
| `lib/screens/song_list_screen.dart` | Add Share icon action & dialog for ChordPro/PDF sharing via system share sheet |
| `test/services/pdf_export_service_test.dart` | Add unit test covering multi-song HTML generation |

## Verification Plan

### Automated Tests
- Run `flutter test` to verify `PdfExportService` unit tests pass cleanly.
- Run `flutter analyze` to ensure zero static analysis warnings.

### Manual Verification
- Select 1 or multiple songs on the song list screen.
- Verify Share icon appears in top action bar.
- Tap Share icon and verify dialog appears with ChordPro selected by default.
- Test sharing as ChordPro: confirm OS share sheet opens with `.chordpro` file.
- Test sharing as PDF: confirm OS share sheet opens with `.pdf` file.
