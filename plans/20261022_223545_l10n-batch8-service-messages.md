# Plan: Localization batch 8 — service, repository and provider messages

**Status:** completed

## The issue

After batches 1–7 every screen and widget takes its words from
`lib/l10n/app_en.arb`. But some English sentences are still **built below the
UI** and then shown on screen as-is:

| Where | Messages | How they reach the screen |
|-------|----------|---------------------------|
| `song_repository.dart` (7), `setlist_repository.dart` (5) | "Could not save the song.", "Could not delete setlist.", … | `StorageException.message`, shown with `Text(e.message)` in 5 screens (13 places) |
| `pitch_drone_provider.dart` (3) | "Could not play the chord cue.", "Could not play the pitch cue.", "Could not start the drone." | `PitchDroneSettings.lastError`, shown in a SnackBar |
| `melody_parser_service.dart` (2) | "Could not read "X" in "Y".", "Nothing to play in "Y"." | `MelodyLine.problems`, shown under a melody row and in the keypad |
| `carnatic_notation_import_service.dart` (8) | "Could not work out how many beats…", "No notation found to read.", "N of M cycles land on…", "Both readings… score the same…", "Cycle N: …", "nothing readable", "reads as N aksharakalas…", "could not read "c" in "t"" | `CarnaticImportResult.problems`, shown in the Carnatic paste sheet |

That is 30 messages. They break the rule "services must not know UI strings"
(`CLAUDE.md`, architecture rules) and would stay English in any other
language.

Not changed, because they are never shown to the user (they are logs or
debug text, which `CLAUDE.md` allows):

- `HtmlPdfException` messages — the screens catch it and show their own
  translated text; the message only goes to the debug log.
- `AirQrService`'s `errorMessage` ("Checksum verification failed…") — the
  receiver shows its own translated "Transfer failed" text; the field is only
  diagnostic.
- `AppException.debugDetails` — debug log only.

## The fix

The lower layers say **what** went wrong; the UI says it in words.

### 1. Storage errors

- `lib/core/errors/app_exception.dart`: new enum `StorageFailure` (12 values:
  `loadSongs`, `openSong`, `findSongByTitle`, `saveSong`, `updateSong`,
  `saveScrollSpeed`, `deleteSong`, `createSetlist`, `updateSetlist`,
  `updateSetlistSongs`, `addSongToSetlist`, `deleteSetlist`).
  `StorageException` gets a `kind` field. The English `message` stays for
  logs and `debugDetails`.
- The two repositories pass the kind when they throw.
- `lib/l10n/l10n_labels.dart`: new `AppException.text(l10n)` extension. A
  `StorageException` gets its translated sentence; any other `AppException`
  (for example the `ImportException`s the import screen throws, which already
  carry translated text) shows its `message` as before.
- The 13 `Text(e.message)` / `_showError(context, e.message)` calls in
  `song_list_screen.dart`, `setlist_list_screen.dart`,
  `setlist_detail_screen.dart`, `song_editor_screen.dart` and
  `import_export_screen.dart` use `e.text(l10n)`.

### 2. Drone errors

- `lib/models/pitch_drone_settings.dart`: `lastError` changes from
  `String?` to a new enum `DroneError?` (`chordCue`, `pitchCue`,
  `startDrone`).
- `pitch_drone_provider.dart` sets the enum.
- `pitch_drone_controls.dart` and `pitch_drone_settings_screen.dart` turn it
  into text with `DroneError.text(l10n)`; the existing "Could not play the
  sound." fallback stays.

### 3. Melody line problems

- `lib/models/melody_line.dart`: new `MelodyProblem` class (kind + the token
  and piece it is about). `MelodyLine.problems` becomes
  `List<MelodyProblem>`. `hasProblems` is unchanged.
- `melody_parser_service.dart` adds `MelodyProblem`s instead of strings.
- `melody_line_row.dart` and `melody_keypad_sheet.dart` show
  `problem.text(l10n)`.

### 4. Carnatic import problems

- `lib/models/carnatic_import_result.dart`: new `sealed class
  CarnaticProblem` with one small subclass per case (unknown tala, no
  notation, cycles off the tala, readings tie, nothing readable, wrong length,
  unreadable character). Problems inside one cycle carry the cycle number, so
  the "Cycle N: …" prefix is added by the text, not glued on in the service.
  `CarnaticImportResult.problems` becomes `List<CarnaticProblem>`;
  `failure()` takes a `CarnaticProblem`.
- `carnatic_notation_import_service.dart` builds those objects.
- `carnatic_notation_sheet.dart` shows `problem.text(l10n)`.

### Words

About 31 new ARB keys (12 storage, 3 drone, 2 melody, 8 Carnatic, plus the
"Cycle {n}: {problem}" wrapper), each with an `@key` description. **The
English the user sees stays exactly the same.**

## Tests

- `test/providers/pitch_drone_provider_test.dart`: expect `DroneError`
  values instead of English strings.
- `test/services/carnatic_notation_import_service_test.dart`: the 3 checks
  that look inside the English (`'score the same'`, `'aksharakalas'`,
  `'snap'`) check the problem types instead.
- `test/services/melody_parser_service_test.dart`: `problems` checks that
  only test empty / not empty keep working; add one test for the problem kind
  and token.
- Repository tests: add checks that a failed write throws a
  `StorageException` with the right `kind`.
- `test/l10n/l10n_labels_test.dart`: every `StorageFailure`, `DroneError`,
  melody and Carnatic problem has non-empty text, and a few sample sentences
  read exactly as before (e.g. "Could not save the song.", "Cycle 2: could
  not read "q" in "qa"").
- Widget tests that show a melody problem (`melody_line_row_test`,
  `melody_keypad_sheet_test`, `carnatic_notation_sheet_test`) keep their
  English text checks.

## Files to change

- `lib/core/errors/app_exception.dart`
- `lib/repositories/song_repository.dart`, `lib/repositories/setlist_repository.dart`
- `lib/models/pitch_drone_settings.dart`, `lib/providers/pitch_drone_provider.dart`
- `lib/models/melody_line.dart`, `lib/services/melody_parser_service.dart`
- `lib/models/carnatic_import_result.dart`,
  `lib/services/carnatic_notation_import_service.dart`
- `lib/l10n/l10n_labels.dart`, `lib/l10n/app_en.arb` (+ regenerated files)
- `lib/screens/song_list_screen.dart`, `setlist_list_screen.dart`,
  `setlist_detail_screen.dart`, `song_editor_screen.dart`,
  `import_export_screen.dart`, `pitch_drone_settings_screen.dart`
- `lib/widgets/pitch_drone_controls.dart`, `melody_line_row.dart`,
  `melody_keypad_sheet.dart`, `carnatic_notation_sheet.dart`
- Tests listed above

No files in the `docs/guidelines/` submodule are touched. No database schema,
Android or iOS change. Saved songs are not affected: problems are worked out
fresh each time a line is read; nothing about them is stored.

## Checks after the change

- `flutter gen-l10n`, `dart format .`, `flutter analyze` (zero issues),
  `flutter test` (all pass, including the batch 7 guard).
- A search of `lib/services/`, `lib/repositories/` and `lib/providers/` finds
  no English sentence that reaches the screen (only log/debug text, as
  listed above).

## Change log

`change_log/<timestamp>_l10n-batch8-service-messages.md` after the work.
