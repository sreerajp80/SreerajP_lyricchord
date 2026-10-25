# Change log: Localization batch 1 — songbook and setlists

Implements
[plans/20261022_143227_l10n-batch1-songbook-setlists.md](../plans/20261022_143227_l10n-batch1-songbook-setlists.md).

## What changed

All user-visible text in the songbook and setlist screens now comes from
`lib/l10n/app_en.arb` through `AppLocalizations`.

- **`lib/l10n/app_en.arb`:** 90 new keys, each with an `@key` description.
  Reused the existing `appTitle`, `songs`, `setlists`, `settings`, `cancel`,
  `save` and `delete`. New shared keys: `create`, `share`, `tryAgain`. Counts
  use ICU plural messages. `flutter gen-l10n` re-run.
- **Screens:** `home_shell.dart`, `song_list_screen.dart`,
  `setlist_list_screen.dart`, `setlist_detail_screen.dart`.
- **Widgets:** `song_card.dart`, `song_search_field.dart`,
  `song_filter_row.dart`, `songbook_error.dart`, `empty_songbook.dart`,
  `setlist_editor_dialog.dart`, `setlist_song_picker_sheet.dart`.

## Text the user sees

The English is the same as before, except for the planned plural fixes:

- "Exported 3 song(s)." → "Exported 3 songs." / "Exported 1 song."
- "Deleted 3 song(s)." → "Deleted 3 songs." / "Deleted 1 song."
- "Share 3 selected song(s)" → "Share 3 selected songs" / "Share 1 selected song"
- "Delete 1 songs?" → "Delete 1 song?"
- The AirQR title for one selected song is now "1 Selected Song".

Left as code (allowed by `CLAUDE.md`): route paths, map keys, format values
(`chordpro`, `pdf`), default file names, the row number in a setlist, and the
raw technical error under "Could not open your songbook".

## Tests

- New helper `test/helpers/localized_app.dart` (a `MaterialApp` with the
  localization delegates).
- `test/screens/song_list_screen_test.dart` and
  `test/widgets/song_card_test.dart` use it. Their text checks did not change.
- New `test/widgets/setlist_editor_dialog_test.dart` (4 tests): new vs edit
  titles and buttons, empty-name message, trimmed result.
- New `test/l10n/app_localizations_plural_test.dart` (3 tests): plural and
  placeholder messages.

## Change from the plan

- `lib/widgets/empty_songbook.dart` was added. It is part of the songbook and
  had 6 hard-coded texts that the first count missed.

## Checks

- `dart format`, `flutter analyze`: no issues.
- `flutter test`: 953 tests, all pass.
- A search of the 11 files finds only the allowed literals listed above.
- No Android, iOS or database change, so no Gradle build was needed.
