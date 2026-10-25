# Plan: Localization batch 1 — songbook and setlists

**Status:** completed

## The issue

`CLAUDE.md` says every user-visible text must come from `lib/l10n/*.arb`
through `AppLocalizations`. About 400 texts in screens and widgets are still
written straight in the Dart code, plus the help text. The second gap review
([20261022_140401_second-gap-review.md](20261022_140401_second-gap-review.md),
decision B1) chose to fix this in separate batches.

## All batches (each gets its own plan)

| Batch | Area | Main files |
|-------|------|-----------|
| **1 (this plan)** | Songbook and setlists | `home_shell`, `song_list_screen`, `song_card`, `song_search_field`, `song_filter_row`, `songbook_error`, `setlist_list_screen`, `setlist_detail_screen`, `setlist_editor_dialog`, `setlist_song_picker_sheet` |
| 2 | Song editor | `song_editor_screen`, `song_meta_fields`, `chord_inserter_bar`, `rename_imported_song_dialog`, `melody_keypad_sheet`, `carnatic_notation_sheet`, `melody_line_row` |
| 3 | Performance view | `song_performance_screen`, `performance_controls`, `auto_scroll_controls`, `transpose_sheet`, `chord_reference_dialog`, `stage_hud`, `stage_help_overlay`, `gestures_help_dialog`, `metronome_tempo_sheet`, `pitch_drone_controls`, chord diagram labels |
| 4 | Settings and About | `settings_screen` and all `*_settings_screen` files, `about_screen` |
| 5 | Import, export and AirQR | `import_export_screen`, `import_preview_screen`, `air_qr_receiver_screen`, `air_qr_transmitter_screen`, `air_qr_receiver_hud`, user-facing import error messages |
| 6 | Help | `help_content.dart`, `help_screen`, `help_detail_screen` |
| 7 | Guard | A test that fails if a new hard-coded `Text('…')`, `tooltip: '…'`, `labelText:` or `hintText:` appears in `lib/screens/` or `lib/widgets/` |

## Batch 1 — what changes

About 105 texts in 10 files move into `lib/l10n/app_en.arb`. The English the
user sees stays the same, with two small wording fixes listed below.

### Rules used in this batch

- Reuse existing keys where the text is the same: `appTitle`, `songs`,
  `setlists`, `settings`, `cancel`, `save`, `delete`.
- New keys are named by area: `songList…`, `songCard…`, `songbook…`,
  `setlist…`, plus a few shared ones (`create`, `share`, `tryAgain`).
- Counts use ICU plural messages, so "1 song" / "3 songs" is correct
  without `?:` in the code.
- Song and setlist names go in as placeholders, e.g.
  `songDeleted: 'Deleted "{title}".'`.
- Every key gets an `@key` description.
- Not moved (allowed as literals by `CLAUDE.md`): route paths, map keys
  (`'name'`, `'description'`), format values (`'chordpro'`, `'pdf'`), file
  extensions and default file names (`selected_songs.chordpro`), and the
  number-only text `'${index + 1}'`.
- The raw error shown under "Could not open your songbook" (`'$error'`) stays
  as it is. It is technical detail, not app text.

### Small wording fixes (same meaning, plural-correct)

- "Exported 3 song(s)." → "Exported 3 songs." / "Exported 1 song." Same for
  "Deleted … song(s)" and "Share … selected song(s)".
- "Delete 1 songs?" → "Delete 1 song?" when one song is selected.

### Texts by file

- **`home_shell.dart`** (2): "Pick a song", "Choose a song on the left to open
  it here."
- **`song_list_screen.dart`** (~30): selection bar ("{count} selected",
  "Cancel selection", "Select all", "Deselect all", "Delete selected", "Export
  selected (ChordPro)", "Share selected", "Share selected via AirQR"); top bar
  (title, "Lyrics & Chords Notebook", "Scan AirQR Song", "Settings"); tabs;
  "New song"; export dialog title and results; share dialog (title, format
  names, Cancel, Share) and errors; delete dialogs for one and many songs;
  "Copied …", "Deleted …"; the AirQR title "{count} Selected Songs".
- **`song_card.dart`** (6): key and BPM badge labels and their screen-reader
  labels, "Add to starred", "Remove from starred", "Duplicate song", "Delete
  song".
- **`song_search_field.dart`** (2): search hint, "Clear search".
- **`song_filter_row.dart`** (2): "All Songs ({count})", "Starred ({count})".
- **`songbook_error.dart`** (3): title, explanation, "Try again".
- **`setlist_list_screen.dart`** (8): load error, empty state title and text,
  "Create Setlist", song count, "Perform", "Edit Songs", "New Setlist".
- **`setlist_detail_screen.dart`** (~20): "Setlist", load error, "Setlist not
  found.", three tooltips, "Perform Setlist", song count, "Add Songs", empty
  state, "Add Songs Now", the song line "Key: {key} • {bpm} BPM", "Remove from
  setlist", delete dialog, "Deleted setlist …", "No songs in setlist to share.",
  AirQR title "Setlist: {name}".
- **`setlist_editor_dialog.dart`** (9): titles, field labels and hints, the
  "Please enter a setlist name" check, Cancel, Save / Create.
- **`setlist_song_picker_sheet.dart`** (5): title, "Done ({count})", search
  hint, load error, "No songs found".

### Tests

The app's `MaterialApp.router` already has the localization delegates. Tests
that build a bare `MaterialApp` do not, so `AppLocalizations.of` would fail
there.

- New helper `test/helpers/localized_app.dart`: `localizedApp(Widget home)`
  returns a `MaterialApp` with `AppLocalizations.localizationsDelegates` and
  `supportedLocales`.
- Use it in `test/screens/song_list_screen_test.dart` and
  `test/widgets/song_card_test.dart`. Their English text checks stay the same,
  except where the wording fixes above change a string.
- New `test/widgets/setlist_editor_dialog_test.dart`: titles, the empty-name
  check, and Create vs Save.
- New unit checks for the plural keys (1 song / 2 songs, 1 selected /
  2 selected) by building `AppLocalizationsEn` directly.

## Files to change

- `lib/l10n/app_en.arb` (+ regenerated `lib/l10n/app_localizations.dart`,
  `lib/l10n/app_localizations_en.dart`)
- `lib/screens/home_shell.dart`
- `lib/screens/song_list_screen.dart`
- `lib/screens/setlist_list_screen.dart`
- `lib/screens/setlist_detail_screen.dart`
- `lib/widgets/song_card.dart`
- `lib/widgets/song_search_field.dart`
- `lib/widgets/song_filter_row.dart`
- `lib/widgets/songbook_error.dart`
- `lib/widgets/setlist_editor_dialog.dart`
- `lib/widgets/setlist_song_picker_sheet.dart`
- `test/helpers/localized_app.dart` (new)
- `test/screens/song_list_screen_test.dart`
- `test/widgets/song_card_test.dart`
- `test/widgets/setlist_editor_dialog_test.dart` (new)
- `test/l10n/app_localizations_plural_test.dart` (new)

No files in the `docs/guidelines/` submodule are touched. No database, Android
or iOS change.

## Checks after the change

- `flutter gen-l10n`, `dart format .`, `flutter analyze` (zero issues),
  `flutter test` (all pass).
- A search of the 10 files finds no user-visible string literal left, except
  the allowed ones listed above.

## Change log

`change_log/<timestamp>_l10n-batch1-songbook-setlists.md` after the work.
