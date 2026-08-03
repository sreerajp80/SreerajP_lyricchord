# Change Log: Share selected song(s) as ChordPro or PDF

**Plan reference:** [plans/20260728_072045_share-selected-songs.md](file:///l:/Android/SreerajP_lyricchord/plans/20260728_072045_share-selected-songs.md)

## Summary

Added a **Share** icon button in the app bar when songs are selected on the `SongListScreen`. Tapping the Share icon displays an `AlertDialog` allowing the user to select either **ChordPro** (`.chordpro`) or **PDF** (`.pdf`) format (with ChordPro as the default choice), and shares the selected file(s) directly using the system share sheet (`Printing.sharePdf`).

## Changes Made

### 1. `lib/services/pdf_export_service.dart`

- Added `buildHtmlForMultiple(List<SongNote> songs, {LyricFont font})` to support exporting multiple songs into a single HTML document.
- Added CSS `.song-container { page-break-after: always; }` to place each song on a fresh A4 page when converted to PDF.

### 2. `lib/screens/song_list_screen.dart`

- Added a Share icon (`Icons.share_outlined`, tooltip: `'Share selected'`) to the AppBar action bar in multi-song selection mode.
- Implemented `_shareSelected(...)` which opens an `AlertDialog` using `RadioGroup` for selecting format:
  - **ChordPro** (`.chordpro`) — default selected.
  - **PDF** (`.pdf`).
- Implemented `_shareChordPro(...)` and `_sharePdf(...)` helper methods that invoke `Printing.sharePdf(...)` with appropriate filename (`<safe_title>.chordpro` / `<safe_title>.pdf` or `selected_songs.chordpro` / `selected_songs.pdf`).

### 3. `test/services/pdf_export_service_test.dart`

- Added unit tests for `buildHtmlForMultiple` to ensure multi-song HTML is properly generated with paged-media CSS breaks.

## Verification

- `flutter analyze`: clean (0 issues).
- `flutter test`: all 280 unit & widget tests passed.
