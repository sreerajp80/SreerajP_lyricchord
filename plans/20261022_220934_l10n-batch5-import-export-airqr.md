# Plan: Localization batch 5 — import, export and AirQR

**Status:** completed

## The issue

`CLAUDE.md` says every user-visible text must come from `lib/l10n/*.arb`
through `AppLocalizations`. Batches 1–4 did the songbook, setlists, editor,
performance view and settings. This batch does the Import & Export screen,
the import preview, and the two AirQR screens (send and receive).

About 60 texts in 5 files.

## What changes

The English the user sees stays the same, except the plural fixes below.

### Rules (same as earlier batches)

- Reuse existing keys only where the words and meaning are exactly the
  same: `cancel`, `generalImport` ("Import"), `export`, and `infoBpm`
  ("{bpm} BPM"). "Select All" / "Deselect All" get their own keys because the
  song list uses lower-case "Select all".
- New keys are named by screen: `importExport…`, `importPreview…`,
  `airQrReceiver…`, `airQrTransmitter…`, `airQrHud…`.
- Counts use ICU plurals; names and numbers are placeholders.
- Every key gets an `@key` description.
- Not moved (allowed literals): file extensions (`cho`, `pro`, `chordpro`,
  `txt`) and the extension checks, default file names
  (`imported.chordpro`, `lyricchord_all_songs.chordpro`), the `{new_song}`
  directive, route paths, the platform channel and method names, map keys,
  `FPS` number formats, and `%` values.
- "Import failed: {reason}" keeps the technical reason as data; only the
  words "Import failed" move.

### Plural fixes

- Import & Export: "Exported 1 song(s)." → "Exported 1 song." /
  "Exported 3 songs."
- AirQR title for a whole songbook: "Full Songbook (1 songs)" → "(1 song)".
- Import preview: "Imported 3 songs." and "Found 1 song in file…" now use
  plural messages (the second already worked by hand).

### Texts by file

- **`import_export_screen.dart`** (~20): title, the Import and Export
  headings, the four rows and their subtitles, the "Only .cho, .pro,
  .chordpro, and .txt files can be imported." and "Could not read any chosen
  files." messages, "{count} files selected", "Could not import the files.",
  "No songs to export.", the save-dialog title, "Exported …", "Could not
  export songs.", "No songs to share.", the AirQR title, "Could not prepare
  AirQR export."
- **`import_preview_screen.dart`** (~16): title, Select All / Deselect All,
  the "Found {count} songs in file…" line, "No valid songs found in this
  file.", "In Songbook", "Already in Songbook", "Key: {key}", "{bpm} BPM",
  "Preview", Cancel, "Importing...", "Import Selected ({count})", "Imported
  \"{title}\".", "Imported {count} songs.", "Import failed: {reason}".
- **`air_qr_receiver_screen.dart`** (7): title, the two tooltips, "No AirQR
  code detected in chosen photo.", "Could not scan photo.", "Initializing
  AirQR Camera Receiver...", and the preview file name "AirQR Stream Share".
- **`air_qr_transmitter_screen.dart`** (~9): "AirQR Share: {title}", the
  size line ("{bytes} bytes • {frames} Optical Frames"), "Stream Speed:",
  Pause / Resume Optical Stream, "No frames generated", the two frame lines,
  and the "Point receiving phone camera…" note.
- **`air_qr_receiver_hud.dart`** (5): the three status lines, "Captured:
  {received} / {total} Blocks", "Missing: {count}".

### Not in this batch

Messages made in repositories and services and shown to the user through
`AppException.message` — for example "Could not save the song.",
"Could not delete setlist." (13 places in `song_repository.dart` and
`setlist_repository.dart`) and `AirQrService`'s checksum message — join the
proposed **batch 8 — service, repository and provider messages**. The
repositories would throw an error kind, and the screen would pick the text.

## Tests

- `test/screens/import_preview_screen_test.dart`: add the localization
  delegates to its 3 `MaterialApp`s. Its English text checks stay the same.
- `test/widgets/air_qr_receiver_hud_test.dart` already has them.
- `test/l10n/app_localizations_plural_test.dart`: the new plurals (exported,
  found, imported, full songbook) and the transmitter frame lines.

The AirQR screens and the Import & Export screen open the camera or the file
picker, so they have no widget tests; the plural test covers their messages.

## Files to change

- `lib/l10n/app_en.arb` (+ regenerated `app_localizations*.dart`)
- `lib/screens/import_export_screen.dart`
- `lib/screens/import_preview_screen.dart`
- `lib/screens/air_qr_receiver_screen.dart`
- `lib/screens/air_qr_transmitter_screen.dart`
- `lib/widgets/air_qr_receiver_hud.dart`
- `test/screens/import_preview_screen_test.dart`
- `test/l10n/app_localizations_plural_test.dart`

No files in the `docs/guidelines/` submodule are touched. No database, Android
or iOS change.

## Checks after the change

- `flutter gen-l10n`, `dart format .`, `flutter analyze` (zero issues),
  `flutter test` (all pass).
- A search of the 5 files finds no user-visible string literal left, except
  the allowed ones listed above.

## Change log

`change_log/<timestamp>_l10n-batch5-import-export-airqr.md` after the work.
