# Change log: Localization batch 8 — service, repository and provider messages

Implements
[plans/20261022_223545_l10n-batch8-service-messages.md](../plans/20261022_223545_l10n-batch8-service-messages.md).

## What changed

The 30 English messages that were built below the UI and shown on screen now
come from `lib/l10n/app_en.arb`. The lower layers report **what** went wrong;
the screen picks the words. The English the user sees is the same as before.

### Storage errors

- `lib/core/errors/app_exception.dart`: new enum `StorageFailure` (12 values).
  `StorageException` has a required `kind`. The English `message` stays for
  logs and `debugDetails` only.
- `song_repository.dart` (7) and `setlist_repository.dart` (5) pass the kind.
- New `AppException.text(l10n)` in `lib/l10n/l10n_labels.dart`: a
  `StorageException` shows its translated sentence; other `AppException`s
  (only the import screen's, already translated) show their message.
- The 13 places that showed `e.message` now show `e.text(l10n)`:
  `song_list_screen.dart` (4), `setlist_detail_screen.dart` (5),
  `setlist_list_screen.dart` (1), `song_editor_screen.dart` (2),
  `import_export_screen.dart` (1).

### Drone errors

- `lib/models/pitch_drone_settings.dart`: new enum `DroneError` (`chordCue`,
  `pitchCue`, `startDrone`); `lastError` is now `DroneError?`.
- `pitch_drone_provider.dart` sets the enum; `pitch_drone_controls.dart` and
  `pitch_drone_settings_screen.dart` show `DroneError.text(l10n)`.

### Melody line problems

- `lib/models/melody_line.dart`: new `MelodyProblem` (kind, token, piece);
  `MelodyLine.problems` is now `List<MelodyProblem>`.
- `melody_parser_service.dart` adds `MelodyProblem`s instead of sentences.
- `melody_line_row.dart` and `melody_keypad_sheet.dart` show
  `problem.text(l10n)`.

### Carnatic import problems

- `lib/models/carnatic_import_result.dart`: new `sealed class
  CarnaticProblem` with 7 subclasses (unknown tala, no notation, cycles off
  the tala, readings tie, nothing readable, wrong length, unreadable
  character). Problems found inside one avarta carry its number; "Cycle N: …"
  is added when the text is shown.
- `carnatic_notation_import_service.dart` builds these objects;
  `carnatic_notation_sheet.dart` shows `problem.text(l10n)`.

### Words

25 new ARB keys (942 in all): 12 storage, 3 drone, 2 melody, 8 Carnatic
(including the "Cycle {cycle}: {problem}" wrapper). The text helpers live in
`lib/l10n/l10n_labels.dart` next to the earlier label helpers.

## Left as English on purpose (never shown to the user)

- `HtmlPdfException` messages and `AppException.debugDetails` — debug log.
- `AirQrService`'s `errorMessage` — diagnostic; the receiver shows its own
  translated "Transfer failed" text.
- `StageSecurityService`: the default unlock reason (the screen always passes
  the translated one) and `StageAuthResult.message` (the screen uses the
  outcome, not the message).
- `'Untitled Song'` and the `(Copy)` suffix are saved into the song itself as
  its title, so they are song data, not screen text.

## Tests

- `test/providers/pitch_drone_provider_test.dart`: expects `DroneError`
  values.
- `test/services/carnatic_notation_import_service_test.dart`: 4 checks now
  look at problem types (readings tie, unknown tala with its name, wrong
  length with cycle and wanted length, and "no problems" for the snapped-note
  case) instead of English words.
- `test/services/melody_parser_service_test.dart`: 1 new test for the
  problem kind and token.
- `test/repositories/song_repository_test.dart` and
  `setlist_repository_test.dart`: 1 new test each. They drop a table to make a
  real database failure and check the `StorageException.kind`
  (`loadSongs`, `deleteSong`, `deleteSetlist`). (Closing an in-memory test
  database does not work for this: it simply reopens.)
- `test/l10n/l10n_labels_test.dart`: 6 new tests — every storage failure,
  drone error, melody and Carnatic problem reads exactly as before, including
  "Cycle 2: could not read "q" in "qa"".
- Widget tests that show melody and Carnatic problems keep their English
  checks and pass.

## Checks

- `dart format`, `flutter analyze`: no issues.
- `flutter test`: 985 tests, all pass, including the batch 7 guard.
- A sweep of `lib/services/`, `lib/repositories/`, `lib/providers/`,
  `lib/models/` and `lib/core/` finds only the log, debug and song-data text
  listed above.
- No database schema, Android or iOS change, so no Gradle build was needed.
  Nothing stored changes: problems are worked out fresh each time a line is
  read.

## Where localization stands

All 8 batches are done. Every word the user sees now comes from
`lib/l10n/app_en.arb`, and the guard test stops new hard-coded UI text.
